class ZCL_BOOK_CTRL_STATUS definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_CTRL_STATUS
*"* do not include other source files here!!!
public section.

  events STATUS_CHANGED
    exporting
      value(STATUS) type ZBOOK_TICKET_STATUS .

  methods CONSTRUCTOR
    importing
      !CC_NAME type CLIKE optional
      !CONTAINER type ref to CL_GUI_CONTAINER optional
      !STATUS type ZBOOK_TICKET_STATUS optional .
  methods SAVE .
  methods SET_STATUS
    importing
      !STATUS type ZBOOK_TICKET_STATUS .
  methods REFRESH .
protected section.
*"* protected components of class ZCL_BOOK_CTRL_STATUS
*"* do not include other source files here!!!

  methods ADD_STATUS2TABLE
    importing
      !ICON type ICON_NAME
      !TEXT type CLIKE
      !CODE type CLIKE
      !COL1 type ref to CL_DD_AREA
      !COL2 type ref to CL_DD_AREA .
  methods CREATE_DYNDOC .
  methods HANDLE_SUBMIT_LINKS
    for event CLICKED of CL_DD_LINK_ELEMENT
    importing
      !SENDER .
  methods HANDLE_STATUS_CHANGED .
private section.
*"* private components of class ZCL_BOOK_CTRL_STATUS
*"* do not include other source files here!!!

  data GV_CURRENT_STATUS type ZBOOK_TICKET_STATUS .
  data GR_DOC type ref to CL_DD_DOCUMENT .
  data GV_STATUS type CHAR10 .
ENDCLASS.



CLASS ZCL_BOOK_CTRL_STATUS IMPLEMENTATION.


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

    SET HANDLER handle_submit_links FOR link.

  ENDIF.

ENDMETHOD.


METHOD constructor.

*== data
  DATA lr_container        TYPE REF TO cl_gui_container.
  data lv_cc_name          TYPE SDYDO_VALUE.

  IF cc_name <> space.
*== use given name of custom control
    lv_cc_name = cc_name.
  ELSE.
*== use given container
    lr_container = container.
  ENDIF.

  if status is INITIAL.
    set_status( 'OPEN' ).
  else.
    set_status( status ).
  endif.

  create_dyndoc( ).


*== display documents
  gr_doc->display_document( container = lv_cc_name
                            parent    = lr_container ) .

ENDMETHOD.


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
*  gr_doc->add_text( text = 'STATUS XYZ' ).
*
*  CALL METHOD gr_doc->add_link
*    EXPORTING
*      text = 'Hier klicken um status zu ändern'
*      name = 'STATUS1'
*    IMPORTING
*      link = link.
*
*  SET HANDLER handle_submit_links FOR link.
*
*  CALL METHOD gr_doc->add_icon
*    EXPORTING
*      sap_icon         = 'ICON_OKAY'
*      alternative_text = 'irgendwas'
*      sap_size         = cl_dd_area=>large
*      sap_style        = 'success'.



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


ENDMETHOD.


method HANDLE_STATUS_CHANGED.
endmethod.


METHOD handle_submit_links.

*== data
*  DATA lv_ok_code TYPE syucomm.

*== set new status
  gv_current_status = sender->name.
  create_dyndoc( ).
  refresh( ).

*== inform application
*  CONCATENATE 'STATUS_CHANGE_' gv_current_status INTO lv_ok_code.

  RAISE EVENT status_changed EXPORTING status = gv_current_status.
*  cl_gui_cfw=>set_new_ok_code( lv_ok_code ).

ENDMETHOD.


METHOD refresh.

*== display documents
  gr_doc->display_document( reuse_control = 'X' ) .

ENDMETHOD.


METHOD save.

  IF gv_status <> gv_current_status.



  ENDIF.

ENDMETHOD.


METHOD set_status.

  gv_status         = status.
  gv_current_status = status.

ENDMETHOD.
ENDCLASS.
