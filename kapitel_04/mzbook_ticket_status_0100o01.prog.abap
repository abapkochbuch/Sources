*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_STATUS_0100O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

*  if gv_okcode = 'AREA'.
*    PERFORM get_values_area.
**    PERFORM get_values_clas.
*  endif.



  SET PF-STATUS 'CREATE'." excluding 'VARVALUES'.
  CASE sy-tcode.
    WHEN 'ZTIK' OR 'ZTIK1'.
      SET TITLEBAR 'CREATE'.
    WHEN 'ZTIK2'.
      SET TITLEBAR 'CHANGE' WITH zbook_ticket_dynpro-ticket-tiknr.
    WHEN 'ZTIK3'.
      SET TITLEBAR 'DISPLAY' WITH zbook_ticket_dynpro-ticket-tiknr.
  ENDCASE.
  CLEAR gv_okcode.

  IF sy-dynnr = '1110'. "DEMO
*== DEMO Transaktion ZTIK1X für Beschreibung
    PERFORM init_textarea.
    PERFORM init_html_buttons.
    PERFORM init_control_framework_right.
    PERFORM init_control_framework_left.
  ELSE.
    PERFORM init.
    PERFORM init_controls.
  ENDIF.
  PERFORM init_ticket.

*== PFLEGE SFAW Bildgruppe A100 (TEST) ==*
*  CALL FUNCTION 'FIELD_SELECTION_MODIFY_ALL'
*    EXPORTING
*      DYNPROGRUPPE = sy-dyngr
*      mode      = 'A'
*      modulpool = 'SAPMZBOOK_TICKET'.


  CALL FUNCTION 'Z_BOOK_LOCATION_SET_DATA'
    EXPORTING
      location = zbook_ticket_dynpro-ticket-location.

*== Feldsteuerung
  zcl_book_screen=>init( ).

  zcl_book_screen=>set_field_no_input('ZBOOK_TICKET_DYNPRO-TIKNRTIK').
  zcl_book_screen=>set_field_inactive('ZBOOK_TICKET_DYNPRO-LOCATIONTIK').

  IF zbook_ticket_dynpro-ticket-status = 'CLSD'.
    zcl_book_screen=>set_field_no_input('ZBOOK_TICKET_DYNPRO-STATUSTIK').
*  zcl_book_screen=>set_field_no_input('ZBOOK_TICKET_DYNPRO-RESPONSIBLETIK').
  ENDIF.
*  zcl_book_screen=>set_field_no_input('PB_VARVALUES').

  zcl_book_screen=>activate( ).

  gr_dyn_data_grid->prepare_data(
    tiknr  = zbook_ticket_dynpro-ticket-tiknr
    area   = zbook_ticket_dynpro-ticket-area
    clas   = zbook_ticket_dynpro-ticket-clas ).


ENDMODULE.                 " STATUS_0100  OUTPUT
