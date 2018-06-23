*"---------------------------------------------------------------------*
*" Report  ZBOOK_TICKET_OVERVIEW
*"---------------------------------------------------------------------*
*"                                                                     *
*"        _____ _   _ _    _ ___________ _   _______ _   _             *
*"       |_   _| \ | | |  | |  ___| ___ \ | / /  ___| \ | |            *
*"         | | |  \| | |  | | |__ | |_/ / |/ /| |__ |  \| |            *
*"         | | | . ` | |/\| |  __||    /|    \|  __|| . ` |            *
*"        _| |_| |\  \  /\  / |___| |\ \| |\  \ |___| |\  |            *
*"        \___/\_| \_/\/  \/\____/\_| \_\_| \_|____/\_| \_/            *
*"                                                                     *
*"                                           einfach anders            *
*"                                                                     *
*"---------------------------------------------------------------------*

REPORT zbook_ticket_overview.

DATA: gv_tiknr TYPE zbook_ticket_nr,
      gv_area  TYPE zbook_area,
      gv_clas  TYPE zbook_clas,
      gv_resp  TYPE zbook_person_repsonsible,
      gv_stat  TYPE zbook_ticket_status.

DATA: gr_custom_cont TYPE REF TO cl_gui_custom_container,
      gr_dock_cont   TYPE REF TO cl_gui_docking_container,
      gr_book_ticket TYPE REF TO zcl_book_ticket_overview,
      gr_team_tree   TYPE REF TO zcl_book_team,
      gs_selection   TYPE        zbook_ticket_so_ranges,
      ok_code        TYPE        sy-ucomm.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_tiknr FOR gv_tiknr,
                so_area  FOR gv_area,
                so_clas  FOR gv_clas,
                so_resp  FOR gv_resp,
                so_stat  FOR gv_stat.
SELECTION-SCREEN END OF BLOCK sel.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari LIKE gs_selection-variant-variant.

SELECTION-SCREEN SKIP 3.
PARAMETERS p_docker AS CHECKBOX DEFAULT space.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.

* Aufbauen der Wertehilfe für die ALV-Layout auswahl auf dem Selektionsbild
  PERFORM value_request.

*"* Init
INITIALIZATION.

  CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
    EXPORTING
      report               = sy-repid
      variant              = '/STD'
    EXCEPTIONS
      variant_not_existent = 1
      variant_obsolete     = 2
      OTHERS               = 3.

  gs_selection-variant-report   = sy-repid.
  gs_selection-variant-username = sy-uname.

*"* Start of program
START-OF-SELECTION.

  gs_selection-variant-variant = p_vari.
  gs_selection-so_tiknr        = so_tiknr[].
  gs_selection-so_area         = so_area[].
  gs_selection-so_clas         = so_clas[].
  gs_selection-so_resp         = so_resp[].
  gs_selection-so_stat         = so_stat[].

  CALL SCREEN 0100.

  INCLUDE zbook_ticket_overview_pbo.
  INCLUDE zbook_ticket_overview_pai.
  INCLUDE zbook_ticket_overview_f01.
