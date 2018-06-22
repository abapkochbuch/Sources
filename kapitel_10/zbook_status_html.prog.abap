REPORT zbook_status_html.

*----------------------------------------------------------------------*
*       CLASS lcl_status DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_status DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING cc_name   TYPE clike OPTIONAL
                container TYPE REF TO cl_gui_container OPTIONAL
                status    TYPE zbook_ticket_status OPTIONAL.
    METHODS set_status
      IMPORTING status TYPE clike.
    METHODS get_html EXPORTING html TYPE STANDARD TABLE.
    EVENTS status_changed
      EXPORTING VALUE(status) TYPE zbook_ticket_status.

  PROTECTED SECTION.
    DATA gv_current_status  TYPE zbook_ticket_status.
    DATA gr_doc	            TYPE REF TO cl_dd_document.
    METHODS refresh.
    METHODS add_status2table
      IMPORTING icon TYPE icon_name
                text TYPE clike
                code TYPE clike
                col1 TYPE REF TO cl_dd_area
                col2 TYPE REF TO cl_dd_area.

    METHODS create_dyndoc.
    METHODS handle_links
                  FOR EVENT clicked OF cl_dd_link_element
      IMPORTING sender .


ENDCLASS.                    "lcl_status DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_status IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_status IMPLEMENTATION.

  METHOD constructor.
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

  ENDMETHOD.                    "constructor

  METHOD set_status.
    gv_current_status = status.
    create_dyndoc( ).
    refresh( ).
  ENDMETHOD.                    "set_status

  METHOD refresh.
    gr_doc->display_document( reuse_control = 'X' ) .
  ENDMETHOD.                    "refresh

  METHOD add_status2table.
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
  ENDMETHOD.                    "ADD_STATUS2TABLE

  METHOD create_dyndoc.
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
  ENDMETHOD.                    "CREATE_DYNDOC

  METHOD get_html.
    DATA lv_url TYPE c LENGTH 80.
    DATA lt_html TYPE TABLE OF text1000.
    html = gr_doc->html_table.
*  call method gr_doc->html_control->load_data
*       exporting
*            type         = 'text'
*            subtype      = 'html'
*       importing
*            assigned_url = lv_url
*       changing
*            data_table   = html
*       exceptions
*         others = 1.
  ENDMETHOD.

  METHOD handle_links.

*== set new status
    set_status( sender->name ).
    RAISE EVENT status_changed EXPORTING status = gv_current_status.
  ENDMETHOD.                    "HANDLE_SUBMIT_LINKS

ENDCLASS.                    "lcl_status IMPLEMENTATION

PARAMETERS p_status TYPE zbook_ticket_status DEFAULT 'OPEN'.

*----------------------------------------------------------------------*
*       CLASS lcl_handler DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.

  PUBLIC SECTION.
    METHODS status_clicked
                  FOR EVENT status_changed OF lcl_status
      IMPORTING status.

ENDCLASS.                    "lcl_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_handler IMPLEMENTATION.

  METHOD status_clicked.
    p_status = status.
  ENDMETHOD.                    "status_clicked

ENDCLASS.                    "lcl_handler IMPLEMENTATION


INITIALIZATION.
  DATA lr_dock TYPE REF TO cl_gui_docking_container.
  DATA lr_handler TYPE REF TO lcl_handler.
  DATA lr_status  TYPE REF TO lcl_status.
  CREATE OBJECT lr_dock
    EXPORTING
      side                    = lr_dock->dock_at_left
      extension               = 250
      no_autodef_progid_dynnr = 'X'.

  CREATE OBJECT lr_handler.

  CREATE OBJECT lr_status
    EXPORTING
      status    = p_status
      container = lr_dock.

  SET HANDLER lr_handler->status_clicked FOR lr_status.

  DATA lt_html TYPE TABLE OF text1000.
  lr_status->get_html( IMPORTING html = lt_html ).


AT SELECTION-SCREEN.
  lr_status->set_status( p_status ).
