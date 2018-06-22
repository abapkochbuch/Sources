*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_INIT_CONTROL_F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_CONTROL_DRAWER_RIGHT
*&---------------------------------------------------------------------*
FORM init_control_drawer_right .

  DATA l_caption     TYPE sbptcaptn.
  DATA lt_captions   TYPE sbptcaptns.

  IF gr_drawer IS INITIAL.
    l_caption-caption = 'Meldungen'.
    l_caption-icon    = icon_information.
    APPEND l_caption TO lt_captions.
    l_caption-caption = 'Dokumentation'.
    l_caption-icon    = icon_personal_help.
    APPEND l_caption TO lt_captions.
    l_caption-caption = 'Status'.
    l_caption-icon    = icon_status_overview.
    APPEND l_caption TO lt_captions.
    CREATE OBJECT gr_drawer
      EXPORTING
        parent                       = gr_docker_right
        captions                     = lt_captions
      EXCEPTIONS
        max_number_of_cells_exceeded = 1
        OTHERS                       = 2.

    CREATE OBJECT gr_appl.
    SET HANDLER gr_appl->on_click FOR gr_drawer.
    gr_drawer->set_active( 1 ).
    set handler gr_appl->on_responsible_click for gr_team_tree.

  ENDIF.


ENDFORM.                    " INIT_CONTROL_DRAWER_RIGHT
