FUNCTION z_book_ticket_shlp_exit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_data,
           tiknr  TYPE zbook_ticket_nr,
           status TYPE zbook_ticket_status,
         END OF ty_data.
  DATA lt_data         TYPE STANDARD TABLE OF ty_data.
  FIELD-SYMBOLS <data> TYPE ty_data.

  DATA lt_icon         TYPE STANDARD TABLE OF ddshicon.
  FIELD-SYMBOLS <icon> TYPE ddshicon.

  IF callcontrol-step = 'PRESEL1'.

    DATA: ls_shlp      LIKE LINE OF shlp-selopt.

*  IF callcontrol-step =  'PRESEL1'.
    CLEAR ls_shlp.
    ls_shlp-shlpname  = shlp-shlpname.
    ls_shlp-shlpfield = 'STATUS'.
    ls_shlp-sign      = 'E'.
    ls_shlp-option    = 'EQ'.
    ls_shlp-low       = 'CLSD'.
    APPEND ls_shlp TO shlp-selopt.
*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.


* EXIT immediately, if you do not want to handle this step
  IF callcontrol-step <> 'SELONE' AND
     callcontrol-step <> 'SELECT' AND
     " AND SO ON
     callcontrol-step <> 'DISP'.
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP SELONE  (Select one of the elementary searchhelps)
*"----------------------------------------------------------------------
* This step is only called for collective searchhelps. It may be used
* to reduce the amount of elementary searchhelps given in SHLP_TAB.
* The compound searchhelp is given in SHLP.
* If you do not change CALLCONTROL-STEP, the next step is the
* dialog, to select one of the elementary searchhelps.
* If you want to skip this dialog, you have to return the selected
* elementary searchhelp in SHLP and to change CALLCONTROL-STEP to
* either to 'PRESEL' or to 'SELECT'.
  IF callcontrol-step = 'SELONE'.
*   PERFORM SELONE .........
    EXIT.
  ENDIF.


*"----------------------------------------------------------------------
* STEP PRESEL  (Enter selection conditions)
*"----------------------------------------------------------------------
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF callcontrol-step = 'PRESEL'.


*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF callcontrol-step = 'SELECT'.
*   PERFORM STEP_SELECT TABLES RECORD_TAB SHLP_TAB
*                       CHANGING SHLP CALLCONTROL RC.
*   IF RC = 0.
*     CALLCONTROL-STEP = 'DISP'.
*   ELSE.
*     CALLCONTROL-STEP = 'EXIT'.
*   ENDIF.
    EXIT. "Don't process STEP DISP additionally in this call.
  ENDIF.
*"----------------------------------------------------------------------
* STEP DISP     (Display values)
*"----------------------------------------------------------------------
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF callcontrol-step = 'DISP'.
    CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
      EXPORTING
        parameter   = 'STATUS'
        fieldname   = 'STATUS'
      TABLES
        shlp_tab    = shlp_tab
        record_tab  = record_tab
        results_tab = lt_data
      CHANGING
        shlp        = shlp
        callcontrol = callcontrol
      EXCEPTIONS
        OTHERS      = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
        EXPORTING
          parameter   = 'TIKNR'
          fieldname   = 'TIKNR'
        TABLES
          shlp_tab    = shlp_tab
          record_tab  = record_tab
          results_tab = lt_data
        CHANGING
          shlp        = shlp
          callcontrol = callcontrol
        EXCEPTIONS
          OTHERS      = 2.
      IF sy-subrc = 0.
        LOOP AT lt_data ASSIGNING <data>.
*          if <data>-status = 'CLSD'.
*            delete record_tab index sy-tabix.
*            continue.
*          endif.

          APPEND INITIAL LINE TO lt_icon ASSIGNING <icon>.
          CASE <data>-status.
            WHEN 'OPEN'.
              <icon>-name      = 'ICON_LED_RED'.
              <icon>-text      = 'Offen'.
              <icon>-quickinfo = 'Ticketstatus: Offen'.
            WHEN 'CLSD'.
              <icon>-name      = 'ICON_LED_GREEN'.
              <icon>-text      = 'Abgeschlossen'.
              <icon>-quickinfo = 'Ticket wurde geschlossen'.
            WHEN 'HOLD'.
              <icon>-name      = 'ICON_LED_INACTIVE'.
              <icon>-text      = 'Zurückgestellt'.
              <icon>-quickinfo = 'Ticket wurde zurückgestellt'.
            WHEN OTHERS.
              <icon>-name      = 'ICON_SPACE'.
          ENDCASE.
        ENDLOOP.

        CALL FUNCTION 'F4UT_ICONS_DISPLAY'
          EXPORTING
            parameter   = 'ICON'
          TABLES
            shlp_tab    = shlp_tab
            record_tab  = record_tab
            icon_tab    = lt_icon
          CHANGING
            shlp        = shlp
            callcontrol = callcontrol
          EXCEPTIONS
            OTHERS      = 2.

        CALL FUNCTION 'F4UT_PARAMETER_SORT'
          EXPORTING
            parameter_sort  = 'TIKNR'
            leading_columns = '0'
            descending      = ' '
          TABLES
            shlp_tab        = shlp_tab
            record_tab      = record_tab
          CHANGING
            shlp            = shlp
            callcontrol     = callcontrol.

      ENDIF.

    ENDIF.



*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
    EXIT.
  ENDIF.
ENDFUNCTION.
