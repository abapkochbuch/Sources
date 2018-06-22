*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  SET PF-STATUS '0500'.
  SET TITLEBAR '0500'.

  IF gr_dd_grid IS INITIAL.
    CREATE OBJECT gr_dd_grid
      EXPORTING
        container_name = 'CC_DYN'
        cont_log_name  = 'CC_LOG'.
  ENDIF.

  IF gr_dd_single IS INITIAL.
    CREATE OBJECT gr_dd_single.
  ENDIF.


  CASE sy-ucomm.
    WHEN 'AREA'.
      SET CURSOR FIELD 'ZBOOK_TICKET-CLAS'.
      IF gr_dd_grid IS BOUND.
        gr_dd_grid->prepare_data( area = zbook_ticket-area
                                  clas = zbook_ticket-clas ).
      ENDIF.

      IF gr_dd_single IS BOUND.
        gr_dd_single->prepare_data( area = zbook_ticket-area
                                    clas = zbook_ticket-clas ).
      ENDIF.
    WHEN 'CLAS'.
      IF gr_dd_grid IS BOUND.
        gr_dd_grid->prepare_data( area = zbook_ticket-area
                                  clas = zbook_ticket-clas ).
      ENDIF.
      IF gr_dd_single IS BOUND.
        gr_dd_single->prepare_data( area = zbook_ticket-area
                                    clas = zbook_ticket-clas ).
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " STATUS_0500  OUTPUT
