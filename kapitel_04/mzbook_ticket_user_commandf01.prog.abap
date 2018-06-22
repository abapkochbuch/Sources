*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_USER_COMMANDF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command .

  CASE gv_okcode.
    WHEN 'VARVALUES'.
      PERFORM var_values.

    WHEN 'BACK' OR 'HOME' OR 'CANCEL'.
      PERFORM leave.

    WHEN 'AREA'.
      CLEAR zbook_ticket_dynpro-ticket-clas.
      PERFORM get_values_area.

    WHEN 'SAVE'.
      PERFORM save.

    WHEN 'CLOSE'.
      PERFORM set_status USING 'CLSD'.
      PERFORM save.

    WHEN 'REJECT'.
      PERFORM set_status USING 'DECL'.
      PERFORM save.

    WHEN 'PERS'.
      PERFORM personalization_dialog.
  ENDCASE.

ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
FORM set_status USING iv_status.

  CHECK gr_log IS BOUND.

  zbook_ticket_dynpro-ticket-status = iv_status.
  IF gr_status_cntl IS BOUND.
    gr_status_cntl->set_status( iv_status ).
  ENDIF.

  DATA lr_msg TYPE REF TO zcl_book_ticket_log_msg.
  DATA lv_msg TYPE string.

  MESSAGE i001 WITH iv_status INTO lv_msg.
  lr_msg = zcl_book_ticket_log_msg=>create_symsg( ).
  gr_log->add_msg( ir_msg = lr_msg iv_status = iv_status ).
  gr_log->display( ).

ENDFORM.                    "set_status

*&---------------------------------------------------------------------*
*&      Form  leave
*&---------------------------------------------------------------------*
FORM leave.

  PERFORM personalization_save.
  IF sy-dynnr = 50.
    SET SCREEN 0. LEAVE SCREEN.
  ELSE.
    CASE sy-tcode.
      WHEN 'ZTIK2' OR
           'ZTIK3'.
        IF sy-calld IS INITIAL.
          SET SCREEN 50.
        ELSE.
          LEAVE PROGRAM.
        ENDIF.
      WHEN OTHERS.
        SET SCREEN 0. LEAVE SCREEN.
    ENDCASE.
  ENDIF.

ENDFORM.                    "leave
