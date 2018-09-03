class ZCL_BOOK_HTML_BUTTON3D definition
  public
  create public .

*"* public components of class ZCL_BOOK_HTML_BUTTON3D
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IV_CC_NAME type CLIKE optional
      !IR_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IV_TEXT type CLIKE
      !IV_COLOR type CLIKE
      !IV_OK_CODE type CLIKE .
protected section.
*"* protected components of class ZCL_BOOK_HTML_BUTTON
*"* do not include other source files here!!!

  methods HANDLE_SAPEVENT
    for event SAPEVENT of CL_GUI_HTML_VIEWER
    importing
      !ACTION
      !FRAME
      !GETDATA
      !POSTDATA
      !QUERY_TABLE .
private section.
*"* private components of class ZCL_BOOK_HTML_BUTTON
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_HTML_BUTTON3D IMPLEMENTATION.


METHOD constructor.
*  funktioniert leider nicht dolle. Nachdem der Button gedrückt wurde, erscheint ein blauer Rahmen

  DATA t_events        TYPE cntl_simple_events.
  DATA wa_event        LIKE LINE OF t_events.
  DATA t_html          TYPE STANDARD TABLE OF text1000 WITH NON-UNIQUE DEFAULT KEY.
  DATA html            LIKE LINE OF t_html.
  DATA url             TYPE text1000.
  DATA color           TYPE string.

  DATA lr_custom_container TYPE REF TO cl_gui_custom_container.
  DATA lr_container        TYPE REF TO cl_gui_container.
  DATA lr_html             TYPE REF TO cl_gui_html_viewer.

  IF iv_cc_name <> space.
    CREATE OBJECT lr_custom_container
      EXPORTING
        container_name = iv_cc_name.
    lr_container ?= lr_custom_container.
  ELSE.
    lr_container = ir_container.
  ENDIF.


  CHECK lr_container IS BOUND.

  IF iv_color IS INITIAL.
    color = '#F2E1AF'.
  ELSE.
    color = iv_color.
  ENDIF.


  CREATE OBJECT lr_html
    EXPORTING
      parent = lr_container.

* Register SAPEVENT
  CALL METHOD lr_html->get_registered_events
    IMPORTING
      events     = t_events
    EXCEPTIONS
      cntl_error = 1
      OTHERS     = 2.
  wa_event-eventid    = cl_gui_html_viewer=>m_id_sapevent.
  wa_event-appl_event = ' '.
  READ TABLE t_events TRANSPORTING NO FIELDS WITH KEY eventid = wa_event-eventid.
  IF sy-subrc <> 0.
    APPEND wa_event TO t_events.
  ENDIF.

  lr_html->set_registered_events( t_events ).
  SET HANDLER handle_sapevent FOR lr_html.




  CONCATENATE
'<html><head><style type="text/css">'
'#button {'
*'  border: none;' / outline: none
'  border-width:10px;'
'  border-color:#2b7;'
'  border-style:outset;'
'  background-color:#3c8;'
'  color:#fff;'
'  width: 100%; height: 100%;'
'  font-weight:bold;'
'  font-family:arial;'
'  font-size:20px; }'
'body {overflow:hidden; margin:0; }'
'</style>'
'</head><body>'
'<input id="button" type="button" value="'
iv_text
    '" onclick="location.href=''SAPEVENT:'
    iv_ok_code
    '''"></body></html>'
    INTO html.
  APPEND html TO t_html.



  CALL METHOD lr_html->load_data
    IMPORTING
      assigned_url = url
    CHANGING
      data_table   = t_html.

  lr_html->show_url( url ).

ENDMETHOD.


METHOD HANDLE_SAPEVENT.

  data ucomm type syucomm.
  ucomm = action.
  cl_gui_cfw=>set_new_ok_code( ucomm ).

ENDMETHOD.
ENDCLASS.
