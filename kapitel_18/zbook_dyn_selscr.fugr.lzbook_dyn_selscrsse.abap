*&---------------------------------------------------------------------*
*&  Include           LZBOOK_DYN_SELSCRSSE
*&---------------------------------------------------------------------*
*  DATA: lv_repid            TYPE syrepid,
*        lt_sscr             LIKE gt_first_sscr,
*        ls_this_screen_prog LIKE gs_first_screen_prog.
*

  AT SELECTION-SCREEN OUTPUT.

    zcl_book_dyn_selscr=>dyn_screen_pbo( is_dyn_field_settings = gs_zbook_dyn_selscr_parameters ).
    zcl_book_dyn_selscr=>refresh_dyn_screen( iv_dyn_selscr_fields = gs_zbook_dyn_selscr_parameters ).


  AT SELECTION-SCREEN ON BLOCK dyn_template.
*  break sschmoecker.

  AT SELECTION-SCREEN ON p_dyn01.
*  break sschmoecker.

  AT SELECTION-SCREEN.
*  break sschmoecker.
