REPORT zbook_dyn_data.



PARAMETERS p_type01 TYPE char80  NO-DISPLAY.
PARAMETERS p_type02 TYPE char80  NO-DISPLAY.
PARAMETERS p_type03 TYPE char80  NO-DISPLAY.
PARAMETERS p_type04 TYPE char80  NO-DISPLAY.
PARAMETERS p_type05 TYPE char80  NO-DISPLAY.


SELECTION-SCREEN BEGIN OF SCREEN 100.

PARAMETERS p_data01 LIKE (p_type01) MODIF ID 01 VALUE CHECK.
PARAMETERS p_data02 LIKE (p_type02) MODIF ID 02 VALUE CHECK.
PARAMETERS p_data03 LIKE (p_type03) MODIF ID 03 VALUE CHECK.
PARAMETERS p_data04 LIKE (p_type04) MODIF ID 04 VALUE CHECK.
PARAMETERS p_data05 LIKE (p_type05) MODIF ID 05 VALUE CHECK.

SELECTION-SCREEN END OF SCREEN 100.



*----------------------------------------------------------------------*
*       CLASS lcl_dyn DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_dyn DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA gv_field TYPE c LENGTH 80.

    CLASS-METHODS pai IMPORTING ucomm TYPE clike.
    CLASS-METHODS pbo.
    CLASS-METHODS init.

  PROTECTED SECTION.
    CLASS-METHODS check_values.
    CLASS-METHODS export_values.

ENDCLASS.                    "lcl_dyn DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_dyn IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_dyn IMPLEMENTATION.

  METHOD pai.
    CASE ucomm.
      WHEN 'ABBR'.
        MESSAGE s000(oo) WITH 'Eingabe abgebrochen'.
        LEAVE PROGRAM.

      WHEN 'OK'.
        check_values( ).
        export_values( ).
        LEAVE PROGRAM.
      WHEN OTHERS.
        check_values( ).
        GET CURSOR FIELD gv_field.
    ENDCASE.
  ENDMETHOD.                    "pai

  METHOD pbo.
    DATA lv_pname     TYPE c LENGTH 80.
    FIELD-SYMBOLS <type>  TYPE any.

    LOOP AT SCREEN.

      IF screen-group1 IS NOT INITIAL.
        CONCATENATE 'P_TYPE' screen-group1 INTO lv_pname.
        ASSIGN (lv_pname) TO <type>.
        IF sy-subrc = 0 AND <type> IS INITIAL.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gv_field IS NOT INITIAL.
      SET CURSOR FIELD gv_field.
    ENDIF.
  ENDMETHOD.                    "pbo

  METHOD init.
    DATA lt_excl  TYPE STANDARD TABLE OF syucomm.

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = 'ZBOOK'
        p_program = 'ZBOOK_DYN_DATA'
      TABLES
        p_exclude = lt_excl.

    DATA lv_count     TYPE n LENGTH 2.
    DATA lv_pname     TYPE c LENGTH 80.

    DO 5 TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_DATA' lv_count INTO lv_pname.
      FREE MEMORY ID lv_pname.
    ENDDO.

    FREE MEMORY ID '$DYN$'.

  ENDMETHOD.                    "init

  METHOD check_values.
    DATA lv_tabname   TYPE dfies-tabname.
    DATA lv_fieldname TYPE dfies-lfieldname.
    DATA lv_count     TYPE n LENGTH 2.
    DATA lv_pname     TYPE c LENGTH 80.
    FIELD-SYMBOLS <type>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    DO 5 TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_TYPE' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <type>.
      SPLIT <type> AT '-' INTO lv_tabname lv_fieldname.

      CONCATENATE 'P_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <value>.

      CALL FUNCTION 'DDUT_INPUT_CHECK'
        EXPORTING
          tabname   = lv_tabname
          fieldname = lv_fieldname
          value     = <value>
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

    DATA lv_count     TYPE n LENGTH 2.
    DATA lv_pname     TYPE c LENGTH 80.
    DATA lv_type      TYPE c LENGTH 80.
    FIELD-SYMBOLS <type>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    DO 5 TIMES.
      lv_count = sy-index.
      CONCATENATE 'P_TYPE' lv_count INTO lv_type.
      ASSIGN (lv_type) TO <type>.

      CHECK <type> IS NOT INITIAL.

      CONCATENATE 'P_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <value>.

      APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
      <param>-field = lv_count.
      <param>-value = lv_pname.

      EXPORT value FROM <value> TO MEMORY ID lv_pname.
    ENDDO.
    EXPORT (lt_params) TO MEMORY ID '$DYN$'.

  ENDMETHOD.                    "export_values

ENDCLASS.                    "lcl_dyn IMPLEMENTATION




START-OF-SELECTION.
  CALL SELECTION-SCREEN 100 STARTING AT 2 2 ENDING AT 70 9.

INITIALIZATION.
  lcl_dyn=>init( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_dyn=>pbo( ).

AT SELECTION-SCREEN.
  lcl_dyn=>pai( sy-ucomm ).
