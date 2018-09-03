FUNCTION z_book_dyn_selscr_get_param.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_DYN_PARAM_NAME) TYPE  CLIKE
*"  EXPORTING
*"     REFERENCE(EV_DYN_PARAM_VALUE) TYPE  TEXT132
*"  EXCEPTIONS
*"      UNKNOWN_DYN_PARAMETER
*"----------------------------------------------------------------------


  FIELD-SYMBOLS: <fs> TYPE ANY.

  ASSIGN (iv_dyn_param_name) TO <fs>.
  IF <fs> IS NOT ASSIGNED.
    RAISE unknown_dyn_parameter.
  ENDIF.

  ev_dyn_param_value = <fs>.


ENDFUNCTION.
