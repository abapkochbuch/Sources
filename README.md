# Sources
Sources of ABAP Kochbuch by Rheinwerk-Verlag
Written by Enno Wulff, Maic Haubitz, Dennis Goerke, Udo Toenges, Sascha Seegebarth.

[ABAP Kochbuch, 2nd Edition](https://www.rheinwerk-verlag.de/das-abap-kochbuch_4103/)

![ABAP Kochbuch](https://s3-eu-west-1.amazonaws.com/cover2.galileo-press.de/print/9783836241076_267.png "ABAP Kochbuch")

# abapGit

Use [abapGit](http://docs.abapgit.org/) for installing the sources in your SAP system.

The sources will be installed as local objects with package $ABAP_KOCHBUCH and sub packages $ABAP_KOCHBUCH_KAPITEL_nn.

# Current status
The migration of the ABAP Kochbuch sources are in progress.

All migrated chapters are shown below.

## Chapter 01
No sources, just text

## Chapter 02
Tables ZBOOK_AREAS and ZBOOK_CLASS 

Maintenance Dialog must be genarated by you.

## Chapter 03
Viewcluster must be generated by you.

Main prog for exit routines are here:

ZBOOK_VIEWCLUSTER_EXIT_POOL

## Chapter 04
In the book we describe to use number range objekt "ZBOOK_TIK". Actually it's "ZBOOK_TIC". Please make sure you use the right object name.
Replaced Demo with VBAK by Demo with DD02L
PROG ZBOOK_DEMO_VBAK -> ZBOOK_DEMO_DD02L
TABL ZBOOK_DEMO_VBAK -> ZBOOK_DEMO_DD02L

## Chapter 05
Reuse Controls

## Chapter 06
Work with textedit Control

## Chapter 07 
Application log

## Chapter 08
Change documents.
not yet supportet by abapGit. Create as described in the book

## Chapter 09
Work with Tree Controls

## Chapter 10
Dynamic documents

## Chapter 11
Implement modules in ticket system (no sources)

## Chapter 12
Use frame works. Creation of Spliiter-admin-control.

## Chapter 13
ALV Grid control

## Chapter 14
Drag & drop

## Chapter 15
smart forms

