*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'OKAY'.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
