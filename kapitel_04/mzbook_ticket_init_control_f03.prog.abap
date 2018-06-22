*&---------------------------------------------------------------------*
*&      Form  INIT_CONTROL_FRAMEWORK_RIGHT
*&---------------------------------------------------------------------*
FORM init_control_framework_right.

  DATA l_caption     TYPE sbptcaptn.
  DATA lt_captions   TYPE sbptcaptns.

  CHECK gr_docker_right IS INITIAL.
    CREATE OBJECT gr_docker_right
      EXPORTING
        side      = cl_gui_docking_container=>dock_at_right
        extension = 250
        name      = 'DockerRight'.


    l_caption-caption = 'Dokumentation'.
    l_caption-icon    = icon_personal_help.
    APPEND l_caption TO lt_captions.
    l_caption-caption = 'Meldungen'.
    l_caption-icon    = icon_information.
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

*    CREATE OBJECT gr_appl.
    SET HANDLER lcl_application=>drawer_clicked FOR gr_drawer.
    gr_drawer->set_active( 1 ).




ENDFORM.                    " INIT_CONTROL_FRAMEWORK
