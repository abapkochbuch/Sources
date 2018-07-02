class ZCL_BOOK_ATTR definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TIKNR type ZBOOK_TICKET_NR
      !AREA type ZBOOK_AREA optional
      !CLAS type ZBOOK_CLAS optional .
  methods SAVE
    importing
      !TIKNR type ZBOOK_TICKET_NR optional .
  methods SHOW
    importing
      !COUNT type I .
  class-methods DELETE
    importing
      !TIKNR type ZBOOK_TICKET_NR .
  methods EDIT
    importing
      !COUNT type I .
protected section.

  data GV_TIKNR type ZBOOK_TICKET_NR .
  class-data:
    GT_ATTR type STANDARD TABLE OF zbook_attr .

  methods CALL_DYNAMIC_SCREEN
    importing
      !COUNT type I
      !SHOW type CHAR01 .
  methods SET_DYNAMIC_TYPE
    importing
      !TABLE type TABNAME
      !FIELD type FIELDNAME .
private section.

  data:
    GT_VALUES type STANDARD TABLE OF zbook_attr_value .
  data GV_TYPE type CHAR50 .
  data GV_DATA type TEXT80 .
  data GV_AREA type ZBOOK_AREA .
  data GV_CLAS type ZBOOK_CLAS .

  methods GET_DATA
    importing
      !COUNT type I
    exceptions
      ERROR .
  methods READ_ATTRIBUTES
    importing
      !AREA type ZBOOK_AREA
      !CLAS type ZBOOK_CLAS .
  methods SET_DATA
    importing
      !COUNT type I .
  methods READ_DATA .
ENDCLASS.



CLASS ZCL_BOOK_ATTR IMPLEMENTATION.


METHOD call_dynamic_screen.

  CALL METHOD get_data
    EXPORTING
      count = count
    EXCEPTIONS
      error = 1.
  CHECK sy-subrc = 0.

  DELETE FROM MEMORY ID 'Kochbuch'.

  SUBMIT zbook_demo_dyn_param_oo
    WITH p_type = gv_type
    WITH p_data = gv_data
    WITH p_show = show
     VIA SELECTION-SCREEN AND RETURN.

  IF show = space.
    IMPORT data TO gv_data FROM MEMORY ID 'Kochbuch'.
    IF sy-subrc = 0.
      set_data( count ).
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD constructor.

  gv_tiknr = tiknr.
  gv_area  = area.
  gv_clas  = clas.

  IF gv_tiknr IS NOT INITIAL AND
     gv_area IS INITIAL AND
     gv_clas IS INITIAL.
    SELECT SINGLE area clas FROM zbook_ticket
      INTO (gv_area, gv_clas)
     WHERE tiknr = tiknr.
  ENDIF.

  read_attributes( area = gv_Area clas = gv_clas ).

  read_data( ).

ENDMETHOD.


METHOD delete.

  DELETE FROM zbook_attr_value WHERE tiknr = tiknr.

ENDMETHOD.


METHOD edit.

  call_dynamic_screen( count = count
                       show  = space ).

ENDMETHOD.


METHOD get_data.

  DATA ls_attr   TYPE zbook_attr.
  DATA ls_value  TYPE zbook_attr_value.

  READ TABLE gt_attr INTO ls_attr INDEX count.
  IF sy-subrc = 0.
    set_dynamic_type( table = ls_attr-tablename
                      field = ls_attr-fieldname ).

    READ TABLE gt_values INTO ls_value
          WITH KEY tablename = ls_attr-tablename
                   fieldname = ls_attr-fieldname.
    IF sy-subrc = 0.
      gv_data = ls_value-value.
    ELSE.
      gv_data = space.
    ENDIF.
  ELSE.
    RAISE error.
  ENDIF.

ENDMETHOD.


METHOD READ_ATTRIBUTES.

  CLEAR gt_attr.

  SELECT * FROM zbook_attr INTO TABLE gt_attr
   WHERE ( area = area AND clas = clas )
      or ( area = area and clas = space ).

  SORT gt_attr BY sort.

ENDMETHOD.


METHOD read_data.

  DATA ls_value TYPE zbook_attr_value.

  CHECK gv_tiknr IS NOT INITIAL.
  SELECT * FROM zbook_attr_value
    INTO TABLE gt_values
   WHERE tiknr = gv_tiknr.

ENDMETHOD.


METHOD save.

  DATA ls_attr_value TYPE zbook_attr_value.
  FIELD-SYMBOLS <attr> TYPE zbook_attr.

  IF tiknr IS NOT INITIAL.
    gv_tiknr = tiknr.
  ENDIF.

  CHECK gv_tiknr IS NOT INITIAL.

  delete( gv_tiknr ).

  INSERT zbook_attr_value FROM TABLE gt_values.
  COMMIT WORK.


ENDMETHOD.


METHOD set_data.

  FIELD-SYMBOLS <value> TYPE zbook_attr_value.
  DATA ls_attr TYPE zbook_attr.

  READ TABLE gt_attr INTO ls_attr INDEX count.
  IF sy-subrc = 0.
    READ TABLE gt_values ASSIGNING <value>
          WITH KEY tablename = ls_attr-tablename
                   fieldname = ls_attr-fieldname.
    IF sy-subrc > 0.
      APPEND INITIAL LINE TO gt_values ASSIGNING <value>.
      <value>-tiknr = gv_tiknr.
      <value>-tablename = ls_attr-tablename.
      <value>-fieldname = ls_attr-fieldname.
    ENDIF.
    <value>-value = gv_data.

  ENDIF.

ENDMETHOD.


METHOD set_dynamic_type.

  CONCATENATE table '-' field INTO gv_type.

ENDMETHOD.


METHOD show.

  call_dynamic_screen( count = count show = 'X' ).

ENDMETHOD.
ENDCLASS.
