*&---------------------------------------------------------------------*
*&      Form  LOCATION2RADIO
*&---------------------------------------------------------------------*
FORM location2radio using location type zbook_location.

  CLEAR gs_location.

  CASE location.
    WHEN 'HH'.   gs_location-hh  = 'X'.
    WHEN 'HB'.   gs_location-hb  = 'X'.
    WHEN 'H'.    gs_location-h   = 'X'.
    WHEN 'FFM'.  gs_location-ffm = 'X'.
    WHEN 'M'.    gs_location-m   = 'X'.
    WHEN 'S'.    gs_location-s   = 'X'.
  ENDCASE.

  PERFORM check_location.

ENDFORM.                    " LOCATION2RADIO

*&---------------------------------------------------------------------*
*&      Form  radio2location
*&---------------------------------------------------------------------*
FORM radio2location changing location type zbook_location.

  CASE 'X'.
    WHEN gs_location-hh.  location = 'HH'.
    WHEN gs_location-hb.  location = 'HB'.
    WHEN gs_location-h.   location = 'H'.
    WHEN gs_location-ffm. location = 'FFM'.
    WHEN gs_location-m.   location = 'M'.
    WHEN gs_location-s.   location = 'S'.
  ENDCASE.

ENDFORM.                    "radio2location
