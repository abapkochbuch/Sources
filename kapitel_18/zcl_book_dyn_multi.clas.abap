class ZCL_BOOK_DYN_MULTI definition
  public
  final
  create public .

public section.

  class-data GC_MEMORY_ID type CHAR30 read-only value 'Kochbuch'. "#EC NOTEXT .  .  . " .

  methods CONSTRUCTOR
    importing
      !TIKNR type ZBOOK_TICKET_NR
      !AREA type ZBOOK_AREA
      !CLAS type ZBOOK_CLAS .
  methods EDIT
    importing
      !SHOW type C .
  methods SAVE
    importing
      !TIKNR type ZBOOK_TICKET_NR .
protected section.

  data:
    gt_attributes TYPE STANDARD TABLE OF zbook_attr .
  data:
    gt_attr_value TYPE STANDARD TABLE OF zbook_attr_value .
  data GV_TYPE01 type CHAR80 .
  data GV_TYPE02 type CHAR80 .
  data GV_TYPE03 type CHAR80 .
  data GV_TYPE04 type CHAR80 .
  data GV_TYPE05 type CHAR80 .
  data GV_DATA01 type CHAR30 .
  data GV_DATA02 type CHAR30 .
  data GV_DATA03 type CHAR30 .
  data GV_DATA04 type CHAR30 .
  data GV_DATA05 type CHAR30 .

  methods READ_VALUES
    importing
      !TIKNR type ZBOOK_TICKET_NR .
  methods IMPORT_DATA .
private section.
ENDCLASS.



CLASS ZCL_BOOK_DYN_MULTI IMPLEMENTATION.


METHOD constructor.

  SELECT * FROM zbook_attr
    INTO TABLE gt_attributes
   WHERE ( area = area AND clas = clas )
      OR ( area = area AND clas = space ).

  SORT gt_attributes BY clas sort.

  IF tiknr IS NOT INITIAL.
    read_values( tiknr ).
  ENDIF.

ENDMETHOD.


METHOD edit.

  DATA lv_count              TYPE n LENGTH 2.
  DATA lv_type               TYPE c LENGTH 80.
  DATA lv_tablename          TYPE char80.
  DATA lv_fieldname          TYPE char80.
  FIELD-SYMBOLS <type>       TYPE any.
  FIELD-SYMBOLS <attribute>  TYPE zbook_attr.

  CHECK gt_attributes IS NOT INITIAL.

  IF gt_attr_value IS INITIAL.
    LOOP AT gt_attributes ASSIGNING <attribute>.
      lv_count = sy-tabix.
      CONCATENATE 'GV_TYPE' lv_count INTO lv_type.
      ASSIGN (lv_type) TO <type>.
      IF sy-subrc = 0.
        CONCATENATE <attribute>-tablename
                    <attribute>-fieldname
               INTO <type> SEPARATED BY '-'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SUBMIT zbook_demo_dyn_multi
          WITH p_show   = show
          WITH p_data01 = gv_data01
          WITH p_data02 = gv_data02
          WITH p_data03 = gv_data03
          WITH p_data04 = gv_data04
          WITH p_data05 = gv_data05
          WITH p_type01 = gv_type01
          WITH p_type02 = gv_type02
          WITH p_type03 = gv_type03
          WITH p_type04 = gv_type04
          WITH p_type05 = gv_type05
           AND RETURN.

  import_data( ).

ENDMETHOD.


METHOD import_data.

  TYPES: BEGIN OF ty_param,
           id   TYPE c LENGTH 80,
           name TYPE c LENGTH 80,
         END OF ty_param.
  DATA lv_tablename      TYPE char80.
  DATA lv_fieldname      TYPE char80.
  DATA lt_params         TYPE STANDARD TABLE OF ty_param.
  FIELD-SYMBOLS <param>  TYPE ty_param.
  FIELD-SYMBOLS <data>   TYPE any.
  FIELD-SYMBOLS <type>   TYPE any.

  DATA lv_count          TYPE n LENGTH 2.
  DATA lv_pname          TYPE c LENGTH 80.

  FIELD-SYMBOLS <attr_value> TYPE zbook_attr_value.


  DO 5 TIMES.
    lv_count = sy-index.
    APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
    <param>-id = lv_count.
    CONCATENATE 'GV_DATA' lv_count INTO <param>-name.
  ENDDO.


  IMPORT (lt_params) FROM MEMORY ID gc_memory_id.
  check sy-subrc = 0.
  LOOP AT lt_params ASSIGNING <param>.
    lv_count = sy-tabix.
    ASSIGN (<param>-name) TO <data>.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_pname.
    ASSIGN (lv_pname) TO <type>.
    CHECK <type> IS ASSIGNED AND <type> IS NOT INITIAL.
    SPLIT <type> AT '-' INTO lv_tablename lv_fieldname.

    READ TABLE gt_attr_value ASSIGNING <attr_value>
          WITH KEY tablename = lv_tablename
                   fieldname = lv_fieldname.
    IF sy-subrc > 0.
      APPEND INITIAL LINE TO gt_attr_value ASSIGNING <attr_value>.
      <attr_value>-tiknr = space.
      <attr_value>-tablename = lv_tablename.
      <attr_value>-fieldname = lv_fieldname.
    ENDIF.
    <attr_value>-value = <data>.
  ENDLOOP.

ENDMETHOD.


METHOD read_values.

  FIELD-SYMBOLS <attr_value> TYPE zbook_attr_value.
  FIELD-SYMBOLS <attr>       TYPE zbook_attr.
  FIELD-SYMBOLS <type>       TYPE any.
  FIELD-SYMBOLS <data>       TYPE any.
  DATA lv_count              TYPE n LENGTH 2.
  DATA lv_pname              TYPE string.

  SELECT * FROM zbook_attr_value
    INTO TABLE gt_attr_value
   WHERE tiknr = tiknr.

  IF sy-subrc = 0.
    LOOP AT gt_attributes ASSIGNING <attr>.
      READ TABLE gt_attr_value ASSIGNING <attr_value>
            WITH KEY tablename = <attr>-tablename
                     fieldname = <attr>-fieldname.
      CHECK sy-subrc = 0.
      lv_count = sy-tabix.
      CONCATENATE 'GV_TYPE' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <type>.
      CONCATENATE <attr_value>-tablename '-' <attr_value>-fieldname INTO <type>.
      CONCATENATE 'GV_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <data>.
      <data> = <attr_value>-value.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD save.

  FIELD-SYMBOLS <attrvalue> TYPE zbook_attr_value.
  DATA ls_attrvalue TYPE zbook_attr_value.

  ls_attrvalue-tiknr = tiknr.
  MODIFY gt_attr_value FROM ls_attrvalue TRANSPORTING tiknr
   WHERE tiknr = space.

  MODIFY zbook_attr_value FROM TABLE gt_attr_value.

ENDMETHOD.
ENDCLASS.
