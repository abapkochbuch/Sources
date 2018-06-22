*&---------------------------------------------------------------------*
*&      Form  INIT_HTML_BUTTONS
*&---------------------------------------------------------------------*
FORM init_html_buttons .

  STATICS created.

  CHECK created IS INITIAL.
  zcl_book_html_button_ticket=>save( ).
  zcl_book_html_button_ticket=>decline( ).
  zcl_book_html_button_ticket=>close( ).
  created = 'X'.

ENDFORM.                    " INIT_HTML_BUTTONS
