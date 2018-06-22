*"* components of interface ZIF_HNDL_TREE_MODEL
interface ZIF_HNDL_TREE_MODEL
  public .


  methods HANDLE_DEF_CONTEXT_MENU_REQ
    for event DEFAULT_CONTEXT_MENU_REQUEST of CL_TREE_MODEL
    importing
      !MENU
      !SENDER .
  methods HANDLE_DEF_CONTEXT_MENU_SEL
    for event DEFAULT_CONTEXT_MENU_SELECT of CL_TREE_MODEL
    importing
      !FCODE
      !SENDER .
  methods HANDLE_DROP
    for event DROP of CL_TREE_MODEL
    importing
      !NODE_KEY
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DROP_GET_FLAVOR
    for event DROP_GET_FLAVOR of CL_TREE_MODEL
    importing
      !NODE_KEY
      !FLAVORS
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_EXPAND_NO_CHILDREN
    for event EXPAND_NO_CHILDREN of CL_TREE_MODEL
    importing
      !NODE_KEY
      !SENDER .
  methods HANDLE_NODE_CONTEXT_MENU_REQ
    for event NODE_CONTEXT_MENU_REQUEST of CL_TREE_MODEL
    importing
      !NODE_KEY
      !MENU
      !SENDER .
  methods HANDLE_NODE_CONTEXT_MENU_SEL
    for event NODE_CONTEXT_MENU_SELECT of CL_TREE_MODEL
    importing
      !NODE_KEY
      !FCODE
      !SENDER .
  methods HANDLE_NODE_DOUBLE_CLICK
    for event NODE_DOUBLE_CLICK of CL_TREE_MODEL
    importing
      !NODE_KEY
      !SENDER .
  methods HANDLE_NODE_KEYPRESS
    for event NODE_KEYPRESS of CL_TREE_MODEL
    importing
      !NODE_KEY
      !KEY
      !SENDER .
  methods HANDLE_SELECTION_CHANGED
    for event SELECTION_CHANGED of CL_TREE_MODEL
    importing
      !NODE_KEY
      !SENDER .
endinterface.
