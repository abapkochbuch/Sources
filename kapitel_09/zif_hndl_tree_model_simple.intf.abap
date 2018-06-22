*"* components of interface ZIF_HNDL_TREE_MODEL_SIMPLE
interface ZIF_HNDL_TREE_MODEL_SIMPLE
  public .


  interfaces ZIF_HNDL_TREE_MODEL .

  methods HANDLE_DRAG
    for event DRAG of CL_SIMPLE_TREE_MODEL
    importing
      !NODE_KEY
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DRAG_MULTIPLE
    for event DRAG_MULTIPLE of CL_SIMPLE_TREE_MODEL
    importing
      !NODE_KEY_TABLE
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DROP_COMPLETE
    for event DROP_COMPLETE of CL_SIMPLE_TREE_MODEL
    importing
      !NODE_KEY
      !DRAG_DROP_OBJECT
      !SENDER .
  methods HANDLE_DROP_COMPLETE_MULTIPLE
    for event DROP_COMPLETE_MULTIPLE of CL_SIMPLE_TREE_MODEL
    importing
      !NODE_KEY_TABLE
      !DRAG_DROP_OBJECT
      !SENDER .
endinterface.
