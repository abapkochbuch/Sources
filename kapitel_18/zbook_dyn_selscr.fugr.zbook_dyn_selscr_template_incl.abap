*&---------------------------------------------------------------------*
*&  Include           ZBOOK_DYN_SELSCR_TEMPLATE_INCL
*&---------------------------------------------------------------------*
  DATA: gs_zbook_dyn_selscr_parameters  TYPE zbook_dyn_selscr_fields.


  PARAMETERS:     p_dyn01 LIKE  (gs_zbook_dyn_selscr_parameters-p_dyn01) MODIF ID p01.
  SELECT-OPTIONS: s_dyn01 FOR   (gs_zbook_dyn_selscr_parameters-s_dyn01) MODIF ID s01.

  PARAMETERS:     p_dyn02 LIKE  (gs_zbook_dyn_selscr_parameters-p_dyn02) MODIF ID p02.
  SELECT-OPTIONS: s_dyn02 FOR   (gs_zbook_dyn_selscr_parameters-s_dyn02) MODIF ID s02.

  PARAMETERS:     p_dyn03 LIKE  (gs_zbook_dyn_selscr_parameters-p_dyn03) MODIF ID p03.
  SELECT-OPTIONS: s_dyn03 FOR   (gs_zbook_dyn_selscr_parameters-s_dyn03) MODIF ID s03.

  PARAMETERS:     p_dyn04 LIKE  (gs_zbook_dyn_selscr_parameters-p_dyn04) MODIF ID p04.
  SELECT-OPTIONS: s_dyn04 FOR   (gs_zbook_dyn_selscr_parameters-s_dyn04) MODIF ID s04.

*... falls mehr benötigt wird
