// Programa   : DPCLIENTESDOC
// Fecha/Hora : 19/02/2006 22:26:50
// Propósito  : Visualizar Documentos del Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESCON
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cWhere,cTitle)
  LOCAL cSql,oTable,aData:={}

  DEFAULT cCodigo:=STRZERO(1,10),;
          cWhere :="DOC_CXC<>0 AND DOC_ACT='1'",;
          cTitle:="Documentos de Cuentas por Cobrar " 

  cSql:=" SELECT DPDOCCLI.DOC_CODSUC,DPDOCCLI.DOC_NUMERO,DPDOCCLI.DOC_TIPDOC,DPDOCCLI.DOC_CODIGO,DPCLIENTES.CLI_NOMBRE,DPDOCCLI.DOC_TIPTRA,DPDOCCLI.DOC_CXC,DPDOCCLI.DOC_ACT,DPDOCCLI.DOC_ESTADO FROM DPDOCCLI "+;
        " INNER JOIN DPCLIENTES ON DPDOCCLI.DOC_CODIGO=DPCLIENTES.CLI_CODIGO "+;
        "  WHERE (DPDOCCLI.DOC_CODSUC"     +GetWhere("=",oDp:cSucursal)+;
        "   AND  "+cWhere+" AND DOC_ACT=1 AND DOC_CODIGO"+GetWhere("=",cCodigo)+")"+;
        "  ORDER BY DPDOCCLI.DOC_CODIGO "

  oTable:=EJECUTAR("CLIDOCREP",NIL,cSql)

  oTable:Gotop()

  WHILE !oTable:Eof()

     AADD(aData,{oTable:DOC_TIPDOC,oTable:DOC_NUMERO,;
                 oTable:DOC_CODVEN,;
                 oTable:DOC_NETO  ,;
                 oTable:DOC_PAGOS ,;
                 oTable:DOC_SALDO ,;
                 oTable:DOC_FECHA ,;
                 oTable:DOC_FCHVEN,;
                 oTable:DOC_DIAVEN,;
                 oTable:DOC_CXC,;
                 oTable:DOC_ESTADO})

     oTable:DbSkip()

  ENDDO

//IIF(oTable:DOC_SALDO<>0,oDp:dFecha-oTable:DOC_FCHVEN,0),;

  oTable:End()

  IF !Empty(aData)
     ViewData(aData,cCodigo,cTitle)
  ELSE
     MensajeErr("Información no Encontrada")
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

   oCliCxC:=DPEDIT():New(cTitle,"DPCLIENTESDOC.EDT","oCliCxC",.T.)
   oCliCxC:cCodigo:=cCodigo
   oCliCxC:cNombre:=cNombre
   oCliCxC:lMsgBar:=.F.

   oCliCxC:oBrw:=TXBrowse():New( oCliCxC:oDlg )
   oCliCxC:oBrw:SetArray( aData, .F. )
   oCliCxC:oBrw:SetFont(oFont)
   oCliCxC:oBrw:lFooter := .T.
   oCliCxC:oBrw:lHScroll:= .T.
   oCliCxC:oBrw:nHeaderLines:= 2

   oCliCxC:cCodTra  :=cCodigo
   oCliCxC:cNombre  :=ALLTRIM(cNombre)

   AEVAL(oCliCxC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCliCxC:oBrw:aCols[1]:cHeader      :="Tipo"
   oCliCxC:oBrw:aCols[1]:nWidth       :=035

   oCliCxC:oBrw:aCols[2]:cHeader      :="Número"+CRLF+"Documento"
   oCliCxC:oBrw:aCols[2]:nWidth       :=080


   oCliCxC:oBrw:aCols[3]:cHeader      :="Cód."+CRLF+"Vend."
   oCliCxC:oBrw:aCols[3]:nWidth       :=050

   oCliCxC:oBrw:aCols[4]:cHeader      :="Neto"
   oCliCxC:oBrw:aCols[4]:nWidth       :=160
   oCliCxC:oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[4]:nFootStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[4]:bStrData     :={|nMonto|nMonto:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt,4],;
                                                 TRAN(nMonto,"99,999,999,999.99")}

   oCliCxC:oBrw:aCols[4]:cFooter      :=TRAN(nNeto,"99,999,999,999.99")
   oCliCxC:oBrw:aCols[4]:bClrStd      := {|oBrw,nClrText|oBrw    :=oCliCxC:oBrw,;
                                                         nClrText:=iif(oBrw:aArrayData[oBrw:nArrayAt,10]=1,CLR_HBLUE,CLR_HRED),;
                                                        {nClrText,iif( oBrw:nArrayAt%2=0, 9690879, 14217982 ) } }

   oCliCxC:oBrw:aCols[5]:cHeader      :="Pagos"
   oCliCxC:oBrw:aCols[5]:nWidth       :=160
   oCliCxC:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[5]:bStrData     :={|nMonto|nMonto:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt,5],;
                                                 TRAN(nMonto,"99,999,999,999.99")}

   oCliCxC:oBrw:aCols[5]:bClrStd      := {|oBrw,nClrText|oBrw    :=oCliCxC:oBrw,;
                                                         nClrText:=iif(oBrw:aArrayData[oBrw:nArrayAt,10]=-1,CLR_HBLUE,CLR_HRED),;
                                                         nClrText:=iif(oBrw:aArrayData[oBrw:nArrayAt,5 ]=0,        0,nClrText),;
                                                        {nClrText,iif( oBrw:nArrayAt%2=0, 9690879, 14217982 ) } }



   oCliCxC:oBrw:aCols[5]:cFooter      :=TRAN(nPagos,"99,999,999,999.99")

   oCliCxC:oBrw:aCols[6]:cHeader      :="Saldo"
   oCliCxC:oBrw:aCols[6]:nWidth       :=160
   oCliCxC:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[6]:bStrData     :={|nMonto|nMonto:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt,6],;
                                                 TRAN(nMonto,"99,999,999,999.99")}

   oCliCxC:oBrw:aCols[6]:bClrStd      := {|oBrw,nClrText|oBrw    :=oCliCxC:oBrw,;
                                                         nClrText:=iif(oBrw:aArrayData[oBrw:nArrayAt,6 ]>0,CLR_HBLUE,CLR_HRED),;
                                                         nClrText:=iif(oBrw:aArrayData[oBrw:nArrayAt,6 ]=0, 0,nClrText),;
                                                        {nClrText,iif( oBrw:nArrayAt%2=0, 9690879, 14217982 ) } }



   oCliCxC:oBrw:aCols[6]:cFooter      :=TRAN(nSaldo,"99,999,999,999.99")

   oCliCxC:oBrw:aCols[7]:cHeader      :="Fecha"+CRLF+"Emisión"
   oCliCxC:oBrw:aCols[7]:nWidth       :=070
   oCliCxC:oBrw:aCols[7]:nHeadStrAlign:= AL_RIGHT

   oCliCxC:oBrw:aCols[8]:cHeader      :="Fecha"+CRLF+"Venc."
   oCliCxC:oBrw:aCols[8]:nWidth       :=070
   oCliCxC:oBrw:aCols[8]:nHeadStrAlign:= AL_RIGHT

   oCliCxC:oBrw:aCols[9]:cHeader      :="Días"+CRLF+"Vencido"
   oCliCxC:oBrw:aCols[9]:nWidth       :=070
   oCliCxC:oBrw:aCols[9]:nHeadStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[9]:bStrData     :={|nDias|nDias:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt,9],;
                                                TRAN(nDias,"9999")}
   oCliCxC:oBrw:aCols[9]:nDataStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[9]:nHeadStrAlign:= AL_RIGHT
   oCliCxC:oBrw:aCols[9]:nFootStrAlign:= AL_RIGHT

   oCliCxC:oBrw:bClrStd               := {|oBrw,nClrText|oBrw    :=oCliCxC:oBrw,;
                                                         nClrText:=0,;
                                                        {nClrText,iif( oBrw:nArrayAt%2=0, 9690879, 14217982 ) } }

   oCliCxC:oBrw:aCols[10]:cHeader      :="Edo."
   oCliCxC:oBrw:aCols[10]:nWidth       :=035
   oCliCxC:oBrw:aCols[10]:bStrData     :={|cEdo|cEdo:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt,11],;
                                                 Left(cEdo,3)}

   WHILE LEN(oCliCxC:oBrw:aCols)>10
      oCliCxC:oBrw:DelCol(LEN(oCliCxC:oBrw:aCols))
   ENDDO

   oCliCxC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliCxC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliCxC:oBrw:CreateFromCode()

   oCliCxC:Activate({||oCliCxC:ViewDatBar(oCliCxC)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oCliCxC)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oCliCxC:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION oCliCxC:View()

   oBtn:cToolTip:="Consultar Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION  (oDp:oRep:=REPORTE("CLIDOC"),;
                   oFrmRun:oWnd:cTitle:=oCliCxC:cTitle+" ["+oCliCxC:cNombre+"]",;
                   oDp:oRep:SetRango(1,oCliCxC:cCodigo,oCliCxC:cCodigo,.T.))

   oBtn:cToolTip:="Listado de Documentos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliCxC:oBrw,oCliCxC:cTitle,oCliCxC:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCliCxC:oBrw:GoTop(),oCliCxC:oBrw:Setfocus())

   oBtn:cToolTip:="Primer Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oCliCxC:oBrw:PageDown(),oCliCxC:oBrw:Setfocus())

   oBtn:cToolTip:="Página Siguiente"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oCliCxC:oBrw:PageUp(),oCliCxC:oBrw:Setfocus())

   oBtn:cToolTip:="Página Anterior"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCliCxC:oBrw:GoBottom(),oCliCxC:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Documento"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliCxC:Close()

  oBtn:cToolTip:="Cerrar Consulta"

  oCliCxC:oBrw:SetColor(0,14217982)
  oCliCxC:oBrw:GoBottom()

  @ 0.1,56 SAY " "+oCliCxC:cCodigo OF oBar BORDER SIZE 395,18
  @ 1.4,56 SAY " "+oCliCxC:cNombre OF oBar BORDER SIZE 395,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,oForm:=oCliCxC

  oRep:=REPORTE("CLIDOC")

//  SysRefresh(.T.)
//  oRep:=REPORTE("CLIDOC")
//
  IF ValType(oRep)="O"
    //? oRep:ClassName(),oCliCxC:ClassName()
    //? oCliCxC:cCodigo 
    oRep:SetRango(1,oCliCxC:cCodigo,oCliCxC:cCodigo,.T.)
  ENDIF

  oCliCxC:=oForm

RETURN .T.

/*
// Imprimir
*/
/*
// Consulta del Documento
*/
FUNCTION VIEW()
   LOCAL cFile
   LOCAL aLine:=oCliCxC:oBrw:aArrayData[oCliCxC:oBrw:nArrayAt]
   LOCAL cCodSuc:=oDp:cSucursal,cNumero:=aLine[2]
   LOCAL cTipDoc:=aLine[1]

   oCliCxC:cTipDoc:=aLine[1]

   cFile:="DPXBASE\DPDOCCLI"+oCliCxC:cTipDoc+"CON"

   IF FILE(cFile+".DXB")
      EJECUTAR("DPDOCCLI"+oCliCxC:cTipDoc+"CON",NIL,cCodSuc,cTipDoc,cNumero,oCliCxC:cCodigo)
   ELSE
      EJECUTAR("DPDOCCLIFAVCON",NIL,cCodSuc,cTipDoc,cNumero,oCliCxC:cCodigo)
   ENDIF

RETURN .T.



// EOF


