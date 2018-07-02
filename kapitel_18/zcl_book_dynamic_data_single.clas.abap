class ZCL_BOOK_DYNAMIC_DATA_SINGLE definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods DISPLAY_DATA .
  methods GET_DATA_REFERENCE_STRUC
    returning
      value(DATA) type ref to DATA .
  methods GET_DATA_REFERENCE_TABLE
    returning
      value(DATA) type ref to DATA .
  methods GET_XML
    returning
      value(XML_STRING) type STRING .
  methods PREPARE_DATA
    importing
      !AREA type ZBOOK_AREA
      !CLAS type ZBOOK_CLAS .
  methods PREPARE_STRUC
    importing
      !STRUC type CLIKE .
  methods GET_DATA_STRUC
    exporting
      value(STRUC) type ANY .
protected section.

  data GD_DYNAMIC_DATA type ref to DATA .
  data GD_DYNAMIC_STRUC type ref to DATA .
  data GT_ATTRIBUTES type ZBOOK_CLASS_ATTR_TT .
  data GV_AREA type ZBOOK_AREA .
  data GV_CLAS type ZBOOK_CLAS .
  data GV_DATA01 type TEXT40 .
  data GV_DATA02 type TEXT40 .
  data GV_DATA03 type TEXT40 .
  data GV_DATA04 type TEXT40 .
  data GV_DATA05 type TEXT40 .
  data GV_TYPE01 type TEXT80 .
  data GV_TYPE02 type TEXT80 .
  data GV_TYPE03 type TEXT80 .
  data GV_TYPE04 type TEXT80 .
  data GV_TYPE05 type TEXT80 .
  data GD_STRUC type ref to DATA .

  methods CONVERT_DATA_TO_TABLE .
  methods CONVERT_TABLE_TO_XML
    importing
      !TABLE type STANDARD TABLE
    returning
      value(XML_STRING) type STRING .
  methods IMPORT_DATA .
private section.
ENDCLASS.



CLASS ZCL_BOOK_DYNAMIC_DATA_SINGLE IMPLEMENTATION.


METHOD CONSTRUCTOR.

  SELECT * FROM zbook_class_attr INTO TABLE gt_attributes.

ENDMETHOD.


METHOD convert_data_to_table.

  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.
  DATA lv_fieldname         TYPE string.
  DATA lr_datadescr         TYPE REF TO cl_abap_datadescr.
  DATA lr_structdescr       TYPE REF TO cl_abap_structdescr.
  DATA lr_tabledescr        TYPE REF TO cl_abap_tabledescr.
  DATA lt_dyn_components    TYPE cl_abap_structdescr=>component_table. "Struktur von cl_abap_structdescr=>COMPONENT_TABLE
  DATA ls_dyn_component     LIKE LINE OF lt_dyn_components.
  FIELD-SYMBOLS <dd_table>  TYPE STANDARD TABLE.
  FIELD-SYMBOLS <dd_warea>  TYPE any.

  FIELD-SYMBOLS <dd_value>  TYPE any.
  FIELD-SYMBOLS <data>      TYPE any.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_pname             TYPE c LENGTH 80.

  DATA lv_xml_string        TYPE string.

  LOOP AT  gt_attributes ASSIGNING  <attribute>.

    ls_dyn_component-name = <attribute>-attribute_field.

    CONCATENATE <attribute>-attribute_table <attribute>-attribute_field INTO lv_fieldname SEPARATED BY '-'.
    lr_datadescr ?= cl_abap_datadescr=>describe_by_name( lv_fieldname ).
    ls_dyn_component-type       = lr_datadescr.
    ls_dyn_component-as_include = ' '.
    ls_dyn_component-name       = <attribute>-attribute_field.
    APPEND ls_dyn_component TO lt_dyn_components.

  ENDLOOP.


* Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lr_structdescr = cl_abap_structdescr=>create(  p_components = lt_dyn_components ).
      CREATE DATA gd_dynamic_struc TYPE HANDLE lr_structdescr.
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

  ASSIGN gd_dynamic_data->*  TO <dd_table>.
  ASSIGN gd_dynamic_struc->* TO <dd_warea>.


*  APPEND INITIAL LINE TO <dd_table> ASSIGNING <dd_warea>.
  DO.
    lv_count = sy-index.
    ASSIGN  COMPONENT sy-index OF STRUCTURE <dd_warea> TO <dd_value>.
    IF sy-subrc = 0.
      CONCATENATE 'GV_DATA' lv_count INTO lv_pname.
      ASSIGN (lv_pname) TO <data>.
      IF sy-subrc = 0.
        <dd_value> = <data>.
      ENDIF.
    ELSE.
      EXIT. "from do
    ENDIF.
  ENDDO.

  APPEND <dd_warea> TO <dd_table>.

ENDMETHOD.


METHOD CONVERT_TABLE_TO_XML.

  CALL TRANSFORMATION id SOURCE data = table
                         RESULT XML xml_string.

ENDMETHOD.


METHOD DISPLAY_DATA.

  CHECK gv_type01 IS NOT INITIAL.

  SUBMIT zbook_demo_dyn_data
          WITH p_data01 = gv_data01
          WITH p_data02 = gv_data02
          WITH p_data03 = gv_data03
          WITH p_data04 = gv_data04
          WITH p_data05 = gv_data05
          WITH p_type01 = gv_type01
          WITH p_type02 = gv_type02
          WITH p_type03 = gv_type03
          WITH p_type04 = gv_type04
          WITH p_type05 = gv_type05
           AND RETURN.

  import_data( ).

ENDMETHOD.


METHOD GET_DATA_REFERENCE_STRUC.

  data = gd_dynamic_struc.

ENDMETHOD.


METHOD GET_DATA_REFERENCE_TABLE.

  data = gd_dynamic_data.

ENDMETHOD.


METHOD get_data_struc.



  FIELD-SYMBOLS <data> TYPE any.
  FIELD-SYMBOLS <field> TYPE any.
  FIELD-SYMBOLS <struc> type any.

  DATA lv_count     TYPE n LENGTH 2.
  DATA lv_pname     TYPE c LENGTH 80.


*  ASSIGN gd_struc->* to <struc>.
*
*  DO 5 TIMES.
*    lv_count = sy-index.
*    CONCATENATE 'GV_DATA' lv_count INTO lv_pname.
*    ASSIGN (lv_pname) TO <data>.
*    ASSIGN COMPONENT lv_count OF STRUCTURE <struc> TO <field>.
*    IF sy-subrc = 0.
*      <field> = <data>.
*    ENDIF.
*  ENDDO.
*
*  struc = <struc>.



*  ASSIGN gd_dynamic_struc->* TO <struc>.
*  IF sy-subrc = 0.
*    struc = <struc>.
*  ENDIF.

ENDMETHOD.


METHOD GET_XML.

  FIELD-SYMBOLS <table>    TYPE STANDARD TABLE.
  ASSIGN gd_dynamic_data->* TO <table>.

  convert_data_to_table( ).
  convert_table_to_xml( <table> ).

  xml_string = convert_table_to_xml( <table> ).

ENDMETHOD.


METHOD IMPORT_DATA.

  TYPES: BEGIN OF ty_param,
           field TYPE c LENGTH 80,
           value TYPE c LENGTH 80,
         END OF ty_param.
  DATA lt_params TYPE STANDARD TABLE OF ty_param.
  FIELD-SYMBOLS <param> TYPE ty_param.
  FIELD-SYMBOLS <value> TYPE any.

  DATA lv_count     TYPE n LENGTH 2.
  DATA lv_pname     TYPE c LENGTH 80.


  DO 5 TIMES.
    lv_count = sy-index.
    APPEND INITIAL LINE TO lt_params ASSIGNING <param>.
    <param>-field = lv_count.
    CONCATENATE 'GV_DATA' lv_count INTO <param>-value.
  ENDDO.


  IMPORT (lt_params) FROM MEMORY ID '$DYN$'.
  LOOP AT lt_params ASSIGNING <param>.
    ASSIGN (<param>-value) TO <value>.
*    WRITE: / <param>-value, <value> COLOR COL_TOTAL.
  ENDLOOP.

  DO 5 TIMES.
    lv_count = sy-index.
    CONCATENATE 'P_DATA' lv_count INTO lv_pname.
    ASSIGN (lv_pname) TO <value>.
    IMPORT value TO <value> FROM MEMORY ID lv_pname.
    CHECK sy-subrc = 0.
*    WRITE: / lv_pname, <value> COLOR COL_POSITIVE.
  ENDDO.

ENDMETHOD.


METHOD PREPARE_DATA.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_type              TYPE c LENGTH 80.
  FIELD-SYMBOLS <type>      TYPE any.
  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.

  CHECK gv_area <> area
     OR gv_clas <> clas.

  gv_area = area.
  gv_clas = clas.

  CLEAR gv_data01.
  CLEAR gv_data02.
  CLEAR gv_data03.
  CLEAR gv_data04.
  CLEAR gv_data05.

  CLEAR gv_type01.
  CLEAR gv_type02.
  CLEAR gv_type03.
  CLEAR gv_type04.
  CLEAR gv_type05.

  LOOP AT gt_attributes ASSIGNING <attribute>
       WHERE ( area = area AND clas = clas )
          or ( area = area and clas = space ).

    ADD 01 TO lv_count.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_type.
    ASSIGN (lv_type) TO <type>.
    IF sy-subrc = 0.
      CONCATENATE <attribute>-attribute_table <attribute>-attribute_field INTO <type> SEPARATED BY '-'.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD prepare_struc.

  DATA lv_count             TYPE n LENGTH 2.
  DATA lv_type              TYPE c LENGTH 80.
  DATA lv_data              TYPE c LENGTH 80.
  FIELD-SYMBOLS <type>      TYPE any.
  FIELD-SYMBOLS <data>      TYPE any.
  FIELD-SYMBOLS <field>     TYPE any.
  FIELD-SYMBOLS <attribute> TYPE zbook_class_attr.


  CLEAR gv_data01.
  CLEAR gv_data02.
  CLEAR gv_data03.
  CLEAR gv_data04.
  CLEAR gv_data05.

  CLEAR gv_type01.
  CLEAR gv_type02.
  CLEAR gv_type03.
  CLEAR gv_type04.
  CLEAR gv_type05.


  DATA lr_typedescr         TYPE REF TO cl_abap_typedescr.
  DATA lr_structdescr       TYPE REF TO cl_abap_structdescr.
  DATA lt_components        TYPE abap_component_tab.
  FIELD-SYMBOLS <component> TYPE abap_componentdescr.
  DATA lv_dummy             TYPE string.
  DATA lv_table             TYPE string.

*  GET REFERENCE OF struc INTO gd_struc.

  lr_structdescr ?= cl_abap_datadescr=>describe_by_data( struc ).
  lt_components = lr_structdescr->get_components( ).

  SPLIT lr_structdescr->absolute_name AT '=' INTO lv_dummy lv_table.

  LOOP AT lt_components ASSIGNING <component>.

*    lr_typedescr = lr_structdescr->type( ).

    ADD 01 TO lv_count.
    CONCATENATE 'GV_TYPE' lv_count INTO lv_type.
    ASSIGN (lv_type) TO <type>.
    CHECK sy-subrc = 0.
    CONCATENATE lv_table <component>-name INTO <type> SEPARATED BY '-' .
    ASSIGN COMPONENT lv_count OF STRUCTURE struc TO <field>.
    IF sy-subrc = 0.
      CONCATENATE 'GV_DATA' lv_count INTO lv_data.
      ASSIGN (lv_data) TO <data>.
      <data> = <field>.
    ENDIF.
  ENDLOOP.

ENDMETHOD.
ENDCLASS.
