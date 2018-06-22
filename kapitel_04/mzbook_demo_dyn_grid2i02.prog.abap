*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'SAVE'.
      IF gr_dd_grid IS BOUND.
        gr_dd_grid->save_data( gs_zbook_ticket-tiknr ).
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0500  INPUT
