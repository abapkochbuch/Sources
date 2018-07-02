interface ZIF_BOOK_PARALLEL
  public .


  data MV_TASKS_STARTED type I .
  data MV_TASKS_RUNNING type I .
  data MV_TASKS_COMPLETED type I .

  methods ON_TASK_COMPLETE
    importing
      !P_TASK type CLIKE .
endinterface.
