class ZCL_BOOK_EXCEPTION_TEST definition
  public
  final
  create public .

public section.

  methods THROW_EXCEPTION
    raising
      resumable(ZCX_BOOK_EXCEPTION) .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BOOK_EXCEPTION_TEST IMPLEMENTATION.


  METHOD throw_exception.
    RAISE RESUMABLE EXCEPTION TYPE zcx_book_exception.
  ENDMETHOD.
ENDCLASS.
