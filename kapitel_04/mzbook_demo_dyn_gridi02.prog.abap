*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  FIELD-SYMBOLS <data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <line> TYPE any.
  FIELD-SYMBOLS <valu> TYPE any.

  CASE sy-ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'SAVE'.
      IF gr_dd_grid IS BOUND.
        gd_data = gr_dd_grid->get_data_reference( ).
        ASSIGN gd_data->* TO <data>.
        IF sy-subrc = 0.
          LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
          SET PF-STATUS space.
          LOOP  AT <data> ASSIGNING <line>.

*** Neue Zeile für jeden Tabelleneintrag
            NEW-LINE.

*** Felder des Arbeitsbereiches ausgeben
            DO.
              ASSIGN COMPONENT sy-index OF STRUCTURE <line> TO <valu>.
              IF sy-subrc > 0.
*** Kein Feld mehr vorhanden
                EXIT. "from do
              ELSE.
*** Feldwert ausgeben
                WRITE: <valu> COLOR COL_TOTAL.
              ENDIF.
            ENDDO.

          ENDLOOP.
        ENDIF.
      ENDIF.
    WHEN 'AREA'.
      PERFORM listbox_clas.

    WHEN 'CLAS'.

    WHEN 'SINGLE_VALUE'.
      gr_dd_single->display_data( ).
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0500  INPUT
