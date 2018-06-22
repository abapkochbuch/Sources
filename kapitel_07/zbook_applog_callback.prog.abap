*"---------------------------------------------------------------------*
*" Report  ZBOOK_APPLOG_CALLBACK
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

REPORT zbook_applog_callback.

PARAMETERS
  : p_tiknr   TYPE zbook_ticket_nr      OBLIGATORY
  , p_status  type zbook_ticket_status  OBLIGATORY DEFAULT 'WORK'
  .
DATA
  : gr_log    TYPE REF TO zcl_book_ticket_log
  , gr_dock   TYPE REF TO cl_gui_docking_container
  , gr_msg    TYPE REF TO zcl_book_ticket_log_msg
  , gv_msg    TYPE        string
  , gt_logh   TYPE        bal_t_logh
  .

START-OF-SELECTION.

AT SELECTION-SCREEN.

  gr_log = zcl_book_ticket_log=>get_instance(
                                   iv_tiknr = p_tiknr   ).

  IF gr_dock IS INITIAL.
    CREATE OBJECT gr_dock
      EXPORTING
        side      = gr_dock->dock_at_bottom
        extension = 350.

    gr_log->set_container( gr_dock ).
    gr_log->display( ).
  ENDIF.

  MESSAGE i011(zbook) WITH p_tiknr 'OPEN' p_status
      INTO gv_msg.
  gr_msg = zcl_book_ticket_log_msg=>create_symsg( ).
  gr_msg->add_param(
      iv_parname  = 'TICKET_NR'
      iv_parvalue = p_tiknr ).
  "Callback mit Funktionsbaustein
  gr_msg->add_callback( iv_baluef  = 'Z_BOOK_APPLOG_CB_TICKET_CHANGE' ).
  gr_log->add_msg( ir_msg = gr_msg iv_status = p_status ).
  APPEND gr_log->log_handle TO gt_logh.

  "Anzeige der Meldung
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_t_log_handle = gt_logh.
