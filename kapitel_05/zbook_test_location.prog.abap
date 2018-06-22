*"---------------------------------------------------------------------*
*" Report  ZBOOK_TEST_LOCATION
*"---------------------------------------------------------------------*
REPORT zbook_test_location.

PARAMETERS p_loc TYPE zbook_location.

INITIALIZATION.
  CALL METHOD zcl_book_docu=>display
    EXPORTING
      id      = 'RE'
      object  = sy-repid
      side    = cl_gui_docking_container=>dock_at_right
      autodef = space.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_loc.
  CALL FUNCTION 'Z_BOOK_LOCATION_SHOW'
    CHANGING
      location = p_loc.

START-OF-SELECTION.
  WRITE: / 'Standort:', p_loc.
