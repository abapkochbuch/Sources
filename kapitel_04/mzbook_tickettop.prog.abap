*&---------------------------------------------------------------------*
*& Include MZBOOK_TICKETTOP                                  Modulpool        SAPMZBOOK_TICKET
*&
*&---------------------------------------------------------------------*

PROGRAM  sapmzbook_ticket MESSAGE-ID zbook.

TYPE-POOLS vrm.
TYPE-POOLS icon.

*TABLES zbook_ticket.
TABLES zbook_ticket_dynpro.
DATA gs_ticket_dynpro_original    TYPE zbook_ticket_dynpro.


DATA gv_okcode                     TYPE syucomm.
DATA gt_values_class               TYPE vrm_values.

DATA gr_docker_right               TYPE REF TO cl_gui_docking_container.
DATA gr_docker_left                TYPE REF TO cl_gui_docking_container.
*DATA gr_splitter_right             TYPE REF TO cl_gui_splitter_container.
DATA gr_container01                TYPE REF TO cl_gui_container.
DATA gr_container02                TYPE REF TO cl_gui_container.
DATA gr_container03                TYPE REF TO cl_gui_container.
DATA gr_container04                TYPE REF TO cl_gui_container.
DATA gr_container05                TYPE REF TO cl_gui_container.
DATA gr_container06                TYPE REF TO cl_gui_container.

DATA gr_text01                     TYPE REF TO cl_gui_textedit.
DATA gr_text_ticket                TYPE REF TO cl_gui_textedit.
DATA gr_picture01                  TYPE REF TO cl_gui_picture.
DATA gr_picture02                  TYPE REF TO cl_gui_picture.

DATA gr_splitter_admin_right       TYPE REF TO zcl_book_splitter_admin.
DATA gr_splitter_admin_left        TYPE REF TO zcl_book_splitter_admin.
DATA gr_splitadmin_left            TYPE REF TO zcl_book_splitter_admin.

DATA gr_drawer                     TYPE REF TO cl_gui_container_bar.

DATA gr_textarea                   TYPE REF TO cl_gui_custom_container.
DATA gr_team_tree                  TYPE REF TO zcl_book_team.
DATA gr_hist_cntl                  TYPE REF TO zcl_book_ticket_hist_cntl.
DATA gr_button                     TYPE REF TO zcl_book_html_button.
DATA gr_button_save                TYPE REF TO zcl_book_html_button.
DATA gr_button_close               TYPE REF TO zcl_book_html_button_close.
DATA gr_button_decline             TYPE REF TO zcl_book_html_button_decline.

DATA gr_status_cntl                TYPE REF TO zcl_book_ctrl_status.
DATA gr_status_document            TYPE REF TO zcl_book_status_document.

DATA gr_log                        TYPE REF TO zcl_book_ticket_log.
DATA gr_msg                        TYPE REF TO zcl_book_ticket_log_msg.

DATA gs_zbook_pers                 TYPE zbook_pers.

*--------------------------------------------------------------------*
* Dyn. Attribute
DATA gr_dyn_attributes             TYPE REF TO zcl_book_ticket_dyn_attributes.
*--------------------------------------------------------------------*
DATA  gv_demo                      TYPE c LENGTH 5.
CLASS lcl_appl     DEFINITION DEFERRED.
DATA gr_appl                       TYPE REF TO lcl_appl.
DATA gr_gos                        TYPE REF TO zcl_book_gos_wrapper.

DATA gr_var_values                 TYPE REF TO zcl_book_dyn_multi.
DATA gr_dyn_data_grid              TYPE REF TO zcl_book_dynamic_data_grid.

CLASS lcl_application DEFINITION DEFERRED.
