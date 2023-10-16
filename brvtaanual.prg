// Programa   : BRVTAANUAL
// Fecha/Hora : 15/10/2023 19:46:47
// Propósito  : "Resumen de Ventas Anual"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRVTAANUAL.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oVTAANUAL")="O" .AND. oVTAANUAL:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oVTAANUAL,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Resumen de Ventas Anual" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oVTAANUAL

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oVTAANUAL","BRVTAANUAL.EDT")
// oVTAANUAL:CreateWindow(0,0,100,550)
   oVTAANUAL:Windows(0,0,aCoors[3]-160,MIN(584,aCoors[4]-10),.T.) // Maximizado



   oVTAANUAL:cCodSuc  :=cCodSuc
   oVTAANUAL:lMsgBar  :=.F.
   oVTAANUAL:cPeriodo :=aPeriodos[nPeriodo]
   oVTAANUAL:cCodSuc  :=cCodSuc
   oVTAANUAL:nPeriodo :=nPeriodo
   oVTAANUAL:cNombre  :=""
   oVTAANUAL:dDesde   :=dDesde
   oVTAANUAL:cServer  :=cServer
   oVTAANUAL:dHasta   :=dHasta
   oVTAANUAL:cWhere   :=cWhere
   oVTAANUAL:cWhere_  :=cWhere_
   oVTAANUAL:cWhereQry:=""
   oVTAANUAL:cSql     :=oDp:cSql
   oVTAANUAL:oWhere   :=TWHERE():New(oVTAANUAL)
   oVTAANUAL:cCodPar  :=cCodPar // Código del Parámetro
   oVTAANUAL:lWhen    :=.T.
   oVTAANUAL:cTextTit :="" // Texto del Titulo Heredado
   oVTAANUAL:oDb      :=oDp:oDb
   oVTAANUAL:cBrwCod  :="VTAANUAL"
   oVTAANUAL:lTmdi    :=.T.
   oVTAANUAL:aHead    :={}
   oVTAANUAL:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oVTAANUAL:bValid   :={|| EJECUTAR("BRWSAVEPAR",oVTAANUAL)}

   oVTAANUAL:lBtnRun     :=.F.
   oVTAANUAL:lBtnMenuBrw :=.F.
   oVTAANUAL:lBtnSave    :=.F.
   oVTAANUAL:lBtnCrystal :=.F.
   oVTAANUAL:lBtnRefresh :=.F.
   oVTAANUAL:lBtnHtml    :=.T.
   oVTAANUAL:lBtnExcel   :=.T.
   oVTAANUAL:lBtnPreview :=.T.
   oVTAANUAL:lBtnQuery   :=.F.
   oVTAANUAL:lBtnOptions :=.T.
   oVTAANUAL:lBtnPageDown:=.T.
   oVTAANUAL:lBtnPageUp  :=.T.
   oVTAANUAL:lBtnFilters :=.T.
   oVTAANUAL:lBtnFind    :=.T.
   oVTAANUAL:lBtnColor   :=.T.

   oVTAANUAL:nClrPane1:=16775408
   oVTAANUAL:nClrPane2:=16771797

   oVTAANUAL:nClrText :=0
   oVTAANUAL:nClrText1:=0
   oVTAANUAL:nClrText2:=0
   oVTAANUAL:nClrText3:=0




   oVTAANUAL:oBrw:=TXBrowse():New( IF(oVTAANUAL:lTmdi,oVTAANUAL:oWnd,oVTAANUAL:oDlg ))
   oVTAANUAL:oBrw:SetArray( aData, .F. )
   oVTAANUAL:oBrw:SetFont(oFont)

   oVTAANUAL:oBrw:lFooter     := .T.
   oVTAANUAL:oBrw:lHScroll    := .F.
   oVTAANUAL:oBrw:nHeaderLines:= 2
   oVTAANUAL:oBrw:nDataLines  := 1
   oVTAANUAL:oBrw:nFooterLines:= 1




   oVTAANUAL:aData            :=ACLONE(aData)

   AEVAL(oVTAANUAL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: YEAR(DOC_FECHA)
  oCol:=oVTAANUAL:oBrw:aCols[1]
  oCol:cHeader      :='Año'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAANUAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt,1],;
                              oCol  := oVTAANUAL:oBrw:aCols[1],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[1],oCol:cEditPicture)


  // Campo: DOC_MONTO
  oCol:=oVTAANUAL:oBrw:aCols[2]
  oCol:cHeader      :='Monto'+CRLF+'Bs.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAANUAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt,2],;
                              oCol  := oVTAANUAL:oBrw:aCols[2],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[2],oCol:cEditPicture)


  // Campo: DOC_MTODIV
  oCol:=oVTAANUAL:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAANUAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt,3],;
                              oCol  := oVTAANUAL:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)


  // Campo: DIAS_FREC
  oCol:=oVTAANUAL:oBrw:aCols[4]
  oCol:cHeader      :='Freq.'+CRLF+'Días'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAANUAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt,4],;
                              oCol  := oVTAANUAL:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)


  // Campo: CUANTOS
  oCol:=oVTAANUAL:oBrw:aCols[5]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAANUAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt,5],;
                              oCol  := oVTAANUAL:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}



   oVTAANUAL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oVTAANUAL:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oVTAANUAL:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oVTAANUAL:nClrText,;
                                                 nClrText:=IF(.F.,oVTAANUAL:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oVTAANUAL:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oVTAANUAL:nClrPane1, oVTAANUAL:nClrPane2 ) } }

//   oVTAANUAL:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oVTAANUAL:oBrw:bClrFooter            := {|| {0,14671839 }}

   oVTAANUAL:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oVTAANUAL:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oVTAANUAL:oBrw:bLDblClick:={|oBrw|oVTAANUAL:RUNCLICK() }

   oVTAANUAL:oBrw:bChange:={||oVTAANUAL:BRWCHANGE()}
   oVTAANUAL:oBrw:CreateFromCode()


   oVTAANUAL:oWnd:oClient := oVTAANUAL:oBrw



   oVTAANUAL:Activate({||oVTAANUAL:ViewDatBar()})

   oVTAANUAL:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oVTAANUAL:lTmdi,oVTAANUAL:oWnd,oVTAANUAL:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oVTAANUAL:oBrw:nWidth()

   oVTAANUAL:oBrw:GoBottom(.T.)
   oVTAANUAL:oBrw:Refresh(.T.)

   IF !File("FORMS\BRVTAANUAL.EDT")
     oVTAANUAL:oBrw:Move(44,0,584+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oVTAANUAL:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oVTAANUAL:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS() Repintar




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oVTAANUAL:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oVTAANUAL:oBrw,oVTAANUAL:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oVTAANUAL:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","VTAANUAL")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","VTAANUAL"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oVTAANUAL:oBrw,"VTAANUAL",oVTAANUAL:cSql,oVTAANUAL:nPeriodo,oVTAANUAL:dDesde,oVTAANUAL:dHasta,oVTAANUAL)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oVTAANUAL:oBtnRun:=oBtn



       oVTAANUAL:oBrw:bLDblClick:={||EVAL(oVTAANUAL:oBtnRun:bAction) }


   ENDIF




IF oVTAANUAL:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oVTAANUAL");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oVTAANUAL:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oVTAANUAL:lBtnColor

     oVTAANUAL:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oVTAANUAL:oBrw,oVTAANUAL,oVTAANUAL:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oVTAANUAL,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oVTAANUAL,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oVTAANUAL:oBtnColor:=oBtn

ENDIF

IF oVTAANUAL:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Guardar";
             ACTION EJECUTAR("DPBRWSAVE",oVTAANUAL:oBrw,oVTAANUAL:oFrm)

ENDIF

IF oVTAANUAL:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oVTAANUAL),;
                  EJECUTAR("DPBRWMENURUN",oVTAANUAL,oVTAANUAL:oBrw,oVTAANUAL:cBrwCod,oVTAANUAL:cTitle,oVTAANUAL:aHead));
          WHEN !Empty(oVTAANUAL:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oVTAANUAL:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oVTAANUAL:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oVTAANUAL:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oVTAANUAL:oBrw,oVTAANUAL);
          ACTION EJECUTAR("BRWSETFILTER",oVTAANUAL:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oVTAANUAL:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oVTAANUAL:oBrw);
          WHEN LEN(oVTAANUAL:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oVTAANUAL:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oVTAANUAL:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oVTAANUAL:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oVTAANUAL)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oVTAANUAL:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oVTAANUAL:oBrw,oVTAANUAL:cTitle,oVTAANUAL:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oVTAANUAL:oBtnXls:=oBtn

ENDIF

IF oVTAANUAL:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oVTAANUAL:HTMLHEAD(),EJECUTAR("BRWTOHTML",oVTAANUAL:oBrw,NIL,oVTAANUAL:cTitle,oVTAANUAL:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oVTAANUAL:oBtnHtml:=oBtn

ENDIF


IF oVTAANUAL:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oVTAANUAL:oBrw))

   oBtn:cToolTip:="Previsualización"

   oVTAANUAL:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRVTAANUAL")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oVTAANUAL:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oVTAANUAL:oBtnPrint:=oBtn

   ENDIF

IF oVTAANUAL:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oVTAANUAL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oVTAANUAL:oBrw:GoTop(),oVTAANUAL:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oVTAANUAL:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oVTAANUAL:oBrw:PageDown(),oVTAANUAL:oBrw:Setfocus())

  ENDIF

  IF  oVTAANUAL:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oVTAANUAL:oBrw:PageUp(),oVTAANUAL:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oVTAANUAL:oBrw:GoBottom(),oVTAANUAL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oVTAANUAL:Close()

  oVTAANUAL:oBrw:SetColor(0,oVTAANUAL:nClrPane1)

  IF oDp:lBtnText
     oVTAANUAL:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oVTAANUAL:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oVTAANUAL:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oVTAANUAL:oBar:=oBar

  

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL aLine :=oVTAANUAL:oBrw:aArrayData[oVTAANUAL:oBrw:nArrayAt]
  LOCAL dDesde:=CTOD("01/01/"+LSTR(aLine[1]))
  LOCAL dHasta:=CTOD("31/12/"+LSTR(aLine[1]))

  EJECUTAR("BREMVTAANOMES",NIL,oVTAANUAL:cCodSuc,oDp:nAnual,dDesde,dHasta,NIL)

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRVTAANUAL",cWhere)
  oRep:cSql  :=oVTAANUAL:cSql
  oRep:cTitle:=oVTAANUAL:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oVTAANUAL:oPeriodo:nAt,cWhere

  oVTAANUAL:nPeriodo:=nPeriodo


  IF oVTAANUAL:oPeriodo:nAt=LEN(oVTAANUAL:oPeriodo:aItems)

     oVTAANUAL:oDesde:ForWhen(.T.)
     oVTAANUAL:oHasta:ForWhen(.T.)
     oVTAANUAL:oBtn  :ForWhen(.T.)

     DPFOCUS(oVTAANUAL:oDesde)

  ELSE

     oVTAANUAL:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oVTAANUAL:oDesde:VarPut(oVTAANUAL:aFechas[1] , .T. )
     oVTAANUAL:oHasta:VarPut(oVTAANUAL:aFechas[2] , .T. )

     oVTAANUAL:dDesde:=oVTAANUAL:aFechas[1]
     oVTAANUAL:dHasta:=oVTAANUAL:aFechas[2]

     cWhere:=oVTAANUAL:HACERWHERE(oVTAANUAL:dDesde,oVTAANUAL:dHasta,oVTAANUAL:cWhere,.T.)

     oVTAANUAL:LEERDATA(cWhere,oVTAANUAL:oBrw,oVTAANUAL:cServer,oVTAANUAL)

  ENDIF

  oVTAANUAL:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oVTAANUAL:cWhereQry)
       cWhere:=cWhere + oVTAANUAL:cWhereQry
     ENDIF

     oVTAANUAL:LEERDATA(cWhere,oVTAANUAL:oBrw,oVTAANUAL:cServer,oVTAANUAL)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oVTAANUAL)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
          " YEAR(DOC_FECHA) AS ANO ,  "+;
          " SUM(DOC_NETO*DOC_CXC)  AS DOC_MONTO,"+;
          " SUM(DOC_MTODIV*DOC_CXC)  AS DOC_MTODIV,"+;
          " DATEDIFF(MAX(DOC_FECHA), MIN(DOC_FECHA)) / (COUNT(DOC_FECHA) - 1) AS DIAS_FREC, "+;
          " COUNT(*) AS CUANTOS"+;
          " FROM DPDOCCLI "+;
          " INNER JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO AND TDC_ESTVTA=1 "+;
          " WHERE DOC_ACT=1 AND DOC_TIPTRA='D' AND DOC_FECHA"+GetWhere("<>","")+;
          " GROUP BY YEAR(DOC_FECHA) "+;
          " HAVING ANO>0 "+;
          " ORDER BY YEAR(DOC_FECHA)"+;
          ""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRVTAANUAL.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{0,0,0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oVTAANUAL:cSql   :=cSql
      oVTAANUAL:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oVTAANUAL:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oVTAANUAL:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRVTAANUAL.MEM",V_nPeriodo:=oVTAANUAL:nPeriodo
  LOCAL V_dDesde:=oVTAANUAL:dDesde
  LOCAL V_dHasta:=oVTAANUAL:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oVTAANUAL)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oVTAANUAL")="O" .AND. oVTAANUAL:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oVTAANUAL:cWhere_),oVTAANUAL:cWhere_,oVTAANUAL:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oVTAANUAL:LEERDATA(oVTAANUAL:cWhere_,oVTAANUAL:oBrw,oVTAANUAL:cServer,oVTAANUAL)
      oVTAANUAL:oWnd:Show()
      oVTAANUAL:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oVTAANUAL:aHead:=EJECUTAR("HTMLHEAD",oVTAANUAL)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oVTAANUAL)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

