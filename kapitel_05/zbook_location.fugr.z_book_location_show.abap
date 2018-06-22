FUNCTION Z_BOOK_LOCATION_SHOW .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  CHANGING
*"     REFERENCE(LOCATION) TYPE  ZBOOK_LOCATION
*"----------------------------------------------------------------------

  PERFORM location2radio using location.

  CALL SCREEN 100 STARTING AT 3 3.

  IF gv_okcode = 'OKAY'.
    PERFORM radio2location CHANGING location.
  ENDIF.

ENDFUNCTION.
