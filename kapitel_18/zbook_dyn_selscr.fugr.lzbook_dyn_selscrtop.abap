FUNCTION-POOL zbook_dyn_selscr.             "MESSAGE-ID ..



*DATA: gv_area         TYPE zbook_ticket-area,
*      gv_class        TYPE zbook_ticket-clas.



SELECTION-SCREEN BEGIN OF SCREEN 9000 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK dyn_template.
INCLUDE zbook_dyn_selscr_template_incl.
SELECTION-SCREEN END OF BLOCK dyn_template.
SELECTION-SCREEN END OF SCREEN 9000.
