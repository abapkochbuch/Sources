FUNCTION z_book_applog_cb_ticket_change.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_T_PARAMS STRUCTURE  SPAR
*"----------------------------------------------------------------------

  DATA
    : lv_tiknr  TYPE zbook_ticket_nr
    , ls_par    TYPE spar
    .
  READ TABLE i_t_params
    INTO ls_par
    WITH KEY param = 'TICKET_NR'.
  IF sy-subrc = 0.
    lv_tiknr = ls_par-value.
    SET PARAMETER ID 'ZBOOK_TICKET_NR' FIELD lv_tiknr.
    CALL TRANSACTION 'ZTIK2' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFUNCTION.
