*"---------------------------------------------------------------------*
*" Report  ZBOOK_APPLOG_SIMPLE
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

REPORT zbook_applog_simple.

DATA
  : gs_log            TYPE bal_s_log
  , gv_log_handle     TYPE balloghndl

  , gs_msg            TYPE bal_s_msg
  .

START-OF-SELECTION.

  gs_log-extnumber = 'AppLog-Test'.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = gs_log
    IMPORTING
      e_log_handle = gv_log_handle.

  gs_msg-msgty      = 'S'.
  gs_msg-msgid      = '00'.
  gs_msg-msgno      = '002'.
  gs_msg-probclass  = '3'.
  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle = gv_log_handle
      i_s_msg      = gs_msg.

  CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
    EXPORTING
      i_log_handle = gv_log_handle
      i_msgty      = 'S'
      i_text       = 'Frei hinzugefügter Text'.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
