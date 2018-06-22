FUNCTION z_book_location_set_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(LOCATION) TYPE  ZBOOK_LOCATION
*"----------------------------------------------------------------------

  PERFORM location2radio USING location.

ENDFUNCTION.
