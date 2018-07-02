FUNCTION Z_BOOK_GET_OPEN_TICKETS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(E_OPEN_TICKETS) TYPE  I
*"----------------------------------------------------------------------
  SELECT COUNT( DISTINCT tiknr ) INTO e_open_tickets
    FROM zbook_ticket
   WHERE status IN
        ('OPEN',  " Offen
         'WORK',  " In Arbeit
         'USER',  " Warten auf Rückmeldung des Anwenders
         'HOLD'). " "Geparkt", Warten auf irgendwas

ENDFUNCTION.
