FUNCTION CONVERSION_EXIT_ZBPER_OUTPUT.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     VALUE(OUTPUT) TYPE  CLIKE
*"--------------------------------------------------------------------

  DATA lv_uname   TYPE xubname.
  DATA lv_length  TYPE i.
  DATA ls_address TYPE bapiaddr3.
  DATA lt_return  TYPE STANDARD TABLE OF bapiret2.

  lv_uname = input.

  lv_length = STRLEN( lv_uname ).

  IF lv_length > 12.

    output = input.
  ELSE.

    TRANSLATE lv_uname TO UPPER CASE.

    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = lv_uname
      IMPORTING
        address  = ls_address
      TABLES
        return   = lt_return.

    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc > 0.
      CONCATENATE ls_address-firstname ls_address-lastname INTO output SEPARATED BY space.
    ELSE.
      output = input.
    ENDIF.

  ENDIF.


ENDFUNCTION.
