*"---------------------------------------------------------------------*
*" Report  ZBOOK_TEST_BUTTON
*"---------------------------------------------------------------------*
*"                                                                     *
*"        _____ _   _ _    _ ___________ _   _______ _   _             *
*"       |_   _| \ | | |  | |  ___| ___ \ | / /  ___| \ | |            *
*"         | | |  \| | |  | | |__ | |_/ / |/ /| |__ |  \| |            *
*"         | | | . ` | |/\| |  __||    /|    \|  __|| . ` |            *
*"        _| |_| |\  \  /\  / |___| |\ \| |\  \ |___| |\  |            *
*"        \___/\_| \_/\/  \/\____/\_| \_\_| \_|____/\_| \_/            *
*"                                                                     *
*"                                           einfach anders            *
*"                                                                     *
*"---------------------------------------------------------------------*

REPORT zbook_test_button.

DATA gr_button1 TYPE REF TO zcl_book_html_button.
DATA gr_button2 TYPE REF TO zcl_book_html_button.
DATA gr_button3 TYPE REF TO zcl_book_html_button.
DATA gr_button4 TYPE REF TO zcl_book_html_button.
DATA gr_button5 TYPE REF TO zcl_book_html_button.
DATA gr_button6 TYPE REF TO zcl_book_html_button.
DATA gr_button7 TYPE REF TO zcl_book_html_button.
DATA gr_button8 TYPE REF TO zcl_book_html_button.
DATA gr_cc1     TYPE REF TO cl_gui_custom_container.

*"* Init
INITIALIZATION.

*"* Start of program
START-OF-SELECTION.

  CALL SCREEN 100.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '100'.
*  SET TITLEBAR 'xxx'.
  PERFORM init.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
      MESSAGE s000(oo) WITH 'Button' sy-ucomm.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init.

  CHECK gr_button1 IS INITIAL.

  CREATE OBJECT gr_cc1
    EXPORTING
      container_name = 'BUTTON1'.

  CREATE OBJECT gr_button1
    EXPORTING
*      iv_cc_name = 'BUTTON1'
      ir_container = gr_cc1
      iv_text    = 'Versand'(001)
      iv_color   = '#ff0'
      iv_ok_code = 'SHIPPING'.

  CREATE OBJECT gr_button2
    EXPORTING
      iv_cc_name = 'BUTTON2'
      iv_text    = 'Verwaltung'(002)
      iv_color   = '#AFF'
      iv_ok_code = 'ADMINISTRATION'.

  CREATE OBJECT gr_button3
    EXPORTING
      iv_cc_name = 'BUTTON3'
      iv_text    = 'Produktion 1'(003)
      iv_color   = '#ea0'
      iv_ok_code = 'PRODUCTION1'.

  CREATE OBJECT gr_button4
    EXPORTING
      iv_cc_name = 'BUTTON4'
      iv_text    = 'Produktion 2'(004)
      iv_color   = '#09f'
      iv_ok_code = 'PRODUCTION2'.

  CREATE OBJECT gr_button5
    EXPORTING
      iv_cc_name = 'BUTTON5'
      iv_text    = 'A'
      iv_color   = '#aaa'
      iv_ok_code = 'A'.

  CREATE OBJECT gr_button6
    EXPORTING
      iv_cc_name = 'BUTTON6'
      iv_text    = 'B'
      iv_color   = '#ccc'
      iv_ok_code = 'B'.

  CREATE OBJECT gr_button7
    EXPORTING
      iv_cc_name = 'BUTTON7'
      iv_text    = 'C'
      iv_color   = '#eee'
      iv_ok_code = 'C'.


ENDFORM.                    "init
