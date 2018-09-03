FUNCTION Z_BOOK_DYN_SELSCR_SET_PARAM.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_DYN_PARAM_NAME) TYPE  CLIKE
*"     REFERENCE(IV_DYN_PARAM_VALUE) TYPE  TEXT132
*"  EXCEPTIONS
*"      UNKNOWN_DYN_PARAMETER
*"----------------------------------------------------------------------


  FIELD-SYMBOLS: <fs> TYPE ANY.

  ASSIGN (iv_dyn_param_name) TO <fs>.
  IF <fs> IS NOT ASSIGNED.
    RAISE unknown_dyn_parameter.
  ENDIF.

  <fs> = iv_dyn_param_value.


ENDFUNCTION.
