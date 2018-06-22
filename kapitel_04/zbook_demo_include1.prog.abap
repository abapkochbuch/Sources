REPORT zbook_demo_include1.

DATA gt_fcat           TYPE lvc_t_fcat.
FIELD-SYMBOLS <fcat>   TYPE lvc_s_fcat.
DATA gr_grid           TYPE REF TO cl_salv_table.

DATA gt_demo           TYPE STANDARD TABLE OF zbook_status_demo1.
FIELD-SYMBOLS <demo>   TYPE                   zbook_status_demo1.
DATA gv_name           TYPE c LENGTH 30 VALUE 'ZBOOK_STATUS_DEMO1'.


PARAMETERS p_fcat      TYPE c RADIOBUTTON GROUP type.
PARAMETERS p_salv      TYPE c RADIOBUTTON GROUP type.

START-OF-SELECTION.

  APPEND INITIAL LINE TO gt_demo ASSIGNING <demo>.
  <demo>-stat01-status = 'OPEN'.
  <demo>-stat01-sttext = 'Eröffnet'.
  <demo>-stat02-status = 'CLSD'.
  <demo>-stat02-sttext = 'abgeschlossen'.
  <demo>-stat03-status = 'HOLD'.
  <demo>-stat03-sttext = 'Zurückgestellt'.

*call screen 0100.

*BREAK-POINT.

  CASE 'X'.
    WHEN p_fcat.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gv_name
        CHANGING
          ct_fieldcat            = gt_fcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.

      LOOP AT gt_fcat ASSIGNING <fcat>.
        WRITE: / <fcat>-col_pos,
                 <fcat>-fieldname.
      ENDLOOP.

    WHEN p_salv.

      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = gr_grid
            CHANGING
              t_table      = gt_demo ).
        CATCH cx_salv_msg.
      ENDTRY.
      gr_grid->display( ).
  ENDCASE.
