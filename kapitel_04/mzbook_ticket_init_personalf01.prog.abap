*&---------------------------------------------------------------------*
*&      Form  personalization_get
*&---------------------------------------------------------------------*
FORM personalization_get.

  CALL METHOD cl_pers_admin=>get_data
    EXPORTING
      p_pers_key    = 'ZBOOK_TICKET'
    IMPORTING
      p_pers_data   = gs_zbook_pers
    EXCEPTIONS
      OTHERS        = 4.
*  IF sy-subrc > 0 or gs_zbook_pers is INITIAL.
*    CALL METHOD cl_pers_admin=>get_data_role
*      EXPORTING
*        p_pers_key       = 'ZBOOK_TICKET'
*        p_role_name      = 'ZBOOK_TICKETS'
*        p_refresh_buffer = 'X'
*      IMPORTING
*        p_pers_data      = gs_zbook_pers
*      EXCEPTIONS
*        OTHERS           = 6.
*  ENDIF.

ENDFORM.                    " GET_PERSONALIZATION

*&---------------------------------------------------------------------*
*&      Form  personalization_save
*&---------------------------------------------------------------------*
FORM personalization_save .

  DATA lv_size_left  TYPE i.
  DATA lv_size_right TYPE i.
  DATA lv_visible    TYPE c LENGTH 1.

  IF gr_docker_left IS BOUND.
    gr_docker_left->get_visible( IMPORTING visible = lv_visible ).
    cl_gui_cfw=>flush( ).
    IF lv_visible IS NOT INITIAL.
      gr_docker_left->get_width( IMPORTING width = lv_size_left ).
    ELSE.
      lv_size_left = 0.
    ENDIF.
  ENDIF.

  IF gr_docker_right IS BOUND.
    gr_docker_right->get_visible( IMPORTING visible = lv_visible ).
    cl_gui_cfw=>flush( ).
    IF lv_visible IS NOT INITIAL.
      gr_docker_right->get_width( IMPORTING width = lv_size_right ).
    ELSE.
      lv_size_right = 0.
    ENDIF.
  ENDIF.

  IF lv_size_right <> gs_zbook_pers-size_right OR
     lv_size_left  <> gs_zbook_pers-size_left.
    gs_zbook_pers-size_right = lv_size_right.
    gs_zbook_pers-size_left  = lv_size_left.

    CALL METHOD cl_pers_admin=>set_data
      EXPORTING
        p_pers_key  = 'ZBOOK_TICKET'
        p_pers_data = gs_zbook_pers
      EXCEPTIONS
        OTHERS      = 4.
  ENDIF.

ENDFORM.                    "personalization_save

*&---------------------------------------------------------------------*
*&      Form  personalization_dialog
*&---------------------------------------------------------------------*
FORM personalization_dialog.

  cl_pers_admin=>user_dialog(
    EXPORTING
      p_uname                 = sy-uname
      p_pers_key              = 'ZBOOK_TICKET'
      p_check_user            = 'X'
      p_commit                = 'X'
      p_view_mode             = space
    EXCEPTIONS
      user_does_not_exist     = 1
      pers_key_does_not_exist = 2
      access_class_not_found  = 3
      dialog_not_defined      = 4
      dialog_canceled         = 5
      OTHERS                  = 6
         ).
  IF sy-subrc = 0.
    PERFORM personalization_get.
    PERFORM personalization_apply.
  ENDIF.


ENDFORM.                    "personalization_dialog


*&---------------------------------------------------------------------*
*&      Form  personalization_apply
*&---------------------------------------------------------------------*
FORM personalization_apply.

  PERFORM personalization_apply_dock USING gr_docker_right  gs_zbook_pers-size_right.
  PERFORM personalization_apply_dock USING gr_docker_left   gs_zbook_pers-size_left.

ENDFORM.                    "personalization_apply

*&---------------------------------------------------------------------*
*&      Form  personalization_apply_dock
*&---------------------------------------------------------------------*
FORM personalization_apply_dock USING ir_docker TYPE REF TO cl_gui_docking_container
                                      iv_size   TYPE i.

  IF ir_docker IS BOUND.
    IF iv_size IS INITIAL.
      ir_docker->set_visible( space ).
    ELSE.
      ir_docker->set_width( iv_size ).
      ir_docker->set_visible( 'X' ).
    ENDIF.
  ENDIF.

ENDFORM.                    "personalization_apply_dock
