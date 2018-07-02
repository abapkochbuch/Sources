class ZCL_BOOK_GOS definition
  public
  final
  create public .

public section.

  class-methods ADD
    importing
      !I_TIKNR type ZBOOK_TICKET_NR
      !I_DATEI type STRING .
  class-methods GET
    importing
      !I_INSTID type SIBFBORIID
      !I_TYPEID type SIBFTYPEID default 'ZBOOKTICK'
      !I_CATID type SIBFCATID default 'BO'
    returning
      value(RT_ATTACHMENTS) type ZBOOK_GOS_ATTS
    raising
      CX_OBL .
  class-methods ADD_SERVER
    importing
      !I_TIKNR type ZBOOK_TICKET_NR
      !I_DATEI type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BOOK_GOS IMPLEMENTATION.


  METHOD add.
    " Ordner
    DATA ls_folder   TYPE soodk.

    " Verknüpfung: Quelle & Ziel
    DATA ls_object   TYPE sibflporb.
    DATA ls_objtgt   TYPE sibflporb.

    " Dokumenten-Grunddaten
    DATA ls_doc_info TYPE sofolenti1.
    DATA ls_doc_data TYPE sodocchgi1.
    DATA ld_doc_type TYPE soodk-objtp.

    " Dokumenteninhalt binär
    DATA lt_contx    TYPE solix_tab.

    " Dateiinformationen
    DATA ld_flen     TYPE i.

    " Felder für die ID des Business-Objekts
    DATA ld_instid    TYPE sibfboriid.
    DATA ld_typeid    TYPE sibftypeid VALUE 'ZBOOKTICK'.
    DATA ld_catid     TYPE sibfcatid  VALUE 'BO'.

    ld_instid = i_tiknr.

    " Datei hochladen
    cl_gui_frontend_services=>gui_upload(
          EXPORTING
            filename = i_datei
            filetype   = 'BIN'
          CHANGING
            data_tab   = lt_contx ).
*          EXCEPTIONS OTHERS = 1 ).
*    IF sy-subrc > 0.
*      RAISE EXCEPTION TYPE zcx_book_exception.
*    ENDIF.

    " Root-Folder der GOS ermitteln
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        region    = 'B'
      IMPORTING
        folder_id = ls_folder.

    " Dateiinfo in Dokumenteninfo übernehmen
    CALL FUNCTION 'CH_SPLIT_FILENAME'
      EXPORTING
        complete_filename = i_datei
      IMPORTING
        extension         = ld_doc_type
        name              = ls_doc_data-obj_descr
        name_with_ext     = ls_doc_data-obj_name.
    TRANSLATE ld_doc_type TO UPPER CASE.

    ls_doc_data-doc_size = ld_flen.

    " Dokument anlegen
    CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
      EXPORTING
        folder_id     = ls_folder
        document_data = ls_doc_data
        document_type = ld_doc_type
      IMPORTING
        document_info = ls_doc_info
      TABLES
        contents_hex  = lt_contx.

    " Businessobjekt-ID übernehmen
    ls_object-instid  = ld_instid.
    ls_object-typeid  = ld_typeid.
    ls_object-catid   = ld_catid.

    " Dokumentdaten als Ziel
    CONCATENATE ls_folder ls_doc_info-object_id
       INTO ls_objtgt-instid RESPECTING BLANKS.
    ls_objtgt-typeid  = 'MESSAGE'.
    ls_objtgt-catid   = 'BO'.

    TRY.
        " Verknüpfung anlegen
        cl_binary_relation=>create_link(
          EXPORTING
            is_object_a = ls_object
            is_object_b = ls_objtgt
            ip_reltype  = 'ATTA' ).
        COMMIT WORK AND WAIT.
      CATCH cx_obl_parameter_error cx_obl_model_error cx_obl_internal_error.
*        RAISE EXCEPTION TYPE zcx_book_exception.
    ENDTRY.
  ENDMETHOD.


  METHOD add_server.
    " Ordner
    DATA ls_folder   TYPE soodk.

    " Verknüpfung: Quelle & Ziel
    DATA ls_object   TYPE sibflporb.
    DATA ls_objtgt   TYPE sibflporb.

    " Dokumenten-Grunddaten
    DATA ls_doc_info TYPE sofolenti1.
    DATA ls_doc_data TYPE sodocchgi1.
    DATA ld_doc_type TYPE soodk-objtp.

    " Dokumenteninhalt binär
    DATA lt_contx    TYPE solix_tab.
    DATA ls_contx    LIKE LINE OF lt_contx.

    " Dateiinformationen
    DATA ld_flen     TYPE i.

    " Felder für die ID des Business-Objekts
    DATA ld_instid    TYPE sibfboriid.
    DATA ld_typeid    TYPE sibftypeid VALUE 'ZBOOKTICK'.
    DATA ld_catid     TYPE sibfcatid  VALUE 'BO'.

    ld_instid = i_tiknr.

    " Datei hochladen

    OPEN DATASET i_datei FOR INPUT IN BINARY MODE.
    DO.
      READ DATASET i_datei INTO ls_contx-line MAXIMUM LENGTH 255. " LENGTH ld_flen.
      IF sy-subrc > 0.
*        IF ld_flen > 0.
          APPEND ls_contx TO lt_contx.
*        ENDIF.
        EXIT.
      ELSE.
        APPEND ls_contx TO lt_contx.
      ENDIF.
    ENDDO.
    CLOSE DATASET i_datei.


    " Root-Folder der GOS ermitteln
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        region    = 'B'
      IMPORTING
        folder_id = ls_folder.

    " Dateiinfo in Dokumenteninfo übernehmen
    CALL FUNCTION 'CH_SPLIT_FILENAME'
      EXPORTING
        complete_filename = i_datei
      IMPORTING
        extension         = ld_doc_type
        name              = ls_doc_data-obj_descr
        name_with_ext     = ls_doc_data-obj_name.
    TRANSLATE ld_doc_type TO UPPER CASE.

    ls_doc_data-doc_size = ld_flen.

    " Dokument anlegen
    CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
      EXPORTING
        folder_id     = ls_folder
        document_data = ls_doc_data
        document_type = ld_doc_type
      IMPORTING
        document_info = ls_doc_info
      TABLES
        contents_hex  = lt_contx.

    " Businessobjekt-ID übernehmen
    ls_object-instid  = ld_instid.
    ls_object-typeid  = ld_typeid.
    ls_object-catid   = ld_catid.

    " Dokumentdaten als Ziel
    CONCATENATE ls_folder ls_doc_info-object_id
       INTO ls_objtgt-instid RESPECTING BLANKS.
    ls_objtgt-typeid  = 'MESSAGE'.
    ls_objtgt-catid   = 'BO'.

    TRY.
        " Verknüpfung anlegen
        cl_binary_relation=>create_link(
          EXPORTING
            is_object_a = ls_object
            is_object_b = ls_objtgt
            ip_reltype  = 'ATTA' ).
        COMMIT WORK AND WAIT.
      CATCH cx_obl_parameter_error cx_obl_model_error cx_obl_internal_error.
*        RAISE EXCEPTION TYPE zcx_book_exception.
    ENDTRY.
  ENDMETHOD.


  METHOD get.

    " Schlüssel des Business-Objekts
    DATA ls_object    TYPE sibflporb.

    " Verknüpfungen zum Objekt
    DATA lt_links     TYPE obl_t_link.
    DATA ls_links     TYPE obl_s_link.

    " Verknüpfungsoptionen
    DATA lt_relopt    TYPE obl_t_relt.
    DATA ls_relopt    TYPE obl_s_relt.

    " Dokumenten-ID
    DATA ld_doc_id    TYPE so_entryid.

    DATA ls_att       TYPE zbook_gos_att.

    " Businessobjekt-ID übernehmen
    ls_object-instid  = i_instid.
    ls_object-typeid  = i_typeid.
    ls_object-catid   = i_catid.

    " Verknüpfungstypen:
    ls_relopt-sign = 'I'.
    ls_relopt-option = 'EQ'.

    " Anhänge
    ls_relopt-low = 'ATTA'.
    APPEND ls_relopt TO lt_relopt.
    " Notizen
    ls_relopt-low = 'NOTE'.
    APPEND ls_relopt TO lt_relopt.
    " URLs
    ls_relopt-low = 'URL'.
    APPEND ls_relopt TO lt_relopt.

    " Verknüpfungen zum Objekt lesen
    cl_binary_relation=>read_links_of_binrels(
      EXPORTING
        is_object           = ls_object
        it_relation_options = lt_relopt
        ip_role             = 'GOSAPPLOBJ'
      IMPORTING
        et_links            = lt_links ).
    LOOP AT lt_links INTO ls_links WHERE typeid_b = 'MESSAGE'.
      " Die Dokumenten-ID für SAPOffice entspricht der ermittelten
      "   Instanz-ID
      ld_doc_id = ls_links-instid_b.

      " Dokumenteninhalte löschen
      CLEAR ls_att.

      " Dokument lesen
      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id    = ld_doc_id
        IMPORTING
          document_data  = ls_att-doc_data
        TABLES
          object_content = ls_att-cont
          contents_hex   = ls_att-contx.
      APPEND ls_att TO rt_attachments.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
