REPORT zbook_parallel_demo_singlserv.


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
    DATA mt_server_files    TYPE STANDARD TABLE OF epsfili.
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

    DATA lv_dir_name      TYPE epsf-epsdirnam.

    lv_dir_name = mv_directory.
    CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
      EXPORTING
        dir_name     = lv_dir_name
      IMPORTING
        file_counter = mv_number_of_files
      TABLES
        dir_list     = mt_server_files
 EXCEPTIONS
       OTHERS       = 8.

  ENDMETHOD.                    "get_files

  METHOD upload_all.

    FIELD-SYMBOLS <sfile> TYPE epsfili.
    mv_directory = directory.
    mv_tiknr = tiknr.
    "Maximale Anzahl zu verwendender Tasks setzen
    "(Wegen maximaler Anzahl interner Modi bei Upload!)
    zcl_book_parallel=>mv_max_tasks = 3.

*== Dateinamen lesen
    get_files(  ).

*== Dateinamen einzeln hochladen
*    LOOP AT mt_files ASSIGNING <file>.
    LOOP AT mt_server_files ASSIGNING <sfile>.
*      zcl_book_parallel=>check_free_task( ).
      upload_single( <sfile>-name ).
    ENDLOOP.

***== Warten, bis alle Prozesse (Uploads) erledigt sind
*    WAIT UNTIL zcl_book_parallel=>mv_tasks_started
*             = zcl_book_parallel=>mv_tasks_completed.

  ENDMETHOD.                    "upload_all

  METHOD upload_single.

    DATA lv_file TYPE string.
    DATA lv_task TYPE c LENGTH 32.
    DATA lv_text TYPE text200.
    CONCATENATE mv_directory '/' file INTO lv_file.

    WRITE: / lv_file.
    lv_task = file.

    CALL FUNCTION 'Z_BOOK_PARALLEL_DEMO'
      EXPORTING
        tiknr                 = mv_tiknr
        dateiname             = lv_file
      EXCEPTIONS
        ressource_failure     = 3
        OTHERS                = 4.
    IF sy-subrc = 0.
      zcl_book_parallel=>task_started( ).
    ELSE.
      WRITE: / 'Fehler', lv_task, lv_text.
    ENDIF.
  ENDMETHOD.                    "upload_single

  METHOD zif_book_parallel~on_task_complete.
  ENDMETHOD.                    "zif_be_tools_parallel~on_task_complete

ENDCLASS.                    "lcl_upload IMPLEMENTATION


PARAMETERS p_dir   TYPE string          DEFAULT '/usr/sap/tmp/gos' LOWER CASE. "'D:\temp\gos'.
PARAMETERS p_tiknr TYPE zbook_ticket_nr DEFAULT '0000000006'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
*  CALL METHOD cl_gui_frontend_services=>directory_browse
*    EXPORTING
*      window_title         = 'Dateiauswahl'
*      initial_folder       = 'D:\'
*    CHANGING
*      selected_folder      = p_dir
*    EXCEPTIONS
*      cntl_error           = 1
*      error_no_gui         = 2
*      not_supported_by_gui = 3
*      OTHERS               = 4.

START-OF-SELECTION.

  GET RUN TIME FIELD DATA(start).

  DATA demo TYPE REF TO lcl_upload.
  CREATE OBJECT demo.
  demo->upload_all( directory = p_dir
                    tiknr     = p_tiknr ).

  GET RUN TIME FIELD DATA(stopp).

  DATA(runtime) = stopp - start.
  WRITE: / 'Laufzeit:', runtime.
