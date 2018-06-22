FUNCTION z_book_location_get_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(LOCATION) TYPE  ZBOOK_LOCATION
*"----------------------------------------------------------------------

  PERFORM radio2location changing location.

ENDFUNCTION.
