*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_INIT_CONTROLSF01 .
*----------------------------------------------------------------------*
FORM init_controls.

  IF gr_docker_right IS INITIAL.
    CREATE OBJECT gr_docker_right
      EXPORTING
        repid     = sy-cprog
        dynnr     = sy-dynnr
        side      = cl_gui_docking_container=>dock_at_right
        extension = 250
        name      = 'DockerRight'.
  ENDIF.

  IF gr_docker_left IS INITIAL.
    CREATE OBJECT gr_docker_left
      EXPORTING
        repid     = sy-cprog
        dynnr     = sy-dynnr
        side      = cl_gui_docking_container=>dock_at_left
        extension = 250
        name      = 'DockerLeft'.
  ENDIF.

  PERFORM personalization_apply.

  IF gr_splitter_admin_left IS INITIAL.
    CREATE OBJECT gr_splitter_admin_left
      EXPORTING
        iv_no_of_container = 3
        ir_parent          = gr_docker_left.
    gr_container04 = gr_splitter_admin_left->get_container( 1 ).
    gr_container05 = gr_splitter_admin_left->get_container( 2 ).
    gr_container06 = gr_splitter_admin_left->get_container( 3 ).
    gr_team_tree = zcl_book_team=>get_instance( ir_cont   = gr_container04
                                                id_expand = 'X' ).

    PERFORM init_historie.

    IF gr_dyn_data_grid IS INITIAL.
*== Dynamic-Data-Grid erzeugen
      CREATE OBJECT gr_dyn_data_grid
        EXPORTING
          container = gr_container06.
    ENDIF.
  ENDIF.

  IF NOT gr_gos IS BOUND.
    CREATE OBJECT gr_gos
      EXPORTING
        iv_tiknr = zbook_ticket_dynpro-ticket-tiknr.
  ENDIF.

  PERFORM init_control_drawer_right.


  IF gr_dyn_attributes IS NOT BOUND.
    CREATE OBJECT gr_dyn_attributes
      EXPORTING
        iv_tiknr = zbook_ticket_dynpro-ticket-tiknr.
  ENDIF.


  PERFORM init_button.
  PERFORM init_textarea.

ENDFORM.                    " INIT_CONTROLS

*&---------------------------------------------------------------------*
*&      Form  init_button
*&---------------------------------------------------------------------*
FORM init_button.



  IF gr_button_close IS INITIAL.
    CREATE OBJECT gr_button_close
      EXPORTING
        iv_cc_name = 'CC_BUTTON1'.


    CREATE OBJECT gr_button_decline
      EXPORTING
        iv_cc_name = 'CC_BUTTON2'.

    CREATE OBJECT gr_button_save
      EXPORTING
        iv_cc_name = 'CC_BUTTON3'
        iv_text    = 'SAVE'
        iv_color   = '#ff0'
        iv_ok_code = 'SAVE'.
  ENDIF.

  IF zbook_ticket_dynpro-statustik = 'CLSD'.
    gr_button_close->set_inactive( ).
    gr_button_decline->set_inactive( ).
    gr_button_save->set_inactive( ).
  ELSE.
    gr_button_close->set_active( ).
    gr_button_decline->set_active( ).
    gr_button_save->set_active( ).
  ENDIF.

ENDFORM.                    "init_button

*&---------------------------------------------------------------------*
*&      Form  init_textarea
*&---------------------------------------------------------------------*
FORM init_textarea.

  DATA lr_dragdrop TYPE REF TO cl_dragdrop.

  IF gr_textarea IS INITIAL.
    CREATE OBJECT gr_textarea
      EXPORTING
        container_name = 'CC_TEXTAREA'.

    CREATE OBJECT gr_text_ticket
      EXPORTING
        parent = gr_textarea.
    gr_text_ticket->set_readonly_mode( 0 ).
    gr_text_ticket->set_statusbar_mode( 0 ).
    gr_text_ticket->set_toolbar_mode( 0 ).
    CREATE OBJECT lr_dragdrop.
    CALL METHOD lr_dragdrop->add
      EXPORTING
        flavor     = 'copy'
        dragsrc    = ' '
        droptarget = 'X'
        effect     = cl_dragdrop=>copy.

    gr_text_ticket->set_dragdrop( lr_dragdrop ).
    SET HANDLER lcl_application=>on_team_drop FOR gr_text_ticket.
  ENDIF.

ENDFORM.                    "init_textarea

*&---------------------------------------------------------------------*
*&      Form  init_historie
*&---------------------------------------------------------------------*
FORM init_historie.

  gr_hist_cntl = zcl_book_ticket_hist_cntl=>get_instance( ).
  gr_hist_cntl->set_ticket_number( iv_tiknr = zbook_ticket_dynpro-ticket-tiknr ).
  gr_hist_cntl->show_history( ir_container = gr_container05 ).

ENDFORM.                    "init_historie

*&---------------------------------------------------------------------*
*&      Form  init
*&---------------------------------------------------------------------*
FORM init.

  PERFORM personalization_get.
  PERFORM init_historie.
  PERFORM init_data.

ENDFORM.                    "init

*&---------------------------------------------------------------------*
*&      Form  init_data
*&---------------------------------------------------------------------*
FORM init_data.

  CLEAR gs_ticket_dynpro_original.
  IF gr_text_ticket IS BOUND.
    gr_text_ticket->delete_text( ).
  ENDIF.

ENDFORM.                    "init_data
