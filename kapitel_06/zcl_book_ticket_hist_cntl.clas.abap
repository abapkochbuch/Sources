class ZCL_BOOK_TICKET_HIST_CNTL definition
  public
  final
  create private .

*"* public components of class ZCL_BOOK_TICKET_HIST_CNTL
*"* do not include other source files here!!!
public section.

  data GR_VIEW type ref to CL_GUI_TEXTEDIT .

  methods SAVE .
  methods CONSTRUCTOR .
  methods ADD_HISTORY
    importing
      !IV_HISTORY type ZBOOK_TICKET_HISTORY .
  methods SHOW_HISTORY
    importing
      !IR_CONTAINER type ref to CL_GUI_CONTAINER .
  methods SWITCH_HISTORY .
  class-methods GET_INSTANCE
    returning
      value(RR_INST) type ref to ZCL_BOOK_TICKET_HIST_CNTL .
  methods SET_TICKET_NUMBER
    importing
      !IV_TIKNR type ZBOOK_TICKET_NR .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_HIST_CNTL
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_HIST_CNTL
*"* do not include other source files here!!!

  data GR_CONTAINER type ref to CL_GUI_CONTAINER .
  data GR_MODEL type ref to ZCL_BOOK_TICKET_HIST_MODEL .
  data VISIBLE type CHAR1 value '1' ##NO_TEXT.
  class-data GR_SINGLETON type ref to ZCL_BOOK_TICKET_HIST_CNTL .

  methods CREATE_VIEW .
  methods DESTROY_VIEW .
  methods HNDL_HISTORY_CHANGED
    for event HISTORY_CHANGED of ZCL_BOOK_TICKET_HIST_MODEL .
ENDCLASS.



CLASS ZCL_BOOK_TICKET_HIST_CNTL IMPLEMENTATION.


METHOD add_history.

  IF me->gr_model IS BOUND.
    me->gr_model->add_history( iv_history = iv_history ).
  ENDIF.

ENDMETHOD.


METHOD constructor.

ENDMETHOD.


METHOD create_view.

  " Textview erstellen
  CREATE OBJECT gr_view
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = me->gr_container.

  gr_view->set_comments_string( '>' ).
  gr_View->set_highlight_comments_mode( ).
  gr_View->set_Status_text( 'Historie' ).
  gr_view->set_toolbar_mode( space ). "enno
  gr_view->set_statusbar_mode( space ). "enno

  " Eingabefähigkeit deaktivieren
  CALL METHOD gr_view->set_readonly_mode
    EXPORTING
      readonly_mode = cl_gui_textedit=>true.


  IF gr_model IS BOUND.
    gr_view->set_textstream( text = gr_model->gv_history ).
  ENDIF.


ENDMETHOD.


METHOD destroy_view.

  IF gr_view IS BOUND.
    gr_view->free( ).
  ENDIF.

ENDMETHOD.


METHOD get_instance.

  IF NOT gr_singleton IS BOUND.
    CREATE OBJECT gr_singleton.
  ENDIF.
  rr_inst = gr_singleton.

ENDMETHOD.


  method HNDL_HISTORY_CHANGED.
  endmethod.


METHOD save.
  gr_model->save( ).
ENDMETHOD.


METHOD set_ticket_number.

  IF me->gr_model IS BOUND.
    " Event-Behandler deregistrieren
    SET HANDLER me->hndl_history_changed FOR me->gr_model ACTIVATION space.
  ENDIF.

  me->gr_model = zcl_book_ticket_hist_model=>get_instance( iv_tiknr = iv_tiknr   ).

  " Reaktion auf Änderungen der Historie vorbereiten
  SET HANDLER me->hndl_history_changed FOR me->gr_model.

ENDMETHOD.


METHOD show_history.

  IF NOT ir_container IS BOUND.
    " Übergebener Container zeigt auf nichts
    RETURN.
  ENDIF.
  IF me->gr_container = ir_container.
    " Anzeige der Historie in diesem Container bereits aktiviert
    IF gr_model IS BOUND. "enno
      " evtl. neues Ticket? Textanzeige aktualisieren
      gr_view->set_textstream( text = gr_model->gv_history ). "enno
    ENDIF. "enno

    RETURN.
  ENDIF.

  me->gr_container = ir_container.

  destroy_view( ).

  create_view( ).

ENDMETHOD.


METHOD switch_history.

  CALL METHOD gr_view->get_visible
    IMPORTING
      visible = visible.
  " Der FLUSH der Automation Queue *MUSS* erfolgen, da der
  "   Wert von VISIBLE sonst nicht übertragen wird!
  cl_gui_cfw=>flush( ).

  IF visible = '1'.
    visible = '0'.
  ELSE.
    visible = '1'.
  ENDIF.
  gr_view->set_visible( visible ).

  " Der Container verschwindet nur, falls es sich um einen
  "   Docking Container handelt. Alle anderen Container
  "   werden lediglich leer dargestellt...
  gr_container->set_visible( visible ).

ENDMETHOD.
ENDCLASS.
