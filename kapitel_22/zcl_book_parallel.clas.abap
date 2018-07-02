class ZCL_BOOK_PARALLEL definition
  public
  final
  create public .

public section.

  class-data MV_TASKS_STARTED type I .
  class-data MV_TASKS_COMPLETED type I .
  class-data MV_TASKS_RUNNING type I .
  class-data MV_MAX_TASKS type I .

  class-methods CLASS_CONSTRUCTOR .
  class-methods SET_PID_INFO
    importing
      !TEXT type CLIKE optional
      !FUNKTION type CLIKE optional .
  class-methods WAIT_FOR_FREE_TASK .
  class-methods TASK_STARTED .
  class-methods TASK_COMPLETED .
protected section.
private section.

  class-data MV_MAX_FREE_TASKS type I .
ENDCLASS.



CLASS ZCL_BOOK_PARALLEL IMPLEMENTATION.


  METHOD class_constructor.

*== Parallelverarbeitung: Prozessinfo init
    CALL FUNCTION 'SPBT_INITIALIZE'
      IMPORTING
        free_pbt_wps = mv_max_free_tasks
      EXCEPTIONS
        OTHERS       = 7.

  ENDMETHOD.


  METHOD set_pid_info.

*== Lokale Daten
    DATA lv_appl_info     TYPE c LENGTH 100.
    DATA lv_appl_info_len TYPE i.

*== Funktions-Info für den Workprozess setzen
    IF funktion IS NOT INITIAL.
      lv_appl_info = 'Dieser Prozess ist ein Kind-Prozess von:'(001).
      CONCATENATE lv_appl_info funktion INTO lv_appl_info SEPARATED BY space.
      lv_appl_info_len = strlen( lv_appl_info ).
      CALL FUNCTION 'TH_SET_APPL_INFO'
        EXPORTING
          appl_info     = lv_appl_info
          appl_info_len = lv_appl_info_len
        EXCEPTIONS
          OTHERS        = 1.
    ENDIF.

    IF text IS NOT INITIAL.
*== spezielle Info setzen
      lv_appl_info     = text.
      lv_appl_info_len = strlen( lv_appl_info ).
      CALL FUNCTION 'TH_SET_APPL_INFO'
        EXPORTING
          appl_info     = lv_appl_info
          appl_info_len = lv_appl_info_len
        EXCEPTIONS
          OTHERS        = 1.
    ENDIF.

  ENDMETHOD.


  METHOD task_completed.

    ADD 1 TO mv_tasks_completed.
    SUBTRACT 1 FROM mv_tasks_running.

  ENDMETHOD.


  METHOD task_started.

    ADD 1 TO mv_tasks_started.
    ADD 1 TO mv_tasks_running.

  ENDMETHOD.


METHOD wait_for_free_task.

*== Lokale Daten
  DATA lv_free_tasks TYPE i.

  DO.

*== Maximale Anzahl Tasks erreicht?
    IF mv_max_tasks > 0.
      IF mv_tasks_running >= mv_max_tasks.
        "Ja, dann warten
        WAIT  FOR ASYNCHRONOUS TASKS UNTIL mv_tasks_running < mv_max_tasks.
        CONTINUE.
      ENDIF.
    ENDIF.

*== Anzahl aktuell freier Dialogprozesse ermitteln
    CALL FUNCTION 'SPBT_GET_CURR_RESOURCE_INFO'
      IMPORTING
        free_pbt_wps = lv_free_tasks
      EXCEPTIONS
        OTHERS       = 3.
    IF sy-subrc = 0 AND lv_free_tasks > 0.
*== Es ist mindestens ein freier Prozess vorhanden
      EXIT. "From Do-Loop
    ELSE.
*== Kein freier Prozess vorhanden: Eine Sekunde warten
*      WAIT UP TO 1 SECONDS.
      WAIT  FOR ASYNCHRONOUS TASKS UNTIL mv_tasks_running < mv_max_tasks.
    ENDIF.
  ENDDO.

ENDMETHOD.
ENDCLASS.
