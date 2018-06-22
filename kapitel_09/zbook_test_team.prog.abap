REPORT zbook_test_team.


DATA: gr_custom_cont TYPE REF TO cl_gui_custom_container,
      gr_team_tree   TYPE REF TO zcl_book_team,
      ok_code        TYPE sy-ucomm.

PARAMETERS p_full  RADIOBUTTON GROUP type DEFAULT 'X'.
PARAMETERS p_popup RADIOBUTTON GROUP type.

START-OF-SELECTION.

  IF p_full IS INITIAL.
    CALL SCREEN 0100 STARTING AT  1 2 ENDING AT 50 12.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF p_full IS INITIAL.
    SET PF-STATUS 'STATUS'.
  ELSE.
    SET PF-STATUS 'STATUS_POPUP'.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  OUTPUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE output OUTPUT.
  IF gr_custom_cont IS NOT BOUND.
    CREATE OBJECT gr_custom_cont
      EXPORTING
        container_name = 'CCONT'.
  ENDIF.

  gr_team_tree = zcl_book_team=>get_instance( ir_cont   = gr_custom_cont
                                              id_expand = 'X' ).
ENDMODULE.                 " OUTPUT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
