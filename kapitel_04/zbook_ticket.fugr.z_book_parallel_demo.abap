FUNCTION z_book_parallel_demo.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(TIKNR) TYPE  ZBOOK_TICKET_NR
*"     VALUE(DATEINAME) TYPE  STRING
*"     VALUE(P_TASK) TYPE  TW_TASK_LUW_ID OPTIONAL
*"  EXCEPTIONS
*"      FEHLER
*"----------------------------------------------------------------------

  zcl_book_parallel=>set_pid_info(
            funktion = 'Kochbuch Parallel Demo'
            text     = |Upload Datei: { dateiname }| ).


*  MESSAGE e000(oo) WITH 'Fehlertest' RAISING fehler.
  TRY.
  zcl_book_gos=>add_server( i_tiknr = tiknr i_datei = dateiname ).
    CATCH zcx_book_exception.
      MESSAGE e000(oo) WITH 'Fehler bei Upload Datei' dateiname.
  ENDTRY.


ENDFUNCTION.
