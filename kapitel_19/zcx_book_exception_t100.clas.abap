class ZCX_BOOK_EXCEPTION_T100 definition
  public
  inheriting from CX_STATIC_CHECK
  create private .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of WRONG_ORDER,
      msgid type symsgid value 'ZBOOK_EXC',
      msgno type symsgno value '001',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WRONG_ORDER .
  constants:
    begin of TICKET_DOES_NOT_EXIST,
      msgid type symsgid value 'ZBOOK_EXC',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'TIKNR',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of TICKET_DOES_NOT_EXIST .
  data TIKNR type ZBOOK_TICKET_NR .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !TIKNR type ZBOOK_TICKET_NR optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_BOOK_EXCEPTION_T100 IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->TIKNR = TIKNR .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
