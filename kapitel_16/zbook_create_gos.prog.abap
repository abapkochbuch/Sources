REPORT zbook_create_gos.

DATA
     " Ordner
   : gs_folder   TYPE soodk

     " Verknüpfung: Quelle & Ziel
   , gs_object   TYPE sibflporb
   , gs_objtgt   TYPE sibflporb

     " Dokumenten-Grunddaten
   , gs_doc_info TYPE sofolenti1
   , gs_doc_data TYPE sodocchgi1
   , gd_doc_type TYPE soodk-objtp

     " Dokumenteninhalt binär
   , gt_contx    TYPE solix_tab

     " Dateiinformationen
   , gd_file     TYPE string
   , gd_flen     TYPE i
   .
PARAMETERS
    " Eingabefelder für die ID des Business-Objekts
  : p_instid    TYPE sibfboriid OBLIGATORY DEFAULT '0000000017'
  , p_typeid    TYPE sibftypeid OBLIGATORY DEFAULT 'ZBOOKTICK'
  , p_catid     TYPE sibfcatid  OBLIGATORY DEFAULT 'BO'
    " Dateiname
  , p_file      TYPE fileextern OBLIGATORY VISIBLE LENGTH 40
  .

START-OF-SELECTION.

  gd_file = p_file.

  " Datei hochladen
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename   = gd_file
      filetype   = 'BIN'
    IMPORTING
      filelength = gd_flen
    TABLES
      data_tab   = gt_contx
    EXCEPTIONS
      OTHERS     = 1.

  IF sy-subrc <> 0.
    WRITE: / 'Dateifehler!'.
    STOP.
  ENDIF.

  " Root-Folder der GOS ermitteln
  CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
    EXPORTING
      region    = 'B'
    IMPORTING
      folder_id = gs_folder.

  " Dateiinfo in Dokumenteninfo übernehmen
  CALL FUNCTION 'CH_SPLIT_FILENAME'
    EXPORTING
      complete_filename = gd_file
    IMPORTING
      extension         = gd_doc_type
      name              = gs_doc_data-obj_descr
      name_with_ext     = gs_doc_data-obj_name.
  TRANSLATE gd_doc_type TO UPPER CASE.

  gs_doc_data-doc_size = gd_flen.

  " Dokument anlegen
  CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
    EXPORTING
      folder_id     = gs_folder
      document_data = gs_doc_data
      document_type = gd_doc_type
    IMPORTING
      document_info = gs_doc_info
    TABLES
      contents_hex  = gt_contx.

  " Businessobjekt-ID übernehmen
  gs_object-instid  = p_instid.
  gs_object-typeid  = p_typeid.
  gs_object-catid   = p_catid.

  " Dokumentdaten als Ziel
  CONCATENATE gs_folder gs_doc_info-object_id
     INTO gs_objtgt-instid RESPECTING BLANKS.
  " Alternative:
  " gs_objtgt-instid = gs_doc_info-doc_id.
  gs_objtgt-typeid  = 'MESSAGE'.
  gs_objtgt-catid   = 'BO'.

  TRY.
      " Verknüpfung anlegen
      cl_binary_relation=>create_link(
        EXPORTING
          is_object_a = gs_object
          is_object_b = gs_objtgt
          ip_reltype  = 'ATTA' ).
      COMMIT WORK AND WAIT.
      MESSAGE 'Anlage wurde hinzugefügt' TYPE 'I'.
    CATCH cx_obl_parameter_error cx_obl_model_error cx_obl_internal_error.
      MESSAGE 'Fehler beim Hinzufügen der Anlage' TYPE 'E'.
  ENDTRY.
