FUNCTION Z_BOOK_GET_TICKET_STAT_COUNT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(ET_TICKETS) TYPE  ZBOOK_TICKET_STATUS_COUNT_TAB
*"----------------------------------------------------------------------

  select status count( distinct tiknr ) as anzahl
    into corresponding fields of table et_tickets
    from zbook_ticket
   group by status.

ENDFUNCTION.
