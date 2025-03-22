// Programa   : DPDOCCLIVSAUDITOR
// Fecha/Hora : 20/04/2023 19:52:04
// Propósito  : Comparar facturas vs Pistas de Auditoría
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL oMenu
   LOCAL nAdd   :=0
   LOCAL cTitle := "Testing the Splitter controls"
   LOCAL aData  :=EJECUTAR("DBFVIEWARRAY","DATADBF\DPLINK.DBF",NIL,.F.)
   LOCAL aMenu  :=EJECUTAR("DBFVIEWARRAY","DATADBF\DPMENU.DBF",NIL,.F.)
   LOCAL aBotBar:=EJECUTAR("DBFVIEWARRAY","DATADBF\DPBOTBAR.DBF",NIL,.F.)

   LOCAL cInfo  := "Lee las indicaciones que he puesto al final de cada " + ;
                   "programa fuente." + CRLF + "AdaptaPro"



   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=oDp:nEjercicio,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

   IF !Empty(aFechas)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

? dDesde,dHasta

   CLOSE ALL

   MENU oMenu
        MENUITEM "&Splitters"
           MENU
               MENUITEM "&Info" ACTION MsgInfo(oMdi:cInfo)
               MENUITEM "&Exit" ACTION oMdi:oWnd:End()
           ENDMENU
   ENDMENU

   DpMdi("cTitle","oMdi","SPLITER3.EDT",,oMenu)
   oMdi:Windows(0,0,600,1010,.T.) // Maximizado
   oMdi:cInfo:=cInfo

   oMdi:nAltoBrw  :=100
   oMdi:nAnchoSpl1:=120


//   SELECT 1
//   USE DATADBF\DPMENU.DBF
//   @ 0,0 LISTBOX oMdi:oBrw1 FIELDS SIZE 200+oMdi:nAnchoSpl1,355 PIXEL OF oMdi:oWnd

   oMdi:oBrw1:=TXBrowse():New(oMdi:oWnd)
   oMdi:oBrw1:SetArray( aMenu, .F. )
   oMdi:oBrw1:CreateFromCode()
   oMdi:oBrw1:Move(0,0,.T.)
   oMdi:oBrw1:SetSize(200+oMdi:nAnchoSpl1,355)


//  SELECT B
//  USE DATADBF\DPPROGRA.DBF 
//  @ 0,205 LISTBOX oMdi:oBrw FIELDS SIZE 300,200 PIXEL OF oMdi:oWnd

   oMdi:oBrw2:=TXBrowse():New(oMdi:oWnd)
   oMdi:oBrw2:SetArray( aData, .F. )
   oMdi:oBrw2:CreateFromCode()
   oMdi:oBrw2:Move(0,205+oMdi:nAnchoSpl1,.T.)
   oMdi:oBrw2:SetSize(300,200+oMdi:nAltoBrw)

// @ 205+oMdi:nAltoBrw,205+oMdi:nAnchoSpl1 GET oMdi:oGet VAR B->PRG_TEXTO TEXT SIZE 300,150 PIXEL OF oMdi:oWnd

   oMdi:oBrw3:=TXBrowse():New(oMdi:oWnd)
   oMdi:oBrw3:SetArray( aBotBar, .F. )
   oMdi:oBrw3:CreateFromCode()
   oMdi:oBrw3:Move(205+oMdi:nAltoBrw,205+oMdi:nAnchoSpl1,.T.)
   oMdi:oBrw3:SetSize(300,150,.T.)

// SOLO PARA EL GET   oMdi:oBrw:bChange:={|| oMdi:oGet:Refresh() }

   @ 200+oMdi:nAltoBrw,205+oMdi:nAnchoSpl1 SPLITTER oMdi:oHSplit ;
             HORIZONTAL ;
             PREVIOUS CONTROLS oMdi:oBrw2 ;
             HINDS CONTROLS oMdi:oBrw3 ;
             TOP MARGIN 80 ;
             BOTTOM MARGIN 80 ;
             SIZE 300, 4  PIXEL ;
             OF oMdi:oWnd ;
             _3DLOOK

   @ 0,200+oMdi:nAnchoSpl1   SPLITTER oMdi:oVSplit ;
             VERTICAL ;
             PREVIOUS CONTROLS oMdi:oBrw1 ;
             HINDS CONTROLS oMdi:oBrw2, oMdi:oHSplit, oMdi:oBrw3 ;
             LEFT MARGIN 80 ;
             RIGHT MARGIN 80 ;
             SIZE 4, 355  PIXEL ;
             OF oMdi:oWnd ;
             _3DLOOK

   oMdi:Activate({||oMdi:INICIO()})

RETURN .T.

FUNCTION INICIO()
   LOCAL oCursor,oBar,oFont,oBtn

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oMdi:oBar SIZE 45,45 OF oMdi:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   DEFINE BUTTON oBtn;
          OF oMdi:oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oMdi:Close()

   oBtn:cToolTip:="Consultar Vinculos"

   oMdi:oBar:SetSize(NIL,100,.T.)

   oMdi:oWnd:bResized:={||( oMdi:oVSplit:AdjLeft(), ;
                            oMdi:oHSplit:AdjRight())}

   Eval( oMdi:oWnd:bResized )

RETURN .T.

//----------------------------------------------------------------------------//
/*
      Para acotar el desplazamiento máximo que puede tener un Splitter
      se utilizán las clausulas:

             [ TOP, LEFT ] MARGIN  nPixels

      que deja un mínimo de nPixels desde el borde superior o izquierdo
      de la ventana hasta el splitter ya sea Horizontal o Vertical
      reepectivamente.

             [ BOTTOM, RIGHT ] MARGIN  nPixels ;

      que deja un mínimo de nPixels desde el borde inferior o derecho
      de la ventana hasta el splitter ya sea Horizontal o Vertical
      reepectivamente.

      Es importante destacar que he hecho que la clase esplitter guarde
      estas dimensiones como Codeblocks, para poder referenciar en estas
      clausular a objetos spritters que a un no se han creado (esto será
      muy importante para no dejar que se monten dos spritters paralelos,
      ver el ejemplo TextSpl4.prg).
                                                                              */
RETURN

