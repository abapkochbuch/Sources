*"---------------------------------------------------------------------*
*" Report  ZBOOK_DEMO_CALL_TRANSACTION
*"---------------------------------------------------------------------*

REPORT ZBOOK_DEMO_CALL_TRANSACTION.

PARAMETERS p_ticket type zbook_ticket_nr MEMORY ID zbook_ticket_nr.


*"* Start of program
START-OF-SELECTION.

  set PARAMETER ID 'ZBOOK_TICKET' field p_ticket.
  call TRANSACTION 'ZTIK2' AND SKIP FIRST SCREEN.
