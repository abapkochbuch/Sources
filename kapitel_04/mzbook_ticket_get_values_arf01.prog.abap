*----------------------------------------------------------------------*
***INCLUDE MZBOOK_TICKET_GET_VALUES_ARF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_VALUES_AREA
*&---------------------------------------------------------------------*
FORM get_values_area .


  CLEAR zbook_ticket_dynpro-clastik.

*== get area text
  SELECT clas AS key
         ctext AS text
    FROM zbook_clast
    INTO TABLE gt_values_class
   WHERE area = zbook_ticket_dynpro-areatik
     AND spras = sy-langu.

*== set values
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'ZBOOK_TICKET_DYNPRO-CLASTIK'
      values          = gt_values_class
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

ENDFORM.                    " GET_VALUES_AREA
