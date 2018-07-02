class ZCL_BOOK_DYNAMIC_DATA_GRID definition
  public
  final
  create public .

public section.

  data GR_CONTAINER type ref to CL_GUI_CONTAINER .
  data GR_CONT_LOG type ref to CL_GUI_CONTAINER .

  methods CONSTRUCTOR
    importing
      !CONTAINER type ref to CL_GUI_CONTAINER optional
      !CONTAINER_NAME type CLIKE default 'CC_DYN'
      !CONT_LOG_NAME type CLIKE optional
      !CONTAINER_LOG type ref to CL_GUI_CONTAINER optional .
  methods GET_DATA_REFERENCE
    returning
      value(DATA) type ref to DATA .
  methods SET_ATTRIBUTES
    importing
      !AREA type ZBOOK_AREA
      !CLAS type ZBOOK_CLAS .
  methods PREPARE_DATA
    importing
      !TIKNR type ZBOOK_TICKET_NR optional
      !AREA type ZBOOK_AREA
      !CLAS type ZBOOK_CLAS .
  class-methods CONVERT_TABLE_TO_XML
    importing
      !TABLE type STANDARD TABLE
    returning
      value(XML_STRING) type STRING .
  methods GET_XML
    returning
      value(XML_STRING) type STRING .
  methods SAVE_DATA
    importing
      value(TIKNR) type ZBOOK_TICKET_NR .
  methods READ_DATA .
  methods FREE .
protected section.

  data GT_ATTRIBUTES type STANDARD TABLE OF zbook_attr.
  data GD_DYNAMIC_DATA type ref to DATA .
  data GR_GRID type ref to CL_GUI_ALV_GRID .
  data GV_AREA type ZBOOK_AREA .
  data GV_CLAS type ZBOOK_CLAS .
  data GT_FCAT type LVC_T_FCAT .
  data GV_TIKNR type ZBOOK_TICKET_NR .

  methods CREATE_GRID .
  methods HANDLE_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
private section.
ENDCLASS.



CLASS ZCL_BOOK_DYNAMIC_DATA_GRID IMPLEMENTATION.


METHOD constructor.

  IF container IS BOUND.
    gr_container = container.
  ELSE.
    CREATE OBJECT gr_container TYPE cl_gui_custom_container
      EXPORTING
        container_name = container_name.
  ENDIF.

  IF cont_log_name IS NOT INITIAL.
    CREATE OBJECT gr_cont_log TYPE cl_gui_custom_container
      EXPORTING
        container_name = cont_log_name.
  ENDIF.

  SELECT * FROM zbook_attr INTO TABLE gt_attributes.

ENDMETHOD.


METHOD CONVERT_TABLE_TO_XML.

  CALL TRANSFORMATION id SOURCE data = table
                         RESULT XML xml_string.

ENDMETHOD.


METHOD CREATE_GRID.

  DATA ls_layout           TYPE lvc_s_layo.
  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.
  FIELD-SYMBOLS <workarea> TYPE any.
  FIELD-SYMBOLS <fcat>     TYPE lvc_s_fcat.

  ASSIGN gd_dynamic_data->* TO <table>.


  IF gr_grid IS NOT INITIAL.
    gr_grid->free( ).
    CLEAR gr_grid.
  ENDIF.

  CHECK gt_fcat IS NOT INITIAL.

  IF gr_grid IS INITIAL.
*** ALV anbinden
    CREATE OBJECT gr_grid
      EXPORTING
        i_parent       = gr_container
        i_applogparent = gr_cont_log
        i_appl_events  = ' '
      EXCEPTIONS
        others         = 5.

*** Edit-Event extra registrieren
*    gr_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
    gr_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).

*** Edit-Mode aktiv setzen
    gr_grid->set_ready_for_input( 1 ).

*** ...und EventHandler zuweisen
    SET HANDLER handle_data_changed FOR gr_grid.
    SET HANDLER handle_toolbar      FOR gr_grid.

*** First Display
    CALL METHOD gr_grid->set_table_for_first_display
      EXPORTING
        is_layout       = ls_layout
      CHANGING
        it_fieldcatalog = gt_fcat
        it_outtab       = <table>
      EXCEPTIONS
        OTHERS          = 4.
  ELSE.
    gr_grid->set_frontend_fieldcatalog( it_fieldcatalog = gt_fcat ).
    gr_grid->refresh_table_display( ).
  ENDIF.

*** Fokus auf das Grid setzen
  cl_gui_alv_grid=>set_focus( gr_grid ).

ENDMETHOD.


METHOD free.

  gr_grid->parent->free( ).

ENDMETHOD.


METHOD get_data_reference.

  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.
  FIELD-SYMBOLS <workarea> TYPE any.
  DATA lv_valid TYPE c LENGTH 1.

  ASSIGN gd_dynamic_data->* TO <table>.

  gr_grid->check_changed_data( IMPORTING e_valid = lv_valid ).
  IF lv_valid = space.
    MESSAGE e000(oo) WITH 'Fehler!'.
  ELSE.

    LOOP AT <table> ASSIGNING <workarea>.
      IF <workarea> IS INITIAL.
        DELETE <table> INDEX sy-tabix.
      ENDIF.
    ENDLOOP.


    data = gd_dynamic_data.
  ENDIF.

ENDMETHOD.


method GET_XML.

  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.
  ASSIGN gd_dynamic_data->* TO <table>.
  xml_string = convert_table_to_xml( <table> ).

endmethod.


METHOD handle_data_changed.
*
*  DATA: dl_ins_row  TYPE lvc_s_moce.   " Insert Row
*  FIELD-SYMBOLS <t> TYPE table.    " Output table
*  FIELD-SYMBOLS <f> TYPE any.
*  FIELD-SYMBOLS <c> TYPE any.
*
** Loop at the inserted rows table and assign default values
*  LOOP AT er_data_changed->mt_inserted_rows INTO dl_ins_row.
*    ASSIGN er_data_changed->mp_mod_rows->* TO <t>.
*    LOOP AT <t> ASSIGNING <f>.
*      DO.
*        ASSIGN COMPONENT sy-index OF STRUCTURE <f> TO <c>.
*        IF sy-subrc > 0.
*          EXIT.
*        ELSE.
*          <c> = sy-index.
*        ENDIF.
*      ENDDO.
*    ENDLOOP.
*  ENDLOOP.
ENDMETHOD.


METHOD handle_toolbar.

  DATA: ls_toolbar LIKE LINE OF e_object->mt_toolbar.

  LOOP AT e_object->mt_toolbar INTO ls_toolbar.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_append_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_copy.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_copy_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_delete_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_insert_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_move_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_paste.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    CHECK ls_toolbar-function <> cl_gui_alv_grid=>mc_fc_loc_undo.
    DELETE e_object->mt_toolbar INDEX sy-tabix.
  ENDLOOP.

ENDMETHOD.


METHOD PREPARE_DATA.

  FIELD-SYMBOLS <fcat>     TYPE lvc_s_fcat.
  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.

  CHECK gv_area  <> area
     OR gv_clas  <> clas
     or gv_tiknr <> tiknr.

  gv_area  = area.
  gv_clas  = clas.
  gv_tiknr = tiknr.

  FIELD-SYMBOLS <attribute> TYPE zbook_attr.

  CLEAR gt_fcat.

  LOOP AT  gt_attributes ASSIGNING  <attribute>
       WHERE ( area = area AND clas = clas )
          or ( area = area and clas = space ).

*** Feldkatalog der internen Tabelle aufbauen:
    APPEND INITIAL LINE TO gt_fcat ASSIGNING <fcat>.
    <fcat>-fieldname  = <attribute>-fieldname.
    <fcat>-tabname    = '1'.
    <fcat>-ref_field  = <attribute>-fieldname.
    <fcat>-ref_table  = <attribute>-tablename.
    <fcat>-edit       = 'X'.
  ENDLOOP.

  IF gd_dynamic_data IS BOUND.
    ASSIGN gd_dynamic_data->* TO <table>.
    CLEAR <table>.
    CLEAR gd_dynamic_data.
  ENDIF.

  if gt_fcat IS NOT INITIAL.
*** Interne Tabelle aus Feldkatalog generieren
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = gt_fcat
    IMPORTING
      ep_table                  = gd_dynamic_data
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  endif.

  read_data( ).
  create_grid(  ).

ENDMETHOD.


METHOD read_data.

  DATA lv_xml_string TYPE string.
  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.
  ASSIGN gd_dynamic_data->* TO <table>.

  IF gv_tiknr IS NOT INITIAL.

    IMPORT dynamic_data TO lv_xml_string FROM DATABASE indx(z1) ID gv_tiknr.

    IF sy-subrc = 0.
      CALL TRANSFORMATION id SOURCE XML lv_xml_string
                             RESULT data = <table>.
    ENDIF.
  ENDIF.

  IF <table> IS ASSIGNED AND <table> IS INITIAL.
    CLEAR <table>.
    DO 5 TIMES.
      APPEND INITIAL LINE TO <table>.
    ENDDO.
  ENDIF.

  IF gr_grid IS BOUND.
    gr_grid->refresh_table_display( ).
  ENDIF.

ENDMETHOD.


METHOD save_data.

  DATA lv_xml_string    TYPE string.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <warea> TYPE any.

  ASSIGN gd_dynamic_data->* TO <table>.

  gr_grid->check_changed_data( ).

  LOOP AT <table> ASSIGNING <warea>.
    IF <warea> IS INITIAL.
      DELETE <table> INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  CALL TRANSFORMATION id SOURCE data = <table>
                         RESULT XML lv_xml_string.


  EXPORT dynamic_data FROM lv_xml_string
                      TO DATABASE indx(z1) ID tiknr.

ENDMETHOD.


METHOD SET_ATTRIBUTES.

  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.
  DATA lv_fieldname         TYPE string.
  DATA lr_datadescr         TYPE REF TO cl_abap_datadescr.
  DATA lr_structdescr       TYPE REF TO cl_abap_structdescr.
  DATA lr_tabledescr        TYPE REF TO cl_abap_tabledescr.
  DATA lt_dyn_components    TYPE cl_abap_structdescr=>component_table. "Struktur von cl_abap_structdescr=>COMPONENT_TABLE
  DATA ls_dyn_component     LIKE LINE OF lt_dyn_components.

  FIELD-SYMBOLS <dd_table>  TYPE STANDARD TABLE.
  FIELD-SYMBOLS <dd_warea>  TYPE any.

  LOOP AT  gt_attributes ASSIGNING  <attribute>
       WHERE area = area
         AND clas = clas.

    ls_dyn_component-name = <attribute>-attribute_field.

    CONCATENATE <attribute>-attribute_table <attribute>-attribute_field INTO lv_fieldname SEPARATED BY '-'.
    lr_datadescr ?= cl_abap_datadescr=>describe_by_name( lv_fieldname ).
    ls_dyn_component-type       = lr_datadescr.
    ls_dyn_component-as_include = ' '.
    APPEND ls_dyn_component TO lt_dyn_components.

  ENDLOOP.


* Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lr_structdescr = cl_abap_structdescr=>create(  p_components = lt_dyn_components ).
    CATCH cx_sy_struct_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.

* Aus der Strukturbeschreibung eine Tabellenbeschreibung erzeugen und daraus dann eine Referenz auf zugehörige Tabelle
  TRY.
      lr_tabledescr = cl_abap_tabledescr=>create( p_line_type  = lr_structdescr ).
      CREATE DATA gd_dynamic_data TYPE HANDLE lr_tabledescr.
    CATCH cx_sy_table_creation .
      BREAK-POINT.  " Hier sinnvolle Fehlerbehandlung
  ENDTRY.

  ASSIGN gd_dynamic_data->* TO <dd_table>.

  DO 5 TIMES.
    APPEND INITIAL LINE TO <dd_table> ASSIGNING <dd_warea>.
  ENDDO.

*create_grid( ).


ENDMETHOD.
ENDCLASS.
