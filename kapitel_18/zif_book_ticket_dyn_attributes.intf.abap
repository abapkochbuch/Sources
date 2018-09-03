*"* components of interface ZIF_BOOK_TICKET_DYN_ATTRIBUTES
interface ZIF_BOOK_TICKET_DYN_ATTRIBUTES
  public .


  data GV_TIKNR type ZBOOK_TICKET_NR read-only .

  methods READ_TICKET_ATTRIBUTES .
  methods SAVE_TICKET_ATTRIBUTES .
  methods SET_TICKET_NUMBER
    importing
      !IV_TICKET_NR type ZBOOK_TICKET_NR .
endinterface.
