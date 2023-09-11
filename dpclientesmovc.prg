// Programa   : DPCLIENTESMOVC
// Fecha/Hora : 07/12/2008 22:26:50
// Propósito  : Visualizar Cuentas contables por Asientos
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESCON
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,cActual,cTitle)
  LOCAL aData:={},cWhere,nClrPane,nClrText

  DEFAULT cCodigo:=STRZERO(1,10),;
          cCodSuc:=oDp:cSucursal,;
          cTitle:="Cuentas contables Según Todos los Asientos "

  IF !Empty(cActual)
     cWhere:="MOC_ACTUAL"+GetWhere("=",cActual)
  ENDIF

  aData:=ASQL(" SELECT MOC_CUENTA,CTA_DESCRI,COUNT(*) AS CUANTOS FROM DPASIENTOS "+;
              " INNER JOIN DPCTA ON MOC_CUENTA=CTA_CODIGO "+;
              " WHERE MOC_ORIGEN"+GetWhere("=","VTA"  )+;
              "   AND MOC_CODSUC"+GetWhere("=",cCodSuc)+;
              "   AND MOC_CODAUX"+GetWhere("=",cCodigo)+;
              IIF( Empty(cWhere), "" , " AND "+cWhere )+;
              " GROUP BY MOC_CUENTA,CTA_DESCRI")

  nClrPane:=16773862
  nClrText:=16771538

  IF cActual="S"
    nClrPane:=12317412
    nClrText:=9891278
  ENDIF

  IF cActual="A" .OR. .T.
    nClrPane:=14155775
    nClrText:=9240575
  ENDIF


  IF !Empty(aData)
     ViewData(aData,cCodigo,cTitle)
  ELSE
     MensajeErr(cTitle,"Información no Encontrada")
  ENDIF

RETURN NIL

FUNCTION ViewData(aData,cCodigo,cTitle)
   LOCAL oBrw,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable,cNombre:=""
   LOCAL oFont,oFontB

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodigo))

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oCliMcr:=DPEDIT():New(cTitle,"DPCLIENTESMOVC.EDT","oCliMcr",.T.)

   oCliMcr:cCodigo :=cCodigo
   oCliMcr:cNombre :=cNombre
   oCliMcr:cActual :=cActual
   oCliMcr:cCodSuc :=cCodSuc
   oCliMcr:cWhere  :=cWhere 
   oCliMcr:nClrPane:=nClrPane
   oCliMcr:nClrText:=nClrText


   oCliMcr:lMsgBar:=.F.

   oCliMcr:oBrw:=TXBrowse():New( oCliMcr:oDlg )
   oCliMcr:oBrw:SetArray( aData, .F. )
   oCliMcr:oBrw:SetFont(oFont)
   oCliMcr:oBrw:lFooter := .T.
   oCliMcr:oBrw:lHScroll:= .F.
   oCliMcr:oBrw:nHeaderLines:= 1

   oCliMcr:cCodTra  :=cCodigo
   oCliMcr:cNombre  :=ALLTRIM(cNombre)

   AEVAL(oCliMcr:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCliMcr:oBrw:aCols[1]:cHeader      :="Cuenta"
   oCliMcr:oBrw:aCols[1]:nWidth       :=200

   oCliMcr:oBrw:aCols[2]:cHeader      :="Descripción de la Cuenta"
   oCliMcr:oBrw:aCols[2]:nWidth       :=400


   oCliMcr:oBrw:aCols[3]:cHeader      :="Asientos"
   oCliMcr:oBrw:aCols[3]:nWidth       :=100
   oCliMcr:oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT
   oCliMcr:oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT
   oCliMcr:oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT
   oCliMcr:oBrw:aCols[3]:bStrData     :={|nMonto|nMonto:=oCliMcr:oBrw:aArrayData[oCliMcr:oBrw:nArrayAt,3],;
                                                 TRAN(nMonto,"999999")}

   oCliMcr:oBrw:aCols[3]:cFooter      :=TRAN(aTotal[3],"999999")

   oCliMcr:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCliMcr:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oCliMcr:nClrPane, oCliMcr:nClrText ) } }

   oCliMcr:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliMcr:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliMcr:oBrw:CreateFromCode()

   oCliMcr:Activate({||oCliMcr:ViewDatBar(oCliMcr)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oCliMcr)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oCliMcr:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION EJECUTAR("DPCTACON",NIL,oCliMcr:oBrw:aArrayData[oCliMcr:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Consultar Cuenta Contable"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION EJECUTAR("DPCLIMOVCEJER",oCliMcr:oBrw:aArrayData[oCliMcr:oBrw:nArrayAt,1],;
                                          oCliMcr:cCodigo,oCliMcr:cCodSuc,oCliMcr:cActual )

   oBtn:cToolTip:="Visualizar Resumen por Ejercicio"

   oCliMcr:oBrw:bLDblClick:=oBtn:bAction

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION  oCliMcr:IMPRIMIR()

   oBtn:cToolTip:="Imprimir"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliMcr:oBrw,oCliMcr:cTitle,oCliMcr:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCliMcr:oBrw:GoTop(),oCliMcr:oBrw:Setfocus())

   oBtn:cToolTip:="Primer Registro"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oCliMcr:oBrw:PageDown(),oCliMcr:oBrw:Setfocus())

   oBtn:cToolTip:="Página Siguiente"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oCliMcr:oBrw:PageUp(),oCliMcr:oBrw:Setfocus())

   oBtn:cToolTip:="Página Anterior"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCliMcr:oBrw:GoBottom(),oCliMcr:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Documento"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliMcr:Close()

  oBtn:cToolTip:="Cerrar Consulta"

  oCliMcr:oBrw:SetColor(0,oCliMcr:nClrPane)
  oCliMcr:oBrw:GoBottom()

  @ 0.1,60 SAY " "+oCliMcr:cCodigo OF oBar BORDER SIZE 395,18
  @ 1.4,60 SAY " "+oCliMcr:cNombre OF oBar BORDER SIZE 395,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep:=REPORTE("DPCLICTASMOC",oCliMcr:cWhere,NIL,NIL,oCliMcr:cTitle)

  oRep:SetRango(1,oCliMcr:cCodigo,oCliMcr:cCodigo)
  oRep:SetCriterio(1,oCliMcr:cCodSuc)

RETURN NIL
// EOF
