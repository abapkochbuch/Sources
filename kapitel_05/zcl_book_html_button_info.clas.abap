class ZCL_BOOK_HTML_BUTTON_INFO definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_HTML_BUTTON_INFO
*"* do not include other source files here!!!
public section.

  class-methods DISPLAY
    importing
      !CC_NAME type CLIKE default 'CC_BUTTON_INFO'
      !FUNCTION type CLIKE default 'INFO'
      !CONTAINER type ref to CL_GUI_CONTAINER optional .
protected section.
*"* protected components of class ZCL_BOOK_HTML_BUTTON_INFO
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_HTML_BUTTON_INFO
*"* do not include other source files here!!!

  class-data GR_BUTTON type ref to ZCL_BOOK_HTML_BUTTON .
ENDCLASS.



CLASS ZCL_BOOK_HTML_BUTTON_INFO IMPLEMENTATION.


METHOD display.

  IF gr_button IS INITIAL.
    CREATE OBJECT gr_button
      EXPORTING
        iv_cc_name   = cc_name
        ir_container = container
        iv_text      = 'INFO'
        iv_color     = 'mediumblue'
        iv_ok_code   = 'INFO'.
  ENDIF.

ENDMETHOD.
ENDCLASS.
