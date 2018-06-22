*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature
TYPES
  : BEGIN OF gys_inst
  ,   tiknr   TYPE        zbook_ticket_nr
  ,   r_inst  TYPE REF TO zcl_book_ticket_hist_model
  , END OF gys_inst
  , gyt_inst  TYPE HASHED TABLE OF gys_inst
              WITH UNIQUE KEY tiknr
  .
