class ZCL_BOOK_HTML_BUTTON definition
  public
  create public .

*"* public components of class ZCL_BOOK_HTML_BUTTON
*"* do not include other source files here!!!
public section.

  types:
    ty_html_table TYPE STANDARD TABLE OF text1000 .

  methods CONSTRUCTOR
    importing
      !IV_CC_NAME type CLIKE optional
      !IR_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IV_TEXT type CLIKE
      !IV_COLOR type CLIKE
      !IV_OK_CODE type CLIKE .
  methods SET_INACTIVE .
  methods SET_ACTIVE .
protected section.
*"* protected components of class ZCL_BOOK_HTML_BUTTON
*"* do not include other source files here!!!

  data GV_INACTIVE type CHAR01 .
  data GV_TEXT type TEXT80 .
  data GV_COLOR type TEXT40 .
  data GV_OK_CODE type TEXT40 .
  data GR_HTML type ref to CL_GUI_HTML_VIEWER .

  methods HANDLE_SAPEVENT
    for event SAPEVENT of CL_GUI_HTML_VIEWER
    importing
      !ACTION
      !FRAME
      !GETDATA
      !POSTDATA
      !QUERY_TABLE .
  methods BUILD_HTML_CODE
    importing
      !IV_TEXT type CLIKE
      !IV_COLOR type CLIKE
      !IV_OK_CODE type CLIKE
    changing
      !CT_HTML type TY_HTML_TABLE .
private section.
*"* private components of class ZCL_BOOK_HTML_BUTTON
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_HTML_BUTTON IMPLEMENTATION.


METHOD build_html_code.

  DATA lv_html             LIKE LINE OF ct_html.

  CONCATENATE
      '<html><head><title>BUTTON</title>'
      '<style type="text/css">'
      'body {overflow:hidden; margin:0; }'
      'input.bgcolor { background-color:'
      iv_color
      '; width: 100%; height: 100%; font-size:large; }'
      '</style></head><body>'
      '<input class="bgcolor" type="button" value="'
      iv_text     '" onclick="location.href=''SAPEVENT:'
      iv_ok_code  '''"></body></html>'
      INTO lv_html.
  APPEND lv_html TO ct_html.

ENDMETHOD.


METHOD constructor.

*== local data
  DATA lt_events           TYPE cntl_simple_events.
  DATA ls_event            LIKE LINE OF lt_events.
  DATA lt_html             TYPE ty_html_table.
  DATA lv_url              TYPE text1000.
  DATA lv_color            TYPE string.

*  DATA lr_custom_container TYPE REF TO cl_gui_custom_container.
  DATA lr_container        TYPE REF TO cl_gui_container.

  IF iv_cc_name <> space AND ir_container IS INITIAL.
*== create custom container
    CREATE OBJECT lr_container
      TYPE
      cl_gui_custom_container
      EXPORTING
        container_name = iv_cc_name.
  ELSE.
*== use given container
    lr_container = ir_container.
  ENDIF.

*== check if container is bound
  CHECK lr_container IS BOUND.

  IF iv_color IS INITIAL.
*== set default color
    lv_color = '#F2E1AF'.
  ELSE.
*== use given color
    lv_color = iv_color.
  ENDIF.

  gv_color   = lv_color.
  gv_text    = iv_text.
  gv_ok_code = iv_ok_code.

*== create HTML control
  CREATE OBJECT gr_html
    EXPORTING
      parent = lr_container.

*== Register SAPEVENT
  CALL METHOD gr_html->get_registered_events
    IMPORTING
      events = lt_events.
  ls_event-eventid    = cl_gui_html_viewer=>m_id_sapevent.
  ls_event-appl_event = ' '.
  READ TABLE lt_events TRANSPORTING NO FIELDS WITH KEY eventid = ls_event-eventid.
  IF sy-subrc <> 0.
    APPEND ls_event TO lt_events.
    gr_html->set_registered_events( lt_events ).
  ENDIF.

  SET HANDLER handle_sapevent FOR gr_html.

*== build HTML code for Button
  CALL METHOD build_html_code
    EXPORTING
      iv_text    = iv_text
      iv_color   = iv_color
      iv_ok_code = iv_ok_code
    CHANGING
      ct_html    = lt_html.

*== load created HTML code into HTML control
  CALL METHOD gr_html->load_data
    IMPORTING
      assigned_url = lv_url
    CHANGING
      data_table   = lt_html.

*== show HTML page
  gr_html->show_url( lv_url ).

ENDMETHOD.


METHOD handle_sapevent.

*== data
  DATA ucomm TYPE syucomm.

*== button active?
  check gv_inactive = space.

*== cast user command
  ucomm = action.
*== set user command
  cl_gui_cfw=>set_new_ok_code( ucomm ).

ENDMETHOD.


METHOD SET_ACTIVE.

  DATA lt_html             TYPE ty_html_table.
  DATA lv_url              TYPE text1000.

*== set flag for handler
  gv_inactive = space.

*== build HTML code for Button
  CALL METHOD build_html_code
    EXPORTING
      iv_text    = gv_text
      iv_color   = gv_color
      iv_ok_code = gv_ok_code
    CHANGING
      ct_html    = lt_html.

*== load created HTML code into HTML control
  CALL METHOD gr_html->load_data
    IMPORTING
      assigned_url = lv_url
    CHANGING
      data_table   = lt_html.

*== show HTML page
  gr_html->show_url( lv_url ).
ENDMETHOD.


METHOD set_inactive.

  DATA lt_html             TYPE ty_html_table.
  DATA lv_url              TYPE text1000.

*== set flag for handler
  gv_inactive = 'X'.

*== build HTML code for Button
  CALL METHOD build_html_code
    EXPORTING
      iv_text    = gv_text
      iv_color   = 'grey'
      iv_ok_code = gv_ok_code
    CHANGING
      ct_html    = lt_html.

*== load created HTML code into HTML control
  CALL METHOD gr_html->load_data
    IMPORTING
      assigned_url = lv_url
    CHANGING
      data_table   = lt_html.

*== show HTML page
  gr_html->show_url( lv_url ).
ENDMETHOD.
ENDCLASS.
