*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_GET_DATAF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT SINGLE * FROM zbook_ticket
    INTO zbook_ticket_dynpro-ticket
   WHERE tiknr = zbook_ticket_dynpro-tiknrtik.
  IF sy-subrc > 0.
    MESSAGE i005 with zbook_ticket_dynpro-ticket-tiknr.
  ELSE.

*== init data
    PERFORM init.
*== inform user
    MESSAGE s006 WITH zbook_ticket_dynpro-tiknrtik.
*== save original state
    gs_ticket_dynpro_original = zbook_ticket_dynpro.
*== Status control
    IF gr_status_cntl IS BOUND.
      gr_status_cntl->set_status( zbook_ticket_dynpro-ticket-status ).
    ENDIF.
*== dynamic attributes
    CLEAR gr_dyn_attributes.
    CREATE OBJECT gr_dyn_attributes
      EXPORTING
        iv_tiknr = zbook_ticket_dynpro-ticket-tiknr.
    CLEAR gr_var_values.
    gs_ticket_dynpro_original = zbook_ticket_dynpro.
  ENDIF.

ENDFORM.                    " GET_DATA
