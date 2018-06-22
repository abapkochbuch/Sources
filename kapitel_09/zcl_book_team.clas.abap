class ZCL_BOOK_TEAM definition
  public
  create private .

*"* public components of class ZCL_BOOK_TEAM
*"* do not include other source files here!!!
public section.

  interfaces ZIF_HNDL_TREE_MODEL .
  interfaces ZIF_HNDL_TREE_MODEL_LIST_COL .

  events ZRESP_CLICK
    exporting
      value(RESPONSIBLE) type TM_ITEMTXT .

  class-methods GET_INSTANCE
    importing
      !IR_CONT type ref to CL_GUI_CONTAINER
      !ID_EXPAND type XFELD
    returning
      value(ER_INSTANCE) type ref to ZCL_BOOK_TEAM .
protected section.
*"* protected components of class ZCL_BOOK_TEAM
*"* do not include other source files here!!!

  data T_DATA type ZBOOK_TT_TEAM .
  data T_RESPONSIBLES type TREEMNOTAB .

  methods GET_DATA .
  methods ADD_NODE
    importing
      !IS_DATA type ZBOOK_TEAM .
  methods BUILD_ITEMS
    importing
      !IS_DATA type ZBOOK_TEAM
    returning
      value(ET_ITEMS) type TREEMLITAB .
  methods SETUP_DRAG_DROP .
  methods CHECK_RESPONSIBLE
    importing
      !IV_ID type TM_NODEKEY
    returning
      value(EV_KZ_RESP) type XFELD .
private section.
*"* private components of class ZCL_BOOK_TEAM
*"* do not include other source files here!!!

  class-data R_INSTANCE type ref to ZCL_BOOK_TEAM .
  data R_TREE type ref to CL_LIST_TREE_MODEL .
  data R_DRAG_DROP type ref to CL_DRAGDROP .
  data D_DND_HANDLE_COPY type I .

  methods CONSTRUCTOR
    importing
      !IR_CONT type ref to CL_GUI_CONTAINER
      !ID_EXPAND type XFELD .
ENDCLASS.



CLASS ZCL_BOOK_TEAM IMPLEMENTATION.


METHOD add_node.
  DATA: ls_data      LIKE LINE OF t_data,
        lv_node_key  TYPE         tm_nodekey,
        lv_parent    TYPE         tm_nodekey,
        lv_folder    TYPE         xfeld,
        lt_items     TYPE         treemlitab,
        lv_drag_drop TYPE         i,
        lv_image     TYPE         tv_image.

  lv_node_key = is_data-id.
  lv_image    = is_data-icon.

  IF is_data-parent_id IS NOT INITIAL.
    lv_parent = is_data-parent_id.
  ENDIF.

  lt_items = me->build_items( is_data = is_data ).

* Prüfen ob es sich um den untersten Knoten(Mitarbeiter) handelt
  READ TABLE t_data TRANSPORTING NO FIELDS WITH KEY parent_id = is_data-id.

  IF sy-subrc <> 0.
    lv_drag_drop = me->d_dnd_handle_copy.
    APPEND lv_node_key TO t_responsibles.
  ENDIF.

  CALL METHOD me->r_tree->add_node
    EXPORTING
      node_key          = lv_node_key
      relative_node_key = lv_parent
      relationship      = me->r_tree->relat_last_child
      isfolder          = lv_folder "immer leer
      item_table        = lt_items
      drag_drop_id      = lv_drag_drop
      image             = lv_image
      expanded_image    = lv_image.

  LOOP AT t_data INTO ls_data WHERE parent_id = is_data-id.
* Alle darunter hängen die unter dem hereingegebenen Knoten hängen
    me->add_node( ls_data ).
  ENDLOOP.
ENDMETHOD.


METHOD build_items.
  DATA: ls_item   TYPE treemlitem,
        lv_cnt(4) TYPE n.

* Aufbauen des Knotentextes im ersten Item
  CLEAR ls_item.
  ADD 1 TO lv_cnt.
  ls_item-item_name = lv_cnt.
  ls_item-class     = r_tree->item_class_text.
  ls_item-alignment = r_tree->align_auto.
  ls_item-font      = r_tree->item_font_prop.
  ls_item-text      = is_data-text.
  APPEND ls_item TO et_items.

* Prüfen ob der Mitarbeiter Urlaub eingetragen hat
  IF  is_data-holiday_from IS NOT INITIAL
  AND is_data-holiday_to   IS NOT INITIAL.
* Wenn der Mitarbeiter Urlaub hat, dann den Urlaub als Item anfügen
    CLEAR ls_item.
    ADD 1 TO lv_cnt.
    ls_item-item_name = lv_cnt.
    ls_item-class     = r_tree->item_class_text.
    ls_item-alignment = r_tree->align_auto.
    ls_item-font      = r_tree->item_font_prop.
    ls_item-style     = r_tree->style_intensifd_critical.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal = is_data-holiday_from
      IMPORTING
        date_external = ls_item-text.

    APPEND ls_item TO et_items.

    CLEAR ls_item.
    ADD 1 TO lv_cnt.
    ls_item-item_name = lv_cnt.
    ls_item-class     = r_tree->item_class_text.
    ls_item-alignment = r_tree->align_auto.
    ls_item-font      = r_tree->item_font_prop.
    ls_item-text      = ' - '.
    APPEND ls_item TO et_items.

    CLEAR ls_item.
    ADD 1 TO lv_cnt.
    ls_item-item_name = lv_cnt.
    ls_item-class     = r_tree->item_class_text.
    ls_item-alignment = r_tree->align_auto.
    ls_item-font      = r_tree->item_font_prop.
    ls_item-style     = r_tree->style_intensifd_critical.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal = is_data-holiday_to
      IMPORTING
        date_external = ls_item-text.

    APPEND ls_item TO et_items.
  ENDIF.
ENDMETHOD.


METHOD check_responsible.
  READ TABLE t_responsibles TRANSPORTING NO FIELDS WITH KEY table_line = iv_id.
  IF sy-subrc = 0.
    ev_kz_resp = 'X'.
  ELSE.
    CLEAR ev_kz_resp.
  ENDIF.
ENDMETHOD.


METHOD constructor.
  DATA: ls_data     TYPE zbook_team,
        lt_events   TYPE cntl_simple_events,
        ls_events   LIKE LINE OF lt_events,
        lc_initial  TYPE i.

* Erstellen einer Identifikation(Handle) für Drag&Drop
  me->setup_drag_drop( ).

* Ermitteln der Teamdaten
  me->get_data( ).

* Create Tree-Model-Instanz
  CREATE OBJECT me->r_tree
    EXPORTING
      node_selection_mode = cl_list_tree_model=>node_sel_mode_single
      item_selection      = 'X' "braucht man für item double click
      with_headers        = ' '.

* Create Tree-Control-Instanz
  me->r_tree->create_tree_control( EXPORTING parent = ir_cont ).

  ls_events-eventid    = me->r_tree->eventid_item_double_click.
  ls_events-appl_event = 'X'.
  APPEND ls_events TO lt_events.

  me->r_tree->set_registered_events( EXPORTING events = lt_events ).

* Definieren eines Behandlers für das Drag-Ereignis
  SET HANDLER me->zif_hndl_tree_model_list_col~handle_drag              FOR me->r_tree.
  SET HANDLER me->zif_hndl_tree_model_list_col~handle_item_double_click FOR me->r_tree.

* Get Root-Data
  READ TABLE me->t_data INTO ls_data WITH KEY parent_id = lc_initial. "root

* Create nodes and items, starting with root
  me->add_node( ls_data ).

* expand all nodes depending on me->d_expand
  me->r_tree->expand_root_nodes( expand_subtree = id_expand ).
ENDMETHOD.


METHOD get_data.
  SELECT *
    FROM zbook_team
    INTO CORRESPONDING FIELDS OF TABLE t_data
    WHERE active = 'X'.
ENDMETHOD.


METHOD get_instance.
  IF r_instance IS INITIAL.
    CREATE OBJECT r_instance
      EXPORTING
        ir_cont   = ir_cont
        id_expand = id_expand.
  ENDIF.
  er_instance = r_instance.
ENDMETHOD.


METHOD setup_drag_drop.
  CREATE OBJECT r_drag_drop.
  r_drag_drop->add( flavor     = 'copy'
                    dragsrc    = 'X'
                    droptarget = ' '
                    effect     = cl_dragdrop=>copy ).
  r_drag_drop->get_handle( IMPORTING handle = d_dnd_handle_copy  ).
ENDMETHOD.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_BUTTON_CLICK.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_CHECKBOX_CHANGE.
endmethod.


METHOD zif_hndl_tree_model_list_col~handle_drag.

  DATA: lr_dragdropdata TYPE REF TO zcl_dnd_model_tree.

  DATA: lt_items TYPE treemlitab.

  CALL METHOD r_tree->node_get_items
    EXPORTING
      node_key   = node_key
    IMPORTING
      item_table = lt_items.

  BREAK-POINT.

  CREATE OBJECT lr_dragdropdata.
  lr_dragdropdata->set_litem_table( EXPORTING it_item_table = lt_items
                                              iv_item_index = 1 ).
  TRY.
      drag_drop_object->object ?= lr_dragdropdata.
    CATCH cx_sy_move_cast_error.
      drag_drop_object->abort( ).
  ENDTRY.

ENDMETHOD.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_DRAG_MULTIPLE.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_DROP_COMPLETE.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_DROP_COMPLETE_MULTIPLE.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_HEADER_CLICK.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_HEADER_CONTEXT_MENU_REQ.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_HEADER_CONTEXT_MENU_SEL.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_ITEM_CONTEXT_MENU_REQ.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_ITEM_CONTEXT_MENU_SEL.
endmethod.


METHOD zif_hndl_tree_model_list_col~handle_item_double_click.
  DATA: lt_items TYPE         treemlitab,
        ls_items LIKE LINE OF lt_items.

  BREAK dgoerke.

  IF me->check_responsible( node_key ) = 'X'.
    CALL METHOD r_tree->node_get_items
      EXPORTING
        node_key   = node_key
      IMPORTING
        item_table = lt_items.

    READ TABLE lt_items INTO ls_items INDEX 1.

    RAISE EVENT zresp_click
      EXPORTING
        responsible = ls_items-text.
  ENDIF.
ENDMETHOD.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_ITEM_KEYPRESS.
endmethod.


method ZIF_HNDL_TREE_MODEL_LIST_COL~HANDLE_LINK_CLICK.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_DEF_CONTEXT_MENU_REQ.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_DEF_CONTEXT_MENU_SEL.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_DROP.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_DROP_GET_FLAVOR.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_EXPAND_NO_CHILDREN.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_NODE_CONTEXT_MENU_REQ.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_NODE_CONTEXT_MENU_SEL.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_NODE_DOUBLE_CLICK.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_NODE_KEYPRESS.
endmethod.


method ZIF_HNDL_TREE_MODEL~HANDLE_SELECTION_CHANGED.
endmethod.
ENDCLASS.
