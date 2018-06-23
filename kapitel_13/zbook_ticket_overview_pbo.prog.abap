*----------------------------------------------------------------------*
***INCLUDE ZBOOK_TICKET_OVERVIEW_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR  'TITLE100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  OUTPUT  OUTPUT
*&---------------------------------------------------------------------*
MODULE output OUTPUT.

  IF p_docker = abap_true.
    IF gr_custom_cont IS NOT BOUND.
      CREATE OBJECT gr_custom_cont
        EXPORTING
          container_name = 'CCONT'.
    ENDIF.

    IF gr_dock_cont IS NOT BOUND.
      CREATE OBJECT gr_dock_cont
        EXPORTING
          repid     = sy-repid
          dynnr     = '0100'
          side      = cl_gui_docking_container=>dock_at_left
          extension = '370'.
    ENDIF.

    gr_team_tree = zcl_book_team=>get_instance( ir_cont   = gr_dock_cont
                                                id_expand = 'X' ).
  ENDIF.

  gr_book_ticket = zcl_book_ticket_overview=>get_instance( ir_cont      = gr_custom_cont
                                                           is_selection = gs_selection ).

ENDMODULE.                 " OUTPUT  OUTPUT
