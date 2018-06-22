*&---------------------------------------------------------------------*
*&      Form  INIT_TICKET
*&---------------------------------------------------------------------*
FORM init_ticket .

  CASE zbook_ticket_dynpro-ticket-status.

    WHEN space.
      zbook_ticket_dynpro-ticket-status = 'OPEN'.
      CALL FUNCTION 'Z_BOOK_LOCATION_SET_DISPLAY'
        EXPORTING
          display = ' '.
    WHEN 'CLSD'.
      CALL FUNCTION 'Z_BOOK_LOCATION_SET_DISPLAY'
        EXPORTING
          display = 'X'.

    WHEN OTHERS.
      CALL FUNCTION 'Z_BOOK_LOCATION_SET_DISPLAY'
        EXPORTING
          display = ' '.
  ENDCASE.

  IF zbook_ticket_dynpro-ticket-location IS INITIAL.
    zbook_ticket_dynpro-ticket-location = 'HH'.
  ENDIF.

ENDFORM.                    " INIT_TICKET
