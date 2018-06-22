*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'ZBOOK_TICKET_DYNPRO-TICKET-LOCATION'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " STATUS_0200  OUTPUT
