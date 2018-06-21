class ZCL_BOOK_DOCU definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_DOCU
*"* do not include other source files here!!!
public section.

  class-methods DISPLAY
    importing
      !ID type DOKU_ID
      !OBJECT type C
      !SIDE type I default CL_GUI_DOCKING_CONTAINER=>DOCK_AT_RIGHT
      !AUTODEF type C optional
      !CONTAINER type ref to CL_GUI_CONTAINER optional .
  class-methods DISPLAY2
    importing
      !ID type DOKU_ID
      !OBJECT type C
      !SIDE type I default CL_GUI_DOCKING_CONTAINER=>DOCK_AT_RIGHT
      !AUTODEF type C optional
      !CONTAINER type ref to CL_GUI_CONTAINER optional .
protected section.
*"* protected components of class ZCL_BOOK_DOCU
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_DOCU
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BOOK_DOCU IMPLEMENTATION.


METHOD display.

  DATA lt_lines        TYPE STANDARD TABLE OF tline.
  DATA ls_header       TYPE thead.
  DATA lt_html         TYPE STANDARD TABLE OF htmlline.
  DATA lv_url          TYPE c LENGTH 500.
  DATA lv_spras        TYPE sylangu.
  STATICS sv_object    TYPE doku_obj.
  STATICS sr_dock      TYPE REF TO cl_gui_docking_container.
  STATICS sr_container TYPE REF TO cl_gui_container.
  STATICS sr_html      TYPE REF TO cl_gui_html_viewer.
  CHECK sv_object <> object.
  sv_object = object.
*== Dokumentation lesen
  CALL FUNCTION 'DOCU_GET'
    EXPORTING
      id     = id
      langu  = sy-langu
      object = sv_object
    IMPORTING
      head   = ls_header
    TABLES
      line   = lt_lines
    EXCEPTIONS
      OTHERS = 5.
  IF sr_dock IS INITIAL.
*== Docking-Container erzeugen
    CREATE OBJECT sr_dock
      EXPORTING
        Side       = side
        extension  = 400
        no_autodef_progid_dynnr = 'X'.
  ENDIF.
  IF lt_lines IS INITIAL.
*== Keine Dokumentation vorhanden:
*== Docking-Container ausblenden
    IF sr_html IS BOUND. sr_html->set_visible( ' ' ). ENDIF.
    IF sr_dock IS BOUND. sr_dock->set_visible( ' ' ). ENDIF.
  ELSE.
*== Dokumentation ist vorhanden:
*== Docking-Container einblenden
    IF sr_html IS BOUND. sr_html->set_visible( 'X' ). ENDIF.
    IF sr_dock IS BOUND. sr_dock->set_visible( 'X' ). ENDIF.
  ENDIF.

  IF lt_lines IS NOT INITIAL.
    IF sr_html IS INITIAL.
      CREATE OBJECT sr_html
        EXPORTING
          parent = sr_dock.
    ENDIF.
    CALL FUNCTION 'CONVERT_ITF_TO_HTML'
      EXPORTING
        i_header    = ls_header
      TABLES
        t_itf_text  = lt_lines
        t_html_text = lt_html
      EXCEPTIONS
        OTHERS      = 4.
    IF sy-subrc = 0.
      CALL METHOD sr_html->load_data
        IMPORTING
          assigned_url = lv_url
        CHANGING
          data_table   = lt_html
        EXCEPTIONS
          OTHERS       = 4.
      IF sy-subrc = 0.
        sr_html->show_url( lv_url ).
      ENDIF.
    ENDIF.
  ENDIF.


ENDMETHOD.


METHOD DISPLAY2.

  DATA lt_lines        TYPE STANDARD TABLE OF tline.
  DATA ls_header       TYPE thead.
  DATA lt_html         TYPE STANDARD TABLE OF  htmlline.
  DATA lv_url          TYPE c LENGTH 500.
  DATA lv_spras        TYPE sylangu.

  STATICS sv_object    TYPE doku_obj.
  STATICS sr_dock      TYPE REF TO cl_gui_docking_container.
  STATICS sr_container TYPE REF TO cl_gui_container.
  STATICS sr_html      TYPE REF TO cl_gui_html_viewer.

  DATA lv_id           TYPE doku_id.
  DATA lv_tabclass     TYPE tabclass.


  IF object IS INITIAL.
    sv_object = object.
    IF sr_dock IS BOUND.
      sr_dock->set_visible( space ).
      EXIT.
    ENDIF.
  ELSE.
    sv_object = object.
  ENDIF.

  IF id = 'Z'.
    SELECT SINGLE tabclass
      FROM dd02l
      INTO lv_tabclass
     WHERE tabname  = sv_object
       AND as4local = 'A'
       AND as4vers  = 0.
    CASE lv_tabclass.
      WHEN 'VIEW'.
        lv_id = 'TB'.
        SELECT SINGLE roottab
          FROM dd25l
          INTO sv_object
         WHERE viewname = sv_object
           AND as4local = 'A'
           AND as4vers = 0.
      WHEN 'TRANSP'.
        lv_id = 'TB'.
      WHEN OTHERS.
        EXIT.
    ENDCASE.
  ELSE.
    lv_id = id.
  ENDIF.

  CALL FUNCTION 'DOCU_GET'
    EXPORTING
      id     = lv_id
      langu  = sy-langu
      object = sv_object
      typ    = 'E'
    IMPORTING
      head   = ls_header
    TABLES
      line   = lt_lines
    EXCEPTIONS
      OTHERS = 1.

  IF sr_dock IS INITIAL.
*== Docking Container erzeugen
    CREATE OBJECT sr_dock
      EXPORTING
        side                    = side
        extension               = 400
        no_autodef_progid_dynnr = 'X'.
  ENDIF.

*== Sichtbarkeit
  IF lt_lines IS INITIAL.
    IF sr_html IS BOUND. sr_html->set_visible( space ). ENDIF.
    IF sr_dock IS BOUND. sr_dock->set_visible( space ). ENDIF.
  ELSE.
    IF sr_html IS BOUND. sr_html->set_visible( 'X' ). ENDIF.
    IF sr_dock IS BOUND. sr_dock->set_visible( 'X' ). ENDIF.
  ENDIF.

  IF lt_lines IS NOT INITIAL.
    IF sr_html IS INITIAL.
*== HTML-Control erzeugen
      CREATE OBJECT sr_html
        EXPORTING
          parent = sr_dock.
    ENDIF.
*== Dokumentation in HTML umwandeln
    CALL FUNCTION 'CONVERT_ITF_TO_HTML'
      EXPORTING
        i_header    = ls_header
      TABLES
        t_itf_text  = lt_lines
        t_html_text = lt_html
      EXCEPTIONS
        OTHERS      = 4.
    IF sy-subrc = 0.
*== Dokumentation im HTML-Format ins HTML-Control laden
      CALL METHOD sr_html->load_data
        IMPORTING
          assigned_url = lv_url
        CHANGING
          data_table   = lt_html
        EXCEPTIONS
          OTHERS       = 4.
      IF sy-subrc = 0.
*== Dokumentation anzeigen
        sr_html->show_url( lv_url ).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
