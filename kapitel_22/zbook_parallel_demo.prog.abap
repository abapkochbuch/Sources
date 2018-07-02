REPORT zbook_parallel_demo.

CLASS lcx_parallel DEFINITION INHERITING FROM cx_no_check.

ENDCLASS.
*-----------------------------------------------------------*
*       CLASS lcl_upload DEFINITION
*-----------------------------------------------------------*
CLASS lcl_upload DEFINITION.

  PUBLIC SECTION.
    METHODS upload_all
      IMPORTING directory TYPE string
                tiknr     TYPE zbook_ticket_nr.
    INTERFACES zif_book_parallel.

  PRIVATE SECTION.
    DATA mt_files           TYPE STANDARD TABLE OF file_info.
    DATA mt_server_files    TYPE STANDARD TABLE OF salfldir.
    DATA mv_number_of_files TYPE i.
    DATA mv_directory       TYPE string.
    DATA mv_tiknr           TYPE zbook_ticket_nr.
    METHODS get_files.
    METHODS upload_single
      IMPORTING file TYPE clike.

ENDCLASS.                    "lcl_upload DEFINITION

*-----------------------------------------------------------*
*       CLASS lcl_upload IMPLEMENTATION
*-----------------------------------------------------------*
CLASS lcl_upload IMPLEMENTATION.

  METHOD get_files.


*DATA FILE_TBL TYPE STANDARD TABLE OF SALFLDIR.

    CALL FUNCTION 'RZL_READ_DIR'
      EXPORTING
        name     = mv_directory
      TABLES
        file_tbl = mt_server_files
      EXCEPTIONS
        OTHERS   = 5.

  ENDMETHOD.                    "get_files

  METHOD upload_all.

    FIELD-SYMBOLS <sfile> LIKE LINE OF mt_server_files.
*    FIELD-SYMBOLS <file> TYPE file_info.
    mv_directory = directory.
    mv_tiknr = tiknr.
    "Maximale Anzahl zu verwendender Tasks setzen
    "(Wegen maximaler Anzahl interner Modi bei Upload!)
    zcl_book_parallel=>mv_max_tasks = 3.

*== Dateinamen lesen
    get_files(  ).

    TRY.

*== Dateinamen einzeln hochladen
*    LOOP AT mt_files ASSIGNING <file>.
        LOOP AT mt_server_files ASSIGNING <sfile>.
          CHECK <sfile>-name(1) <> '.'.
          zcl_book_parallel=>wait_for_free_task( ).
          upload_single( <sfile>-name ).
*      upload_single( <file>-filename ).
        ENDLOOP.
*        zcl_book_parallel=>check_error( ).
      CATCH zcx_parallel into data(lx_error).
        data(ftext) = lx_error->get_longtext( ).
        message ftext type 'I'.
    ENDTRY.


**== Warten, bis alle Prozesse (Uploads) erledigt sind
    WAIT UNTIL zcl_book_parallel=>mv_tasks_started
             = zcl_book_parallel=>mv_tasks_completed.

  ENDMETHOD.                    "upload_all

  METHOD upload_single.

    DATA lv_file TYPE string.
    DATA lv_task TYPE c LENGTH 32.
    DATA lv_text TYPE text200.

    IF sy-opsys(3) = 'Win'.
      CONCATENATE mv_directory '\' file INTO lv_file.
    ELSE.
      CONCATENATE mv_directory '/' file INTO lv_file.
    ENDIF.

    WRITE: / lv_file.
    lv_task = file.

    CALL FUNCTION 'Z_BOOK_PARALLEL_DEMO'
      STARTING NEW TASK lv_task
      DESTINATION IN GROUP DEFAULT
      CALLING zif_book_parallel~on_task_complete ON END OF TASK
      EXPORTING
        tiknr                 = mv_tiknr
        dateiname             = lv_file
      EXCEPTIONS
        communication_failure = 1 MESSAGE lv_text
        system_failure        = 2 MESSAGE lv_text
        ressource_failure     = 3
        OTHERS                = 4.
    IF sy-subrc = 0.
      zcl_book_parallel=>task_started( ).
    ELSE.
      WRITE: / 'Fehler', lv_task, lv_text.
    ENDIF.

  ENDMETHOD.                    "upload_single

  METHOD zif_book_parallel~on_task_complete.
    DATA lv_result TYPE boolean.
    DATA lv_text TYPE c LENGTH 80.
*== Ergebnis abholen
    RECEIVE RESULTS FROM FUNCTION 'Z_BOOK_PARALLEL_DEMO'
      IMPORTING
        result = lv_result
      EXCEPTIONS
        communication_failure = 1  MESSAGE lv_text
        system_failure        = 2  MESSAGE lv_text
        OTHERS                = 3.
    IF sy-subrc > 0.
*== oha...
      IF sy-subrc = 3.
        MESSAGE ID sy-msgid
              TYPE sy-msgty
            NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 INTO lv_text.
      ENDIF.
*      zcl_book_parallel=>error( lv_text ).

      zcl_book_parallel=>task_completed( ).
    ELSE.
      zcl_book_parallel=>task_completed( ).
    ENDIF.
  ENDMETHOD.                    "zif_be_tools_parallel~on_task_complete

ENDCLASS.                    "lcl_upload IMPLEMENTATION


PARAMETERS p_dir   TYPE string          DEFAULT '/usr/sap/tmp/gos' LOWER CASE. "'D:\temp\gos'.
PARAMETERS p_tiknr TYPE zbook_ticket_nr DEFAULT '0000000006'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.

START-OF-SELECTION.

  GET RUN TIME FIELD DATA(start).

  DATA demo TYPE REF TO lcl_upload.
  CREATE OBJECT demo.
  demo->upload_all( directory = p_dir
                    tiknr     = p_tiknr ).

  GET RUN TIME FIELD DATA(stopp).

  DATA(runtime) = stopp - start.
  WRITE: / 'Laufzeit:', runtime.
