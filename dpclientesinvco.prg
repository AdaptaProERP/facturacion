// Programa   : DPCLIENTESINVCO
// Fecha/Hora : 19/02/2006 22:26:50
// Propósito  : Visualizar Productos de Interes del Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESINVCO
// Aplicación : Ventas
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo)
  LOCAL cSql,oTable,aData:={},cTitle:="Productos de Interés" 

  DEFAULT cCodigo:=STRZERO(1,10)

  cSql:=" SELECT MOV_CODIGO,INV_DESCRI,MOV_CODCOM,MOV_FECHA,MOV_UNDMED,MOV_CANTID FROM DPMOVINV	"+;
        " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
        " WHERE MOV_CODCTA"+GetWhere("=",cCodigo)+;
        "   AND MOV_APLORG='1' "+;
        " ORDER BY MOV_FECHA "

  aData:=ASQL(cSql,.T.)

  IF !Empty(aData)
     ViewData(aData,cCodigo,cTitle)
  ELSE
     MensajeErr("No hay Productos de Interés para el Cliente "+cCodigo)
  ENDIF

RETURN NIL


FUNCTION ViewData(aData,cCodigo,cTitle)
   LOCAL oBrw
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable,cNombre:=""
   LOCAL oFont,oFontB
   LOCAL nNeto:=0,nPagos:=0,nSaldo:=0
   LOCAL nDebe:=0,nHaber:=0

   AEVAL(aData,{|a,n|nNeto:=nNeto+a[4],nPagos:=nPagos+a[5],nSaldo:=nSaldo+a[6]})

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodigo))

   AEVAL(aData,{|a|nDebe:=nDebe+a[5],nHaber:=nHaber+a[6]})

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oCliInvInt:=DPEDIT():New(cTitle,"DPCLIENTESINVCO.EDT","oCliInvInt",.T.)
   oCliInvInt:cCodigo:=cCodigo
   oCliInvInt:cNombre:=cNombre
   oCliInvInt:lMsgBar:=.F.

   oCliInvInt:oBrw:=TXBrowse():New( oCliInvInt:oDlg )
   oCliInvInt:oBrw:SetArray( aData, .F. )
   oCliInvInt:oBrw:SetFont(oFont)
   oCliInvInt:oBrw:lFooter := .T.
   oCliInvInt:oBrw:lHScroll:= .T.
   oCliInvInt:oBrw:nHeaderLines:=1

   oCliInvInt:cCodTra  :=cCodigo
   oCliInvInt:cNombre  :=ALLTRIM(cNombre)

   AEVAL(oCliInvInt:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCliInvInt:oBrw:aCols[1]:cHeader      :="Código"
   oCliInvInt:oBrw:aCols[1]:nWidth       :=130

   oCliInvInt:oBrw:aCols[2]:cHeader      :="Descripción del Producto"
   oCliInvInt:oBrw:aCols[2]:nWidth       :=280

   oCliInvInt:oBrw:aCols[3]:cHeader      :="Comentario"
   oCliInvInt:oBrw:aCols[3]:nWidth       :=200

   oCliInvInt:oBrw:aCols[4]:cHeader      :="Fecha"
   oCliInvInt:oBrw:aCols[4]:nWidth       :=070

   oCliInvInt:oBrw:aCols[5]:cHeader      :="Und/Med"
   oCliInvInt:oBrw:aCols[5]:nWidth       :=060

   oCliInvInt:oBrw:aCols[6]:cHeader      :="Cantidad"
   oCliInvInt:oBrw:aCols[6]:nWidth       :=160
   oCliInvInt:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oCliInvInt:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oCliInvInt:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oCliInvInt:oBrw:aCols[4]:bStrData     :={|nMonto|nMonto:=oCliInvInt:oBrw:aArrayData[oCliInvInt:oBrw:nArrayAt,4],;
                                                 TRAN(nMonto,"99,999,999,999.99")}

   oCliInvInt:oBrw:bClrStd      := {|oBrw,nClrText|oBrw    :=oCliInvInt:oBrw,;
                                                nClrText:=0,;
                                               {nClrText,iif( oBrw:nArrayAt%2=0, 14217982, 9690879 ) } }

   oCliInvInt:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliInvInt:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliInvInt:oBrw:CreateFromCode()

   oCliInvInt:Activate({||oCliInvInt:ViewDatBar(oCliInvInt)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oCliInvInt)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oCliInvInt:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION  (oDp:oRep:=REPORTE("CLIINVINT"),;
                   oCliInvInt:oWnd:cTitle:=oCliInvInt:cTitle+" ["+oCliInvInt:cNombre+"]",;
                   oDp:oRep:SetRango(1,oCliInvInt:cCodigo,oCliInvInt:cCodigo,.T.))

   oBtn:cToolTip:="Emitir Listado"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliInvInt:oBrw,oCliInvInt:cTitle,oCliInvInt:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCliInvInt:oBrw:GoTop(),oCliInvInt:oBrw:Setfocus())

   oBtn:cToolTip:="Primer Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oCliInvInt:oBrw:PageDown(),oCliInvInt:oBrw:Setfocus())

   oBtn:cToolTip:="Página Siguiente"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oCliInvInt:oBrw:PageUp(),oCliInvInt:oBrw:Setfocus())

   oBtn:cToolTip:="Página Anterior"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCliInvInt:oBrw:GoBottom(),oCliInvInt:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Documento"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliInvInt:Close()

  oBtn:cToolTip:="Cerrar Consulta"

  oCliInvInt:oBrw:SetColor(0,14217982)
  oCliInvInt:oBrw:GoBottom()

  @ 0.1,50 SAY " "+oCliInvInt:cCodigo OF oBar BORDER SIZE 395,18
  @ 1.4,50 SAY " "+oCliInvInt:cNombre OF oBar BORDER SIZE 395,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

// EOF


