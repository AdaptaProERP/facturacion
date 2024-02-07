// Programa   : BRPLATODOC
// Fecha/Hora : 01/03/2020 01:47:35
// Propósito  : "Cread Documento desde Plantillas"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDes,oFrm)
   LOCAL aData,aFechas,cFileMem:="USER\BRPLATODOC.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oPLATODOC")="O" .AND. oPLATODOC:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oPLATODOC,GetScript())
   ENDIF

   DEFAULT cTipDes:="PED"


   SQLUPDATE("DPTIPDOCCLI","TDC_REQAPR",.T.,"TDC_TIPO"+GetWhere("=",cTipDes))

//? CLPCOPY(oDp:cSql)

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Crear Documento desde Plantillas" +IF(Empty(cTitle),"",cTitle)

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

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oPLATODOC
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oPLATODOC","BRPLATODOC_"+cTipDes+".EDT")

// oPLATODOC:CreateWindow(0,0,100,550)
   oPLATODOC:Windows(0,0,aCoors[3]-160,MIN(704,aCoors[4]-10),.T.) // Maximizado

   oPLATODOC:cCodSuc  :=cCodSuc
   oPLATODOC:lMsgBar  :=.F.
   oPLATODOC:cPeriodo :=aPeriodos[nPeriodo]
   oPLATODOC:cCodSuc  :=cCodSuc
   oPLATODOC:nPeriodo :=nPeriodo
   oPLATODOC:cNombre  :=""
   oPLATODOC:dDesde   :=dDesde
   oPLATODOC:cServer  :=cServer
   oPLATODOC:dHasta   :=dHasta
   oPLATODOC:cWhere   :=cWhere
   oPLATODOC:cWhere_  :=cWhere_
   oPLATODOC:cWhereQry:=""
   oPLATODOC:cSql     :=oDp:cSql
   oPLATODOC:oWhere   :=TWHERE():New(oPLATODOC)
   oPLATODOC:cCodPar  :=cCodPar // Código del Parámetro
   oPLATODOC:lWhen    :=.T.
   oPLATODOC:cTextTit :="" // Texto del Titulo Heredado
   oPLATODOC:oDb      :=oDp:oDb
   oPLATODOC:cBrwCod  :="PLATODOC"
   oPLATODOC:lTmdi    :=.T.
   oPLATODOC:aHead    :={}
   oPLATODOC:cTipDes  :=cTipDes
   oPLATODOC:oFrm     :=oFrm
 
   // Guarda los parámetros del Browse cuando cierra la ventana
   oPLATODOC:bValid   :={|| EJECUTAR("BRWSAVEPAR",oPLATODOC)}   

   oPLATODOC:lBtnMenuBrw :=.F.
   oPLATODOC:lBtnSave    :=.F.
   oPLATODOC:lBtnCrystal :=.F.
   oPLATODOC:lBtnRefresh :=.F.
   oPLATODOC:lBtnHtml    :=.T.
   oPLATODOC:lBtnExcel   :=.F.
   oPLATODOC:lBtnPreview :=.T.
   oPLATODOC:lBtnQuery   :=.F.
   oPLATODOC:lBtnOptions :=.F.
   oPLATODOC:lBtnPageDown:=.T.
   oPLATODOC:lBtnPageUp  :=.T.
   oPLATODOC:lBtnFilters :=.T.
   oPLATODOC:lBtnFind    :=.T.

   oPLATODOC:nClrPane1:=16774636
   oPLATODOC:nClrPane2:=16772313 

   oPLATODOC:oBrw:=TXBrowse():New( IF(oPLATODOC:lTmdi,oPLATODOC:oWnd,oPLATODOC:oDlg ))
   oPLATODOC:oBrw:SetArray( aData, .F. )
   oPLATODOC:oBrw:SetFont(oFont)

   oPLATODOC:oBrw:lFooter     := .F.
   oPLATODOC:oBrw:lHScroll    := .F.
   oPLATODOC:oBrw:nHeaderLines:= 2
   oPLATODOC:oBrw:nDataLines  := 1
   oPLATODOC:oBrw:nFooterLines:= 1

   oPLATODOC:aData            :=ACLONE(aData)

   AEVAL(oPLATODOC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oPLATODOC:oBrw:aCols[1]
  oCol:cHeader      :='Número'+CRLF+'Plantilla'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPLATODOC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oPLATODOC:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPLATODOC:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  oCol:=oPLATODOC:oBrw:aCols[3]
  oCol:cHeader      :='Tipo'+CRLF+'Doc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPLATODOC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oPLATODOC:oBrw:aCols[4]
  oCol:cHeader      :='Documento Destino'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPLATODOC:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  oCol:=oPLATODOC:oBrw:aCols[5]
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:cHeader      :='Items'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oPLATODOC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oPLATODOC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oPLATODOC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oPLATODOC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oPLATODOC:nClrPane1, oPLATODOC:nClrPane2 ) } }

//   oPLATODOC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oPLATODOC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oPLATODOC:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oPLATODOC:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oPLATODOC:oBrw:bLDblClick:={|oBrw|oPLATODOC:RUNCLICK() }

   oPLATODOC:oBrw:bChange:={||oPLATODOC:BRWCHANGE()}
   oPLATODOC:oBrw:CreateFromCode()


   oPLATODOC:oWnd:oClient := oPLATODOC:oBrw


   oPLATODOC:BRWRESTOREPAR()

   oPLATODOC:Activate({||oPLATODOC:ViewDatBar()})

   BMPGETBTN(oPLATODOC:oBar)


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oPLATODOC:lTmdi,oPLATODOC:oWnd,oPLATODOC:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oPLATODOC:oBrw:nWidth()

   oPLATODOC:oBrw:GoBottom(.T.)
   oPLATODOC:oBrw:Refresh(.T.)

   IF !File("FORMS\BRPLATODOC.EDT")
     oPLATODOC:oBrw:Move(44,0,704+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12	 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oPLATODOC:cServer)

     oPLATODOC:oFontBtn   :=oFont    
   oPLATODOC:nClrPaneBar:=oDp:nGris
   oPLATODOC:oBrw:oLbx  :=oPLATODOC

 DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
              TOP PROMPT "Consulta"; 
              ACTION  EJECUTAR("BRWRUNLINK",oPLATODOC:oBrw,oPLATODOC:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Ejecutar"; 
            ACTION  oPLATODOC:CREADOCCLI(.T.)

//EJECUTAR("CREADOCCLIPLA",oDp:cSucursal,"PLA",oPLATODOC:oBrw:aArrayData[oPLATODOC:oBrw:nArrayAt,1],IoPLATODOC:oBrw:aArrayData[oPLATODOC:oBrw:nArrayAt,3])

   oBtn:cToolTip:="Crear Documento"


 DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\FORM.BMP";
              TOP PROMPT "Origen"; 
              ACTION  oPLATODOC:CREADOCCLI(.F.)

   oBtn:cToolTip:="Editar Plantilla"


  
/*
   IF Empty(oPLATODOC:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","PLATODOC")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","PLATODOC"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
         TOP PROMPT "Detalles"; 
              ACTION  EJECUTAR("BRWRUNBRWLINK",oPLATODOC:oBrw,"PLATODOC",oPLATODOC:cSql,oPLATODOC:nPeriodo,oPLATODOC:dDesde,oPLATODOC:dHasta,oPLATODOC)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oPLATODOC:oBtnRun:=oBtn



       oPLATODOC:oBrw:bLDblClick:={||EVAL(oPLATODOC:oBtnRun:bAction) }


   ENDIF



IF oPLATODOC:lBtnSave
/*
      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
               TOP PROMPT "Grabar"; 
              ACTION  EJECUTAR("DPBRWSAVE",oPLATODOC:oBrw,oPLATODOC:oFrm)
*/
ENDIF

IF oPLATODOC:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
            TOP PROMPT "Menú"; 
              ACTION  (EJECUTAR("BRWBUILDHEAD",oPLATODOC),;
                  EJECUTAR("DPBRWMENURUN",oPLATODOC,oPLATODOC:oBrw,oPLATODOC:cBrwCod,oPLATODOC:cTitle,oPLATODOC:aHead));
          WHEN !Empty(oPLATODOC:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oPLATODOC:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oPLATODOC:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oPLATODOC:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oPLATODOC:oBrw,oPLATODOC);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oPLATODOC:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oPLATODOC:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oPLATODOC:oBrw);
          WHEN LEN(oPLATODOC:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oPLATODOC:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oPLATODOC:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oPLATODOC:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oPLATODOC)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oPLATODOC:lBtnExcel

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
              TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oPLATODOC:oBrw,oPLATODOC:cTitle,oPLATODOC:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oPLATODOC:oBtnXls:=oBtn

ENDIF

IF oPLATODOC:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oPLATODOC:HTMLHEAD(),EJECUTAR("BRWTOHTML",oPLATODOC:oBrw,NIL,oPLATODOC:cTitle,oPLATODOC:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oPLATODOC:oBtnHtml:=oBtn

ENDIF
 

IF oPLATODOC:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oPLATODOC:oBrw))

   oBtn:cToolTip:="Previsualización"

   oPLATODOC:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRPLATODOC")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
              TOP PROMPT "Imprimir"; 
              ACTION  oPLATODOC:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oPLATODOC:oBtnPrint:=oBtn

   ENDIF

IF oPLATODOC:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oPLATODOC:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oPLATODOC:oBrw:GoTop(),oPLATODOC:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oPLATODOC:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
            ACTION  (oPLATODOC:oBrw:PageDown(),oPLATODOC:oBrw:Setfocus())

  ENDIF

  IF  oPLATODOC:lBtnPageUp  

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior"; 
           ACTION  (oPLATODOC:oBrw:PageUp(),oPLATODOC:oBrw:Setfocus())
  ENDIF

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oPLATODOC:oBrw:GoBottom(),oPLATODOC:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oPLATODOC:Close()

  oPLATODOC:oBrw:SetColor(0,oPLATODOC:nClrPane1)

  EVAL(oPLATODOC:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  @ 02,nLin+2 SAY "Destino " OF oBar SIZE 60,20 PIXEL BORDER COLOR CLR_WHITE,16749092 FONT oFont
  @ 23,nLin+2 SAY oPLATODOC:oSayTipDes PROMPT oPLATODOC:cTipDes+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oPLATODOC:cTipDes)) OF oBar BORDER SIZE 300,20;
              PIXEL COLOR CLR_WHITE,16749092 FONT oFont

  @ 02,nLin+71 BMPGET oPLATODOC:oTipDes VAR oPLATODOC:cTipDes OF oBar;
               VALID oPLATODOC:VALTIPDOC();
               NAME "BITMAPS\CLIENTE2.BMP"; 
               ACTION oPLATODOC:LBXTIPDOCCLI();
               SIZE 60,20 PIXEL FONT oFont

  oPLATODOC:oTipDes:lCancel:=.T.

  oPLATODOC:oTipDes:bLostFocus:={||oPLATODOC:VALTIPDOC()}

  oPLATODOC:oTipDes:cToolTip:="Indique Tipo de Documento F6:Catálogo"
  oPLATODOC:oTipDes:cMsg    :=oPLATODOC:oTipDes:cToolTip


  oPLATODOC:oBar:=oBar

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRPLATODOC",cWhere)
  oRep:cSql  :=oPLATODOC:cSql
  oRep:cTitle:=oPLATODOC:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oPLATODOC:oPeriodo:nAt,cWhere

  oPLATODOC:nPeriodo:=nPeriodo


  IF oPLATODOC:oPeriodo:nAt=LEN(oPLATODOC:oPeriodo:aItems)

     oPLATODOC:oDesde:ForWhen(.T.)
     oPLATODOC:oHasta:ForWhen(.T.)
     oPLATODOC:oBtn  :ForWhen(.T.)

     DPFOCUS(oPLATODOC:oDesde)

  ELSE

     oPLATODOC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oPLATODOC:oDesde:VarPut(oPLATODOC:aFechas[1] , .T. )
     oPLATODOC:oHasta:VarPut(oPLATODOC:aFechas[2] , .T. )

     oPLATODOC:dDesde:=oPLATODOC:aFechas[1]
     oPLATODOC:dHasta:=oPLATODOC:aFechas[2]

     cWhere:=oPLATODOC:HACERWHERE(oPLATODOC:dDesde,oPLATODOC:dHasta,oPLATODOC:cWhere,.T.)

     oPLATODOC:LEERDATA(cWhere,oPLATODOC:oBrw,oPLATODOC:cServer)

  ENDIF

  oPLATODOC:SAVEPERIODO()

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

     IF !Empty(oPLATODOC:cWhereQry)
       cWhere:=cWhere + oPLATODOC:cWhereQry
     ENDIF

     oPLATODOC:LEERDATA(cWhere,oPLATODOC:oBrw,oPLATODOC:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

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

   cSql:=" SELECT DOC_NUMERO,MEM_DESCRI,DOC_TIPAFE,TDC_DESCRI,COUNT(*)-1 AS CUANTOS FROM DPDOCCLI "+;
          "  LEFT JOIN DPMEMO      ON DOC_NUMMEM=MEM_NUMERO "+;
          "  LEFT JOIN DPTIPDOCCLI ON DOC_TIPAFE=TDC_TIPO "+;
          "  LEFT JOIN DPMOVINV    ON DOC_CODSUC=MOV_CODSUC AND DOC_TIPDOC=MOV_TIPDOC AND DOC_NUMERO=MOV_DOCUME AND MOV_INVACT=1 AND MOV_APLORG"+GetWhere("=","V")+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DOC_TIPDOC='PLA' AND DOC_ACT=1 "+;
          " GROUP BY DOC_NUMERO ORDER BY DOC_NUMERO"

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRPLATODOC.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',''})
   ENDIF

   

   IF ValType(oBrw)="O"

      oPLATODOC:cSql   :=cSql
      oPLATODOC:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      

      oPLATODOC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oPLATODOC:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oPLATODOC:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRPLATODOC.MEM",V_nPeriodo:=oPLATODOC:nPeriodo
  LOCAL V_dDesde:=oPLATODOC:dDesde
  LOCAL V_dHasta:=oPLATODOC:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oPLATODOC)
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


    IF Type("oPLATODOC")="O" .AND. oPLATODOC:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oPLATODOC:cWhere_),oPLATODOC:cWhere_,oPLATODOC:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oPLATODOC:LEERDATA(oPLATODOC:cWhere_,oPLATODOC:oBrw,oPLATODOC:cServer)
      oPLATODOC:oWnd:Show()
      oPLATODOC:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oPLATODOC:aHead:=EJECUTAR("HTMLHEAD",oPLATODOC)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oPLATODOC)
RETURN .T.

FUNCTION CREADOCCLI(lCrear)
  LOCAL aLine:=oPLATODOC:oBrw:aArrayData[oPLATODOC:oBrw:nArrayAt]

  IF !lCrear
     RETURN EJECUTAR("DPFACTURAV","PLA",aLine[1])
  ENDIF
  
RETURN EJECUTAR("CREADOCCLIPLA",oDp:cSucursal,"PLA",aLine[1],IF(Empty(aLine[3]),oPLATODOC:cTipDes,aLine[3]))

FUNCTION VALTIPDOC()

  oPLATODOC:oTipDes:bLostFocus:=NIL
  oPLATODOC:oSayTipDes:Refresh(.T.)
  oPLATODOC:oTipDes:bLostFocus:={||oPLATODOC:VALTIPDOC()}

RETURN .T.

FUNCTION LBXTIPDOCCLI()
  LOCAL cFileLbx:="DPTIPDOCCLI"
  LOCAL oDpLbx

  oDpLbx:=DpLbx(cFileLbx,NIL,"TDC_PRODUC=1",NIL,nil,nil,oPLATODOC:cTipDes,nil,nil,nil,oPLATODOC:oTipDes)
  oDpLbx:GetValue("TDC_TIPO",oPLATODOC:oTipDes)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF
