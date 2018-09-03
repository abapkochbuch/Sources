FUNCTION Z_BOOK_DYN_SELSCR_SET_USED .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_DYN_FIELDS) TYPE  ZBOOK_DYN_SELSCR_FIELDS
*"----------------------------------------------------------------------

* Move input parameters into global function memory
  gs_zbook_dyn_selscr_parameters = is_dyn_fields.


ENDFUNCTION.
