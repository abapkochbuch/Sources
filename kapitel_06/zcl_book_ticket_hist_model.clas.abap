class ZCL_BOOK_TICKET_HIST_MODEL definition
  public
  final
  create private .

*"* public components of class ZCL_BOOK_TICKET_HIST_MODEL
*"* do not include other source files here!!!
public section.

  data GV_HISTORY type ZBOOK_TICKET_HISTORY .

  events HISTORY_CHANGED .

  methods CONSTRUCTOR
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR .
  methods GET_HISTORY
    returning
      value(RV_HISTORY) type ZBOOK_TICKET_HISTORY .
  methods ADD_HISTORY
    importing
      !IV_HISTORY type ZBOOK_TICKET_HISTORY
    returning
      value(RV_HISTORY) type ZBOOK_TICKET_HISTORY .
  methods SAVE .
  class-methods GET_INSTANCE
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR
    returning
      value(RR_INST) type ref to ZCL_BOOK_TICKET_HIST_MODEL .
  class-methods SAVE_ALL .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_HIST_MODEL
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_HIST_MODEL
*"* do not include other source files here!!!

  data GV_TIKNR type ZBOOK_TICKET_NR .
  class-data GT_INST type GYT_INST .
ENDCLASS.



CLASS ZCL_BOOK_TICKET_HIST_MODEL IMPLEMENTATION.


METHOD add_history.

  DATA
    : ld_date       TYPE char10
    , ld_time       TYPE char8
    , lv_history    type string
    .
  IF NOT gv_history IS INITIAL.
    " Zeilenumbruch
    CONCATENATE gv_history cl_abap_char_utilities=>cr_lf
      INTO gv_history.
  ENDIF.

  " Historie um neuen Eintrag ergänzen
  CONCATENATE gv_history cl_abap_char_utilities=>cr_lf
    INTO gv_history.
  GET TIME.
  WRITE sy-datum TO ld_date.
  WRITE sy-uzeit TO ld_time.
  CONCATENATE '> Ticket geändert durch' sy-uname 'am' ld_date 'um' ld_time '<' cl_abap_char_utilities=>cr_lf iv_history
    INTO lv_history
    SEPARATED BY space.
  CONCATENATE gv_history lv_history into gv_history.

  rv_history = me->get_history( ).

  " Event auslösen
  RAISE EVENT history_changed.

ENDMETHOD.


METHOD constructor.

  me->gv_tiknr = iv_tiknr.

  SELECT SINGLE history
    FROM zbook_history
    INTO me->gv_history
   WHERE tiknr = me->gv_tiknr.

ENDMETHOD.


METHOD get_history.
  rv_history = me->gv_history.
ENDMETHOD.


METHOD get_instance.
  DATA
    : ls_inst   TYPE gys_inst
    .
  " Prüfen, ob bereits eine Instanz zum Ticket
  "   existiert
  READ TABLE gt_inst INTO ls_inst
    WITH TABLE KEY
      tiknr = iv_tiknr.
  IF sy-subrc <> 0.
    " Nein: Instanz anlegen...
    ls_inst-tiknr = iv_tiknr.
    CREATE OBJECT ls_inst-r_inst
      EXPORTING
        iv_tiknr = iv_tiknr.
    " ...und in die Instanztabelle eintragen.
    INSERT ls_inst INTO TABLE gt_inst.
  ENDIF.

  rr_inst = ls_inst-r_inst.
ENDMETHOD.


METHOD save.

  DATA
    : ls_history  TYPE zbook_history
    .
  ls_history-tiknr = me->gv_tiknr.
  ls_history-history = me->gv_history.
  MODIFY zbook_history FROM ls_history.

ENDMETHOD.


METHOD save_all.

  DATA
    : ls_inst   TYPE gys_inst
    .
  LOOP AT gt_inst INTO ls_inst.
    ls_inst-r_inst->save( ).
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
