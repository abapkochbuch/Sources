interface ZIF_GUI_ALV_GRID
  public .

  type-pools CNTL .
  type-pools ICON .
  type-pools WRFAC .

  methods HANDLE_ONF1
    for event ONF1 of CL_GUI_ALV_GRID
    importing
      !E_FIELDNAME
      !ES_ROW_NO
      !ER_EVENT_DATA
      !SENDER .
  methods HANDLE_ONF4
    for event ONF4 of CL_GUI_ALV_GRID
    importing
      !E_FIELDNAME
      !E_FIELDVALUE
      !ES_ROW_NO
      !ER_EVENT_DATA
      !ET_BAD_CELLS
      !E_DISPLAY
      !SENDER .
  methods HANDLE_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM
      !SENDER .
  methods HANDLE_ONDROPGETFLAVOR
    for event ONDROPGETFLAVOR of CL_GUI_ALV_GRID
    importing
      !E_COLUMN
      !ES_ROW_NO
      !E_DRAGDROPOBJ
      !E_FLAVORS
      !SENDER .
  methods HANDLE_ONDRAG
    for event ONDRAG of CL_GUI_ALV_GRID
    importing
      !E_COLUMN
      !ES_ROW_NO
      !E_DRAGDROPOBJ
      !SENDER .
  methods HANDLE_ONDROP
    for event ONDROP of CL_GUI_ALV_GRID
    importing
      !E_COLUMN
      !ES_ROW_NO
      !E_DRAGDROPOBJ
      !SENDER .
  methods HANDLE_ONDROPCOMPLETE
    for event ONDROPCOMPLETE of CL_GUI_ALV_GRID
    importing
      !E_COLUMN
      !ES_ROW_NO
      !E_DRAGDROPOBJ
      !SENDER .
  methods HANDLE_SUBTOTAL_TEXT
    for event SUBTOTAL_TEXT of CL_GUI_ALV_GRID
    importing
      !ES_SUBTOTTXT_INFO
      !EP_SUBTOT_LINE
      !E_EVENT_DATA
      !SENDER .
  methods HANDLE_BEFORE_USER_COMMAND
    for event BEFORE_USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM
      !SENDER .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM
      !SENDER .
  methods HANDLE_AFTER_USER_COMMAND
    for event AFTER_USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM
      !E_SAVED
      !E_NOT_PROCESSED
      !SENDER .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_COLUMN
      !ES_ROW_NO
      !SENDER .
  methods HANDLE_DELAYED_CALLBACK
    for event DELAYED_CALLBACK of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HNDL_DELAYED_CHANGED_SEL_CALLB
    for event DELAYED_CHANGED_SEL_CALLBACK of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HANDLE_PRINT_TOP_OF_PAGE
    for event PRINT_TOP_OF_PAGE of CL_GUI_ALV_GRID
    importing
      !TABLE_INDEX
      !SENDER .
  methods HANDLE_PRINT_TOP_OF_LIST
    for event PRINT_TOP_OF_LIST of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HANDLE_PRINT_END_OF_PAGE
    for event PRINT_END_OF_PAGE of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HANDLE_PRINT_END_OF_LIST
    for event PRINT_END_OF_LIST of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HANDLE_TOP_OF_PAGE
    for event TOP_OF_PAGE of CL_GUI_ALV_GRID
    importing
      !E_DYNDOC_ID
      !TABLE_INDEX
      !SENDER .
  methods HANDLE_CONTEXT_MENU_REQUEST
    for event CONTEXT_MENU_REQUEST of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !SENDER .
  methods HANDLE_MENU_BUTTON
    for event MENU_BUTTON of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_UCOMM
      !SENDER .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE
      !SENDER .
  methods HANDLE_HOTSPOT_CLICK
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_COLUMN_ID
      !ES_ROW_NO
      !SENDER .
  methods HANDLE_END_OF_LIST
    for event END_OF_LIST of CL_GUI_ALV_GRID
    importing
      !E_DYNDOC_ID
      !SENDER .
  methods HANDLE_AFTER_REFRESH
    for event AFTER_REFRESH of CL_GUI_ALV_GRID
    importing
      !SENDER .
  methods HANDLE_BUTTON_CLICK
    for event BUTTON_CLICK of CL_GUI_ALV_GRID
    importing
      !ES_COL_ID
      !ES_ROW_NO
      !SENDER .
  methods HANDLE_DATA_CHANGED_FINISHED
    for event DATA_CHANGED_FINISHED of CL_GUI_ALV_GRID
    importing
      !E_MODIFIED
      !ET_GOOD_CELLS
      !SENDER .
endinterface.
