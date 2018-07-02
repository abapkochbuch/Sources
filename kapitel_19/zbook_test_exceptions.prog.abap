*&---------------------------------------------------------------------*
*& Report            ZBOOK_TEST_EXCEPTIONS
*&---------------------------------------------------------------------*
*                                                                      *
*     _____                        _                         _____     *
*    |_   _|                      | |                  /\   / ____|    *
*      | |  _ ____      _____ _ __| | _____ _ __      /  \ | |  __     *
*    |_____|_| |_|\_/\_/ \___|_|  |_|\_\___|_| |_| /_/    \_\_____|    *
*                                                                      *
*                                                  einfach Inwerken.   *
*                                                                      *
*&---------------------------------------------------------------------*

REPORT zbook_test_exceptions.

DATA exc_stat   TYPE REF TO cx_static_check.
DATA exc_dyn    TYPE REF TO cx_dynamic_check.
DATA exc_book   TYPE REF TO zcx_book_exception.

*TRY .
*    RAISE EXCEPTION TYPE zcx_book_exception.
*  CATCH cx_dynamic_check INTO exc_dyn.
*    WRITE: / 'Dynamic'.
*  CATCH zcx_book_exception INTO exc_stat.
*    WRITE / 'Book'.
*  CATCH cx_static_check INTO exc_stat.
*    WRITE: / 'Static'.
*
*ENDTRY.
*
*TRY .
*    TRY .
*      CATCH zcx_book_exception.
*    ENDTRY.
*  CATCH cx_static_check.
*ENDTRY.

DATA n          TYPE i.
DATA exc_test   TYPE REF TO zcl_book_exception_test.
TRY .
    TRY .
        n = 1 / 0. " !!!
      CATCH cx_static_check.
      CLEANUP.
        " Cleanup-Block zuerst
    ENDTRY.
  CATCH cx_sy_arithmetic_error INTO exc_dyn.
    " Catch-Block danach
ENDTRY.


WRITE: / 'Resumable Exceptions'.
SKIP.
WRITE: / '1. RETRY'.
n = 0.
CREATE OBJECT exc_test.
TRY.
    exc_test->throw_exception( ).
  CATCH zcx_book_exception.
    n = n + 1.
    WRITE: / n.
    IF n < 5.
      RETRY.
    ENDIF.
ENDTRY.

SKIP.
WRITE: / '2. RESUME'.
n = 0.
CREATE OBJECT exc_test.
TRY.
    exc_test->throw_exception( ).
  CATCH BEFORE UNWIND zcx_book_exception.
    n = n + 1.
    WRITE: / n.
    IF n < 5.
      RESUME.
    ENDIF.
ENDTRY.
