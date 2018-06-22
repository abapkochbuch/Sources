*"---------------------------------------------------------------------*
*" Report  ZBOOK_TEST_CHANGEDOCU
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

REPORT zbook_test_changedocu.

INCLUDE fzbook_ticketcdt.
INCLUDE fzbook_ticketcdc.

PARAMETERS
  : p_tiknr   TYPE zbook_ticket_nr
  , p_stat    TYPE zbook_ticket_status
  , p_resp    TYPE zbook_person_repsonsible
  , p_change  TYPE xfeld
  , p_disp    TYPE xfeld
  .
DATA
  : gv_chgind TYPE cdhdr-change_ind
  .

START-OF-SELECTION.

  IF p_change = 'X'.
    objectid        = p_tiknr.
    tcode           = 'ZTIK'.
    utime           = sy-uzeit.
    udate           = sy-datum.
    username        = sy-uname.

    SELECT SINGLE *
      FROM  zbook_ticket
      INTO  os_zbook_ticket
      WHERE tiknr = p_tiknr.
    CASE sy-subrc.
      WHEN 0.
        cdoc_upd_object   = 'U'.
        upd_zbook_ticket  = 'U'.
      WHEN OTHERS.
        cdoc_upd_object   = 'I'.
        upd_zbook_ticket  = 'J'.
    ENDCASE.
    MOVE-CORRESPONDING os_zbook_ticket TO ns_zbook_ticket.
    ns_zbook_ticket-tiknr       = p_tiknr.
    ns_zbook_ticket-status      = p_stat.
    ns_zbook_ticket-responsible = p_resp.

    PERFORM cd_call_zbook_ticket.

    COMMIT WORK.
  ENDIF.

  IF p_disp = 'X'.
    PERFORM display.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  display
*&---------------------------------------------------------------------*
FORM display .

  DATA
    : lv_objectid TYPE cdhdr-objectid
    , lt_editpos  TYPE TABLE OF cdred
    , lv_appid    TYPE repid
    .
  lv_objectid = p_tiknr.
  CALL FUNCTION 'CHANGEDOCUMENT_READ'
    EXPORTING
      objectclass = 'ZBOOK_TICKET'
      objectid    = lv_objectid
    TABLES
      editpos     = lt_editpos.
  lv_appid = sy-repid.
  CALL FUNCTION 'CHANGEDOCUMENT_DISPLAY'
    EXPORTING
      i_applicationid  = lv_appid
      flg_autocondense = 'X'
    TABLES
      i_cdred          = lt_editpos.

ENDFORM.                    " DISPLAY
