// Programa   : DPCLIENTESXPAIS
// Fecha/Hora : 09/01/2012 12:04:55
// Propósito  : Visualizar los PC con Versiones Diferentes
// Creado Por : Juan Navas
// Llamado por: DPPCLOCSAVE
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   LOCAL aData,cTitle

   cTitle:="Resumen "+oDp:DPCLIENTES + " por  "+oDp:xDPPAISES

   aData:=ASQL(" SELECT CLI_PAIS,COUNT(*) AS CUANTOS FROM DPCLIENTES "+;
               " WHERE CLI_SITUAC"+GetWhere("<>","I")+;
               " GROUP BY CLI_PAIS")

   ViewData(aData,cTitle)
            
RETURN .T.

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oCliPais:=DPEDIT():New(cTitle,"DPCLIENTESXPAIS.EDT","oCliPais",.T.)

   oCliPais:lMsgBar :=.F.

   oCliPais:oBrw:=TXBrowse():New( oCliPais:oDlg )
   oCliPais:oBrw:SetArray( aData, .T. )
   oCliPais:oBrw:SetFont(oFont)

   oCliPais:oBrw:lFooter     := .T.
   oCliPais:oBrw:lHScroll    := .F.
   oCliPais:oBrw:nHeaderLines:= 1
   oCliPais:oBrw:lFooter     :=.T.

   oCliPais:aData            :=ACLONE(aData)

   AEVAL(oCliPais:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCliPais:oBrw:aCols[1]   
   oCol:cHeader      :="Pais"
   oCol:nWidth       :=260


   oCol:=oCliPais:oBrw:aCols[2]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Cantidad"
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oCliPais:oBrw:aArrayData[oCliPais:oBrw:nArrayAt,2],;
                                TRAN(nMonto,"99999999")}

   oCol:cFooter      :=TRAN( aTotal[2],"9999999")



   oCliPais:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCliPais:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 14155775, 9240575 ) } }


   oCliPais:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliPais:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCliPais:oBrw:bLDblClick:={||oCliPais:VERESTADOS()  }

   oCliPais:oBrw:CreateFromCode()

   oCliPais:Activate({||oCliPais:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oCliPais:oDlg

   oCliPais:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oCliPais:VERESTADOS()

   oBtn:cToolTip:="Ver "+oDp:DPPCLOG

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliPais:oBrw,oCliPais:cTitle,oCliPais:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliPais:Close()

  oCliPais:oBrw:SetColor(0,14155775)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCliPais:oBar:=oBar

RETURN .T.

FUNCTION VERESTADOS()
  LOCAL cPais:=oCliPais:oBrw:aArrayData[oCliPais:oBrw:nArrayAt,1]
  LOCAL aData :={},aTotal:={}
  LOCAL oBrw,oCol
  LOCAL oFont,oFontB
  LOCAL cTitle:=oDp:DPCLIENTES+"  "+oDp:xDPPAISES+" ["+cPais+"]"

  CursorWait()

  aData:=ASQL(" SELECT CLI_ESTADO,COUNT(*) AS CUANTOS FROM DPCLIENTES "+;
              " WHERE CLI_SITUAC"+GetWhere("<>","I")+" AND CLI_PAIS"+GetWhere("=",cPais)+;
              " GROUP BY CLI_ESTADO")

   aTotal:=ATOTALES(aData)

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"DPCLIENTESXPAIS2.EDT","oCliPais2",.T.)

   oCliPais2:lMsgBar :=.F.
   oCliPais2:cPais   :=cPais

   oCliPais2:oBrw:=TXBrowse():New( oCliPais2:oDlg )
   oCliPais2:oBrw:SetArray( aData, .T. )
   oCliPais2:oBrw:SetFont(oFont)

   oCliPais2:oBrw:lFooter     := .T.
   oCliPais2:oBrw:lHScroll    := .F.
   oCliPais2:oBrw:nHeaderLines:= 1
   oCliPais2:oBrw:lFooter     :=.T.

   oCliPais2:aData            :=ACLONE(aData)

   AEVAL(oCliPais2:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCliPais2:oBrw:aCols[1]   
   oCol:cHeader      :=oDp:xDPESTADOS
   oCol:nWidth       :=260

   oCol:=oCliPais2:oBrw:aCols[2]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Cantidad"
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oCliPais2:oBrw:aArrayData[oCliPais2:oBrw:nArrayAt,2],;
                                TRAN(nMonto,"99999999")}

   oCol:cFooter      :=TRAN( aTotal[2],"9999999")


   oCliPais2:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCliPais2:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oCliPais2:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliPais2:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCliPais2:oBrw:bLDblClick            :={|| oCliPais2:VERCLIENTES() }

   oCliPais2:oBrw:CreateFromCode()

   oCliPais2:Activate({||oCliPais2:ViewDatBar2()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar2()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oCliPais2:oDlg

   oCliPais2:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          ACTION oCliPais2:VERCLIENTES()

   oBtn:cToolTip:="Listar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oDp:oRep:=REPORTE("DPPCLOG"),;
                  oDp:oRep:SetCriterio(1,oCliPais2:dFecha),;
                  oDp:oRep:SetCriterio(2,oCliPais2:cHora ))

   oBtn:cToolTip:="Listar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliPais2:oBrw,oCliPais2:cTitle,oCliPais2:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliPais2:Close()

  oCliPais2:oBrw:SetColor(0,16773862)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCliPais2:oBar:=oBar

RETURN .T.
/*
// Visualizar Clientes
*/
FUNCTION VERCLIENTES()
   LOCAL aData:={},cTitle

   cTitle:=oDp:DPCLIENTES

   oCliPais2:cEstado:=oCliPais2:oBrw:aArrayData[oCliPais2:oBrw:nArrayAt,1]

   aData:=ASQL(" SELECT CLI_CODIGO,CLI_NOMBRE,CLI_MUNICI,CLI_PARROQ,CLI_CODVEN,VEN_NOMBRE,COUNT(*) AS CUANTOS FROM DPCLIENTES "+;
               " LEFT JOIN DPVENDEDOR ON CLI_CODVEN=VEN_CODIGO "+; 
               " LEFT JOIN DPDOCCLI   ON DOC_CODIGO=CLI_CODIGO "+;
               " WHERE CLI_SITUAC"+GetWhere("<>","I")+;
               "   AND CLI_PAIS  "+GetWhere("=",oCliPais2:cPais  )+;
               "   AND CLI_ESTADO"+GetWhere("=",oCliPais2:cEstado)+;
               " GROUP BY CLI_CODIGO,CLI_NOMBRE,CLI_MUNICI,CLI_PARROQ,CLI_CODVEN")

   oCliPais2:ViewData3(aData,cTitle)

RETURN NIL

FUNCTION ViewData3(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oCliPais3:=DPEDIT():New(cTitle,"DPCLIENTESXPAIS3.EDT","oCliPais3",.T.)

   oCliPais3:lMsgBar :=.F.
   oCliPais3:cEstado:=oCliPais2:cEstado
   oCliPais3:cPais  :=oCliPais2:cPais

   oCliPais3:oBrw:=TXBrowse():New( oCliPais3:oDlg )
   oCliPais3:oBrw:SetArray( aData, .T. )
   oCliPais3:oBrw:SetFont(oFont)

   oCliPais3:oBrw:lFooter     := .T.
   oCliPais3:oBrw:lHScroll    := .F.
   oCliPais3:oBrw:nHeaderLines:= 2
   oCliPais3:oBrw:lFooter     :=.T.

   oCliPais3:aData            :=ACLONE(aData)

   AEVAL(oCliPais3:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCliPais3:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=120

   oCol:=oCliPais3:oBrw:aCols[2]   
   oCol:cHeader      :="Nombre "+oDp:xDPCLIENTES
   oCol:nWidth       :=277

   oCol:=oCliPais3:oBrw:aCols[3]   
   oCol:cHeader      :=oDp:xDPMUNICIPIOS
   oCol:nWidth       :=150

   oCol:=oCliPais3:oBrw:aCols[4]   
   oCol:cHeader      :=oDp:xDPPARROQUIAS
   oCol:nWidth       :=150

   oCol:=oCliPais3:oBrw:aCols[5]   
   oCol:cHeader      :="Cód"+CRLF+oDp:xDPVENDEDOR
   oCol:nWidth       :=60

   oCol:=oCliPais3:oBrw:aCols[6]   
   oCol:cHeader      :="Nombre"+CRLF+oDp:xDPVENDEDOR
   oCol:nWidth       :=140

   oCol:=oCliPais3:oBrw:aCols[7]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Cant."+CRLF+"Docs."
   oCol:nWidth       :=40
   oCol:bStrData     :={|nMonto|nMonto:=oCliPais3:oBrw:aArrayData[oCliPais3:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"99999")}



   oCliPais3:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCliPais3:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16770764, 16566954 ) } }

   oCliPais3:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliPais3:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCliPais3:oBrw:bLDblClick:={||oCliPais3:VERESTADOS()  }

   oCliPais3:oBrw:CreateFromCode()

   oCliPais3:Activate({||oCliPais3:ViewDatBar3()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar3()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oCliPais3:oDlg

   oCliPais3:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          ACTION oCliPais3:VERCLIENTE()

   oBtn:cToolTip:="Ver "+oDp:DPCLIENTES

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oCliPais3:IMPRIMIR3()

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliPais3:oBrw,oCliPais3:cTitle,oCliPais3:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliPais3:Close()

  oCliPais3:oBrw:SetColor(0,16770764)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  @ 0.1,60 SAY " "+oDp:xDPPAISES +": "+oCliPais3:cPais   OF oBar BORDER SIZE 395,18
  @ 1.4,60 SAY " "+oDp:xDPESTADOS+": "+oCliPais3:cEstado OF oBar BORDER SIZE 395,18

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCliPais3:oBar:=oBar

RETURN .T.

FUNCTION VERCLIENTE()
  LOCAL cCodCli:=oCliPais3:oBrw:aArrayData[oCliPais3:oBrw:nArrayAt,1]

  EJECUTAR("DPCLIENTESCON",NIL,cCodCli)

RETURN NIL

FUNCTION IMPRIMIR3()
  LOCAL oRep

  oRep:=REPORTE("DPCLIENTEXPAIS")

  oRep:SetCriterio(1,oCliPais3:cPais  )
  oRep:SetCriterio(2,oCliPais3:cEstado)


RETURN NIL

// EOF
