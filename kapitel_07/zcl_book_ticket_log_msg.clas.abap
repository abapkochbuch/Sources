class ZCL_BOOK_TICKET_LOG_MSG definition
  public
  final
  create private .

*"* public components of class ZCL_BOOK_TICKET_LOG_MSG
*"* do not include other source files here!!!
public section.

  methods GET_MSG
    returning
      value(RS_MSG) type BAL_S_MSG .
  class-methods CREATE_SYMSG
    returning
      value(RR_MSG) type ref to ZCL_BOOK_TICKET_LOG_MSG .
  methods ADD_CALLBACK
    importing
      !IV_BALUEF type BALUEF
      !IV_IS_FORM type XFELD optional
      !IV_BALUEP type BALUEP optional .
  methods ADD_PARAM
    importing
      !IV_PARNAME type BALPAR
      !IV_PARVALUE type C .
  methods CONSTRUCTOR
    importing
      !IS_MSG type BAL_S_MSG .
  class-methods CREATE_BAPIRET2
    importing
      !IS_MSG type BAPIRET2
    returning
      value(RR_MSG) type ref to ZCL_BOOK_TICKET_LOG_MSG .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_LOG_MSG
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_LOG_MSG
*"* do not include other source files here!!!

  data GS_MSG type BAL_S_MSG .

  methods GET_PROBCLASS .
ENDCLASS.



CLASS ZCL_BOOK_TICKET_LOG_MSG IMPLEMENTATION.


METHOD add_callback.
  me->gs_msg-params-callback-userexitf = iv_baluef.
  IF iv_is_form IS INITIAL.
    me->gs_msg-params-callback-userexitt = 'F'.
  ELSE.
    me->gs_msg-params-callback-userexitp = iv_baluep.
  ENDIF.
ENDMETHOD.


METHOD add_param.
  DATA
    : ls_par  TYPE bal_s_par
    .
  ls_par-parname  = iv_parname.
  ls_par-parvalue = iv_parvalue.

  APPEND ls_par TO me->gs_msg-params-t_par.
ENDMETHOD.


METHOD constructor.
  me->gs_msg = is_msg.
  get_probclass( ).
ENDMETHOD.


METHOD create_bapiret2.
  DATA
    : ls_msg  TYPE bal_s_msg
    .
  ls_msg-msgty = is_msg-type.
  ls_msg-msgid = is_msg-id.
  ls_msg-msgno = is_msg-number.
  ls_msg-msgv1 = is_msg-message_v1.
  ls_msg-msgv2 = is_msg-message_v2.
  ls_msg-msgv3 = is_msg-message_v3.
  ls_msg-msgv4 = is_msg-message_v4.
  CREATE OBJECT rr_msg
    EXPORTING
      is_msg = ls_msg.
ENDMETHOD.


METHOD create_symsg.
  DATA
    : ls_msg  TYPE bal_s_msg
    .
  MOVE-CORRESPONDING sy TO ls_msg.
  CREATE OBJECT rr_msg
    EXPORTING
      is_msg = ls_msg.
ENDMETHOD.


METHOD get_msg.
  rs_msg = me->gs_msg.
ENDMETHOD.


METHOD get_probclass.
  CASE me->gs_msg-msgty.
    WHEN 'S'.
      me->gs_msg-probclass = '4'. " Zusatzinfo
    WHEN 'I'.
      me->gs_msg-probclass = '3'. " Mittel
    WHEN 'W'.
      me->gs_msg-probclass = '2'. " Wichtig
    WHEN 'E' OR 'A' OR 'X'.
      me->gs_msg-probclass = '1'. " Sehr wichtig
  ENDCASE.
ENDMETHOD.
ENDCLASS.
