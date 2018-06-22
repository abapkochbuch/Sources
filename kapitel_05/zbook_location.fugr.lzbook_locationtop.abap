FUNCTION-POOL zbook_location.               "MESSAGE-ID ..


DATA gv_okcode TYPE syucomm.

DATA gv_message TYPE text100.
DATA gv_display TYPE c LENGTH 1.

DATA: BEGIN OF gs_location,
        hh  TYPE c LENGTH 1,
        hb  TYPE c LENGTH 1,
        h   TYPE c LENGTH 1,
        ffm TYPE c LENGTH 1,
        m   TYPE c LENGTH 1,
        s   TYPE c LENGTH 1,
      END OF gs_location.
