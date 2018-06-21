*"---------------------------------------------------------------------*
REPORT zbook_maintain_single.

PARAMETERS p_call RADIOBUTTON GROUP x DEFAULT 'X'.
PARAMETERS p_sgle RADIOBUTTON GROUP x.
*"* Init
INITIALIZATION.

*"* Start of program
START-OF-SELECTION.


  CASE 'X'.
    WHEN p_call.

      DATA lt_sellist TYPE STANDARD TABLE OF vimsellist.
      DATA ls_sellist TYPE vimsellist.

      DATA lt_exclude TYPE STANDARD TABLE OF vimexclfun.
      DATA ls_exclude TYPE vimexclfun.

      ls_sellist-viewfield = 'AREA'.
      ls_sellist-operator = 'CP'.
      ls_sellist-value    = 'S*'.
      APPEND ls_sellist TO lt_sellist.

      ls_exclude-function = 'AEND'.
      APPEND ls_exclude TO lt_exclude.

      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action               = 'S'
          show_selection_popup = ' '
          view_name            = 'ZBOOK_AREAS'
        TABLES
          dba_sellist          = lt_sellist
          excl_cua_funct       = lt_exclude
        EXCEPTIONS
          OTHERS               = 15.
    WHEN p_sgle.

      DATA ls_area TYPE zbook_areas.

      SELECT * FROM zbook_areas INTO ls_area.
        EXIT.
      ENDSELECT.
      CALL FUNCTION 'VIEW_MAINTENANCE_SINGLE_ENTRY'
        EXPORTING
          action    = 'SHOW'
          view_name = 'ZBOOK_AREAS'
        CHANGING
          entry     = ls_area
        EXCEPTIONS
          OTHERS    = 15.
  ENDCASE.

END-OF-SELECTION.
