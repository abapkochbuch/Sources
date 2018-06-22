class ZCL_BOOK_TICKET_OVERVIEW definition
  public
  final
  create private .

*"* public components of class ZCL_BOOK_TICKET_OVERVIEW
*"* do not include other source files here!!!
public section.
  type-pools ICON .

  interfaces ZIF_GUI_ALV_GRID .

  class-methods GET_INSTANCE
    importing
      !IS_SELECTION type ZBOOK_TICKET_SO_RANGES
      !IR_CONT type ref to CL_GUI_CONTAINER
    returning
      value(ER_INSTANCE) type ref to ZCL_BOOK_TICKET_OVERVIEW .
protected section.
*"* protected components of class ZCL_BOOK_TICKET
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_TICKET_OVERVIEW
*"* do not include other source files here!!!

  data R_ALV type ref to CL_GUI_ALV_GRID .
  data T_FCAT type LVC_T_FCAT .
  data S_LAYOUT type LVC_S_LAYO .
  data S_VARIANT type DISVARIANT .
  data T_DATA type ZBOOK_TT_TICKET_OVERVIEW .
  class-data R_INSTANCE type ref to ZCL_BOOK_TICKET_OVERVIEW .
  data S_SELECTION type ZBOOK_TICKET_SO_RANGES .
  data T_EXCL type UI_FUNCTIONS .
  constants C_FC_DELETE type SY-UCOMM value 'DELETE'. "#EC NOTEXT
  data R_DRAG_DROP type ref to CL_DRAGDROP .
  data D_DND_HANDLE_COPY type I .
  constants C_STATUS_CLSD type ZBOOK_TICKET_STATUS value 'CLSD'. "#EC NOTEXT
  data R_CONT type ref to CL_GUI_CONTAINER .
  constants C_DROP_DOWN_HNDL type I value '1'. "#EC NOTEXT

  methods SETUP_ALV .
  methods ADD_INFO .
  methods CONSTRUCTOR
    importing
      !IS_SELECTION type ZBOOK_TICKET_SO_RANGES
      !IR_CONT type ref to CL_GUI_CONTAINER .
  methods BUILD_DISPLAY_OPTIONS .
  methods GET_DATA .
  methods DELETE_ROWS
    importing
      !SENDER type ref to CL_GUI_ALV_GRID
      !IV_WITH_DB type XFELD optional .
  methods SETUP_DRAG_DROP .
  methods BUILD_DROPDOWN_TABLE .
ENDCLASS.



CLASS ZCL_BOOK_TICKET_OVERVIEW IMPLEMENTATION.


METHOD add_info.
  DATA: ls_styl    TYPE lvc_s_styl,
        ls_dndtab  TYPE lvc_s_drdr.
  FIELD-SYMBOLS: <ls_data> LIKE LINE OF t_data.

  LOOP AT t_data ASSIGNING <ls_data>.
    CLEAR ls_dndtab.
    IF <ls_data>-status <> c_status_clsd.
      ls_styl-fieldname = 'CHANGE_ITEM'.
      ls_styl-style     = cl_gui_alv_grid=>mc_style_button.
      INSERT ls_styl INTO TABLE <ls_data>-t_style.
      <ls_data>-change_item = icon_change.
      IF <ls_data>-responsible IS INITIAL.
        ls_dndtab-dragdropid = d_dnd_handle_copy.
        ls_dndtab-fieldname  = 'RESPONSIBLE'.
        APPEND ls_dndtab TO <ls_data>-t_dndtab.
      ENDIF.
    ENDIF.

    ls_styl-fieldname = 'TEXT'.
    ls_styl-style     = cl_gui_alv_grid=>mc_style_disabled.
    INSERT ls_styl INTO TABLE <ls_data>-t_style.
  ENDLOOP.
ENDMETHOD.


METHOD build_display_options.
  FIELD-SYMBOLS: <ls_fcat> TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZBOOK_TICKET_OVERVIEW'
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = t_fcat.

  DELETE t_fcat WHERE fieldname = 'R_LOG'.

  LOOP AT t_fcat ASSIGNING <ls_fcat>.
    CASE <ls_fcat>-fieldname.
      WHEN 'CHECKBOX'.
        <ls_fcat>-checkbox = 'X'.
        <ls_fcat>-edit     = 'X'.
      WHEN 'ICON_STAT'.
        <ls_fcat>-icon = 'X'.
      WHEN 'CHANGE_ITEM'.
        <ls_fcat>-icon = 'X'.
      WHEN 'AETIM'.
        <ls_fcat>-no_zero = 'X'.
      WHEN 'STATUS'.
        <ls_fcat>-drdn_hndl = c_drop_down_hndl.
        <ls_fcat>-edit      = 'X'.
    ENDCASE.
  ENDLOOP.

  s_layout-cwidth_opt = 'X'.
  s_layout-stylefname = 'T_STYLE'.
  s_layout-s_dragdrop-fieldname = 'T_DNDTAB'.

  s_layout-no_rowmark = 'X'.

  APPEND cl_gui_alv_grid=>mc_fg_edit TO t_excl.
ENDMETHOD.


METHOD build_dropdown_table.

  DATA: lt_dropdown TYPE         lvc_t_drop,
        ls_dropdown LIKE LINE OF lt_dropdown,

        lt_dd07v    TYPE TABLE OF dd07v,
        ls_dd07v    LIKE LINE OF lt_dd07v.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZBOOK_TICKET_STATUS'
    TABLES
      dd07v_tab = lt_dd07v.

  LOOP AT lt_dd07v INTO ls_dd07v.
    ls_dropdown-handle = c_drop_down_hndl.
    ls_dropdown-value  = ls_dd07v-domvalue_l.
    APPEND ls_dropdown TO lt_dropdown.
  ENDLOOP.

  CALL METHOD r_alv->set_drop_down_table
    EXPORTING
      it_drop_down = lt_dropdown.
ENDMETHOD.


METHOD CONSTRUCTOR.

  s_selection = is_selection.
  r_cont      = ir_cont.

* Aufbauen des Feldkatalogs, Layout
  me->build_display_options( ).

  me->setup_drag_drop( ).

  me->get_data( ).

  me->add_info( ).

  me->setup_alv(  ).

ENDMETHOD.


METHOD delete_rows.

  DATA: ls_data  LIKE LINE OF t_data,
        ld_tabix TYPE         sy-tabix.

  DATA: lt_row_no TYPE lvc_t_roid.
  BREAK-POINT.

  LOOP AT t_data INTO ls_data WHERE checkbox = 'X'.
    ld_tabix = sy-tabix.
    IF iv_with_db = 'X'.
      DELETE FROM zbook_ticket WHERE tiknr = ls_data-tiknr.
    ENDIF.
    DELETE t_data INDEX ld_tabix.
  ENDLOOP.

  sender->refresh_table_display( ).

ENDMETHOD.


METHOD get_data.
  SELECT *
      FROM zbook_ticket
      INTO CORRESPONDING FIELDS OF TABLE t_data
      WHERE tiknr       IN s_selection-so_tiknr
        AND area        IN s_selection-so_area
        AND clas        IN s_selection-so_clas
        AND status      IN s_selection-so_stat
        AND responsible IN s_selection-so_resp.
ENDMETHOD.


METHOD get_instance.

  IF r_instance IS NOT BOUND.
    CREATE OBJECT r_instance
      EXPORTING
        is_selection = is_selection
        ir_cont      = ir_cont.
  ENDIF.

  er_instance = r_instance.
  RETURN.

ENDMETHOD.


METHOD setup_alv.

  CREATE OBJECT r_alv
    EXPORTING
      i_parent      = r_cont.

  me->build_dropdown_table( ).

  CALL METHOD r_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  SET HANDLER me->zif_gui_alv_grid~handle_toolbar             FOR r_alv.
  SET HANDLER me->zif_gui_alv_grid~handle_before_user_command FOR r_alv.
  SET HANDLER me->zif_gui_alv_grid~handle_user_command        FOR r_alv.
  SET HANDLER me->zif_gui_alv_grid~handle_button_click        FOR r_alv.
  SET HANDLER me->zif_gui_alv_grid~handle_ondrop              FOR r_alv.

  CALL METHOD r_alv->set_table_for_first_display
   EXPORTING
     i_bypassing_buffer            = 'X'
     is_variant                    = s_selection-variant
     i_save                        = 'X'
     i_default                     = ' '
     it_toolbar_excluding          = t_excl
     is_layout                     = s_layout
   CHANGING
     it_outtab                     = t_data
     it_fieldcatalog               = t_fcat.

ENDMETHOD.


METHOD setup_drag_drop.
  CREATE OBJECT r_drag_drop.

  CALL METHOD r_drag_drop->add
    EXPORTING
      flavor     = 'copy'
      dragsrc    = ' '
      droptarget = 'X'
      effect     = cl_dragdrop=>copy.

  CALL METHOD r_drag_drop->get_handle
    IMPORTING
      handle = d_dnd_handle_copy.
ENDMETHOD.


method ZIF_GUI_ALV_GRID~HANDLE_AFTER_REFRESH.
endmethod.


METHOD zif_gui_alv_grid~handle_after_user_command.

ENDMETHOD.


METHOD zif_gui_alv_grid~handle_before_user_command.
  DATA: ls_data          LIKE LINE OF me->t_data,
        ld_multiple_rows TYPE xfeld,
        ld_index         TYPE sy-index.

  IF e_ucomm = me->r_alv->mc_fc_detail.

    sender->check_changed_data( ).

    CALL METHOD me->r_alv->set_user_command
      EXPORTING
        i_ucomm = space.

    LOOP AT t_data  INTO ls_data WHERE checkbox = 'X'.
      ADD 1 TO ld_index.
      IF ld_index > 1.
        ld_multiple_rows = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF ld_multiple_rows = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'Bitte nur eine Zeile markieren'.
      RETURN.
    ELSE.
        SET PARAMETER ID 'ZBOOK_TICKET_NR' FIELD ls_data-tiknr.
        CALL TRANSACTION 'ZTIK2' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD ZIF_GUI_ALV_GRID~HANDLE_BUTTON_CLICK.

  FIELD-SYMBOLS: <ls_data>  LIKE LINE OF t_data,
                 <ls_style> TYPE         lvc_s_styl.

  READ TABLE t_data ASSIGNING <ls_data> INDEX es_row_no-row_id.

  IF sy-subrc = 0.
    READ TABLE <ls_data>-t_style ASSIGNING <ls_style> WITH KEY fieldname = 'TEXT'.

    IF sy-subrc = 0.
      IF <ls_style>-style = cl_gui_alv_grid=>mc_style_disabled.
        <ls_style>-style       = cl_gui_alv_grid=>mc_style_enabled.
        <ls_data>-change_item  = icon_display.
      ELSE.
        <ls_style>-style       = cl_gui_alv_grid=>mc_style_disabled.
        <ls_data>-change_item  = icon_change.
      ENDIF.
      sender->refresh_table_display( ).
    ENDIF.
  ENDIF.
ENDMETHOD.


method ZIF_GUI_ALV_GRID~HANDLE_CONTEXT_MENU_REQUEST.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_DATA_CHANGED.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_DATA_CHANGED_FINISHED.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_DELAYED_CALLBACK.
  break-point.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_DOUBLE_CLICK.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_END_OF_LIST.
endmethod.


METHOD ZIF_GUI_ALV_GRID~HANDLE_HOTSPOT_CLICK.

ENDMETHOD.


METHOD zif_gui_alv_grid~handle_menu_button.

ENDMETHOD.


method ZIF_GUI_ALV_GRID~HANDLE_ONDRAG.
endmethod.


METHOD zif_gui_alv_grid~handle_ondrop.

  DATA: ls_items        TYPE treemlitem,
        lt_items        TYPE treemlitab,
        lr_dragdropdata TYPE REF TO zcl_dnd_model_tree.

  FIELD-SYMBOLS: <ls_data> LIKE LINE OF t_data.

  TRY.
      CREATE OBJECT lr_dragdropdata.
      lr_dragdropdata ?= e_dragdropobj->object.
      lt_items = lr_dragdropdata->get_litem_table( ).
      READ TABLE lt_items INTO ls_items INDEX lr_dragdropdata->item_index.
      READ TABLE t_data ASSIGNING <ls_data> INDEX es_row_no-row_id.
      IF sy-subrc = 0.
        <ls_data>-responsible = ls_items-text.
        DELETE <ls_data>-t_dndtab WHERE fieldname  = 'RESPONSIBLE'
                                    AND dragdropid = d_dnd_handle_copy.
        UPDATE zbook_ticket
         SET responsible = <ls_data>-responsible
         WHERE tiknr     = <ls_data>-tiknr.

        IF sy-subrc = 0.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    CATCH cx_sy_move_cast_error.
      e_dragdropobj->abort( ).
  ENDTRY.

  r_alv->refresh_table_display( ).
  cl_gui_cfw=>flush( ).

ENDMETHOD.


method ZIF_GUI_ALV_GRID~HANDLE_ONDROPCOMPLETE.
*  break-point.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_ONDROPGETFLAVOR.
  break-point.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_ONF1.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_ONF4.
  break-point.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_PRINT_END_OF_LIST.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_PRINT_END_OF_PAGE.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_PRINT_TOP_OF_LIST.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_PRINT_TOP_OF_PAGE.
endmethod.


method ZIF_GUI_ALV_GRID~HANDLE_SUBTOTAL_TEXT.
endmethod.


METHOD zif_gui_alv_grid~handle_toolbar.
  DATA: ls_menu    TYPE stb_btnmnu,
        lo_menu    TYPE REF TO cl_ctmenu,
        ls_toolbar LIKE LINE OF e_object->mt_toolbar.

  ls_toolbar-function  = 'DEL'.
  ls_toolbar-butn_type = 1.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = 'ICON_DELETE'
      info   = 'Ticket löschen'
    IMPORTING
      result = ls_toolbar-icon.
  APPEND ls_toolbar TO e_object->mt_toolbar.

  CREATE OBJECT lo_menu.

  CALL METHOD lo_menu->add_function
    EXPORTING
      fcode = 'DEL_WITHOUT_DB'
      text  = 'Löschen ohne DB-Update'.

  CALL METHOD lo_menu->add_function
    EXPORTING
      fcode = 'DEL_WITH_DB'
      text  = 'Löschen mit DB-Update'.

  ls_menu-ctmenu = lo_menu.
  ls_menu-function = 'DEL'.

  APPEND ls_menu TO e_object->mt_btnmnu.

ENDMETHOD.


method ZIF_GUI_ALV_GRID~HANDLE_TOP_OF_PAGE.
endmethod.


METHOD zif_gui_alv_grid~handle_user_command.
  sender->check_changed_data( ).
  CASE e_ucomm.
    WHEN 'DEL_WITH_DB'.
      me->delete_rows( sender     = sender
                       iv_with_db = 'X' ).
    WHEN 'DEL_WITHOUT_DB'.
      me->delete_rows( sender = sender ).
  ENDCASE.
ENDMETHOD.


method ZIF_GUI_ALV_GRID~HNDL_DELAYED_CHANGED_SEL_CALLB.
  break-point.
endmethod.
ENDCLASS.
