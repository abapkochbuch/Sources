
*----------------------------------------------------------------------*
*       CLASS lcl_appl DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.

  PUBLIC SECTION.
    METHODS: on_click
                FOR EVENT clicked OF cl_gui_container_bar
                IMPORTING id
                          container,
             on_responsible_click
                FOR EVENT zresp_click OF zcl_book_team
                IMPORTING responsible,
             on_status_change
                FOR EVENT status_changed OF zcl_book_ctrl_status
                IMPORTING status.

ENDCLASS.                    "lcl_appl DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_appl IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.

  METHOD on_status_change.

    MESSAGE s000(oo) WITH 'Status geändert von' zbook_ticket_dynpro-ticket-status 'auf' status.
    zbook_ticket_dynpro-ticket-status = status.

  ENDMETHOD.                    "on_status_change


  METHOD on_click.
    DATA: l_fcode     TYPE ui_func,
          l_link      TYPE swd_htmlco,
          l_quickinfo TYPE iconquick.

    CASE id.
*---- "1"
      WHEN 1.
        gr_log = zcl_book_ticket_log=>get_instance( zbook_ticket_dynpro-ticket-tiknr   ).
        gr_log->set_container( container ).
        gr_log->display( ).

*---- "2"
      WHEN 2.

        CALL METHOD zcl_book_docu=>display
          EXPORTING
            id        = 'RE'
            object    = sy-cprog
            container = container.

*---- "3"
      WHEN 3.

        IF gr_status_cntl IS INITIAL.
          CREATE OBJECT gr_status_cntl
            EXPORTING
              container = container
              status    = zbook_ticket_dynpro-ticket-status.
          SET HANDLER gr_appl->on_status_change FOR gr_status_cntl.

        ELSE.
          gr_status_cntl->set_status( zbook_ticket_dynpro-ticket-status ).
          gr_status_cntl->refresh( ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.                    "on_click

  METHOD on_responsible_click.
    zbook_ticket_dynpro-ticket-responsible = responsible.
*    cl_gui_cfw=>set_new_ok_code( 'AREA' ).
*DATA DYNAME     TYPE D020S-PROG.
*DATA DYNUMB     TYPE D020S-DNUM.
    DATA lt_dynpfields TYPE STANDARD TABLE OF dynpread.
    DATA ls_dynpfields TYPE dynpread.

    ls_dynpfields-fieldname  = 'ZBOOK_TICKET_DYNPRO-RESPONSIBLETIK'.
    ls_dynpfields-fieldvalue = responsible.
    APPEND ls_dynpfields TO lt_dynpfields.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_dynpfields
      EXCEPTIONS
        OTHERS     = 8.

  ENDMETHOD.                    "on_responsible_click
ENDCLASS.                    "lcl_appl IMPLEMENTATION
