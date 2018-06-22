*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_USER_COMMAND_I02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0050  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0050 INPUT.

  CASE gv_okcode.
    WHEN 'BACK' OR 'HOME' OR 'ABBR'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN space.
      CALL FUNCTION 'Z_BOOK_LOCATION_SET_DATA'
        EXPORTING
          location = zbook_ticket_dynpro-ticket-location.
      IF gr_drawer IS BOUND.
        gr_drawer->set_active( 1 ).
      ENDIF.
      SET SCREEN 110.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0050  INPUT
