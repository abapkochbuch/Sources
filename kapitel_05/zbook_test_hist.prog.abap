*"---------------------------------------------------------------------*
*" Report  ZBOOK_TEST_HIST
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

REPORT zbook_test_hist.

PARAMETERS
    " Ticketnummer
  : p_ticket  TYPE zbook_ticket_nr OBLIGATORY
  .
DATA
    " Ticketnummer
  : gv_ticket       TYPE        zbook_ticket_nr

    " Änderbarer Text
  , gr_dock_top     TYPE REF TO cl_gui_docking_container
  , gr_text         TYPE REF TO cl_gui_textedit
  , gv_text         TYPE        zbook_ticket_history

    " Container für die Historie
  , gr_dock_right   TYPE REF TO cl_gui_docking_container
  , gr_dialogbox    TYPE REF TO cl_gui_dialogbox_container
  , gr_custom       TYPE REF TO cl_gui_custom_container

    " Historie
  , gr_hist_cntl    TYPE REF TO zcl_book_ticket_hist_cntl
  .
*"* Init
INITIALIZATION.

*"* Start of program
START-OF-SELECTION.

  gv_ticket = p_ticket.

  CALL SCREEN 0100.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STAT0100'.
  SET TITLEBAR 'TIT0100'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE init_0100
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE init_0100 OUTPUT.
  PERFORM init_0100.
ENDMODULE.                                                  "init_0100

*&---------------------------------------------------------------------*
*&      Form  init_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init_0100.

  IF NOT gr_dock_top IS BOUND.
    " Text-Editor für hinzuzufügenden Text
    CREATE OBJECT gr_dock_top
      EXPORTING
        side  = cl_gui_docking_container=>dock_at_top
        ratio = 30.
    CREATE OBJECT gr_text
      EXPORTING
        wordwrap_mode = cl_gui_textedit=>wordwrap_off
        parent        = gr_dock_top.

    " Container für Historienanzeige instanzieren
    CREATE OBJECT gr_dock_right
      EXPORTING
        side  = cl_gui_docking_container=>dock_at_right
        ratio = 30.
    CREATE OBJECT gr_custom
      EXPORTING
        container_name = 'CUSTOM'.
    CREATE OBJECT gr_dialogbox
      EXPORTING
        width   = 600
        height  = 100
        top     = 50
        left    = 50
        caption = 'Ticket Historie'.

    " Historie einschalten
    gr_hist_cntl = zcl_book_ticket_hist_cntl=>get_instance( ).
    gr_hist_cntl->set_ticket_number( iv_tiknr = gv_ticket ).
    gr_hist_cntl->show_history( ir_container = gr_dock_right ).

  ENDIF.
ENDFORM.                                                    "init_0100

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  PERFORM user_command_0100.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM user_command_0100 .

  CASE sy-ucomm.
    WHEN 'TEXT2HIST'.
      " Text aus dem editierbaren Editor auslesen
      gr_text->get_textstream(
        IMPORTING
          text                   = gv_text ).

      " Erst beim Fllush der Automation Queue wird der
      "   Text tatsächlich übertragen!
      cl_gui_cfw=>flush( ).

      " Text löschen
      gr_text->delete_text( ).

      " Text an Historie anhängen
      gr_hist_cntl->add_history( iv_history = gv_text ).

    WHEN 'CUSTOM'.
      " Historie im Custom Container anzeigen
      gr_hist_cntl->show_history( ir_container = gr_custom ).

    WHEN 'DIALOG'.
      " Historie in der Dialogbox anzeigen
      gr_hist_cntl->show_history( ir_container = gr_dialogbox ).

    WHEN 'DOCK'.
      " Historie im Docking Container anzeigen
      gr_hist_cntl->show_history( ir_container = gr_dock_right ).

    WHEN 'ON_OFF'.
      " Historie an-/ausschalten
      gr_hist_cntl->switch_history( ).

    WHEN 'SAVE'.
      " Historie speichern
      gr_hist_cntl->save( ).
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " USER_COMMAND_0100
