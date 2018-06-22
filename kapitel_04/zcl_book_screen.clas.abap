class ZCL_BOOK_SCREEN definition
  public
  final
  create public .

*"* public components of class ZCL_BOOK_SCREEN
*"* do not include other source files here!!!
public section.

  class-methods ACTIVATE .
  class-methods INIT .
  class-methods SET_FIELD_INACTIVE
    importing
      !FIELDNAME type CLIKE .
  class-methods SET_FIELD_NO_INPUT
    importing
      !FIELDNAME type CLIKE .
  class-methods SET_GROUP1_INACTIVE
    importing
      !NAME type CLIKE .
  class-methods SET_GROUP1_NO_INPUT
    importing
      !NAME type CLIKE .
protected section.
*"* protected components of class ZCL_BOOK_SCREEN
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BOOK_SCREEN
*"* do not include other source files here!!!

  class-data GT_FIELDS type TY_FIELD_TAB .
  class-data GT_GROUP1 type TY_GROUP_TAB .
ENDCLASS.



CLASS ZCL_BOOK_SCREEN IMPLEMENTATION.


METHOD activate.

  FIELD-SYMBOLS <field> LIKE LINE OF gt_fields.
  FIELD-SYMBOLS <group> LIKE LINE OF gt_group1.

  LOOP AT SCREEN.

    READ TABLE gt_fields ASSIGNING <field> WITH TABLE KEY name = screen-name.
    IF sy-subrc = 0.
      IF <field>-active IS NOT INITIAL.
        screen-active = <field>-active.
      ENDIF.
      IF <field>-input IS NOT INITIAL.
        screen-input = <field>-input.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 IS NOT INITIAL.
      READ TABLE gt_group1 ASSIGNING <group> WITH TABLE KEY name = screen-group1.
      IF sy-subrc = 0.
        IF <group>-active IS NOT INITIAL.
          screen-active = <group>-active.
        ENDIF.
        IF <group>-input IS NOT INITIAL.
          screen-input = <group>-input.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDMETHOD.


METHOD init.

  CLEAR gt_group1.
  CLEAR gt_fields.

ENDMETHOD.


METHOD set_field_inactive.

  FIELD-SYMBOLS <field> like LINE OF gt_fields.
  DATA field            like LINE OF gt_fields.

  READ TABLE gt_fields ASSIGNING <field> WITH TABLE KEY name = fieldname.
  IF sy-subrc > 0.
    field-name   = fieldname.
    field-active = '0'.
    INSERT field INTO TABLE gt_fields.
  ELSE.
    <field>-active = '0'.
  ENDIF.

ENDMETHOD.


METHOD set_field_no_input.

  FIELD-SYMBOLS <field> LIKE LINE OF gt_fields.
  DATA field            LIKE LINE OF gt_fields.

  READ TABLE gt_fields ASSIGNING <field> WITH TABLE KEY name = fieldname.
  IF sy-subrc > 0.
    field-name  = fieldname.
    field-input = '0'.
    INSERT field INTO TABLE gt_fields.
  ELSE.
    <field>-input = '0'.
  ENDIF.

ENDMETHOD.


METHOD SET_GROUP1_INACTIVE.

  FIELD-SYMBOLS <group> LIKE LINE OF gt_group1.
  DATA group            LIKE LINE OF gt_group1.

  READ TABLE gt_group1 ASSIGNING <group> WITH TABLE KEY name = name.
  IF sy-subrc > 0.
    group-name = name.
    group-active    = '0'.
    INSERT group INTO TABLE gt_group1.
  ELSE.
    <group>-active = '0'.
  ENDIF.

ENDMETHOD.


METHOD SET_GROUP1_NO_INPUT.

  FIELD-SYMBOLS <group> LIKE LINE OF gt_group1.
  DATA group            LIKE LINE OF gt_group1.

  READ TABLE gt_group1 ASSIGNING <group> WITH TABLE KEY name = name.
  IF sy-subrc > 0.
    group-name  = name.
    group-input = '0'.
    INSERT group INTO TABLE gt_group1.
  ELSE.
    <group>-input = '0'.
  ENDIF.

ENDMETHOD.
ENDCLASS.
