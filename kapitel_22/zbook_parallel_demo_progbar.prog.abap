REPORT zbook_parallel_demo_progbar.


*-----------------------------------------------------------*
*       CLASS lcl_upload DEFINITION
*-----------------------------------------------------------*
CLASS lcl_upload DEFINITION.
  PUBLIC SECTION.
    METHODS upload_all IMPORTING directory TYPE string
                                 tiknr     TYPE zbook_ticket_nr.
    INTERFACES zif_book_parallel.
  PRIVATE SECTION.
    DATA mt_files TYPE STANDARD TABLE OF file_info.
    DATA mv_number_of_files TYPE i.
    DATA mv_directory TYPE string.
    DATA mv_tiknr     TYPE zbook_ticket_nr.

    DATA: BEGIN OF ms_progress,
            btn_txt     TYPE c LENGTH 75,
            curval      TYPE n LENGTH 6,
            maxval      TYPE n LENGTH 6,
            stat,
            text_1      TYPE c LENGTH 75,
            text_2      TYPE c LENGTH 6,
            text_3      TYPE c LENGTH 75,
            title       TYPE c LENGTH 75,
            winid       TYPE c LENGTH 4,
            m_typ       TYPE c LENGTH 1,
            popup_event TYPE c LENGTH 10,
            rwnid       TYPE c LENGTH 4.
    DATA: END OF ms_progress.



    METHODS get_files.
    METHODS upload_single IMPORTING file TYPE clike.
    METHODS status_set IMPORTING text TYPE clike.
    METHODS status_close.
ENDCLASS.                    "lcl_upload DEFINITION

*-----------------------------------------------------------*
*       CLASS lcl_upload IMPLEMENTATION
*-----------------------------------------------------------*
CLASS lcl_upload IMPLEMENTATION.
  METHOD get_files.
    CALL METHOD cl_gui_frontend_services=>directory_list_files
      EXPORTING
        directory                   = mv_directory
*       filter                      = '*.*'
        files_only                  = abap_true
        directories_only            = abap_false
      CHANGING
        file_table                  = mt_files
        count                       = mv_number_of_files
      EXCEPTIONS
        cntl_error                  = 1
        directory_list_files_failed = 2
        wrong_parameter             = 3
        error_no_gui                = 4
        not_supported_by_gui        = 5
        OTHERS                      = 6.
  ENDMETHOD.                    "get_files

  METHOD upload_all.
    FIELD-SYMBOLS <file> TYPE file_info.
    mv_directory = directory.
    mv_tiknr = tiknr.
    "Maximale Anzahl zu verwendender Tasks setzen
    zcl_book_parallel=>mv_max_tasks = 4.

    get_files(  ).



    CLEAR ms_progress.

    ms_progress-curval  = '1'.
    ms_progress-maxval  = lines( mt_files ).
    ms_progress-text_1 = 'Hier kann ein (variabler) Text stehen'.
    ms_progress-text_2 = ' '.
    ms_progress-title  = 'Fortschrittsanzeige ( by johu )'.



    LOOP AT mt_files ASSIGNING <file>.
      zcl_book_parallel=>wait_for_free_task( ).
      upload_single( <file>-filename ).
*      zcl_book_gos=>add( tiknr = mv_tiknr datei = CONV string( <file>-filename ) ).
    ENDLOOP.

    WAIT UNTIL zcl_book_parallel=>mv_tasks_started
             = zcl_book_parallel=>mv_tasks_completed.

    status_close( ).

  ENDMETHOD.                    "upload_all

  METHOD upload_single.
    DATA lv_file TYPE string.
    DATA lv_task TYPE c LENGTH 32.
    DATA lv_text TYPE text200.
    CONCATENATE mv_directory '\' file INTO lv_file.

    WRITE: / lv_file.
    lv_task = file.
    status_set( file ).
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
      WRITE: / 'Fehler:', sy-subrc, lv_text.
    ELSE.
      zcl_book_parallel=>task_completed( ).
    ENDIF.
  ENDMETHOD.                    "zif_be_tools_parallel~on_task_complete


  METHOD status_set.

    ADD 1 TO ms_progress-curval.

    ms_progress-text_3 = text.
    CALL FUNCTION 'PROGRESS_POPUP'
      EXPORTING
        btn_txt     = ms_progress-btn_txt
        curval      = ms_progress-curval
        maxval      = ms_progress-maxval
        stat        = ms_progress-stat
        text_1      = ms_progress-text_1
        text_2      = ms_progress-text_2
        text_3      = ms_progress-text_3
        title       = ms_progress-title
        winid       = ms_progress-winid
      IMPORTING
        m_typ       = ms_progress-m_typ
        popup_event = ms_progress-popup_event
        rwnid       = ms_progress-rwnid.

 ms_progress-stat = '3'.

  ENDMETHOD.
  METHOD status_close.

    CALL FUNCTION 'GRAPH_DIALOG'
      EXPORTING
        close = 'X'
        kwdid = ms_progress-winid.


  ENDMETHOD.

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

  DATA demo TYPE REF TO lcl_upload.

  CREATE OBJECT demo.

  demo->upload_all( directory = p_dir
                    tiknr     = p_tiknr ).
