PROGRAM zbook_viewcluster_exit_pool.

INCLUDE lsvcmcod.

*&---------------------------------------------------------------------*
*&      Form  zz_documenation
*&---------------------------------------------------------------------*
FORM zz_documentation.


  CALL METHOD zcl_book_docu=>display
    EXPORTING
      id      = 'VW'
*      id      = 'Z'
      object  = vcl_akt_view
      side    = cl_gui_docking_container=>dock_at_right
      autodef = 'X'.

  .

ENDFORM.                    "zz_documentation

*&---------------------------------------------------------------------*
*&      Form  zz_exit
*&---------------------------------------------------------------------*
FORM zz_exit.

*== Definition für Viewclusterstruktur ZBOOK_AREAS
  TYPES: BEGIN OF ty_areas,
           base TYPE zbook_areas,
           text TYPE zbook_areat.
          INCLUDE TYPE vimtbflags.
  TYPES: END OF ty_areas.
  DATA lt_areas     TYPE STANDARD TABLE OF ty_areas.
  FIELD-SYMBOLS <tot_areas> type ty_areas.


  FIELD-SYMBOLS <areas> TYPE ty_areas.
*== Definition für Viewclusterstruktur ZBOOK_CLASV
  TYPES: BEGIN OF ty_clasv.
          INCLUDE TYPE zbook_clasv.
          INCLUDE TYPE vimflagtab.
  TYPES: END OF ty_clasv.
  DATA lt_clasv TYPE STANDARD TABLE OF ty_clasv.
  DATA ls_clasv TYPE ty_clasv.
*== Variablen für Verarbeitung
  DATA lv_error     TYPE c LENGTH 1.
  DATA ls_vcl_total TYPE c LENGTH 1000.

*== Zugriff auf Daten des Objektes ZBOOK_AREAS
  PERFORM vcl_set_table_access_for_obj
    USING 'ZBOOK_AREAS' CHANGING lv_error.

  CHECK lv_error = space.
*== unicode-konforme Zuweisung der Daten mittels Feldsymbol
  LOOP AT <vcl_total> ASSIGNING <tot_areas> CASTING. "INTO ls_vcl_total.
    APPEND INITIAL LINE TO lt_areas ASSIGNING <areas>.
    PERFORM move_unicode_save USING <tot_areas> CHANGING <areas>.
  ENDLOOP.

*== Zugriff auf Daten des Objektes ZBOOK_CLASV
  PERFORM vcl_set_table_access_for_obj
    USING 'ZBOOK_CLASV' CHANGING lv_error.
  CHECK lv_error = space.
*== unicode-konforme Zuweisung der Daten mittels Arbeitsbereich
  LOOP AT <vcl_total> INTO ls_vcl_total.
    CLEAR ls_clasv.
    PERFORM move_unicode_save USING ls_vcl_total CHANGING ls_clasv.
    APPEND ls_clasv TO lt_clasv.
  ENDLOOP.

*== Für neue Einträge Prüfen, ob abhängige Einträge vorhanden sind:
  LOOP AT lt_areas ASSIGNING <areas> WHERE vim_action = vcl_neuer_eintrag.
    READ TABLE lt_clasv TRANSPORTING NO FIELDS WITH KEY area = <areas>-base-area.
    IF sy-subrc > 0.
      MESSAGE i000(oo) WITH 'Es müssen Kategorien zu Bereich'
                             <areas>-base-area 'vorhanden sein!'.
      vcl_stop = 'X'.
    ENDIF.
  ENDLOOP.


ENDFORM.                    "zz_exit

*&---------------------------------------------------------------------*
*&      Form  move_unicode_save
*&---------------------------------------------------------------------*
FORM move_unicode_save USING in TYPE any
                   CHANGING out TYPE any.

  CLEAR   out.
  FIELD-SYMBOLS <in>  TYPE x.
  FIELD-SYMBOLS <out> TYPE x.

  ASSIGN in  TO <in>  CASTING.
  ASSIGN out TO <out> CASTING.

  <out> = <in>.

ENDFORM.                    "move_unicode_save

*&---------------------------------------------------------------------*
*&      Form  zz_exit
*&---------------------------------------------------------------------*
FORM zz_exitalt.

  TYPES: BEGIN OF ty_areas.
          INCLUDE TYPE zbook_areas.
          INCLUDE TYPE vimtbflags.
  TYPES: END OF ty_areas.

  DATA lv_error TYPE c LENGTH 1.
  DATA lt_areas TYPE STANDARD TABLE OF ty_areas.
  DATA ls_areas TYPE ty_areas.

  DATA lt_clasv TYPE STANDARD TABLE OF zbook_clasv.
  DATA ls_clasv TYPE zbook_clasv.


  PERFORM vcl_set_table_access_for_obj
              USING 'ZBOOK_AREAS'
           CHANGING lv_error.
  CHECK lv_error = space.
  lt_areas = <vcl_total>.
  PERFORM vcl_set_table_access_for_obj
              USING 'ZBOOK_CLASV'
           CHANGING lv_error.
  CHECK lv_error = space.
  lt_clasv = <vcl_total>.
  CHECK lt_clasv IS NOT INITIAL.
  LOOP AT lt_areas INTO ls_areas.
    LOOP AT lt_clasv INTO ls_clasv WHERE area = ls_areas-area.

      EXIT.
    ENDLOOP.
    IF sy-subrc > 0.
      MESSAGE i000(oo) WITH 'Es müssen Kategorien zu Bereich' ls_areas-area 'vorhanden sein!'.
      vcl_stop = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "zz_exit
