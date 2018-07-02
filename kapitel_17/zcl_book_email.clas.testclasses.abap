CLASS abap_unit_testclass DEFINITION DEFERRED.
CLASS zcl_book_email DEFINITION LOCAL FRIENDS abap_unit_testclass.
* ----------------------------------------------------------------------
CLASS abap_unit_testclass DEFINITION FOR TESTING  "#AU Duration Medium
  "#AU Risk_Level Harmless
.
* ----------------------------------------------------------------------
* ===============
  PUBLIC SECTION.
* ===============

* ==================
  PROTECTED SECTION.
* ==================

* ================
  PRIVATE SECTION.
* ================
    DATA:
      m_ref TYPE REF TO zcl_book_email.                     "#EC NOTEXT

    METHODS: setup.
    METHODS: teardown.
    METHODS: create_mail_text_dark_link FOR TESTING.
    METHODS: create_mail_text_dark FOR TESTING.
ENDCLASS.       "Abap_Unit_Testclass
* ----------------------------------------------------------------------
CLASS abap_unit_testclass IMPLEMENTATION.
* ----------------------------------------------------------------------

* ----------------------------------------------------------------------
  METHOD setup.
* ----------------------------------------------------------------------

    CREATE OBJECT m_ref.
  ENDMETHOD.       "Setup

* ----------------------------------------------------------------------
  METHOD teardown.
* ----------------------------------------------------------------------


  ENDMETHOD.       "Teardown

* ----------------------------------------------------------------------
  METHOD create_mail_text_dark_link.
* ----------------------------------------------------------------------
    DATA i_ticket TYPE zbook_ticket_nr.
    DATA i_to TYPE zbook_person_repsonsible.
    DATA i_add_link TYPE abap_bool.
    DATA i_commit TYPE abap_bool.
    DATA i_subject TYPE so_obj_des.
    DATA r_mail TYPE REF TO zcl_book_email.

    i_ticket  = 1.
    i_to      = sy-uname.
    i_subject = 'Testmail unit mit link'.

    r_mail = zcl_book_email=>create_mail_text_dark(
        i_ticket   = i_ticket
        i_to       = i_to
        i_add_link = abap_true
*       I_COMMIT = I_Commit
       i_subject = i_subject
    ).

    cl_aunit_assert=>assert_bound(
      act   = r_mail
      msg   = 'Testing value R_Mail'
*     level =
    ).

  ENDMETHOD.       "Add_Ticket_Link

* ----------------------------------------------------------------------
  METHOD create_mail_text_dark.
* ----------------------------------------------------------------------
    DATA i_ticket TYPE zbook_ticket_nr.
    DATA i_to TYPE zbook_person_repsonsible.
    DATA i_add_link TYPE abap_bool.
    DATA i_commit TYPE abap_bool.
    DATA i_subject TYPE so_obj_des.
    DATA r_mail TYPE REF TO zcl_book_email.

    i_ticket = '0000000002'.
    i_to   = 'uts@inwerken.de'.
    i_subject = 'Testmail unit'.

    r_mail = zcl_book_email=>create_mail_text_dark(
        i_ticket = i_ticket
        i_to = i_to
*       I_ADD_LINK = I_Add_Link
*       I_COMMIT = I_Commit
        i_subject = i_subject
    ).
    CALL METHOD zcl_book_email=>create_mail_form_dark
      EXPORTING
*       i_formname = 'ZSFTICKET'
        i_ticket   = i_ticket
        i_to       = i_to
*       i_commit   = ABAP_TRUE
        i_subject  = i_subject.

    cl_aunit_assert=>assert_bound(
      act   = r_mail
      msg   = 'Testing value R_Mail'
*     level =
    ).
  ENDMETHOD.       "Create_Mail_Text_Dark


ENDCLASS.       "Abap_Unit_Testclass
