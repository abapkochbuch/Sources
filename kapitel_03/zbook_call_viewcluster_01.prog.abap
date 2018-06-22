REPORT zbook_call_viewcluster_01.

*== data
DATA gt_sellist TYPE STANDARD TABLE OF vimsellist.
FIELD-SYMBOLS <sellist> TYPE vimsellist.

*== selection screen
PARAMETERS p_area1 LIKE zbook_areasv-area DEFAULT 'HARDWARE'.
PARAMETERS p_area2 LIKE zbook_areasv-area DEFAULT 'SOFTWARE'.

*== Start of program
START-OF-SELECTION.

*== define select options
  APPEND INITIAL LINE TO gt_sellist ASSIGNING <sellist>.
  <sellist>-viewfield = 'AREA'.
  <sellist>-operator  = 'EQ'.
  <sellist>-value     = p_area1.
  <sellist>-and_or    = 'OR'.

*== define select options
  APPEND INITIAL LINE TO gt_sellist ASSIGNING <sellist>.
  <sellist>-viewfield = 'AREA'.
  <sellist>-operator  = 'EQ'.
  <sellist>-value     = p_area2.

  CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'
    EXPORTING
      viewcluster_name     = 'ZBOOK_AREACL_VCL'
      maintenance_action   = 'S'
      show_selection_popup = ' '
    TABLES
      dba_sellist          = gt_sellist
    EXCEPTIONS
      OTHERS               = 16.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
