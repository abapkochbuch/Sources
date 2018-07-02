REPORT zbook_read_gos.

TYPES
   : BEGIN OF gys_key
   ,   foltp TYPE so_fol_tp
   ,   folyr TYPE so_fol_yr
   ,   folno TYPE so_fol_no
   ,   objtp TYPE so_obj_tp
   ,   objyr TYPE so_obj_yr
   ,   objno TYPE so_obj_no
   ,   forwarder TYPE so_usr_nam
   , END OF gys_key
   .

DATA
    " Schlüssel des Business-Objekts
  : gs_object   TYPE sibflporb

    " Verknüpfungen zum Objekt
  , gt_links    TYPE obl_t_link
  , gs_links    TYPE obl_s_link

    " Verknüpfungsoptionen
  , gt_relopt   TYPE obl_t_relt
  , gs_relopt   TYPE obl_s_relt

    " Schlüssel einer Verknüpfung
  , gs_key      TYPE gys_key

    " Dokumenten-ID
  , gd_doc_id   TYPE so_entryid

    " Dokumenten-Grunddaten
  , gs_doc_data TYPE sofolenti1

    " Dokumenteninhalt Text und Binär
  , gt_contx    TYPE solix_tab
  , gt_cont     TYPE soli_tab
  .

PARAMETERS
    " Eingabefelder für die ID des Business-Objekts
  : p_instid    TYPE sibfboriid OBLIGATORY DEFAULT '0000000017'
  , p_typeid    TYPE sibftypeid OBLIGATORY DEFAULT 'ZBOOKTICK'
  , p_catid     TYPE sibfcatid  OBLIGATORY DEFAULT 'BO'
  .

START-OF-SELECTION.

  " Businessobjekt-ID übernehmen
  gs_object-instid  = p_instid.
  gs_object-typeid  = p_typeid.
  gs_object-catid   = p_catid.

  " Verknüpfungstypen:
  gs_relopt-sign = 'I'.
  gs_relopt-option = 'EQ'.

  " Anhänge
  gs_relopt-low = 'ATTA'.
  APPEND gs_relopt TO gt_relopt.
  " Notizen
  gs_relopt-low = 'NOTE'.
  APPEND gs_relopt TO gt_relopt.
  " URLs
  gs_relopt-low = 'URL'.
  APPEND gs_relopt TO gt_relopt.

  TRY.
      " Verknüpfungen zum Objekt lesen
      cl_binary_relation=>read_links_of_binrels(
        EXPORTING
          is_object           = gs_object
          it_relation_options = gt_relopt
          ip_role             = 'GOSAPPLOBJ'
        IMPORTING
          et_links            = gt_links ).
      LOOP AT gt_links INTO gs_links WHERE typeid_b = 'MESSAGE'.
        " Optional: Schlüsselkomponenten extrahieren
        gs_key = gs_links-instid_b.
        WRITE: / 'foltp', gs_key-foltp
             , / 'folyr', gs_key-folyr
             , / 'folno', gs_key-folno
             , / 'objtp', gs_key-objtp
             , / 'objyr', gs_key-objyr
             , / 'objno', gs_key-objno
             .
        " Die Dokumenten-ID für SAPOffice entspricht der ermittelten
        "   Instanz-ID
        gd_doc_id = gs_links-instid_b.

        " Dokumenteninhalte löschen
        CLEAR
          : gt_cont
          , gt_contx
          .
        " Dokument lesen
        CALL FUNCTION 'SO_DOCUMENT_READ_API1'
          EXPORTING
            document_id                = gd_doc_id
          IMPORTING
            document_data              = gs_doc_data
          TABLES
            object_content             = gt_cont
            contents_hex               = gt_contx
          EXCEPTIONS
            document_id_not_exist      = 1
            operation_no_authorization = 2
            x_error                    = 3
            OTHERS                     = 4.
        IF sy-subrc <> 0.
          " Fehlerbehandlung: Lesen des Dokuments
        ELSE.
          " Ausgabe einiger Kopfdaten
          WRITE: /  gs_doc_data-object_id
               ,    gs_doc_data-obj_type
               ,    gs_doc_data-obj_name
               ,    gs_doc_data-obj_descr
               .
        ENDIF.
        SKIP.
        IF NOT gt_cont[] IS INITIAL.
          " Es gibt Inhalt im Textformat
          WRITE: /1 'Es gibt Inhalt im TXT-Format:' color COL_POSITIVE.
          LOOP AT gt_cont INTO DATA(gs_cont).
            WRITE: /3 gs_cont-line.
          ENDLOOP.
        ENDIF.
        IF NOT gt_contx[] IS INITIAL.
          " Es gibt Inhalt im Binärformat
          WRITE: 14 'BIN'.
        ENDIF.
      ENDLOOP.

    CATCH cx_obl_parameter_error cx_obl_internal_error cx_obl_model_error.
      " Fehlerbehandlung: Lesen der Verknüpfungen
  ENDTRY.
