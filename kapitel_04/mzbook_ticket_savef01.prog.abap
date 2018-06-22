*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_SAVEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
FORM save .

  DATA lv_text          TYPE string.
  DATA lv_text_modified TYPE i.

*== save personalization data
  PERFORM personalization_save.

*== check if text has been entered
  CALL METHOD gr_text_ticket->get_textstream
    IMPORTING
      text        = lv_text
      is_modified = lv_text_modified.

*== Erst beim Flush der Automation Queue wird der Text tatsächlich übertragen!
  cl_gui_cfw=>flush( ).

  IF lv_text_modified IS INITIAL AND
     zbook_ticket_dynpro = gs_ticket_dynpro_original.
    MESSAGE s010.
    LEAVE TO TRANSACTION sy-tcode..
  ENDIF.


  IF gs_ticket_dynpro_original-ticket-status <> zbook_ticket_dynpro-ticket-status.
    PERFORM set_status USING zbook_ticket_dynpro-ticket-status.
  ENDIF.

*== get location data
  CALL FUNCTION 'Z_BOOK_LOCATION_GET_DATA'
    IMPORTING
      location = zbook_ticket_dynpro-ticket-location.

*== save ticket
  CALL FUNCTION 'Z_BOOK_TICKET_SAVE'
    EXPORTING
      is_ticket    = zbook_ticket_dynpro-ticket
    IMPORTING
      ev_ticket_nr = zbook_ticket_dynpro-ticket-tiknr.


  IF lv_text IS NOT INITIAL.

    " Text löschen
    gr_text_ticket->delete_text( ).

    " Text an Historie anhängen
    IF gr_hist_cntl IS BOUND.
      gr_hist_cntl->set_ticket_number( zbook_ticket_dynpro-ticket-tiknr ).
      gr_hist_cntl->add_history( iv_history = lv_text ).
      gr_hist_cntl->save( ).
    ENDIF.
  ENDIF.

  IF gr_status_cntl IS BOUND.
    gr_status_cntl->save( ).
  ENDIF.

  IF gr_log IS BOUND.
    gr_log->save( ).
  ENDIF.

  IF gr_var_values IS BOUND.
    gr_var_values->save( zbook_ticket_dynpro-ticket-tiknr ).
  ENDIF.

  IF gr_dyn_attributes IS BOUND.
    gr_dyn_attributes->set_ticket_number( zbook_ticket_dynpro-ticket-tiknr ).
    gr_dyn_attributes->save_ticket_attributes(  ).
  ENDIF.

  IF gr_dyn_data_grid IS BOUND.
    gr_dyn_data_grid->save_data( zbook_ticket_dynpro-ticket-tiknr ).
  ENDIF.

*== send mail
  DATA  lv_subject  TYPE sood-objdes.

  IF zbook_ticket_dynpro-ticket-status = 'CLSD'.
    CONCATENATE 'Ticket ' zbook_ticket_dynpro-ticket-text
     INTO lv_subject SEPARATED BY space.

    CALL METHOD zcl_book_email=>create_mail_form_dark
      EXPORTING
        i_formname = 'ZSFTICKET'
        i_ticket   = zbook_ticket_dynpro-ticket-tiknr
        i_to       = zbook_ticket_dynpro-ticket-owner
        i_commit   = abap_true
        i_subject  = lv_subject.
  ENDIF.

  PERFORM leave.

ENDFORM.                    " SAVE
