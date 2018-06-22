FORM CD_CALL_ZBOOK_TICKET.
  IF   ( UPD_ZBOOK_TICKET NE SPACE )
  .
    CALL FUNCTION 'ZBOOK_TICKET_WRITE_DOCUMENT' IN UPDATE TASK
        EXPORTING
          OBJECTID                = OBJECTID
          TCODE                   = TCODE
          UTIME                   = UTIME
          UDATE                   = UDATE
          USERNAME                = USERNAME
          PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
          OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
          PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
          NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
* workarea_old of ZBOOK_TICKET
          O_ZBOOK_TICKET
                      = OS_ZBOOK_TICKET
* workarea_new of ZBOOK_TICKET
          N_ZBOOK_TICKET
                      = NS_ZBOOK_TICKET
* updateflag of ZBOOK_TICKET
          UPD_ZBOOK_TICKET
                      = UPD_ZBOOK_TICKET
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
