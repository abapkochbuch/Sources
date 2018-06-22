*&---------------------------------------------------------------------*
*& Include MZBOOK_DEMOTOP                                    Modulpool        SAPMZBOOK_DEMO
*&
*&---------------------------------------------------------------------*

PROGRAM sapmzbook_demo.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'TC_DEMO'
CONSTANTS: BEGIN OF c_tc_demo,
             tab1 LIKE sy-ucomm VALUE 'TC_DEMO_FC1',
             tab2 LIKE sy-ucomm VALUE 'TC_DEMO_FC2',
             tab3 LIKE sy-ucomm VALUE 'TC_DEMO_FC3',
             tab4 LIKE sy-ucomm VALUE 'TC_DEMO_FC4',
           END OF c_tc_demo.
*&SPWIZARD: DATA FOR TABSTRIP 'TC_DEMO'
CONTROLS:  tc_demo TYPE TABSTRIP.
DATA:      BEGIN OF g_tc_demo,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPMZBOOK_DEMO',
             pressed_tab LIKE sy-ucomm VALUE c_tc_demo-tab1,
           END OF g_tc_demo.
DATA:      sy-ucomm LIKE sy-ucomm.


TABLES vbak.
TABLES vbap.
DATA gt_vbak TYPE STANDARD TABLE OF vbak.
DATA gt_vbap TYPE STANDARD TABLE OF vbap.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_VBAK' ITSELF
CONTROLS: TC_VBAK TYPE TABLEVIEW USING SCREEN 0501.
