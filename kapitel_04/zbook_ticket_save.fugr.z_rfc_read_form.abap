FUNCTION z_rfc_read_form.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(CLIENT) LIKE  SY-MANDT DEFAULT SY-MANDT
*"     VALUE(FORM) LIKE  ITCTA-TDFORM
*"     VALUE(LANGUAGE) LIKE  SY-LANGU DEFAULT SY-LANGU
*"     VALUE(OLANGUAGE) LIKE  SY-LANGU DEFAULT SPACE
*"     VALUE(OSTATUS) LIKE  ITCTA-TDSTATUS DEFAULT SPACE
*"     VALUE(STATUS) LIKE  ITCTA-TDSTATUS DEFAULT SPACE
*"     VALUE(THROUGHCLIENT) TYPE  CHAR01 DEFAULT SPACE
*"     VALUE(READ_ONLY_HEADER) TYPE  CHAR01 DEFAULT SPACE
*"     VALUE(THROUGHLANGUAGE) TYPE  CHAR01 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(FORM_HEADER) LIKE  ITCTA STRUCTURE  ITCTA
*"     VALUE(FOUND) TYPE  CHAR01
*"     VALUE(HEADER) LIKE  THEAD STRUCTURE  THEAD
*"     VALUE(OLANGUAGE) LIKE  SY-LANGU
*"  TABLES
*"      FORM_LINES STRUCTURE  TLINE OPTIONAL
*"      PAGES STRUCTURE  ITCTG OPTIONAL
*"      PAGE_WINDOWS STRUCTURE  ITCTH OPTIONAL
*"      PARAGRAPHS STRUCTURE  ITCDP OPTIONAL
*"      STRINGS STRUCTURE  ITCDS OPTIONAL
*"      TABS STRUCTURE  ITCDQ OPTIONAL
*"      WINDOWS STRUCTURE  ITCTW OPTIONAL
*"----------------------------------------------------------------------


  CALL FUNCTION 'READ_FORM'
    EXPORTING
      client           = sy-mandt
      form             = form
      language         = sy-langu
      olanguage        = olanguage
      ostatus          = ostatus
      status           = status
      throughclient    = throughclient
      read_only_header = read_only_header
      throughlanguage  = throughlanguage
    IMPORTING
      form_header      = form_header
      found            = found
      header           = header
      olanguage        = olanguage
    TABLES
      form_lines       = form_lines
      pages            = pages
      page_windows     = page_windows
      paragraphs       = paragraphs
      strings          = strings
      tabs             = tabs
      windows          = windows.

ENDFUNCTION.
