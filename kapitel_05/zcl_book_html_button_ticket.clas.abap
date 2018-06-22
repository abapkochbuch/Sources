class ZCL_BOOK_HTML_BUTTON_TICKET definition
  public
  final
  create public .

public section.

  class-methods SAVE .
  class-methods DECLINE .
  class-methods CLOSE .
protected section.

  class-methods BUILD_BUTTON
    importing
      !IV_CC_NAME type CLIKE
      !IV_TEXT type CLIKE
      !IV_COLOR type CLIKE
      !IV_OK_CODE type CLIKE .
private section.
ENDCLASS.



CLASS ZCL_BOOK_HTML_BUTTON_TICKET IMPLEMENTATION.


METHOD build_button.

  DATA lr_button TYPE REF TO zcl_book_html_button.

  CREATE OBJECT lr_button
    EXPORTING
      iv_cc_name = iv_cc_name
      iv_text    = iv_text
      iv_color   = iv_color
      iv_ok_code = iv_ok_code.

ENDMETHOD.


METHOD close.

  CALL METHOD build_button
    EXPORTING
      iv_cc_name = 'CC_BUTTON_CLOSE'
      iv_text    = 'Abschließen'
      iv_color   = '#0d1'
      iv_ok_code = 'CLOSE'.

ENDMETHOD.


METHOD DECLINE.

  CALL METHOD build_button
    EXPORTING
      iv_cc_name = 'CC_BUTTON_DECLINE'
      iv_text    = 'Ablehnen'
      iv_color   = '#f00'
      iv_ok_code = 'DECLINE'.

ENDMETHOD.


METHOD save.

  CALL METHOD build_button
    EXPORTING
      iv_cc_name = 'CC_BUTTON_SAVE'
      iv_text    = 'Sichern'
      iv_color   = '#ff0'
      iv_ok_code = 'SAVE'.

ENDMETHOD.
ENDCLASS.
