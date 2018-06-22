FUNCTION z_book_ticket_save.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_TICKET) TYPE  ZBOOK_TICKET
*"  EXPORTING
*"     REFERENCE(EV_TICKET_NR) TYPE  ZBOOK_TICKET_NR
*"----------------------------------------------------------------------

*== local data
  DATA ls_ticket TYPE zbook_ticket.

*== save local copy
  ls_ticket = is_ticket.

  IF ls_ticket-tiknr IS INITIAL.
*== get ticket number
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZBOOK_TIC'
      IMPORTING
        number      = ls_ticket-tiknr
      EXCEPTIONS
        OTHERS      = 8.
*== set creation information
    ls_ticket-ernam = sy-uname.
    ls_ticket-erdat = sy-datum.
    ls_ticket-ertim = sy-uzeit.
*== insert new ticket
    INSERT zbook_ticket FROM ls_ticket.
    MESSAGE s003 WITH ls_ticket-tiknr.
  ELSE.
*== set change information
    ls_ticket-aenam = sy-uname.
    ls_ticket-aedat = sy-datum.
    ls_ticket-aetim = sy-uzeit.
*== update existing ticket
    UPDATE zbook_ticket FROM ls_ticket.
    MESSAGE s004 WITH ls_ticket-tiknr.
  ENDIF.

  ev_ticket_nr = ls_ticket-tiknr.

ENDFUNCTION.
