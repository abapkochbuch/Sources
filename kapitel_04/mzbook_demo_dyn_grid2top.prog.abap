*&---------------------------------------------------------------------*
*& Include MZBOOK_DEMOTOP                                    Modulpool        SAPMZBOOK_DEMO
*&
*&---------------------------------------------------------------------*

PROGRAM sapmzbook_demo.
TABLES zbook_ticket.
DATA gr_dd_grid      TYPE REF TO zcl_book_dynamic_data_grid.
DATA gs_zbook_ticket type zbook_ticket.
