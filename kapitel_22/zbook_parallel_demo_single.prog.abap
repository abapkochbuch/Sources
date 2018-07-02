REPORT zbook_parallel_demo_single.


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

    CALL METHOD cl_gui_frontend_services=>directory_list_files
      EXPORTING
        directory        = mv_directory
        filter           = '*.*'
        files_only       = abap_true
        directories_only = abap_false
      CHANGING
        file_table       = mt_files
        count            = mv_number_of_files
      EXCEPTIONS
        OTHERS           = 6.

  ENDMETHOD.                    "get_files

  METHOD upload_all.

    FIELD-SYMBOLS <file> TYPE file_info.
    mv_directory = directory.
    mv_tiknr = tiknr.


*== Dateinamen lesen
    get_files(  ).

*== Dateinamen einzeln hochladen
    LOOP AT mt_files ASSIGNING <file>.

      upload_single( <file>-filename ).
    ENDLOOP.


  ENDMETHOD.                    "upload_all

  METHOD upload_single.

    DATA lv_file TYPE string.
    DATA lv_task TYPE c LENGTH 32.
    DATA lv_text TYPE text200.
    CONCATENATE mv_directory '\' file INTO lv_file.

    WRITE: / lv_file.
    lv_task = file.

    get RUN TIME FIELD data(start).

    CALL FUNCTION 'Z_BOOK_PARALLEL_DEMO'
      EXPORTING
        tiknr                 = mv_tiknr
        dateiname             = lv_file
      EXCEPTIONS
*        communication_failure = 1 MESSAGE lv_text
*        system_failure        = 2 MESSAGE lv_text
        ressource_failure     = 3
        OTHERS                = 4.
    IF sy-subrc = 0.
      get run time field data(stopp).
      data(runtime) = stopp - start.
      write: runtime.
    ELSE.
      WRITE: / 'Fehler', lv_task, lv_text.
    ENDIF.
  ENDMETHOD.                    "upload_single

  METHOD zif_book_parallel~on_task_complete.
  ENDMETHOD.                    "zif_be_tools_parallel~on_task_complete

ENDCLASS.                    "lcl_upload IMPLEMENTATION


PARAMETERS p_dir   TYPE string          DEFAULT 'D:\temp\gos'.
PARAMETERS p_tiknr TYPE zbook_ticket_nr DEFAULT '0000000006'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Dateiauswahl'
      initial_folder       = 'D:\'
    CHANGING
      selected_folder      = p_dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

START-OF-SELECTION.

  get run time FIELD data(start).

  DATA demo TYPE REF TO lcl_upload.
  CREATE OBJECT demo.
  demo->upload_all( directory = p_dir
                    tiknr     = p_tiknr ).

  get RUN TIME FIELD data(stopp).

  data(runtime) = stopp - start.
  write: / 'Laufzeit:', runtime.
