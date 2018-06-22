*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPES: BEGIN OF ty_field,
         name      TYPE c LENGTH 100,
         active    TYPE screen-active,
         input     TYPE screen-input,
       END OF ty_field.

TYPES: BEGIN OF ty_group,
         name      TYPE c LENGTH 3,
         active    TYPE screen-active,
         input     TYPE screen-input,
       END OF ty_group.


TYPES ty_field_tab TYPE SORTED TABLE OF ty_field WITH UNIQUE KEY name.
TYPES ty_group_tab TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY name.
