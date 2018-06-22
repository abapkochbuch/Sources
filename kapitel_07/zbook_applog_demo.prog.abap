*"---------------------------------------------------------------------*
*" Report  ZBOOK_APPLOG_DEMO
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

REPORT zbook_applog_demo MESSAGE-ID zbook.

PARAMETERS
  : p_tiknr   TYPE zbook_ticket_nr      OBLIGATORY
                                        MATCHCODE OBJECT zbook_ticket
  , p_amodal  TYPE xfeld
  , p_status  TYPE zbook_ticket_status  OBLIGATORY
                                        AS LISTBOX
                                        VISIBLE LENGTH 20
  .
DATA
  : gr_log    TYPE REF TO zcl_book_ticket_log
  , gr_msg    TYPE REF TO zcl_book_ticket_log_msg
  , gv_status TYPE        zbook_ticket_status
  , gv_msg    TYPE        string
  , gr_cont   TYPE REF TO cl_gui_docking_container
  .
*"* Init
INITIALIZATION.

  PERFORM init_status.

*"* Start of program
START-OF-SELECTION.

  SELECT SINGLE status
    FROM  zbook_ticket
    INTO  gv_status
    WHERE tiknr = p_tiknr.
  IF sy-subrc <> 0.
    WRITE: / 'Ticket existiert nicht!'.
    STOP.
  ENDIF.


*== set dummy messages
  DO 3 TIMES.
    MESSAGE i013 WITH sy-index INTO gv_msg.
    gr_msg = zcl_book_ticket_log_msg=>create_symsg( ).
    gr_log = zcl_book_ticket_log=>get_instance( iv_tiknr = p_tiknr   ).
    gr_log->add_msg( ir_msg = gr_msg iv_status = gv_status  ).
  ENDDO.

*== set status change
  MESSAGE i012 WITH p_status INTO gv_msg.
  gr_msg = zcl_book_ticket_log_msg=>create_symsg( ).
  gr_log = zcl_book_ticket_log=>get_instance( iv_tiknr = p_tiknr   ).
  gr_log->add_msg( ir_msg = gr_msg iv_status = p_status  ).

*== save
  gr_log->save( ).
  COMMIT WORK.

  CALL SCREEN 0100.


END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  init_status
*&---------------------------------------------------------------------*
FORM init_status.

  DATA lt_values   TYPE vrm_values.

  SELECT
      domvalue_l  AS key
      ddtext      AS text
    FROM  dd07t
    INTO  CORRESPONDING FIELDS OF TABLE lt_values
    WHERE domname = 'ZBOOK_TICKET_STATUS'
      AND ddlanguage = sy-langu.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_STATUS'
      values = lt_values.
ENDFORM.                    "init_status

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'WURST100'.
  SET TITLEBAR 'SHIT0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE init_0100 OUTPUT.
  IF NOT gr_cont IS BOUND.
    CREATE OBJECT gr_cont
      EXPORTING
        side  = cl_gui_docking_container=>dock_at_top
        ratio = 90.
    zcl_book_ticket_log=>set_container( ir_container = gr_cont ).

    gr_log->display(  ).

  ENDIF.
ENDMODULE.                 " INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF sy-ucomm = 'RAUSHIER'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
