*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_USER_COMMAND_I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CALL FUNCTION 'Z_BOOK_LOCATION_GET_DATA'
    IMPORTING
      location = zbook_ticket_dynpro-ticket-location.

  PERFORM user_command.

ENDMODULE.                 " USER_COMMAND_0100  INPUT


*&---------------------------------------------------------------------*
*&      Module  DYN_ATTRIBUTES  INPUT
*&---------------------------------------------------------------------*
MODULE dyn_attributes INPUT.

  CHECK gr_dyn_attributes IS BOUND.

  gr_dyn_attributes->set_area_class( iv_area  = zbook_ticket_dynpro-areatik
                                     iv_class = zbook_ticket_dynpro-clastik ).
ENDMODULE.                 " DYN_ATTRIBUTES  INPUT
