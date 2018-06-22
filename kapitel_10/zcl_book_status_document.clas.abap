class ZCL_BOOK_STATUS_DOCUMENT definition
  public
  create public .

public section.

  events STATUS_CHANGED
    exporting
      value(STATUS) type ZBOOK_TICKET_STATUS .

  methods CONSTRUCTOR
    importing
      !CC_NAME type CLIKE optional
      !CONTAINER type ref to CL_GUI_CONTAINER optional
      !STATUS type ZBOOK_TICKET_STATUS optional .
  methods SET_STATUS
    importing
      !STATUS type CLIKE .
protected section.

  data GV_CURRENT_STATUS type ZBOOK_TICKET_STATUS .
  data GR_DOC type ref to CL_DD_DOCUMENT .

  methods REFRESH .
  methods ADD_STATUS2TABLE
    importing
      !ICON type ICON_NAME
      !TEXT type CLIKE
      !CODE type CLIKE
      !COL1 type ref to CL_DD_AREA
      !COL2 type ref to CL_DD_AREA .
  methods CREATE_DYNDOC .
  methods HANDLE_LINKS
    for event CLICKED of CL_DD_LINK_ELEMENT
    importing
      !SENDER .
private section.
ENDCLASS.



CLASS ZCL_BOOK_STATUS_DOCUMENT IMPLEMENTATION.


method ADD_STATUS2TABLE.

    DATA link TYPE REF TO cl_dd_link_element.

    CALL METHOD col1->add_icon
      EXPORTING
        sap_icon         = icon
        alternative_text = text.
    IF gv_current_status = code.
      col2->add_text( text = text ).
    ELSE.
      CALL METHOD col2->add_link
        EXPORTING
          text = text
          name = code
        IMPORTING
          link = link.

      SET HANDLER handle_links FOR link.

    ENDIF.

endmethod.


method CONSTRUCTOR.

*== data
    DATA lr_container        TYPE REF TO cl_gui_container.
    DATA lv_cc_name          TYPE sdydo_value.

    IF cc_name <> space.
*== use given name of custom control
      lv_cc_name = cc_name.
    ELSE.
*== use given container
      lr_container = container.
    ENDIF.

    IF status IS INITIAL.
      gv_current_status = 'OPEN'.
    ELSE.
      gv_current_status = status.
    ENDIF.

    create_dyndoc( ).
    gr_doc->display_document( container = lv_cc_name
                              parent    = lr_container ) .


endmethod.


method CREATE_DYNDOC.

    DATA text        TYPE        sdydo_text_element.
    DATA link        TYPE REF TO cl_dd_link_element.
    DATA lr_table    TYPE REF TO cl_dd_table_element.
    DATA lr_column_1 TYPE REF TO cl_dd_area.
    DATA lr_column_2 TYPE REF TO cl_dd_area.

    IF gr_doc IS INITIAL.
      CREATE OBJECT gr_doc.
    ELSE.
      gr_doc->initialize_document( ).
    ENDIF.

    CALL METHOD gr_doc->add_text
      EXPORTING
        text      = 'Status aktiviert:'
        sap_style = 'heading'.
    text = gv_current_status.
    CALL METHOD gr_doc->add_text
      EXPORTING
        text      = text
        sap_style = 'heading'.

    gr_doc->new_line( repeat = 1 ).

* set Heading
    text = 'Statusänderungen'.
    CALL METHOD gr_doc->add_text
      EXPORTING
        text      = text
        sap_style = 'heading'.
    gr_doc->new_line( ).

    CALL METHOD gr_doc->add_table
      EXPORTING
        with_heading    = 'X'
        no_of_columns   = 2
        width           = '100%'
        with_a11y_marks = 'X'
        a11y_label      = 'Statustabelle'
      IMPORTING
        table           = lr_table.

* set columns
    CALL METHOD lr_table->add_column
      EXPORTING
        heading = 'Status'
      IMPORTING
        column  = lr_column_1.

    CALL METHOD lr_table->add_column
      EXPORTING
        heading = 'Erklärung'
      IMPORTING
        column  = lr_column_2.



    add_status2table( icon = 'ICON_STATUS_OPEN'
                      text = 'Öffnen'
                      code = 'OPEN'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).
    lr_table->new_row( ).

    add_status2table( icon = 'ICON_COMPLETE'
                      text = 'Abschließen'
                      code = 'CLSD'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).
    lr_table->new_row( ).

    add_status2table( icon = 'ICON_DELETE'
                      text = 'löschen'
                      code = 'DELE'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).

    lr_table->new_row( ).

    add_status2table( icon = 'ICON_PARTNER'
                      text = 'in Arbeit'
                      code = 'WORK'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).

    lr_table->new_row( ).

    add_status2table( icon = 'ICON_CUSTOMER'
                      text = 'Warten auf Anwender'
                      code = 'USER'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).

    lr_table->new_row( ).

    add_status2table( icon = 'ICON_DEFECT'
                      text = 'Zurück gestellt'
                      code = 'HOLD'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).

    lr_table->new_row( ).

    add_status2table( icon = 'ICON_CANCEL'
                      text = 'Ablehnen'
                      code = 'DECL'
                      col1 = lr_column_1
                      col2 = lr_column_2 ).


    gr_doc->merge_document( ).

endmethod.


method HANDLE_LINKS.


*== set new status
    set_status( sender->name ).
    RAISE EVENT status_changed EXPORTING status = gv_current_status.

endmethod.


method REFRESH.

    gr_doc->display_document( reuse_control = 'X' ) .

endmethod.


method SET_STATUS.

    gv_current_status = status.
    create_dyndoc( ).
    refresh( ).

endmethod.
ENDCLASS.
