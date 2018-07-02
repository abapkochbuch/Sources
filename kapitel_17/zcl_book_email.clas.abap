class ZCL_BOOK_EMAIL definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_EMAIL
*"* do not include other source files here!!!
public section.

  constants CV_CRLF type ABAP_CR_LF value CL_ABAP_CHAR_UTILITIES=>CR_LF ##NO_TEXT.

  class-methods CREATE_MAIL_FORM_DARK
    importing
      !I_FORMNAME type TDSFNAME default 'ZSFTICKET'
      !I_TICKET type ZBOOK_TICKET_NR
      !I_TO type ZBOOK_PERSON_REPSONSIBLE
      !I_COMMIT type ABAP_BOOL default ABAP_TRUE
      !I_SUBJECT type SOOD-OBJDES
    returning
      value(R_MAIL) type ref to ZCL_BOOK_EMAIL .
  class-methods CREATE_MAIL_TEXT_DARK
    importing
      !I_TICKET type ZBOOK_TICKET_NR
      !I_TO type ZBOOK_PERSON_REPSONSIBLE
      !I_ADD_LINK type ABAP_BOOL default ABAP_TRUE
      !I_COMMIT type ABAP_BOOL default ABAP_TRUE
      !I_SUBJECT type SOOD-OBJDES optional
    returning
      value(R_MAIL) type ref to ZCL_BOOK_EMAIL .
  methods GET_MAIL_AS_TEXT
    returning
      value(R_STRING) type STRING .
  class-methods CREATE_MAIL_DIALOG
    importing
      !I_SUBJECT type SOOD-OBJDES
      !I_STARTING_AT_X type SY-TABIX default 10
      !I_STARTING_AT_Y type SY-TABIX default 3
      !I_ENDING_AT_X type SY-TABIX default 100
      !I_ENDING_AT_Y type SY-TABIX default 30
      !I_COMMIT type ABAP_BOOL default ABAP_TRUE
      !I_TEXT type BCSY_TEXT optional
      !I_RECIPIENTS type BCSY_RE3 optional
    returning
      value(R_MAIL) type ref to ZCL_BOOK_EMAIL .
  class-methods CREATE_MAIL_DIALOG_SIMPLE
    importing
      value(I_SUBJECT) type SOOD-OBJDES optional
      value(I_STARTING_AT_X) type SY-TABIX default 10
      value(I_STARTING_AT_Y) type SY-TABIX default 10
      value(I_ENDING_AT_X) type SY-TABIX default 100
      value(I_ENDING_AT_Y) type SY-TABIX default 30
      value(I_COMMIT) type ABAP_BOOL default ABAP_TRUE .
protected section.
*"* protected components of class ZCL_BOOK_EMAIL
*"* do not include other source files here!!!
private section.

  data PR_DOCUMENT type ref to IF_DOCUMENT_BCS .
  data PT_RECIPIENTS type BCSY_RE .

  methods ADD_TICKET_LINK
    importing
      !I_TICKET type ZBOOK_TICKET_NR .
  methods GET_MAIL_BODY
    returning
      value(R_BODY) type STRING .
  methods GET_TEXT_TEMPLATE
    importing
      !I_TEMPLATE type TDOBNAME
    returning
      value(RV_BODY) type STRING .
ENDCLASS.



CLASS ZCL_BOOK_EMAIL IMPLEMENTATION.


METHOD add_ticket_link.
* Shortcut zum Ticket, d.h. ein Attachment, mit dem das Ticket im SAP-Gui geöffnet werden kann.
  DATA lt_att_text                    TYPE soli_tab.
  DATA lv_att_text                    TYPE string.
  DATA lv_name                        TYPE so_obj_des.
  DATA lv_size                        TYPE sood-objlen.
  DATA lr_attach_to                   TYPE REF TO cl_document_bcs.

*Der Inhalt baut sich aus folgenden Zeilen auf:
  CONCATENATE '[System]'                                cv_crlf
              'Name='    sy-sysid                       cv_crlf "Ermittlung der Gui Verbindung via Systemid
              'Description='                            cv_crlf "Keine Beschreibung da diese lokal beim User abweichen könnte
              'Client=' sy-mandt                        cv_crlf "Zielmandant
              '[User]'                                  cv_crlf
              'Language=' sy-langu                      cv_crlf
              '[Function]'                              cv_crlf
              'Title='                                  cv_crlf
              'Command=*VD03 RF02D-KUNNR=' i_ticket ';' cv_crlf "Transaktion mit Vorbelegten Feldern
              'Type=Transaction'                        cv_crlf "Starte Transaktion
              '[Options]'                               cv_crlf
              'Reuse=1'                                 cv_crlf "Nutzung offener SAP-Gui Verbindung
               INTO lv_att_text.

  CONCATENATE 'Ticket' i_ticket '.sap' INTO lv_name.
  lv_size     = STRLEN( lv_att_text ).
  lt_att_text = cl_document_bcs=>string_to_soli( lv_att_text ).
  TRY.
      lr_attach_to ?= pr_document.
      lr_attach_to->add_attachment(
          i_attachment_type     = 'SAP'    "Dateiendung veranlasst Ausführung durch SAP-Gui
          i_attachment_subject  = lv_name
          i_attachment_size     = lv_size
          i_att_content_text    = lt_att_text
             ).
    CATCH cx_document_bcs .
  ENDTRY.

ENDMETHOD.


METHOD create_mail_dialog.
  DATA lr_mail                      TYPE REF TO cl_bcs.
  DATA lr_me                        TYPE REF TO zcl_book_email.

  TRY.
* Mailpopup gibt eine Referenz auf den Sendeauftrag zurück:
      lr_mail = cl_bcs=>short_message(
          i_subject       = i_subject
          i_text          = i_text
          i_recipients    = i_recipients
          i_starting_at_x = i_starting_at_x
          i_starting_at_y = i_starting_at_y
          i_ending_at_x   = i_ending_at_x
          i_ending_at_y   = i_ending_at_y
             ).

*     Eigenes Objekt instanzieren,
      CREATE OBJECT lr_me.

*     Die Mail versteckt sich im document:
      lr_me->pr_document = lr_mail->document( ).

*     Auslesen der Empfängerliste
      lr_me->pt_recipients = lr_mail->recipients( ).

*     Zum absenden muß ein Commit abgesetzt werden.
*     dieser kann aber auch im Rahmenprogramm erfolgen....
      IF i_commit EQ abap_true.
        COMMIT WORK AND WAIT.
      ENDIF.

*     Rückgabewert setzen
      r_mail = lr_me.
    CATCH cx_send_req_bcs .
    CATCH cx_bcs .
  ENDTRY.


ENDMETHOD.


METHOD create_mail_dialog_simple.
* Öffnen eines Fenster, in dem eine individuelle Mail verfasst werden kann.

  TRY.
      cl_bcs=>short_message(
          i_subject       = i_subject
          i_starting_at_x = i_starting_at_x
          i_starting_at_y = i_starting_at_y
          i_ending_at_x   = i_ending_at_x
          i_ending_at_y   = i_ending_at_y
             ).
*     Zum absenden muß ein Commit abgesetzt werden.
*     dieser kann aber auch im Rahmenprogramm erfolgen....
      IF i_commit EQ abap_true.
        COMMIT WORK AND WAIT.
      ENDIF.
    CATCH cx_send_req_bcs .
    CATCH cx_bcs .
  ENDTRY.

ENDMETHOD.


METHOD create_mail_form_dark.
  DATA ls_ticket_data   TYPE zbook_ticket_output.
  DATA lv_fm_name       TYPE rs38l_fnam.
  DATA lr_sender        TYPE REF TO cl_cam_address_bcs.
  DATA lr_recipient     TYPE REF TO cl_cam_address_bcs.
  DATA lv_uname         TYPE xubname.
  DATA lv_email         TYPE ad_smtpadr.
  DATA lt_mailtext      TYPE soli_tab.
  DATA lv_subject       TYPE so_obj_des.
  DATA ls_control_param        TYPE ssfctrlop.
  DATA ls_mail_recipient       TYPE swotobjid.
  DATA ls_mail_sender	         TYPE swotobjid.
  DATA ls_output_options       TYPE ssfcompop.
  DATA ls_document_output_info TYPE ssfcrespd.
  DATA ls_job_output_info      TYPE ssfcrescl.

* Titel der Mail Übernehmen
  lv_subject =  i_subject.

* Ermittlung der Ticketdaten:
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_ticket_data-head
    FROM zbook_ticket
   WHERE tiknr = i_ticket.

  IF 0 NE sy-subrc.
    RETURN.
  ENDIF.

  SELECT SINGLE *
    INTO ls_ticket_data-history
    FROM zbook_history
   WHERE tiknr = i_ticket.

* Empfängeradresse erzeugen und zuordnen
  lv_email     = i_to.
  CALL FUNCTION 'CREATE_RECIPIENT_OBJ_PPF'
    EXPORTING
      ip_mailaddr       = lv_email
      ip_type_id        = 'U'      " Internetadresse
    IMPORTING
      ep_recipient_id   = ls_mail_recipient
    EXCEPTIONS
      invalid_recipient = 1
      OTHERS            = 2.
  IF sy-subrc <> 0. RETURN. ENDIF.

*Absender erzeugen und zuordnen
  CALL FUNCTION 'CREATE_SENDER_OBJECT_PPF'
    EXPORTING
      ip_sender      = sy-uname
    IMPORTING
      ep_sender_id   = ls_mail_sender
    EXCEPTIONS
      invalid_sender = 1
      OTHERS         = 2.
  IF sy-subrc <> 0. RETURN. ENDIF.


* Verarbeitenden Funktionsbaustein zu Formular ermitteln
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = i_formname
    IMPORTING
      fm_name  = lv_fm_name.

* Ausgabeparameter setzen:
  ls_control_param-device      = 'MAIL'.
  ls_control_param-no_dialog   = abap_true.
  ls_control_param-preview     = abap_false.
  ls_control_param-langu       = sy-langu.

  ls_output_options-tdtitle = i_subject.

* Verarbeitung des Formulares
  CALL FUNCTION lv_fm_name
    EXPORTING
      control_parameters   = ls_control_param
      mail_recipient       = ls_mail_recipient
      mail_sender          = ls_mail_sender
      output_options       = ls_output_options
      user_settings        = 'X'
      i_logo               = 'ZTICKETTOOL_LOGO'
      is_ticket            = ls_ticket_data
    IMPORTING
      document_output_info = ls_document_output_info
      job_output_info      = ls_job_output_info
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    RETURN.
  ELSEIF ls_job_output_info-outputdone = 'X'.
    " Alles ok. Mailauftrag erzeugt.
    IF abap_true = i_commit.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD create_mail_text_dark.
  DATA lr_me        TYPE REF TO zcl_book_email.
  DATA lr_mail      TYPE REF TO cl_bcs.
  DATA lr_sender    TYPE REF TO cl_cam_address_bcs.
  DATA lr_recipient TYPE REF TO if_recipient_bcs.
  DATA lv_uname     TYPE xubname.
  DATA lv_email     TYPE ad_smtpadr.
  DATA lt_mailtext  TYPE soli_tab.
  DATA lv_subject   TYPE so_obj_des.
  DATA lv_body      TYPE string.

* Sendeauftrag vom System anfordern:
  lr_mail = cl_bcs=>create_persistent( ).
  CREATE OBJECT lr_me.

* Titel der Mail Übernehmen
  lv_subject =  i_subject.

* HTML-Formatierter Mailinhalt
  CONCATENATE lv_body
    `<table cellspacing="1" cellpadding="1"`
    ` width="400" border="0">`           INTO lv_body.
  CONCATENATE lv_body `<tbody>`          INTO lv_body.
  CONCATENATE lv_body `<tr><td valign="top"><strong>`
    `Hallo User!`
    `</strong></td></tr><tr><td>`
    `Bitte bearbeite das Ticket` i_ticket
    ` in unserem Ticketsystem</td></tr>` INTO lv_body.
  CONCATENATE lv_body `</tbody></table>` INTO lv_body.

  lt_mailtext =
    cl_document_bcs=>string_to_soli( lv_body ).

  lr_me->pr_document =
    cl_document_bcs=>create_document( i_type = 'HTM'
                            i_text = lt_mailtext
                            i_subject = lv_subject  ).

* Inhalt dem Sendeauftrag zuordnen
  lr_mail->set_document( lr_me->pr_document ).

* Absenderadresse erzeugen: Hier muß eine valide Adresse
* verwendet werden.
  lr_sender =
    cl_cam_address_bcs=>create_internet_address(
                         'ticketsystem@inwerken.de' ).
* Absender zuordnen
  lr_mail->set_sender( lr_sender ).

* Empfängeradresse erzeugen und zuordnen
  TRY.
      lv_uname = i_to.
      lr_recipient =
        cl_cam_address_bcs=>create_user_home_address(
                    i_user     = lv_uname
                    i_commtype = 'INT'
                       "Internetadresse = E-Mail
        ).
      IF abap_true = i_add_link.
*        SAP-Link zum Ticket anhängen
        lr_me->add_ticket_link( i_ticket ).
      ENDIF.

    CATCH cx_address_bcs.
      lv_email     = i_to.
      lr_recipient =
        cl_cam_address_bcs=>create_internet_address(
                                          lv_email ).
  ENDTRY.

  lr_mail->add_recipient( lr_recipient ).
* Sofort senden aktivieren, andernfalls
* versendet "SCOT" beim nächsten Joblauf
  lr_mail->set_send_immediately( abap_true ).

  lr_mail->send( ).

  IF abap_true EQ i_commit.
    COMMIT WORK AND WAIT.
  ENDIF.

*     Auslesen der Empfängerliste
  lr_me->pt_recipients = lr_mail->recipients( ).
  r_mail = lr_me.
ENDMETHOD.


METHOD get_mail_as_text.
  DATA lv_objdes                      TYPE sood-objdes.
  DATA ls_recip                       TYPE recip_bcs.
  DATA lr_recipient                   TYPE REF TO if_recipient_dialog_bcs.
  DATA lv_string                      TYPE string.

* Titel:
  lv_objdes = pr_document->get_subject( ).
  CONCATENATE 'Subj:' lv_objdes INTO r_string.

  LOOP AT pt_recipients INTO ls_recip.
    lr_recipient ?= ls_recip-recipient.
    lv_string = lr_recipient->get_recipient_name( ).
    IF NOT ls_recip-sndcp IS INITIAL.     "Empfänger ist CC:
      CONCATENATE 'cc:  ' lv_string INTO lv_string RESPECTING BLANKS.
    ELSEIF NOT ls_recip-sndbc IS INITIAL. "Empfänger ist BCC:
      CONCATENATE 'bcc: ' lv_string INTO lv_string RESPECTING BLANKS.
    ELSE.                                 "Empfänger An:
      CONCATENATE 'An:  ' lv_string INTO lv_string RESPECTING BLANKS.
    ENDIF.
    CONCATENATE r_string lv_string INTO r_string SEPARATED BY cv_crlf.
  ENDLOOP.

* Übernehmen des Textes:
  lv_string = get_mail_body( ).

  CONCATENATE r_string lv_string INTO r_string SEPARATED BY cv_crlf.

ENDMETHOD.


METHOD get_mail_body.
  DATA  lv_count                      TYPE i.
  DATA  lv_docnum                     TYPE int4.
  DATA  ls_doc                        TYPE bcss_dbpc.
  DATA  ls_doc_att                    TYPE bcss_dbpa.
  DATA  lv_line                       TYPE soli.
  DATA  lv_attachment_list            TYPE string.

  TRY.
      lv_count = pr_document->get_body_part_count( ).
      DO lv_count TIMES.
        ADD 1 TO lv_docnum.
        ls_doc_att = me->pr_document->get_body_part_attributes( im_part = lv_docnum  ).

        IF NOT ls_doc_att-filename IS INITIAL.
          CONCATENATE lv_attachment_list ls_doc_att-filename
            INTO lv_attachment_list SEPARATED BY cv_crlf.
          CONTINUE.
        ENDIF.

        ls_doc     = me->pr_document->get_body_part_content( im_part = lv_docnum  ).
        LOOP AT ls_doc-cont_text INTO lv_line.
          CONCATENATE r_body lv_line INTO r_body.
          "kein separated by cv_crlf da formatierung in der solitab steckt.
        ENDLOOP.
      ENDDO.
      IF 0 < STRLEN( lv_attachment_list ).
        CONCATENATE r_body 'Attachments:' lv_attachment_list
          INTO r_body SEPARATED BY cv_crlf.
      ENDIF.
    CATCH cx_document_bcs .
  ENDTRY.

ENDMETHOD.


METHOD get_text_template.

  DATA lt_html      TYPE STANDARD TABLE OF  htmlline.
  DATA ls_header    TYPE thead.
  DATA lt_lines     TYPE tline_tab.
  DATA ls_html_line TYPE htmlline.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'ST'
      language = 'DE'
      name     = i_template
      object   = 'TEXT'
    IMPORTING
      header   = ls_header
    TABLES
      lines    = lt_lines.

  IF lt_lines IS NOT INITIAL.
    CALL FUNCTION 'CONVERT_ITF_TO_HTML'
      EXPORTING
        i_header    = ls_header
      TABLES
        t_itf_text  = lt_lines
        t_html_text = lt_html.
    IF sy-subrc = 0.
      LOOP AT lt_html INTO ls_html_line.
        CONCATENATE rv_body ls_html_line INTO rv_body.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
