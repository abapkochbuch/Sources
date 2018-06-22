*&---------------------------------------------------------------------*
*&      Form  VAR_VALUES
*&---------------------------------------------------------------------*
FORM var_values .

  CHECK zbook_ticket_dynpro-ticket-area IS NOT INITIAL
    AND zbook_ticket_dynpro-ticket-clas IS NOT INITIAL.


  IF gr_var_values IS INITIAL.
    CREATE OBJECT gr_var_values
      EXPORTING
        tiknr = zbook_ticket_dynpro-ticket-tiknr
        area  = zbook_ticket_dynpro-ticket-area
        clas  = zbook_ticket_dynpro-ticket-clas.

  ENDIF.

  gr_var_values->edit( space ).

ENDFORM.                    " VAR_VALUES
