REPORT zbook_demo_html_button.

DATA gr_button                     TYPE REF TO zcl_book_html_button3d.

*"* Start of program
START-OF-SELECTION.

  CALL SCREEN 100.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STLI' OF PROGRAM 'SAPMSSY0'.

  IF gr_button IS INITIAL.
    CREATE OBJECT gr_button
      EXPORTING
        iv_cc_name = 'BUTTON'
        iv_text    = 'Demo'
        iv_color   = 'greenyellow'
        iv_ok_code = 'DEMO'.
  ENDIF.

  zcl_book_html_button_info=>display( ).

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'DEMO'.
      MESSAGE i000(oo) WITH sy-ucomm '-Button wurde gedrückt'.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
