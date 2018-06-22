FUNCTION z_book_personal_settings_edit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(P_PERS_OBJECT) TYPE REF TO  CL_PERS_OBJECT_DATA
*"     REFERENCE(P_VIEW_MODE) TYPE  CHAR1
*"  EXCEPTIONS
*"      DIALOG_CANCELED
*"      PERS_OBJECT_ERROR
*"----------------------------------------------------------------------

*== local variables
  DATA lt_fields        TYPE STANDARD TABLE OF sval.
  DATA lt_dd03p         TYPE STANDARD TABLE OF dd03p.
  DATA ls_dd03p         TYPE dd03p.
  DATA lv_return        TYPE c LENGTH 1.
  DATA lv_struct_name   TYPE ddobjname.
  DATA lr_type_descr    TYPE REF TO cl_abap_typedescr.

  DATA lv_typename      TYPE abap_abstypename.
  FIELD-SYMBOLS <field> TYPE sval.
  FIELD-SYMBOLS <value> TYPE any.

  DATA ld_data          TYPE REF  TO data.
  FIELD-SYMBOLS <data>  TYPE any.

*== get defined typename of personalization object
  CALL METHOD p_pers_object->get_type
    IMPORTING
      p_typename = lv_typename.

*== create type description for type
  lr_type_descr = cl_abap_typedescr=>describe_by_name( lv_typename ).

*== get relative name of type
  lv_struct_name = lr_type_descr->get_relative_name( ).

*== create structure with defined type
  CREATE DATA ld_data TYPE (lv_struct_name).
  ASSIGN ld_data->* TO <data>.

*== get personal data
  CALL METHOD p_pers_object->get_data
    EXPORTING
      p_reload_data   = space
    IMPORTING
      p_pers_data     = <data>
    EXCEPTIONS
      data_type_error = 1
      no_data_found   = 2
      internal_error  = 3
      OTHERS          = 4.

  CASE sy-subrc.
    WHEN 1 OR 3 OR 4.
      RAISE pers_object_error.
  ENDCASE.

*== get ddic information of type
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = lv_struct_name
    TABLES
      dd03p_tab     = lt_dd03p
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

*== build up field catalog
  LOOP AT lt_dd03p INTO ls_dd03p.
    APPEND INITIAL LINE TO lt_fields ASSIGNING <field>.
    <field>-tabname    = ls_dd03p-tabname.
    <field>-fieldname  = ls_dd03p-fieldname.
    <field>-novaluehlp = abap_false.
    IF p_view_mode IS NOT INITIAL.
      <field>-field_attr = '02'. "Display
    ENDIF.
*== assign stored value
    ASSIGN COMPONENT ls_dd03p-fieldname OF STRUCTURE <data> TO <value>.
    IF sy-subrc = 0.
      <field>-value = <value>.
    ENDIF.
  ENDLOOP.

*== show all fields of type in popup
  CALL FUNCTION 'POPUP_GET_VALUES_USER_HELP'
    EXPORTING
      popup_title               = 'Einstellungen Ticket-Dialog'
      f1_formname               = 'CALLBACK_F1'
      f1_programname            = 'SAPLZBOOK_TICKET'
      no_check_for_fixed_values = abap_true
    IMPORTING
      returncode                = lv_return
    TABLES
      fields                    = lt_fields
    EXCEPTIONS
      error_in_fields           = 1
      OTHERS                    = 2.

  IF  sy-subrc IS INITIAL AND lv_return <> 'A'.
*== user set values
    LOOP AT lt_fields ASSIGNING <field>.
      ASSIGN COMPONENT <field>-fieldname OF STRUCTURE <data> TO <value>.
      IF sy-subrc = 0.
        <value> = <field>-value.
      ENDIF.
    ENDLOOP.

*== set personal data
    CALL METHOD p_pers_object->set_data
      EXPORTING
        p_pers_data     = <data>
        p_write_through = space
      EXCEPTIONS
        data_type_error = 1
        internal_error  = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
      RAISE pers_object_error.
    ENDIF.
  ELSE.
    RAISE dialog_canceled.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  callback_f1
*&---------------------------------------------------------------------*
FORM callback_f1 USING tabname fieldname.

  CASE fieldname.
    WHEN 'SIZE_LEFT'.
      MESSAGE i000(oo) WITH 'Breite des linken Docking Containers'.
    WHEN 'SIZE_RIGHT'.
      MESSAGE i000(oo) WITH 'Breite des rechten Docking Containers'.
  ENDCASE.

ENDFORM.                    "callback_f1
