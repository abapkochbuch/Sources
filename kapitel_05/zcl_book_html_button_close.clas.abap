class ZCL_BOOK_HTML_BUTTON_CLOSE definition
  public
  inheriting from ZCL_BOOK_HTML_BUTTON
  final
  create public .

*"* public components of class ZCL_BOOK_HTML_BUTTON_CLOSE
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !IV_CC_NAME type CLIKE optional
      !IR_CONTAINER type ref to CL_GUI_CONTAINER optional .
protected section.
*"* protected components of class ZCL_BOOK_HTML_BUTTON_CLOSE
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_HTML_BUTTON_CLOSE
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_HTML_BUTTON_CLOSE IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
  EXPORTING
    iv_cc_name   = iv_cc_name
    ir_container = ir_container
    IV_TEXT      = 'Abschließen'
    IV_COLOR     = '#0d1'
    IV_OK_CODE   = 'CLOSE'.
endmethod.
ENDCLASS.
