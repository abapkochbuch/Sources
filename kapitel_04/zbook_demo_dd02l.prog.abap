REPORT zbook_demo_dd02l.


DATA gt_fcat           TYPE lvc_t_fcat.
FIELD-SYMBOLS <fcat>   TYPE lvc_s_fcat.
DATA gr_grid           TYPE REF TO cl_salv_table.

DATA gt_demo           TYPE STANDARD TABLE OF zbook_demo_dd02l.
DATA gs_demo           TYPE                   zbook_demo_dd02l.
FIELD-SYMBOLS <demo>   TYPE                   zbook_demo_dd02l.
DATA gv_name           TYPE c LENGTH 30 VALUE 'ZBOOK_DEMO_DD02L'.
DATA gs_dd02l          TYPE dd02l.

PARAMETERS p_fcat      TYPE c RADIOBUTTON GROUP type.
PARAMETERS p_salv      TYPE c RADIOBUTTON GROUP type.
PARAMETERS p_break     AS CHECKBOX DEFAULT space.

FIELD-SYMBOLS <quelle> TYPE any.
FIELD-SYMBOLS <links>  TYPE any.
FIELD-SYMBOLS <rechts> TYPE any.
DATA gv_links          TYPE string.
DATA gv_rechts         TYPE string.

DATA gr_strdef         TYPE REF TO cl_abap_structdescr.
FIELD-SYMBOLS <component> TYPE abap_compdescr.

START-OF-SELECTION.

  gr_strdef ?= cl_abap_typedescr=>describe_by_name( 'DD02L' ).

  SELECT SINGLE *
    FROM dd02l
    INTO gs_dd02l
   WHERE tabname = 'ZBOOK_TICKET'.

  LOOP AT gr_strdef->components ASSIGNING <component>.

    ASSIGN COMPONENT <component>-name OF STRUCTURE gs_dd02l TO <quelle>.
    IF sy-subrc = 0.
      CONCATENATE <component>-name '$LI' INTO gv_links.
      ASSIGN COMPONENT gv_links OF STRUCTURE gs_demo TO <links>.
      IF sy-subrc = 0.
        <links> = <quelle>.
      ENDIF.
    ENDIF.

  ENDLOOP.

  SELECT SINGLE *
   FROM dd02l
   INTO gs_demo-rechts
  WHERE tabname = 'ZBOOK_TICKET_DYNPRO'.

  APPEND gs_demo TO gt_demo.

  IF p_break = abap_true.
    BREAK-POINT.
  ENDIF.

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
