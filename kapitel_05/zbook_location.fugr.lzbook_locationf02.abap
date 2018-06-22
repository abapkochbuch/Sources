*&---------------------------------------------------------------------*
*&      Form  CHECK_LOCATION
*&---------------------------------------------------------------------*
FORM check_location .

  CASE 'X'.
    WHEN gs_location-s.
      MESSAGE i000(oo) WITH 'Achtung: Inventur vom 03.08. - 13.08.!' INTO gv_message.
    WHEN gs_location-hh.
      MESSAGE i000(oo) WITH 'Umzug nach HH Bahrenfeld ab Mitte Juli.' INTO gv_message.
    WHEN gs_location-m.
      MESSAGE i000(oo) WITH 'Geplante Eröffnung verschoben auf den 02.09.' INTO gv_message.
    WHEN OTHERS.
      CLEAR gv_message.
  ENDCASE.

ENDFORM.                    " CHECK_LOCATION
