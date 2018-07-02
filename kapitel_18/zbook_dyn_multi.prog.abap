REPORT zbook_dyn_multi.

PARAMETERS p_edit RADIOBUTTON GROUP main DEFAULT 'X'.
PARAMETERS p_show RADIOBUTTON GROUP main.

PARAMETERS p_type01 TYPE char80 DEFAULT 'ZBOOK_TICKET-TIKNR'    NO-DISPLAY.
PARAMETERS p_type02 TYPE char80 DEFAULT 'ZBOOK_TICKET-AREA'     NO-DISPLAY.
PARAMETERS p_type03 TYPE char80 DEFAULT 'ZBOOK_TICKET-CLAS'     NO-DISPLAY.
PARAMETERS p_type04 TYPE char80 DEFAULT 'ZBOOK_TICKET-LOCATION' NO-DISPLAY.
PARAMETERS p_type05 TYPE char80 DEFAULT 'ZBOOK_TICKET-OWNER'    NO-DISPLAY.


SELECTION-SCREEN BEGIN OF SCREEN 100." AS WINDOW.

PARAMETERS p_data01 LIKE (p_type01) MODIF ID 01." VALUE CHECK.
PARAMETERS p_data02 LIKE (p_type02) MODIF ID 02." VALUE CHECK.
PARAMETERS p_data03 LIKE (p_type03) MODIF ID 03." VALUE CHECK.
PARAMETERS p_data04 LIKE (p_type04) MODIF ID 04." VALUE CHECK.
PARAMETERS p_data05 LIKE (p_type05) MODIF ID 05." VALUE CHECK.

SELECTION-SCREEN END OF SCREEN 100.



*----------------------------------------------------------------------*
*       CLASS lcl_dyn DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_dyn DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS pai IMPORTING ucomm  TYPE clike.
    CLASS-METHODS pbo IMPORTING i_show TYPE char01.
    CLASS-METHODS exit.
    CLASS-METHODS init.

  PROTECTED SECTION.
    CLASS-DATA max VALUE 5.
    CLASS-METHODS check_values.
    CLASS-METHODS export_values.
    CLASS-METHODS loop_at_screen IMPORTING i_show TYPE char01.
    CLASS-METHODS change_status.
    CLASS-METHODS adapt_selection_text.

ENDCLASS.                    "lcl_dyn DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_dyn IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_dyn IMPLEMENTATION.

  METHOD pai.
    check_values( ).
    IF ucomm = 'CRET'.
      export_values( ).
      LEAVE PROGRAM.
    ENDIF.
  ENDMETHOD.                    "pai

  METHOD exit.
    FREE MEMORY ID zcl_book_dyn_multi=>gc_memory_id.
    MESSAGE 'Eingabe abgebrochen...' TYPE 'S'.
  ENDMETHOD.                    "exit

  METHOD pbo.
    adapt_selection_text( ).
    loop_at_screen( i_show ).
  ENDMETHOD.

  METHOD adapt_selection_text.

    DATA lt_sel_dtel      TYPE STANDARD TABLE OF rsseldtel.
    DATA ls_sel_dtel      TYPE rsseldtel.

    DATA lv_tabname       TYPE dfies-tabname.
    DATA lv_fieldname     TYPE dfies-lfieldname.
    DATA lv_count         TYPE n LENGTH 2.
    DATA lv_type_name         TYPE c LENGTH 80.
    DATA lv_data_name         TYPE c LENGTH 80.
    FIELD-SYMBOLS <type>  TYPE any.
    FIELD-SYMBOLS <text>  TYPE any.

    DO max TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_DATA' lv_count INTO lv_data_name.
      CONCATENATE 'P_TYPE' lv_count INTO lv_type_name.
      ASSIGN (lv_type_name) TO <type>.
      SPLIT <type> AT '-' INTO lv_tabname lv_fieldname.
      SELECT SINGLE rollname
        FROM dd03l
        INTO ls_sel_dtel-datenelment
       WHERE tabname   = lv_tabname
         AND fieldname = lv_fieldname.
      ls_sel_dtel-kind = 'P'.
      ls_sel_dtel-name = lv_data_name.
      APPEND ls_sel_dtel TO lt_sel_dtel.

    ENDDO.

    CALL FUNCTION 'SELECTION_TEXTS_MODIFY_DTEL'
      EXPORTING
        program                     = sy-cprog
      TABLES
        sel_dtel                    = lt_sel_dtel
      EXCEPTIONS
        program_not_found           = 1
        program_cannot_be_generated = 2
        OTHERS                      = 3.

  ENDMETHOD.

  METHOD loop_at_screen.
    DATA lv_pname     TYPE c LENGTH 80.
    FIELD-SYMBOLS <type>  TYPE any.

    LOOP AT SCREEN.
      IF screen-group1 IS NOT INITIAL.
        CONCATENATE 'P_TYPE' screen-group1 INTO lv_pname.
        ASSIGN (lv_pname) TO <type>.
        IF sy-subrc = 0 AND <type> IS INITIAL.
          screen-active = '0'.
          MODIFY SCREEN.
        ELSEIF i_show IS NOT INITIAL.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "loop_at_screen

  METHOD init.

    DATA lt_excl  TYPE STANDARD TABLE OF syucomm.

    APPEND 'SPOS' TO lt_excl.

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = space
        p_program = space
      TABLES
        p_exclude = lt_excl.
  ENDMETHOD.                    "change_status

  METHOD change_status.
    DATA lt_excl  TYPE STANDARD TABLE OF syucomm.

    APPEND 'SPOS' TO lt_excl.

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = space
        p_program = space
      TABLES
        p_exclude = lt_excl.

  ENDMETHOD.                    "change_status


  METHOD check_values.
    DATA lv_tabname      TYPE dfies-tabname.
    DATA lv_fieldname    TYPE dfies-lfieldname.
    DATA lv_count        TYPE n LENGTH 2.
    DATA lv_pname        TYPE c LENGTH 80.
    FIELD-SYMBOLS <type> TYPE any.
    FIELD-SYMBOLS <data> TYPE any.

    DATA dtype TYPE REF TO data.
    DATA ddata TYPE REF TO data.

    DO max TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_TYPE' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <type>.
      SPLIT <type> AT '-' INTO lv_tabname lv_fieldname.


      CONCATENATE 'P_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <data>.

      CALL FUNCTION 'DDUT_INPUT_CHECK'
        EXPORTING
          tabname   = lv_tabname
          fieldname = lv_fieldname
          value     = <data>
        IMPORTING
          msgid     = sy-msgid
          msgty     = sy-msgty
          msgno     = sy-msgno
          msgv1     = sy-msgv1
          msgv2     = sy-msgv2
          msgv3     = sy-msgv3
          msgv4     = sy-msgv4
        EXCEPTIONS
          OTHERS    = 3.
      IF sy-msgty = 'E'.
        SET CURSOR FIELD lv_pname.
        MESSAGE ID sy-msgid
              TYPE sy-msgty
            NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDDO.
  ENDMETHOD.                    "check_values


  METHOD export_values.

    TYPES: BEGIN OF ty_param,
             field TYPE c LENGTH 80,
             value TYPE c LENGTH 80,
           END OF ty_param.
    DATA lt_params TYPE STANDARD TABLE OF ty_param.
    FIELD-SYMBOLS <param> TYPE ty_param.

    DATA lv_count        TYPE n LENGTH 2.
    DATA lv_pname        TYPE c LENGTH 80.
    DATA lv_type         TYPE c LENGTH 80.
    FIELD-SYMBOLS <type> TYPE any.
    FIELD-SYMBOLS <data> TYPE any.

    DO max TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_TYPE' lv_count INTO lv_type.
      ASSIGN (lv_type) TO <type>.

      CHECK <type> IS NOT INITIAL.

      CONCATENATE 'P_DATA' lv_count INTO lv_pname.
*      ASSIGN (lv_pname) TO <data>.

      APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
      <param>-field = lv_count.
      <param>-value = lv_pname.

    ENDDO.
    EXPORT (lt_params) TO MEMORY ID zcl_book_dyn_multi=>gc_memory_id.

  ENDMETHOD.                    "export_values

ENDCLASS.                    "lcl_dyn IMPLEMENTATION




INITIALIZATION.
  lcl_dyn=>init( ).


START-OF-SELECTION.
  CALL SELECTION-SCREEN 100 STARTING AT 2 2 ENDING AT 80 9.

AT SELECTION-SCREEN ON EXIT-COMMAND.
  lcl_dyn=>exit( ).

AT SELECTION-SCREEN OUTPUT.
  IF sy-dynnr = '0100'.
    lcl_dyn=>pbo( p_show ).
  ENDIF.

AT SELECTION-SCREEN.
  lcl_dyn=>pai( sy-ucomm ).
