*----------------------------------------------------------------------*
***INCLUDE MZBOOK_DEMO_DYN_GRIDF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LISTBOX_CLAS
*&---------------------------------------------------------------------*
FORM listbox_clas .

  DATA lt_values TYPE vrm_values.

  CLEAR zbook_ticket-clas.

  SELECT clas AS key
         ctext AS text
    FROM zbook_clast
    INTO TABLE lt_values
   WHERE area = zbook_ticket-area
     AND spras = sy-langu.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'ZBOOK_TICKET-CLAS'
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.


ENDFORM.                    " LISTBOX_CLAS
