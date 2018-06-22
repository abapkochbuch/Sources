REPORT zbook_demo_vbak.

DATA gt_fcat           TYPE lvc_t_fcat.
FIELD-SYMBOLS <fcat>   TYPE lvc_s_fcat.
DATA gr_grid           TYPE REF TO cl_salv_table.

DATA gt_demo           TYPE STANDARD TABLE OF zbook_demo_vbak.
DATA gs_demo           TYPE                   zbook_demo_vbak.
FIELD-SYMBOLS <demo>   TYPE                   zbook_demo_vbak.
DATA gv_name           TYPE c LENGTH 30 VALUE 'ZBOOK_DEMO_VBAK'.
DATA gs_vbak           TYPE vbak.

PARAMETERS p_fcat      TYPE c RADIOBUTTON GROUP type.
PARAMETERS p_salv      TYPE c RADIOBUTTON GROUP type.


FIELD-SYMBOLS <quelle> TYPE ANY.
FIELD-SYMBOLS <links>  TYPE ANY.
FIELD-SYMBOLS <rechts> TYPE ANY.
DATA gv_links          TYPE string.
DATA gv_rechts         TYPE string.

DATA gr_strdef         TYPE REF TO cl_abap_structdescr.
FIELD-SYMBOLS <component> TYPE abap_compdescr.

START-OF-SELECTION.

  gr_strdef ?= cl_abap_typedescr=>describe_by_name( 'VBAK' ).

  SELECT * FROM vbak INTO gs_vbak.
    EXIT.
  ENDSELECT.

  LOOP AT gr_strdef->components ASSIGNING <component>.

    ASSIGN COMPONENT <component>-name OF STRUCTURE gs_vbak TO <quelle>.
    IF sy-subrc = 0.
      CONCATENATE <component>-name '$LI' INTO gv_links.
      ASSIGN COMPONENT gv_links OF STRUCTURE gs_demo TO <links>.
      IF sy-subrc = 0.
        <links> = <quelle>.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF sy-subrc = 0.




  ENDIF.


*call screen 0100.

BREAK-POINT.

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
