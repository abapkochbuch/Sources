*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  SET PF-STATUS '500'.
  SET TITLEBAR '500'.
  CLEAR gv_okcode.

  if gv_demo is NOT INITIAL.

  loop at screen.

    if  screen-group1 is NOT INITIAL and gv_demo cs screen-group1.
      screen-active = '0'.
      modify screen.
    endif.

  endloop.
endif.

ENDMODULE.                 " STATUS_0500  OUTPUT
