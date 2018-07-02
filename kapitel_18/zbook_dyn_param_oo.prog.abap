REPORT zbook_dyn_param_oo.

PARAMETERS p_show TYPE c LENGTH 1 NO-DISPLAY.
PARAMETERS p_type TYPE char40 NO-DISPLAY.

SELECTION-SCREEN BEGIN OF SCREEN 1 AS WINDOW.
PARAMETERS p_data LIKE (p_type) MODIF ID dat.
SELECTION-SCREEN END OF SCREEN 1.



*----------------------------------------------------------------------*
*       CLASS lcl_dyn DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_dyn DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS init.
    CLASS-METHODS pbo IMPORTING i_show TYPE char01.
    CLASS-METHODS pai IMPORTING i_type TYPE any
                                i_data TYPE any.
    CLASS-METHODS exit.
  PROTECTED SECTION.
    CONSTANTS gc_memory_id TYPE c LENGTH 30 VALUE 'Kochbuch'.

ENDCLASS.                    "lcl_dyn DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_dyn IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_dyn IMPLEMENTATION.
  METHOD init.
    DATA lt_excl  TYPE STANDARD TABLE OF syucomm.
    APPEND 'SPOS' TO lt_excl.
    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = space
        p_program = space
      TABLES
        p_exclude = lt_excl.

  ENDMETHOD.                    "init

  METHOD pbo.

    IF i_show IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'DAT'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.                    "pbo

  METHOD pai.
    DATA lv_tabname   TYPE dfies-tabname.
    DATA lv_fieldname TYPE dfies-lfieldname.
    DATA lv_pname     TYPE c LENGTH 80.

    SPLIT i_type AT '-' INTO lv_tabname lv_fieldname.

    CALL FUNCTION 'DDUT_INPUT_CHECK'
      EXPORTING
        tabname   = lv_tabname
        fieldname = lv_fieldname
        value     = i_data
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

    EXPORT data FROM i_data TO MEMORY ID gc_memory_id.
    LEAVE PROGRAM.
  ENDMETHOD.                    "pai

  METHOD exit.
    FREE MEMORY ID gc_memory_id.
    MESSAGE 'Eingabe abgebrochen...' TYPE 'S'.
  ENDMETHOD.                    "exit
ENDCLASS.                    "lcl_dyn IMPLEMENTATION


INITIALIZATION.
  lcl_dyn=>init( ).

START-OF-SELECTION.
  CALL SELECTION-SCREEN 1 STARTING AT 2 2 ENDING AT 80 5.

AT SELECTION-SCREEN OUTPUT.
  lcl_dyn=>pbo( p_show ).

AT SELECTION-SCREEN.
  lcl_dyn=>pai( i_type = p_type i_data = p_data ).

AT SELECTION-SCREEN ON EXIT-COMMAND.
  lcl_dyn=>exit( ).
