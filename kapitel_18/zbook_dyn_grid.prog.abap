*&---------------------------------------------------------------------*
*& Report  ZBOOK_DYN_GRID
*&---------------------------------------------------------------------*
REPORT zbook_dyn_grid.

TABLES: zbook_ticket.


DATA gd_data   TYPE REF TO data.
DATA gr_salv   TYPE REF TO cl_salv_table.

*--------------------------------------------------------------------*
* Selektionsbild
*--------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-bl1.
SELECT-OPTIONS s_tiknr FOR zbook_ticket-tiknr.
SELECT-OPTIONS s_area  FOR zbook_ticket-area.
SELECT-OPTIONS s_clas  FOR zbook_ticket-clas.
*SELECTION-SCREEN END OF BLOCK a.


START-OF-SELECTION.
  PERFORM dynamic_ticket_data.
  PERFORM output_data.

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DATA
*&---------------------------------------------------------------------*
FORM output_data.

  FIELD-SYMBOLS: <t_data> TYPE STANDARD TABLE.
  DATA lr_salv_col_tab    TYPE REF TO cl_salv_columns_table.

  ASSIGN gd_data->* TO <t_data>.

  TRY.
*== Erzeugen des SALV Objektes
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = gr_salv
        CHANGING
          t_table      = <t_data>.
*== SALV-Spalten:
      lr_salv_col_tab = gr_salv->get_columns( ).
*== Spaltenbreite optimieren
      lr_salv_col_tab->set_optimize( ).
*== SALV-Anzeige
      gr_salv->display( ).
    CATCH cx_salv_msg .
    CATCH cx_salv_data_error.
  ENDTRY.

ENDFORM.                    " OUTPUT_DATA


*&---------------------------------------------------------------------*
*&      Form  dynamic_ticket_data
*&---------------------------------------------------------------------*
FORM dynamic_ticket_data.

  TYPES: BEGIN OF ty_used_attr,
           tablename TYPE zbook_attr-tablename,
           fieldname TYPE zbook_attr-fieldname,
         END OF ty_used_attr.
  DATA lt_used_attr TYPE STANDARD TABLE OF ty_used_attr.

  DATA lt_attr_value     TYPE SORTED TABLE OF zbook_attr_value
                              WITH NON-UNIQUE KEY tiknr.
  DATA lt_tickets        TYPE STANDARD TABLE OF zbook_ticket.
  DATA lr_datadescr      TYPE REF TO cl_abap_datadescr.
  DATA lr_structdescr    TYPE REF TO cl_abap_structdescr.
  DATA lr_tabledescr     TYPE REF TO cl_abap_tabledescr.
  DATA lt_components     TYPE cl_abap_structdescr=>component_table.
  DATA ls_component      LIKE LINE OF lt_components.
  DATA lv_fieldname      TYPE fieldname.


  FIELD-SYMBOLS <attr_value> TYPE zbook_attr_value.
  FIELD-SYMBOLS <used_attr>  TYPE ty_used_attr.
  FIELD-SYMBOLS <t_data>     TYPE STANDARD TABLE.
  FIELD-SYMBOLS <s_data>     TYPE any.
  FIELD-SYMBOLS <field>      TYPE any.
  FIELD-SYMBOLS <tiknr>      TYPE any.


*== Lesen der Ticketdaten
  SELECT * FROM zbook_ticket
    INTO TABLE lt_tickets
   WHERE tiknr IN s_tiknr
     AND area  IN s_area
     AND clas  IN s_clas.
  IF sy-subrc > 0.
    EXIT.
  ENDIF.

*== Lesen aller Ticketattribute
  SELECT *
    INTO TABLE lt_attr_value
    FROM zbook_attr_value
     FOR ALL ENTRIES IN lt_tickets
   WHERE tiknr = lt_tickets-tiknr.

*== lesen aller verwendeten variablen Felder
  SELECT DISTINCT tablename fieldname
    INTO TABLE lt_used_attr
    FROM zbook_attr_value
     FOR ALL ENTRIES IN lt_attr_value
   WHERE tiknr = lt_attr_value-tiknr.

*== Neue Tabelle aufbauen inkl. der verwendeten Ticketattribute
  lr_structdescr ?= cl_abap_typedescr=>describe_by_name( 'ZBOOK_TICKET' ).
  ls_component-name       = 'BASE_TABLE'.
  ls_component-type       = lr_structdescr.
  ls_component-as_include = 'X'.
  APPEND ls_component TO lt_components.

*== Danach dann alle dyn. Attribute hinzufügen
  LOOP AT  lt_used_attr ASSIGNING  <used_attr>.

*== Feldname X_ + Feldname aus Definition
    CONCATENATE 'X_' <used_attr>-fieldname
           INTO ls_component-name.
    CONCATENATE <used_attr>-tablename
                <used_attr>-fieldname
           INTO lv_fieldname SEPARATED BY '-'.
    lr_datadescr ?= cl_abap_datadescr=>describe_by_name( lv_fieldname ).
    ls_component-type       = lr_datadescr.
    ls_component-as_include = ' '.
    APPEND ls_component TO lt_components.
  ENDLOOP.


*== Neue erweiterte Tabelle aufbauen
*== Zunächst eine Strukturbeschreibung erzeugen aus den einzelnen Komponenten
  TRY.
      lr_structdescr = cl_abap_structdescr=>create( p_components = lt_components ).
    CATCH cx_sy_struct_creation .
  ENDTRY.
* Aus der Strukturbeschreibung eine Tabellenbeschreibung erzeugen und daraus dann eine Referenz auf zugehörige Tabelle
  TRY.
      lr_tabledescr = cl_abap_tabledescr=>create( p_line_type  = lr_structdescr ).
      CREATE DATA gd_data TYPE HANDLE lr_tabledescr.
    CATCH cx_sy_table_creation .
  ENDTRY.

*== zuweisung der Datenreferenz an das Feldsymbol
  ASSIGN gd_data->* TO <t_data>.

  <t_data> = lt_tickets.

  LOOP AT <t_data> ASSIGNING <s_data>.
    ASSIGN COMPONENT 'TIKNR' OF STRUCTURE <s_data> TO <tiknr>.
    UNASSIGN <field>.
    LOOP AT lt_attr_value ASSIGNING <attr_value>
         WHERE tiknr =  <tiknr>.
*== Feldname: X_ + Feldname aus Definition
      CONCATENATE 'X_' <attr_value>-fieldname INTO lv_fieldname.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <s_data> TO <field>.
      CHECK sy-subrc = 0.
      <field> = <attr_value>-value.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " DYNAMIC_TICKET_DATA
