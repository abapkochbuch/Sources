*"---------------------------------------------------------------------*
*" Report  ZBOOK_DEMO_SCREEN_MODIF
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

REPORT zbook_demo_screen_modif.

TABLES zbook_ticket_dynpro.

*"* Init
INITIALIZATION.

*"* Start of program
START-OF-SELECTION.
  CALL SCREEN 100.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '0100'.

  zcl_book_screen=>init( ).
  zcl_book_screen=>set_field_no_input('ZBOOK_TICKET_DYNPRO-STATUSTIK').
  zcl_book_screen=>set_field_no_input('ZBOOK_TICKET_DYNPRO-TIKNRTIK').
  zcl_book_screen=>set_group1_no_input('CHG').
  zcl_book_screen=>set_group1_no_input('CRE').
  zcl_book_screen=>activate( ).

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'HOME' OR 'CANCEL'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
      MESSAGE i000(oo) WITH sy-ucomm.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT
