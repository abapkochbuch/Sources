*"* components of interface ZIF_HNDL_TREE_MODEL_LIST_COL
interface ZIF_HNDL_TREE_MODEL_LIST_COL
  public .


  interfaces ZIF_HNDL_TREE_MODEL .

  methods HANDLE_ITEM_DOUBLE_CLICK
    for event ITEM_DOUBLE_CLICK of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !SENDER .
  methods HANDLE_BUTTON_CLICK
    for event BUTTON_CLICK of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !SENDER .
  methods HANDLE_LINK_CLICK
    for event LINK_CLICK of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !SENDER .
  methods HANDLE_CHECKBOX_CHANGE
    for event CHECKBOX_CHANGE of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !CHECKED
      !SENDER .
  methods HANDLE_ITEM_KEYPRESS
    for event ITEM_KEYPRESS of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !KEY
      !SENDER .
  methods HANDLE_HEADER_CLICK
    for event HEADER_CLICK of CL_ITEM_TREE_MODEL
    importing
      !HEADER_NAME
      !SENDER .
  methods HANDLE_ITEM_CONTEXT_MENU_REQ
    for event ITEM_CONTEXT_MENU_REQUEST of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !MENU
      !SENDER .
  methods HANDLE_ITEM_CONTEXT_MENU_SEL
    for event ITEM_CONTEXT_MENU_SELECT of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !FCODE
      !SENDER .
  methods HANDLE_HEADER_CONTEXT_MENU_REQ
    for event HEADER_CONTEXT_MENU_REQUEST of CL_ITEM_TREE_MODEL
    importing
      !HEADER_NAME
      !MENU
      !SENDER .
  methods HANDLE_HEADER_CONTEXT_MENU_SEL
    for event HEADER_CONTEXT_MENU_SELECT of CL_ITEM_TREE_MODEL
    importing
      !HEADER_NAME
      !FCODE
      !SENDER .
  methods HANDLE_DRAG
    for event DRAG of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DRAG_MULTIPLE
    for event DRAG_MULTIPLE of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY_TABLE
      !ITEM_NAME
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DROP_COMPLETE
    for event DROP_COMPLETE of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY
      !ITEM_NAME
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DROP_COMPLETE_MULTIPLE
    for event DROP_COMPLETE_MULTIPLE of CL_ITEM_TREE_MODEL
    importing
      !NODE_KEY_TABLE
      !ITEM_NAME
      !DRAG_DROP_OBJECT
      !SENDER .
endinterface.
