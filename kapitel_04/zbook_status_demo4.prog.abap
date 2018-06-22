*&---------------------------------------------------------------------*
*& Report ZBOOK_STATUS_DEMO4
*&---------------------------------------------------------------------*
REPORT zbook_status_demo4.

DATA gs_demo TYPE zbook_status_demo4.
CLEAR gs_demo-s01.              " Zugriff auf die Gruppe
gs_demo-s01-status = 'OPEN'.    " Zugriff auf ein Gruppenfeld
gs_demo-sttext$01 = 'Eröffnet'. " Direkter Feldbezug
