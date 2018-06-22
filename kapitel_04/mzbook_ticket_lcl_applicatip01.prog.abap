*&---------------------------------------------------------------------*
*&       Class lcl_application
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS drawer_clicked FOR EVENT clicked
                        OF cl_gui_container_bar
                        IMPORTING id container.
    CLASS-METHODS status_clicked FOR EVENT status_changed
                        OF zcl_book_status_document
                        IMPORTING status.
    CLASS-METHODS on_responsible_click
                        FOR EVENT zresp_click OF zcl_book_team
                        IMPORTING responsible.
    CLASS-METHODS on_team_drop
                        FOR EVENT on_drop OF cl_gui_textedit
                        IMPORTING index line pos dragdrop_object.
ENDCLASS.               "lcl_application

*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD drawer_clicked.
    CASE id.
      WHEN 1.
        CALL METHOD zcl_book_docu=>display
          EXPORTING
            id        = 'RE'
            object    = sy-cprog
            container = container.
      WHEN 2.
        gr_log = zcl_book_ticket_log=>get_instance( zbook_ticket_dynpro-ticket-tiknr   ).
        gr_log->set_container( container ).
        gr_log->display( ).
      WHEN 3.
        IF gr_status_document IS INITIAL.
          CREATE OBJECT gr_status_document
            EXPORTING
              container = container
              status    = zbook_ticket_dynpro-ticket-status.
          SET HANDLER lcl_application=>status_clicked FOR gr_status_document.
        ELSE.
          gr_status_document->set_status( zbook_ticket_dynpro-ticket-status ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "drawer_clicked

  METHOD status_clicked.
    zbook_ticket_dynpro-ticket-status = status.
  ENDMETHOD.                    "status_clicked

  METHOD on_responsible_click.
    zbook_ticket_dynpro-ticket-responsible = responsible.
  ENDMETHOD.                    "on_responsible_click

  METHOD on_team_drop.
    DATA lr_dragdropdata TYPE REF TO zcl_dnd_model_tree.
    DATA ls_items        TYPE treemlitem.
    DATA lt_items        TYPE treemlitab.
    DATA lv_text1        TYPE string.
    DATA lv_text2        TYPE string.
    TRY.
        CREATE OBJECT lr_dragdropdata.
        lr_dragdropdata ?= dragdrop_object->object.
        lt_items = lr_dragdropdata->get_litem_table( ).
        READ TABLE lt_items INTO ls_items INDEX lr_dragdropdata->item_index.
        IF sy-subrc = 0.
          gr_text_ticket->get_textstream( IMPORTING text = lv_text2 ).
          cl_gui_cfw=>flush( ).
          lv_text1 = lv_text2(index).
          SHIFT lv_text2 BY index PLACES LEFT.
          CONCATENATE lv_text1 ls_items-text lv_text2 INTO lv_text1 SEPARATED BY space.
          gr_text_ticket->set_textstream( lv_text1 ).
        ENDIF.
      CATCH cx_sy_move_cast_error.
        dragdrop_object->abort( ).
    ENDTRY.

  ENDMETHOD.                    "on_team_drop

ENDCLASS.                    "lcl_application IMPLEMENTATION
