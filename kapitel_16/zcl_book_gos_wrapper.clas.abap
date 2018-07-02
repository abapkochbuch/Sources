class ZCL_BOOK_GOS_WRAPPER definition
  public
  create public .

public section.

  data GR_GOS_MANAGER type ref to CL_GOS_MANAGER .

  methods CONSTRUCTOR
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BOOK_GOS_WRAPPER IMPLEMENTATION.


METHOD constructor.
  DATA
    : ls_object   TYPE borident
    , lt_serv     TYPE tgos_sels
    , ls_serv     TYPE sgos_sels
    .
  ls_object-objtype = 'ZBOOKTICK'.
  ls_object-objkey  = iv_tiknr.
*  ls_serv-sign    = 'I'.
*  ls_serv-option  = 'EQ'.
*  ls_serv-low     = 'PCATTA_CREA'.
*  APPEND ls_serv TO lt_serv.
*  ls_serv-low     = 'PERS_NOTE'.
*  APPEND ls_serv TO lt_serv.
  CREATE OBJECT gr_gos_manager
    EXPORTING
      is_object            = ls_object
      it_service_selection = lt_serv
      ip_no_commit = space.
ENDMETHOD.
ENDCLASS.
