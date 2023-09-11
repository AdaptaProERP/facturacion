// Programa   : DPCLIENTESRECMNU 
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú Abastaecimiento de Producto
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
   LOCAL cNombre:="",cSql,I,nGroup
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={}

   EJECUTAR("DPCLIENTESRECDEF")

   DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))

   DEFINE FONT oFont    NAME GetSysFont() SIZE 0,-14
   DEFINE FONT oFontB   NAME GetSysFont() SIZE 0,-14 BOLD

   DpMdi(GetFromVar("{oDp:DPCLIENTESREC}"),"oCliMnuRec","TEST.EDT")

   oCliMnuRec:cCodCli   :=cCodCli
   oCliMnuRec:cDescri   :=cNombre
   oCliMnuRec:lSalir  :=.F.
   oCliMnuRec:nHeightD:=45
   oCliMnuRec:lMsgBar :=.F.
   oCliMnuRec:oGrp    :=NIL

   SetScript("DPCLIENTESRECMNU")

   oCliMnuRec:Windows(0,0,300,410)
 

  @ 48, -1 OUTLOOK oCliMnuRec:oOut ;
     SIZE 150+250, oCliMnuRec:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oCliMnuRec:oWnd;
     COLOR CLR_BLACK,16771797

   DEFINE GROUP OF OUTLOOK oCliMnuRec:oOut PROMPT "&Opciones "

   DEFINE BITMAP OF OUTLOOK oCliMnuRec:oOut ;
          BITMAP "BITMAPS\RECURSOHUMANO.BMP";
          PROMPT oDp:DPCLIENTESREC_HUMANO;
          ACTION EJECUTAR("DPCLIENTESRECHUMLBX",oCliMnuRec:cCodCli)


   DEFINE BITMAP OF OUTLOOK oCliMnuRec:oOut ;
          BITMAP "BITMAPS\RECURSOEQUIPO.BMP";
          PROMPT oDp:DPCLIENTESREC_EQUIPOS;
          ACTION EJECUTAR("DPCLIENTESRECHUMLBX",oCliMnuRec:cCodCli)

   DEFINE BITMAP OF OUTLOOK oCliMnuRec:oOut ;
          BITMAP "BITMAPS\RECURSOPLANTA.BMP";
          PROMPT oDp:DPCLIENTESREC_PLANTAS;
          ACTION EJECUTAR("DPCLIENTESRECHUMLBX",oCliMnuRec:cCodCli)


   @ 0, 100 SPLITTER oCliMnuRec:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oCliMnuRec:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oCliMnuRec:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oCliMnuRec:oDlg FROM 0,oCliMnuRec:oOut:nWidth() TO oCliMnuRec:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oCliMnuRec:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oCliMnuRec:oGrp TO 10,10 PROMPT "Código ["+oCliMnuRec:cCodCli+"] "

   @ .5,.5 SAY oCliMnuRec:cDescri SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oCliMnuRec:oDlg NOWAIT VALID .F.

   oCliMnuRec:Activate("oCliMnuRec:FRMINIT()",,"oCliMnuRec:oSpl:AdjRight()")
 
RETURN

FUNCTION FRMINIT()

   oCliMnuRec:oWnd:bResized:={||oCliMnuRec:oDlg:Move(0,0,oCliMnuRec:oWnd:nWidth(),50,.T.),;
                             oCliMnuRec:oGrp:Move(0,0,oCliMnuRec:oWnd:nWidth()-15,oCliMnuRec:nHeightD,.T.)}

   EVal(oCliMnuRec:oWnd:bResized)

RETURN .T.

