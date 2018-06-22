*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'LOCATION_TEXT_NORTH' OR
       screen-name = 'LOCATION_TEXT_SOUTH'.
      screen-intensified = '1'.
      MODIFY SCREEN.
    ENDIF.

    IF gv_display IS NOT INITIAL.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDMODULE.                 " STATUS_0200  OUTPUT
