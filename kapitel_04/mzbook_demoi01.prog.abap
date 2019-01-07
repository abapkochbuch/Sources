*&---------------------------------------------------------------------*
*&      Module  TC_DEMO_ACTIVE_TAB_GET  INPUT
*&---------------------------------------------------------------------*
*&SPWIZARD: GETS ACTIVE TAB
MODULE tc_demo_active_tab_get INPUT.

  CASE sy-ucomm.
    WHEN c_tc_demo-tab1.
      g_tc_demo-pressed_tab = c_tc_demo-tab1.
    WHEN c_tc_demo-tab2.
      g_tc_demo-pressed_tab = c_tc_demo-tab2.
    WHEN c_tc_demo-tab3.
      g_tc_demo-pressed_tab = c_tc_demo-tab3.
    WHEN c_tc_demo-tab4.
      g_tc_demo-pressed_tab = c_tc_demo-tab4.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
