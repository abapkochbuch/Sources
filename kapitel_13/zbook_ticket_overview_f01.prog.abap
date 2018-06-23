*----------------------------------------------------------------------*
***INCLUDE ZBOOK_TICKET_OVERVIEW_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM value_request.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gs_selection-variant
      i_save     = 'A'
    IMPORTING
      es_variant = gs_selection-variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid
          TYPE 'S'
        NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4.
  ELSE.
    p_vari = gs_selection-variant-variant.
  ENDIF.

ENDFORM.                    " VALUE_REQUEST
