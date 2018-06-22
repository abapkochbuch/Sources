*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  IF sy-ucomm = 'EXIT'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.


ENDMODULE.                 " USER_COMMAND_0500  INPUT
