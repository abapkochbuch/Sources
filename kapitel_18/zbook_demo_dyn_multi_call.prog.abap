REPORT zbook_demo_dyn_multi_call.

DATA gt_attributes TYPE STANDARD TABLE OF zbook_attr.

PARAMETERS p_tiknr TYPE zbook_ticket_nr.
PARAMETERS p_show AS CHECKBOX.

DATA gv_type01 TYPE c LENGTH 80.
DATA gv_type02 TYPE c LENGTH 80.
DATA gv_type03 TYPE c LENGTH 80.
DATA gv_type04 TYPE c LENGTH 80.
DATA gv_type05 TYPE c LENGTH 80.

DATA gv_data01 TYPE c LENGTH 20.
DATA gv_data02 TYPE c LENGTH 20.
DATA gv_data03 TYPE c LENGTH 20.
DATA gv_data04 TYPE c LENGTH 20.
DATA gv_data05 TYPE c LENGTH 20.


START-OF-SELECTION.

  PERFORM assign_attributes.

  CHECK gt_attributes IS NOT INITIAL.

  SUBMIT zbook_demo_dyn_multi
          WITH p_show   = p_show
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
           VIA SELECTION-SCREEN
           AND RETURN.

  PERFORM import_data.


*&---------------------------------------------------------------------*
*&      Form  assign_attributes
*&---------------------------------------------------------------------*
FORM assign_attributes.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_type              TYPE c LENGTH 80.

  DATA lv_area       TYPE zbook_area.
  DATA lv_clas       TYPE zbook_clas.

  FIELD-SYMBOLS <type>      TYPE any.
  FIELD-SYMBOLS <attribute> TYPE zbook_attr.

  SELECT SINGLE area clas
    FROM zbook_ticket
    INTO (lv_area, lv_clas)
   WHERE tiknr = p_tiknr.

  SELECT * FROM zbook_attr
    INTO TABLE gt_attributes
   WHERE ( area = lv_area AND clas = lv_clas )
      OR ( area = lv_area AND clas = space ).

  CHECK sy-subrc = 0.

  SORT gt_attributes BY clas sort.

  LOOP AT gt_attributes ASSIGNING <attribute>.
    lv_count = sy-tabix.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_type.
    ASSIGN (lv_type) TO <type>.
    IF sy-subrc = 0.
      CONCATENATE <attribute>-tablename <attribute>-fieldname INTO <type> SEPARATED BY '-'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "assign_attributes

*&---------------------------------------------------------------------*
*&      Form  import_data
*&---------------------------------------------------------------------*
FORM import_data.
  TYPES: BEGIN OF ty_param,
           id   TYPE c LENGTH 80,
           name TYPE c LENGTH 80,
         END OF ty_param.
  DATA lt_params         TYPE STANDARD TABLE OF ty_param.
  FIELD-SYMBOLS <param>  TYPE ty_param.
  FIELD-SYMBOLS <value>  TYPE any.
  FIELD-SYMBOLS <type>   TYPE any.

  DATA lv_count          TYPE n LENGTH 2.
  DATA lv_pname          TYPE c LENGTH 80.

  DATA lt_attr_values    TYPE STANDARD TABLE OF zbook_attr_value.
  FIELD-SYMBOLS <attrvalue> TYPE zbook_attr_value.


  DO 5 TIMES.
    lv_count = sy-index.
    APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
    <param>-id = lv_count.
    CONCATENATE 'GV_DATA' lv_count INTO <param>-name.
  ENDDO.

  IMPORT (lt_params) FROM MEMORY ID zcl_book_dyn_multi=>gc_memory_id.
  LOOP AT lt_params ASSIGNING <param>.
    lv_count = sy-tabix.
    ASSIGN (<param>-name) TO <value>.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_pname.
    ASSIGN (lv_pname) TO <type>.
    CHECK <type> IS ASSIGNED AND <type> IS NOT INITIAL.
    WRITE: / <param>-name, <value> COLOR COL_TOTAL.

    APPEND INITIAL LINE TO lt_attr_values ASSIGNING <attrvalue>.
    <attrvalue>-tiknr     = p_tiknr.
    SPLIT <type> AT '-' INTO <attrvalue>-tablename <attrvalue>-fieldname.
    <attrvalue>-value = <value>.
  ENDLOOP.

* BREAK-POINT.

ENDFORM.                    "import_data
