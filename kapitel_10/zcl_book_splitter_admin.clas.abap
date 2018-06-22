class ZCL_BOOK_SPLITTER_ADMIN definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_SPLITTER_ADMIN
*"* do not include other source files here!!!
public section.
  type-pools CNTB .
  type-pools ICON .

  methods CONSTRUCTOR
    importing
      !IV_NO_OF_CONTAINER type I default 2
      !IR_PARENT type ref to CL_GUI_CONTAINER
    preferred parameter IV_NO_OF_CONTAINER .
  methods GET_CONTAINER
    importing
      !NUMBER type I
    preferred parameter NUMBER
    returning
      value(CONTAINER) type ref to CL_GUI_CONTAINER .
protected section.
*"* protected components of class ZCL_BOOK_SPLITTER_ADMIN
*"* do not include other source files here!!!

  data GT_TOOLBARS type SBPTTOOLBARS .
  data GR_SPLITTER type ref to CL_GUI_SPLITTER_CONTAINER .
  data GT_CONTAINER type TY_CONTAINER_TABLE .

  methods BUILD_TOOLBAR
    changing
      !CONTAINER type TY_CONTAINER .
  methods BUTTON_CLICK
    for event FUNCTION_SELECTED of CL_GUI_TOOLBAR
    importing
      !FCODE
      !SENDER .
  methods SET_TOOLBAR
    changing
      !CONTAINER type TY_CONTAINER .
private section.
*"* private components of class ZCL_BOOK_SPLITTER_ADMIN
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_SPLITTER_ADMIN IMPLEMENTATION.


METHOD build_toolbar.
  DATA lr_toolbar TYPE REF TO cl_gui_toolbar.
  DATA lt_event   TYPE cntl_simple_events.
  data ls_event   TYPE cntl_simple_event.

  CREATE OBJECT lr_toolbar
    EXPORTING
      parent       = container-tool
      display_mode = cl_gui_toolbar=>m_mode_horizontal
      name         = 'Toolbar'.
  CALL METHOD lr_toolbar->add_button
    EXPORTING
      fcode       = 'CLOSE'
      icon        = icon_close
      is_disabled = space
      butn_type   = cntb_btype_button
      text        = space
      quickinfo   = 'Close frame'
      is_checked  = space.
  CALL METHOD lr_toolbar->add_button
    EXPORTING
      fcode       = 'Maximize'
      icon        = icon_view_maximize
      is_disabled = space
      butn_type   = cntb_btype_button
      text        = space
      quickinfo   = 'Maximize frame'
      is_checked  = space.
  CALL METHOD lr_toolbar->add_button
    EXPORTING
      fcode       = 'RESET'
      icon        = icon_system_undo
      is_disabled = space
      butn_type   = cntb_btype_button
      text        = space
      quickinfo   = 'Reset all frames'
      is_checked  = space.
  ls_event-eventid = cl_gui_toolbar=>m_id_function_selected.
  APPEND ls_event TO lt_event.
  lr_toolbar->set_registered_events( lt_event ).
  SET HANDLER button_click FOR lr_toolbar.
  container-tbar = lr_toolbar.
ENDMETHOD.


METHOD button_click.
  DATA lv_size                     TYPE i.
  DATA lv_number                   TYPE i.
  DATA lv_count                    TYPE i.
  FIELD-SYMBOLS <container_sender> TYPE ty_container.
  FIELD-SYMBOLS <container_others> TYPE ty_container.
  READ TABLE gt_container ASSIGNING <container_sender> WITH KEY tbar = sender.
  CHECK sy-subrc = 0.
  lv_number = sy-tabix.
  gr_splitter->get_row_height( EXPORTING id = lv_number IMPORTING result = lv_size ).
  cl_gui_cfw=>flush( ).
  CASE fcode.
    WHEN 'CLOSE'.
      LOOP AT gt_container ASSIGNING <container_others>.
        CHECK lv_number <> sy-tabix.
        gr_splitter->get_row_height( EXPORTING id = sy-tabix IMPORTING result = lv_size ).
        cl_gui_cfw=>flush( ).
        IF lv_size > 0.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_size > 0.
        gr_splitter->set_row_height( EXPORTING id = lv_number height = 0 ).
      ENDIF.
    WHEN 'MAXIMIZE'.
      LOOP AT gt_container ASSIGNING <container_others>.
        IF lv_number = sy-tabix.
          gr_splitter->set_row_height( EXPORTING id = sy-tabix height = 100 ).
        ELSE.
          gr_splitter->set_row_height( EXPORTING id = sy-tabix height = 0 ).
        ENDIF.
      ENDLOOP.
      <container_Sender>-tbar->set_button_state( enabled = space fcode   = 'CLOSE' ).
      <container_Sender>-tbar->set_button_state( enabled = space fcode   = 'MAXIMIZE' ).
    WHEN 'RESET'.
      lv_count = LINES( gt_container ).
      LOOP AT gt_container ASSIGNING <container_others>.
        lv_number = sy-tabix.
        lv_size = 100 / lv_count.
        gr_splitter->set_row_height( EXPORTING id = lv_number height = lv_size ).
      ENDLOOP.
      <container_Sender>-tbar->set_button_state( enabled = 'X' fcode   = 'CLOSE' ).
      <container_Sender>-tbar->set_button_state( enabled = 'X' fcode   = 'MAXIMIZE' ).
  ENDCASE.
ENDMETHOD.


METHOD constructor.
  FIELD-SYMBOLS <container> TYPE ty_container.
  DATA lv_number            TYPE i.

  CREATE OBJECT gr_splitter
    EXPORTING
      parent  = ir_parent
      rows    = iv_no_of_container
      columns = 1.

*  gr_splitter->set_name( 'KOCHBUCH_SPLITTER' ).

  gr_splitter->set_row_mode( gr_splitter->mode_relative ).

  DO iv_no_of_container TIMES.
    lv_number = sy-index.
    APPEND INITIAL LINE TO gt_container ASSIGNING <container>.
    <container>-main = gr_splitter->get_container( row = lv_number column  = 1 ).
*    <container>-main->set_name( 'KOCHBUCH_SPLITMAIN' ).
    set_toolbar( changing container = <container> ).
  ENDDO.
ENDMETHOD.


METHOD get_container.
  FIELD-SYMBOLS <container> TYPE ty_container.
  READ TABLE gt_container ASSIGNING <container> INDEX number.
  container = <container>-cust.
ENDMETHOD.


METHOD set_toolbar.
  DATA lr_splitter TYPE REF TO cl_gui_splitter_container.
  DATA lr_toolbar  TYPE REF TO cl_gui_toolbar.
  CREATE OBJECT lr_splitter
    EXPORTING
      parent  = container-main
      rows    = 2
      columns = 1.
* lr_splitter->set_name( 'KOCHBUCH_TOOLMAIN' ).
  CALL METHOD lr_splitter->set_row_sash
    EXPORTING
      id    = 1
      type  = cl_gui_splitter_container=>type_movable
      value = cl_gui_splitter_container=>false.
  lr_splitter->set_row_mode( cl_gui_splitter_container=>mode_absolute ).
  lr_splitter->set_row_height( id = 1 height = 20 ).
  lr_splitter->set_border( cl_gui_cfw=>false ).
  container-tool = lr_splitter->get_container( row = 1 column  = 1 ).
*  container-tool->set_name( 'KOCHBUCH_TOOLBAR' ).
  container-cust = lr_splitter->get_container( row = 2 column  = 1 ).
*  container-cust->set_name( 'KOCHBUCH_TOOLCUST' ).
  build_toolbar( CHANGING container = container ).

ENDMETHOD.
ENDCLASS.
