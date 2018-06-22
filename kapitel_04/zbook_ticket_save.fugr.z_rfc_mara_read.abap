FUNCTION z_rfc_mara_read.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MATNR) LIKE  MARA-MATNR
*"     VALUE(I_SPRACHE) LIKE  MAKT-SPRAS DEFAULT SY-LANGU
*"  EXPORTING
*"     VALUE(E_MAKT) LIKE  MAKT STRUCTURE  MAKT
*"     VALUE(E_MARA) LIKE  MARA STRUCTURE  MARA
*"  EXCEPTIONS
*"      NO_ENTRY
*"----------------------------------------------------------------------

  CALL FUNCTION 'MARA_READ'
    EXPORTING
      i_matnr   = i_matnr
      i_sprache = sy-langu
    IMPORTING
      e_makt    = e_makt
      e_mara    = e_mara
    EXCEPTIONS
      no_entry  = 1
      OTHERS    = 2.

  CASE sy-subrc.
    WHEN 1.
      RAISE no_entry.
  ENDCASE.

ENDFUNCTION.
