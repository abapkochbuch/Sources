class ZCL_BOOK_DYN_SELSCR definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_DYN_SELSCR
*"* do not include other source files here!!!
public section.
  type-pools SYDB0 .

  class-methods DYN_SCREEN_PBO
    importing
      !IV_DYNNR type SYDYNNR optional
      !IS_DYN_FIELD_SETTINGS type ZBOOK_DYN_SELSCR_FIELDS
    preferred parameter IV_DYNNR .
  class-methods REFRESH_DYN_SCREEN
    importing
      !IV_REPID type SYREPID default SY-CPROG
      !IV_DYNNR type SYDYNNR optional
      !IV_DYN_SELSCR_FIELDS type ZBOOK_DYN_SELSCR_FIELDS optional
    preferred parameter IV_REPID .
protected section.
*"* protected components of class ZCL_BOOK_TICKET_DYN_SELSCR
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_DYN_SELSCR
*"* do not include other source files here!!!

  types:
    BEGIN OF gty_screen_progs,
           program              LIKE sy-repid,
           ldbpg                LIKE sy-ldbpg,         " Datenbankprogramm
           variprog             LIKE sy-repid,         " Variantenprogramm
           after_first_pbo(1)   TYPE c,                " Erstes PBO vorbei
           restrict_set(1)      TYPE c,                " Einmal Restriktionen gesetzt
           title                LIKE sy-title,         " Standardtitel
           any_variants(1)      TYPE c,
           submode(2)           TYPE c,
           status_submode(2)    TYPE c,
           dynsel(1)            TYPE c,
           report_writer(1)     TYPE c,         " SPEZIALVARIANTENPFLEGE REPORTWRITER.
           sscr                 TYPE STANDARD TABLE OF rsscr         WITH NON-UNIQUE DEFAULT KEY,
           dynref               TYPE STANDARD TABLE OF sydb0_dynref  WITH NON-UNIQUE DEFAULT KEY,
           texts                TYPE STANDARD TABLE OF rsseltexts    WITH NON-UNIQUE DEFAULT KEY,
*          modtext type sydb0_modtext occurs 0,
           hash(10)             TYPE c,
         END   OF gty_screen_progs .
  types:
    gtyt_rsscr TYPE STANDARD TABLE OF rsscr WITH NON-UNIQUE DEFAULT KEY .

  class-data GT_FIRST_RSSCR type GTYT_RSSCR .
  class-data GS_FIRST_SCREEN_PROG type GTY_SCREEN_PROGS .
  class-data GS_LAST_DYN_FIELDS type ZBOOK_DYN_SELSCR_FIELDS .
ENDCLASS.



CLASS ZCL_BOOK_DYN_SELSCR IMPLEMENTATION.


METHOD dyn_screen_pbo.

* Liste aufbauen, welche Parameter belegt sind und damit angezeigt weden sollen
  TYPES: BEGIN OF lty_used_dynfields,
           group1    TYPE screen-group1,
           used      TYPE flag,
         END OF lty_used_dynfields.
  DATA: lth_used_dynfields            TYPE HASHED TABLE OF lty_used_dynfields WITH UNIQUE KEY group1,
        ls_used_dynfield              LIKE LINE OF lth_used_dynfields.
  DATA: lo_structdescr                TYPE REF TO cl_abap_structdescr.

  FIELD-SYMBOLS: <lv_component>       LIKE LINE OF lo_structdescr->components,
                 <ls_used_dynfield>   LIKE LINE OF lth_used_dynfields,
                 <lv_fieldname>       TYPE zbook_dyn_selscr_fields-p_dyn01.
*--------------------------------------------------------------------*
* Für die sehr kurze Struktur mit 4 Parametern und 4 SelOpts könnte man das hier
* jetzt auch hart codieren - aber falls das mal erweitert werden soll bzw. um
* die RTTI zu zeigen kann das auch gleich allgemein erledigt werden
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Die "simple" Methode hier auskommentiert als Beispiel,
* falls das für das Buch schöner sein sollte
*--------------------------------------------------------------------*
*  if is_DYN_field_settings-p_dyn01 is not INITIAL.
*    insert 'P01' into table lth_used.
*  endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Strukturbeschreibung der dynamischen Feldnamenstruktur holen
*--------------------------------------------------------------------*
  lo_structdescr ?= cl_abap_structdescr=>describe_by_data( is_dyn_field_settings ).
  LOOP AT lo_structdescr->components ASSIGNING <lv_component>.

*--------------------------------------------------------------------*
* Prüfen, ob das Feld belegt ist - theor. könnte man auch noch prüfen ob das Feld existiert  (DD03L)
*--------------------------------------------------------------------*
    CLEAR ls_used_dynfield.
    CONCATENATE <lv_component>-name(1) <lv_component>-name+5(2)                                   " Alle Felder haben die Form "P_DYNxx" oder "S_DYNxx"  mit korrespondierenden
        INTO ls_used_dynfield-group1.                                                             " Screen-Group1-Belegung     "Pxx"     oder "Sxx"
    INSERT ls_used_dynfield INTO TABLE lth_used_dynfields ASSIGNING <ls_used_dynfield>.
    CHECK sy-subrc = 0.                                                                           " Duplikate werden ignoriert - sollten auch nicht vorkommen
    ASSIGN COMPONENT <lv_component>-name OF STRUCTURE is_dyn_field_settings TO <lv_fieldname>.    " Jetzt die Belegung des Feldes überprüfen
    CHECK sy-subrc = 0.                                                                           " sollte immer = 0 sein, da die RTTI ja gerade diese Struktur gelesen hat
    CHECK <lv_fieldname> IS NOT INITIAL.                                                          " Feld belegt  --> es muss angezeigt werden
    <ls_used_dynfield>-used = 'X'.

  ENDLOOP.

  LOOP AT SCREEN.

    READ TABLE lth_used_dynfields ASSIGNING <ls_used_dynfield> WITH TABLE KEY group1 = screen-group1.
    CHECK sy-subrc = 0.                                                                           " Das Feld ist eins der dynamischen Felder
    CHECK <ls_used_dynfield>-used = ' '.                                                          " Aber es ist nicht belegt --> ausblenden

    screen-input     = 0.
    screen-invisible = 1.
    MODIFY SCREEN.

  ENDLOOP.
ENDMETHOD.


METHOD refresh_dyn_screen.

  DATA: lv_repid            TYPE syrepid,
        lt_rsccr            LIKE gt_first_rsscr,
        ls_this_screen_prog LIKE gs_first_screen_prog.


*--------------------------------------------------------------------*
* Beim 1. Durchlaufen des AT-SELECTION-SCREEN OUTPUT hat ABAP die Dyn.
* Parameter noch nicht gesetzt.  Dieses jungfräuliche Layout wird
* gepuffert um beim Wechsel der dyn. Selectionsfelder SAP zu zwingen
* den Dynpro neu aufzubauen.
*--------------------------------------------------------------------*
  IF  gt_first_rsscr IS INITIAL.
* Save dynamic screen without any replacementes so far
    PERFORM set_things_4_sub_v IN PROGRAM rsdbrunt IF FOUND
      TABLES gt_first_rsscr
      USING  lv_repid
             gs_first_screen_prog.
*--------------------------------------------------------------------*
* Falls sich die Belegung der dyn. Felder geändert hat muss jetzt
* die gepufferte Version zurückgeschrieben werden
* ACHTUNG - Hier muss ich nochmal umstellen auf instanziierte Version
*           oder über statische Tabelle für alle Dynpros
*           Das hier erst mal zum Testen, ob das überhaupt funktioniert.
*--------------------------------------------------------------------*
  ELSEIF iv_dyn_selscr_fields <> gs_last_dyn_fields OR
         iv_dyn_selscr_fields IS NOT SUPPLIED.  " Force refresh
* Reset dynamic screen to version without any replacementes
    PERFORM set_things_4_sub_v IN PROGRAM rsdbrunt IF FOUND
      TABLES lt_rsccr
      USING  lv_repid
             ls_this_screen_prog.
    CHECK ls_this_screen_prog IS NOT INITIAL.
    PERFORM reset_dynref IN PROGRAM rsdbrunt IF FOUND.
    PERFORM set_things_4_sub_v IN PROGRAM rsdbrunt IF FOUND
      TABLES lt_rsccr
      USING  lv_repid
             ls_this_screen_prog.
    PERFORM restore_things_from_sub_v IN PROGRAM rsdbrunt IF FOUND
      TABLES gt_first_rsscr
      USING  lv_repid
             gs_first_screen_prog.

  ENDIF.


  IF iv_dyn_selscr_fields IS SUPPLIED.
    gs_last_dyn_fields = iv_dyn_selscr_fields.
  ENDIF.
ENDMETHOD.
ENDCLASS.
