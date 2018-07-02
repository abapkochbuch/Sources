REPORT zbook_dyn_param.
PARAMETERS p_type TYPE char40 NO-DISPLAY.

SELECTION-SCREEN BEGIN OF SCREEN 1 AS WINDOW.
PARAMETERS p_data LIKE (p_type).
SELECTION-SCREEN END OF SCREEN 1.

CALL SELECTION-SCREEN 1 STARTING AT 2 2 ENDING AT 80 5.

INITIALIZATION.
  DATA lt_excl  TYPE STANDARD TABLE OF syucomm.
*  APPEND 'SPOS' TO lt_excl.
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      p_status  = space
      p_program = space
    TABLES
      p_exclude = lt_excl.

AT SELECTION-SCREEN.
  DATA lv_tabname   TYPE dfies-tabname.
  DATA lv_fieldname TYPE dfies-lfieldname.
  DATA lv_pname     TYPE c LENGTH 80.

  SPLIT p_type AT '-' INTO lv_tabname lv_fieldname.

  CALL FUNCTION 'DDUT_INPUT_CHECK'
    EXPORTING
      tabname   = lv_tabname
      fieldname = lv_fieldname
      value     = p_data
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

  EXPORT data FROM p_data TO MEMORY ID 'Kochbuch'.
  LEAVE PROGRAM.

AT SELECTION-SCREEN ON EXIT-COMMAND.
  FREE MEMORY ID 'Kochbuch'.
