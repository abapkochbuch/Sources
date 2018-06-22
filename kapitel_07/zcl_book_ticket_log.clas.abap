class ZCL_BOOK_TICKET_LOG definition
  public
  final
  create private .

*"* public components of class ZCL_BOOK_TICKET_LOG
*"* do not include other source files here!!!
public section.

  data LOGNR type BALOGNR .
  data LOG_HANDLE type BALLOGHNDL read-only .

  methods CONSTRUCTOR
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR .
  class-methods GET_INSTANCE
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR
    returning
      value(RO_LOG) type ref to ZCL_BOOK_TICKET_LOG .
  methods DISPLAY
    importing
      !IV_AMODAL type XFELD optional .
  methods SAVE .
  methods ADD_MSG
    importing
      !IR_MSG type ref to ZCL_BOOK_TICKET_LOG_MSG
      !IV_STATUS type ZBOOK_TICKET_STATUS .
  class-methods SET_CONTAINER
    importing
      !IR_CONTAINER type ref to CL_GUI_CONTAINER .
  class-methods HNDL_CLOSE
    for event CLOSE of CL_GUI_DIALOGBOX_CONTAINER .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_LOG
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_LOG
*"* do not include other source files here!!!

  data TIKNR type ZBOOK_TICKET_NR .
  class-data T_INST type GYT_INST .
  class-data CONTROL_HANDLE type BALCNTHNDL .
  class-data R_CONTAINER type ref to CL_GUI_CONTAINER .
  data STATUS type ZBOOK_TICKET_STATUS .
  class-data R_POPUP type ref to CL_GUI_DIALOGBOX_CONTAINER .
ENDCLASS.



CLASS ZCL_BOOK_TICKET_LOG IMPLEMENTATION.


METHOD add_msg.
  DATA ls_msg     TYPE bal_s_msg.
  DATA ls_context TYPE zbook_s_bal.

  ls_msg = ir_msg->get_msg( ).

  ls_context-status      = iv_status.
  ls_context-user        = sy-uname.

  ls_msg-context-tabname = 'ZBOOK_S_BAL'.
  ls_msg-context-value   = ls_context.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle = me->log_handle
      i_s_msg      = ls_msg.
ENDMETHOD.


METHOD constructor.
  DATA
    : lt_lognumber  TYPE bal_t_logn
    , lt_log_handle TYPE bal_t_logh

    , ls_lfil       TYPE bal_s_lfil
    , ls_extn       TYPE bal_s_extn
    , ls_obj        TYPE bal_s_obj
    , ls_sub        TYPE bal_s_sub
    , lt_logheader  TYPE balhdr_t
    , ls_logheader  TYPE balhdr

    , ls_log        TYPE bal_s_log
    .
  me->tiknr = iv_tiknr.

  ls_log-object     = 'ZBOOK'.
  ls_log-subobject  = 'ZTICKET'.
  ls_log-extnumber  = me->tiknr.
  ls_extn-sign      = ls_obj-sign   = ls_sub-sign   = 'I'.
  ls_extn-option    = ls_obj-option = ls_sub-option = 'EQ'.
  ls_extn-low       = ls_log-extnumber.
  ls_obj-low        = ls_log-object.
  ls_sub-low        = ls_log-subobject.
  APPEND
    : ls_extn TO ls_lfil-extnumber
    , ls_obj  TO ls_lfil-object
    , ls_sub  TO ls_lfil-subobject
    .
  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter = ls_lfil
    IMPORTING
      e_t_log_header = lt_logheader
    EXCEPTIONS
      log_not_found  = 1. "ENNO

  IF NOT lt_logheader IS INITIAL.
    READ TABLE lt_logheader INTO ls_logheader
      INDEX 1.
    APPEND ls_logheader-lognumber TO lt_lognumber.
    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
        i_t_lognumber  = lt_lognumber
      IMPORTING
        e_t_log_handle = lt_log_handle.
    READ TABLE lt_log_handle INTO me->log_handle INDEX 1.
  ELSE.
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = me->log_handle.
  ENDIF.

  SELECT SINGLE status
    FROM  zbook_ticket
    INTO  me->status
    WHERE tiknr = me->tiknr.
ENDMETHOD.


METHOD display.
  DATA
    : lt_log_handle   TYPE bal_t_logh
    , ls_profile      TYPE bal_s_prof
    , ls_fcat         TYPE bal_s_fcat
    .
  APPEND me->log_handle TO lt_log_handle.

  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      e_s_display_profile = ls_profile.

  ls_profile-no_toolbar = 'X'.
  ls_profile-tree_ontop = 'X'.
  ls_profile-tree_size  = '10'.

  ls_fcat-ref_table = 'BAL_S_SHOW'.
  ls_fcat-ref_field = 'MSG_DATE'. APPEND ls_fcat TO ls_profile-lev1_fcat.

  ls_fcat-ref_table = 'ZBOOK_S_BAL'.
  ls_fcat-ref_field = 'STATUS'.   APPEND ls_fcat TO ls_profile-lev2_fcat.

  ls_fcat-ref_table = 'BAL_S_SHOW'.
  ls_fcat-ref_field = 'MSG_TIME'. APPEND ls_fcat TO ls_profile-lev2_fcat.

  ls_fcat-ref_table = 'BAL_S_SHOW'.
  ls_fcat-ref_field = 'MSG_DATE'. APPEND ls_fcat TO ls_profile-mess_fcat.
  ls_fcat-ref_field = 'MSG_TIME'. APPEND ls_fcat TO ls_profile-mess_fcat.

  ls_fcat-ref_table = 'ZBOOK_S_BAL'.
  ls_fcat-ref_field = 'USER'. APPEND ls_fcat TO ls_profile-mess_fcat.

  IF control_handle IS INITIAL.
    IF r_container IS INITIAL.
      CREATE OBJECT r_popup
        EXPORTING
          width  = 350
          height = 100
          top    = 50
          left   = 50.
      r_container = r_popup.
      SET HANDLER hndl_close FOR r_popup.
    ENDIF.
    CALL FUNCTION 'BAL_CNTL_CREATE'
      EXPORTING
        i_container         = me->r_container
        i_s_display_profile = ls_profile
        i_t_log_handle      = lt_log_handle
      IMPORTING
        e_control_handle    = control_handle.
  ELSE.
    CALL FUNCTION 'BAL_CNTL_REFRESH'
      EXPORTING
        i_control_handle = control_handle
        i_t_log_handle   = lt_log_handle.
  ENDIF.
ENDMETHOD.


METHOD get_instance.
  DATA
    : ls_inst   TYPE gys_inst
    .
  READ TABLE t_inst INTO ls_inst
    WITH TABLE KEY
      tiknr = iv_tiknr.
  IF sy-subrc <> 0.
    CREATE OBJECT ls_inst-o_inst
      EXPORTING
        iv_tiknr = iv_tiknr.
    ls_inst-tiknr = iv_tiknr.
    INSERT ls_inst INTO TABLE t_inst.
  ENDIF.
  ro_log = ls_inst-o_inst.
ENDMETHOD.


METHOD hndl_close.
  r_popup->free( ).
  CLEAR
    : r_popup
    , r_container
    , control_handle
    .
ENDMETHOD.


METHOD save.

  DATA
    : lt_log_handle   TYPE bal_t_logh

    , lt_log_nrs      TYPE bal_t_lgnm
    , ls_log_nrs      TYPE bal_s_lgnm
    .
  APPEND me->log_handle TO lt_log_handle.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_t_log_handle   = lt_log_handle
    IMPORTING
      e_new_lognumbers = lt_log_nrs.
  IF me->lognr IS INITIAL.
    READ TABLE lt_log_nrs INTO ls_log_nrs
      INDEX 1.
    me->lognr = ls_log_nrs-lognumber.
  ENDIF.

ENDMETHOD.


METHOD set_container.
  r_container = ir_container.
ENDMETHOD.
ENDCLASS.
