class ZCL_DND_MODEL_TREE definition
  public
  create public .

*"* public components of class ZCL_DND_MODEL_TREE
*"* do not include other source files here!!!
public section.

  data ITEM_INDEX type SY-TABIX read-only .

  methods SET_LITEM_TABLE
    importing
      !IT_ITEM_TABLE type TREEMLITAB
      !IV_ITEM_INDEX type SY-TABIX optional .
  methods SET_CITEM_TABLE
    importing
      !IT_ITEM_TABLE type TREEMCITAB
      !IV_ITEM_INDEX type SY-TABIX optional .
  methods SET_NODE_KEY
    importing
      !IV_NODE_KEY type TM_NODEKEY .
  methods GET_LITEM_TABLE
    returning
      value(ET_ITEM_TABLE) type TREEMLITAB .
  methods GET_NODE_KEY
    returning
      value(EV_NODE_KEY) type TM_NODEKEY .
  methods GET_CITEM_TABLE
    returning
      value(ET_ITEM_TABLE) type TREEMCITAB .
protected section.
*"* protected components of class ZCL_DND_MODEL_TREE
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_DND_MODEL_TREE
*"* do not include other source files here!!!

  data T_CITEM_TABLE type TREEMCITAB .
  data T_LITEM_TABLE type TREEMLITAB .
  data NODE_KEY type TM_NODEKEY .
ENDCLASS.



CLASS ZCL_DND_MODEL_TREE IMPLEMENTATION.


METHOD get_citem_table.
  et_item_table = t_citem_table.
ENDMETHOD.


METHOD get_litem_table.
  et_item_table = t_litem_table.
ENDMETHOD.


method GET_NODE_KEY.
  ev_node_key = node_key.
endmethod.


METHOD set_citem_table.
  t_citem_table = it_item_table.
  item_index    = iv_item_index.
ENDMETHOD.


METHOD set_litem_table.
  t_litem_table = it_item_table.
  item_index    = iv_item_index.
ENDMETHOD.


method SET_NODE_KEY.
  node_key = iv_node_key.
endmethod.
ENDCLASS.
