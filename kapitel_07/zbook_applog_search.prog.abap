*"---------------------------------------------------------------------*
*" Report  ZBOOK_APPLOG_SEARCH
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

REPORT zbook_applog_search.

TABLES
  : balhdr
  .
DATA
  : ls_lfil     TYPE         bal_s_lfil
  , ls_object   LIKE LINE OF ls_lfil-object
  , ls_altcode  LIKE LINE OF ls_lfil-altcode
  , ls_aldate   LIKE LINE OF ls_lfil-aldate
  , lt_balhdr   TYPE         balhdr_t
  .
START-OF-SELECTION.

  ls_object-sign    = 'I'.
  ls_object-option  = 'EQ'.
  ls_object-low     = 'ZBOOK'.
  APPEND ls_object TO ls_lfil-object.
  ls_altcode-sign   = 'I'.
  ls_altcode-option = 'EQ'.
  ls_altcode-low    = 'ZTIK02'.
  APPEND ls_altcode TO ls_lfil-altcode.
  ls_aldate-sign    = 'I'.
  ls_aldate-option  = 'BT'.
  ls_aldate-low     = '20130101'.
  ls_aldate-high    = '20300120'.
  APPEND ls_aldate to ls_lfil-aldate.

  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter = ls_lfil
    IMPORTING
      e_t_log_header = lt_balhdr.
  BREAK-POINT.
