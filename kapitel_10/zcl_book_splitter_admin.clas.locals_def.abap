*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature


TYPES: BEGIN OF ty_container,
         main TYPE REF TO cl_gui_container,
         tool TYPE REF TO cl_gui_container,
         cust TYPE REF TO cl_gui_container,
         tbar type ref to cl_gui_toolbar,
       END OF ty_container.
TYPES ty_container_table TYPE STANDARD TABLE
                         OF ty_container WITH DEFAULT KEY.
