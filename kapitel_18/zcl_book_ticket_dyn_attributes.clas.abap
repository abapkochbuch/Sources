class ZCL_BOOK_TICKET_DYN_ATTRIBUTES definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_TICKET_DYN_ATTRIBUTES
*"* do not include other source files here!!!
public section.

  interfaces ZIF_BOOK_TICKET_DYN_ATTRIBUTES .

  aliases GV_TIKNR
    for ZIF_BOOK_TICKET_DYN_ATTRIBUTES~GV_TIKNR .
  aliases READ_TICKET_ATTRIBUTES
    for ZIF_BOOK_TICKET_DYN_ATTRIBUTES~READ_TICKET_ATTRIBUTES .
  aliases SAVE_TICKET_ATTRIBUTES
    for ZIF_BOOK_TICKET_DYN_ATTRIBUTES~SAVE_TICKET_ATTRIBUTES .
  aliases SET_TICKET_NUMBER
    for ZIF_BOOK_TICKET_DYN_ATTRIBUTES~SET_TICKET_NUMBER .

  constants GC_TEMPLATE_DYNSCREEN_REPID type SYREPID value 'SAPLZBOOK_DYN_SELSCR'. "#EC NOTEXT
  constants GC_TEMPLATE_DYNSCREEN_DYNNR type SYDYNNR value '9000'. "#EC NOTEXT
  data GT_TICKET_ATTRIBUTES type ZBOOK_TT_TICKETATTR read-only .
  data GV_AREA type ZBOOK_AREA read-only .
  data GV_CLASS type ZBOOK_CLAS read-only .

  class-methods DYN_SCREEN_INPUT_DATA_PBO
    importing
      !IV_DYNNR type SYDYNNR optional
      !IV_AREA type ZBOOK_TICKET-AREA
      !IV_CLASS type ZBOOK_TICKET-CLAS
    returning
      value(ES_DYN_FIELDS) type ZBOOK_DYN_SELSCR_FIELDS .
  class-methods DYN_SCREEN_INPUT_DATA_PBO_TICK
    importing
      !IV_DYNNR type SYDYNNR optional
      !IV_TICKET_NR type ZBOOK_TICKET_NR
    returning
      value(ES_DYN_FIELDS) type ZBOOK_DYN_SELSCR_FIELDS .
  class-methods DYN_SCREEN_SELSCREEN_PARAMS
    importing
      !IV_DYNNR type SYDYNNR optional
      !IV_AREA type ZBOOK_TICKET-AREA
      !IV_CLASS type ZBOOK_TICKET-CLAS
    returning
      value(ES_DYN_FIELDS) type ZBOOK_DYN_SELSCR_FIELDS .
  class-methods DYN_SCREEN_SELSCREEN_SELOPTS
    importing
      !IV_DYNNR type SYDYNNR optional
      !IV_AREA type ZBOOK_TICKET-AREA
      !IV_CLASS type ZBOOK_TICKET-CLAS
    returning
      value(ES_DYN_FIELDS) type ZBOOK_DYN_SELSCR_FIELDS .
  methods CONSTRUCTOR
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR optional .
  methods SET_AREA_CLASS
    importing
      !IV_AREA type ZBOOK_AREA
      !IV_CLASS type ZBOOK_CLAS .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_DYN_SELSCR
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_DYN_ATTRIBUTES
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_TICKET_DYN_ATTRIBUTES IMPLEMENTATION.


METHOD constructor.
  DATA: ls_book_ticket  TYPE zbook_ticket,
        ls_dyn_fields   TYPE zbook_dyn_selscr_fields.


  me->gv_tiknr = iv_tiknr.
  SELECT SINGLE *
    INTO ls_book_ticket
    FROM zbook_ticket
    WHERE tiknr = me->gv_tiknr.

  CALL FUNCTION 'Z_BOOK_DYN_SELSCR_INIT_FIELDS'.

* Prepare dynamic selectionscreen for this ticket
  me->set_area_class( iv_area  = ls_book_ticket-area
                      iv_class = ls_book_ticket-clas ).

  me->read_ticket_attributes( ).

ENDMETHOD.


METHOD DYN_SCREEN_INPUT_DATA_PBO.
*--------------------------------------------------------------------*
* Customizing lesen - welche Merkmale sollten zur übergebenen Kategorie gelesen werden
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Dateneingabe --> die Parameter anzeigen lassen
*--------------------------------------------------------------------*
  DATA: lt_zbook_class_attr             TYPE STANDARD TABLE OF zbook_class_attr WITH NON-UNIQUE DEFAULT KEY,
        lv_index                        TYPE syindex.

  FIELD-SYMBOLS: <lv_dynfield>          TYPE zbook_dyn_selscr_fields-p_dyn01,
                 <ls_zbook_class_attr>  LIKE LINE OF lt_zbook_class_attr.


*--------------------------------------------------------------------*
* Merkmale auslesen und deren DDIC-Bezug
*--------------------------------------------------------------------*
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zbook_class_attr
    FROM zbook_class_attr
    WHERE ( ( area = iv_area AND clas = iv_class )
         or ( area = iv_area and clas = space ) )
      AND attribute_table <> space
      AND attribute_field <> space
    ORDER BY clas
             sort_order
             attribute_table
             attribute_field.

*--------------------------------------------------------------------*
* und Merkmale in dyn selektionsstruktur einfügen
*--------------------------------------------------------------------*
  CLEAR es_dyn_fields.
  LOOP AT lt_zbook_class_attr ASSIGNING <ls_zbook_class_attr>.

    lv_index = 2 * sy-tabix - 1.                                          " Weil P_DYNxx und S_DYNxx immer ein Paar bilden muss ich nur jedes 2. Feld holen
    ASSIGN COMPONENT lv_index OF STRUCTURE es_dyn_fields TO <lv_dynfield>.
    IF sy-subrc <> 0.                                                   " Falls zu viele Merkmale eingegeben wurden hier abbrechen
      MESSAGE 'Achtung - zu viele Merkmale für Merkmalseingabe' TYPE 'A'.
      EXIT.
    ENDIF.

    CONCATENATE <ls_zbook_class_attr>-attribute_table <ls_zbook_class_attr>-attribute_field
        INTO <lv_dynfield> SEPARATED BY '-'.

  ENDLOOP.

  zcl_book_dyn_selscr=>dyn_screen_pbo( iv_dynnr              = iv_dynnr
                                       is_dyn_field_settings = es_dyn_fields ).

ENDMETHOD.


METHOD DYN_SCREEN_INPUT_DATA_PBO_TICK.

  DATA: ls_zbook_ticket TYPE zbook_ticket.

  SELECT SINGLE *
    INTO ls_zbook_ticket
    FROM zbook_ticket
    WHERE tiknr = iv_ticket_nr.

  es_dyn_fields = dyn_screen_input_data_pbo( iv_dynnr = iv_dynnr
                                             iv_area  = ls_zbook_ticket-area
                                             iv_class = ls_zbook_ticket-clas ).
ENDMETHOD.


METHOD DYN_SCREEN_SELSCREEN_PARAMS.
*--------------------------------------------------------------------*
* Customizing lesen - welche Merkmale sollten zur übergebenen Kategorie gelesen werden
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Dateneingabe --> die Parameter anzeigen lassen
*--------------------------------------------------------------------*
  DATA: lt_zbook_class_attr             TYPE STANDARD TABLE OF zbook_class_attr WITH NON-UNIQUE DEFAULT KEY,
        lv_index                        TYPE syindex.

  FIELD-SYMBOLS: <lv_dynfield>          TYPE zbook_dyn_selscr_fields-p_dyn01,
                 <ls_zbook_class_attr>  LIKE LINE OF lt_zbook_class_attr.


*--------------------------------------------------------------------*
* Merkmale auslesen und deren DDIC-Bezug
*--------------------------------------------------------------------*
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zbook_class_attr
    FROM zbook_class_attr
    WHERE ( ( area = iv_area AND clas = iv_class )
         or ( area = iv_area and clas = space ) )
      AND attribute_table <> space
      AND attribute_field <> space
    ORDER BY clas
             sort_order
             attribute_table
             attribute_field.


*--------------------------------------------------------------------*
* und Merkmale in dyn selektionsstruktur einfügen
*--------------------------------------------------------------------*
  CLEAR es_dyn_fields.
  LOOP AT lt_zbook_class_attr ASSIGNING <ls_zbook_class_attr>.

    lv_index = 2 * sy-tabix - 1.                                   "Weil P_DYNxx und S_DYNxx immer ein Paar bilden muss ich nur jedes 2. Feld holen
    ASSIGN COMPONENT lv_index OF STRUCTURE es_dyn_fields TO <lv_dynfield>.
    IF sy-subrc <> 0.                                                   " Falls zu viele Merkmale eingegeben wurden hier abbrechen
      MESSAGE 'Achtung - zu viele Merkmale für Merkmalseingabe' TYPE 'A'.
      EXIT.
    ENDIF.

    CONCATENATE <ls_zbook_class_attr>-attribute_table <ls_zbook_class_attr>-attribute_field
        INTO <lv_dynfield> SEPARATED BY '-'.

  ENDLOOP.

*  zcl_book_dyn_selscr=>dyn_screen_pbo( iv_dynnr              = iv_dynnr
*                                       is_dyn_field_settings = es_dyn_fields ).

ENDMETHOD.


METHOD DYN_SCREEN_SELSCREEN_SELOPTS.
*--------------------------------------------------------------------*
* Customizing lesen - welche Merkmale sollten zur übergebenen Kategorie gelesen werden
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Dateneingabe --> die Parameter anzeigen lassen
*--------------------------------------------------------------------*
  DATA: lt_zbook_class_attr             TYPE STANDARD TABLE OF zbook_class_attr WITH NON-UNIQUE DEFAULT KEY,
        lv_index                        TYPE syindex.

  FIELD-SYMBOLS: <lv_dynfield>          TYPE zbook_dyn_selscr_fields-p_dyn01,
                 <ls_zbook_class_attr>  LIKE LINE OF lt_zbook_class_attr.


*--------------------------------------------------------------------*
* Merkmale auslesen und deren DDIC-Bezug
*--------------------------------------------------------------------*
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zbook_class_attr
    FROM zbook_class_attr
    WHERE ( ( area = iv_area AND clas = iv_class )
         or ( area = iv_area and clas = space ) )
      AND attribute_table <> space
      AND attribute_field <> space
    ORDER BY clas
             sort_order
             attribute_table
             attribute_field.


*--------------------------------------------------------------------*
* und Merkmale in dyn selektionsstruktur einfügen
*--------------------------------------------------------------------*
  CLEAR es_dyn_fields.
  LOOP AT lt_zbook_class_attr ASSIGNING <ls_zbook_class_attr>.

    lv_index = 2 * sy-tabix .                                          " Weil P_DYNxx und S_DYNxx immer ein Paar bilden muss ich nur jedes 2. Feld holen
    ASSIGN COMPONENT lv_index OF STRUCTURE es_dyn_fields TO <lv_dynfield>.
    IF sy-subrc <> 0.                                                   " Falls zu viele Merkmale eingegeben wurden hier abbrechen
      MESSAGE 'Achtung - zu viele Merkmale für Merkmalseingabe' TYPE 'A'.
      EXIT.
    ENDIF.

    CONCATENATE <ls_zbook_class_attr>-attribute_table <ls_zbook_class_attr>-attribute_field
        INTO <lv_dynfield> SEPARATED BY '-'.

  ENDLOOP.

  zcl_book_dyn_selscr=>dyn_screen_pbo( iv_dynnr              = iv_dynnr
                                       is_dyn_field_settings = es_dyn_fields ).

ENDMETHOD.


METHOD set_area_class.

  DATA: ls_dyn_fields   TYPE zbook_dyn_selscr_fields.

  me->gv_area  = iv_area.
  me->gv_class = iv_class.

  ls_dyn_fields = dyn_screen_selscreen_params( iv_area  = gv_area
                                               iv_class = gv_class ).
  CALL FUNCTION 'Z_BOOK_DYN_SELSCR_SET_USED'
    EXPORTING
      is_dyn_fields = ls_dyn_fields.




ENDMETHOD.


METHOD zif_book_ticket_dyn_attributes~read_ticket_attributes.

  DATA:
        ls_dyn_fields       TYPE zbook_dyn_selscr_fields,
        lr_struct_descr     TYPE REF TO cl_abap_structdescr,
        ls_component        LIKE LINE OF lr_struct_descr->components,
        lv_table            TYPE string,
        lv_field            TYPE string,
        ls_ticket_attribute LIKE LINE OF me->gt_ticket_attributes.


  FIELD-SYMBOLS: <fs> TYPE ANY,
                 <zbook_ticketattr> TYPE zbook_ticketattr.

  SELECT *
    INTO TABLE me->gt_ticket_attributes
    FROM zbook_ticketattr
    WHERE tiknr = me->gv_tiknr.

  ls_dyn_fields = dyn_screen_selscreen_params( iv_area  = me->gv_area
                                               iv_class = me->gv_class ).
  lr_struct_descr ?= cl_abap_structdescr=>describe_by_data( ls_dyn_fields ).
  LOOP AT lr_struct_descr->components INTO ls_component.

    ASSIGN COMPONENT ls_component-name OF STRUCTURE  ls_dyn_fields TO <fs>.
    CHECK sy-subrc = 0.
    CHECK <fs> IS NOT INITIAL.

    SPLIT <fs> AT '-' INTO lv_table lv_field.

    READ TABLE me->gt_ticket_attributes
        INTO ls_ticket_attribute
        WITH KEY attribute_table = lv_table
                 attribute_field = lv_field.
    CHECK sy-subrc = 0.
    CALL FUNCTION 'Z_BOOK_DYN_SELSCR_SET_PARAM'
      EXPORTING
        iv_dyn_param_name     = ls_component-name
        iv_dyn_param_value    = ls_ticket_attribute-valuation_char
      EXCEPTIONS
        unknown_dyn_parameter = 1
        OTHERS                = 2.

  ENDLOOP.

ENDMETHOD.


METHOD zif_book_ticket_dyn_attributes~save_ticket_attributes.
  DATA: lr_struct_descr     TYPE REF TO cl_abap_structdescr,
        ls_component        LIKE LINE OF lr_struct_descr->components,
        ls_dyn_fields       TYPE zbook_dyn_selscr_fields,
        lt_zbook_ticketattr TYPE STANDARD TABLE OF zbook_ticketattr WITH NON-UNIQUE DEFAULT KEY,
        lv_dyn_data         TYPE text132.

  FIELD-SYMBOLS: <fs> TYPE ANY,
                 <zbook_ticketattr> TYPE zbook_ticketattr.

  ls_dyn_fields = dyn_screen_selscreen_params( iv_area  = me->gv_area
                                               iv_class = me->gv_class ).

* Jetzt für jedes aktuelle Feld die Belegung abfragen
  lr_struct_descr ?= cl_abap_structdescr=>describe_by_data( ls_dyn_fields ).
  LOOP AT lr_struct_descr->components INTO ls_component.

* Jedes eingebbare Feld ist jetzt mit einem Wert belegt.  Der Reihe nach abrufen.
    ASSIGN COMPONENT ls_component-name OF STRUCTURE  ls_dyn_fields TO <fs>.
    CHECK sy-subrc = 0.
    CHECK <fs> IS NOT INITIAL.

    CALL FUNCTION 'Z_BOOK_DYN_SELSCR_GET_PARAM'
      EXPORTING
        iv_dyn_param_name     = ls_component-name
      IMPORTING
        ev_dyn_param_value    = lv_dyn_data
      EXCEPTIONS
        unknown_dyn_parameter = 1
        OTHERS                = 2.
    CHECK sy-subrc = 0.
    APPEND INITIAL LINE TO lt_zbook_ticketattr ASSIGNING <zbook_ticketattr>.
    <zbook_ticketattr>-mandt          = sy-mandt.
    <zbook_ticketattr>-tiknr          = me->gv_tiknr.
    SPLIT <fs> AT '-' INTO             <zbook_ticketattr>-attribute_table
                                       <zbook_ticketattr>-attribute_field.
    <zbook_ticketattr>-valuation_char = lv_dyn_data.
  ENDLOOP.


  DELETE from zbook_ticketattr WHERE tiknr = me->gv_tiknr.
  INSERT zbook_ticketattr FROM TABLE lt_zbook_ticketattr ACCEPTING DUPLICATE KEYS.
ENDMETHOD.


method ZIF_BOOK_TICKET_DYN_ATTRIBUTES~SET_TICKET_NUMBER.
  me->gv_tiknr = iv_ticket_nr.
endmethod.
ENDCLASS.
