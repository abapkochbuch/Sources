class ZCL_BOOK_GOS_WRAPPER_DYN definition
  public
  final
  create public .

public section.

  interfaces IF_GOS_CALLBACK .

  data GR_GOS_MANAGER type ref to CL_GOS_MANAGER .

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BOOK_GOS_WRAPPER_DYN IMPLEMENTATION.


METHOD constructor.
  CREATE OBJECT gr_gos_manager
    EXPORTING
      io_callback = me.
ENDMETHOD.


METHOD if_gos_callback~get_object.
  es_object-objtype =  'ZBOOKTICK'.
  es_object-objkey  = space. """"zcl_ticket_cntl=>tiknr.
  IF abap_true = space. """zcl_ticket_cntl=>change_mode( ).
    ep_mode = 'E'.
  ELSE.
    ep_mode = 'D'.
  ENDIF.
ENDMETHOD.
ENDCLASS.
