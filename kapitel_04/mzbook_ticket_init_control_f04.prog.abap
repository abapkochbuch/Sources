*&---------------------------------------------------------------------*
*&      Form  INIT_CONTROL_FRAMEWORK_LEFT
*&---------------------------------------------------------------------*
FORM init_control_framework_left .

  CHECK gr_splitadmin_left IS INITIAL.

  CREATE OBJECT gr_docker_left
    EXPORTING
      side      = cl_gui_docking_container=>dock_at_left
      extension = 250
      name      = 'Dockerleft'.

  CREATE OBJECT gr_splitadmin_left
    EXPORTING
      iv_no_of_container = 3
      ir_parent          = gr_docker_left.

  gr_container04 = gr_splitadmin_left->get_container( 1 ).
  gr_container05 = gr_splitadmin_left->get_container( 2 ).
  gr_container06 = gr_splitadmin_left->get_container( 3 ).

  gr_team_tree = zcl_book_team=>get_instance(
          ir_cont   = gr_container04
          id_expand = 'X' ).
  SET HANDLER lcl_application=>on_responsible_click FOR gr_team_tree.

  PERFORM init_historie.

  zcl_book_html_button_info=>display( container = gr_container06 ).


ENDFORM.                    " INIT_CONTROL_FRAMEWORK_LEFT
