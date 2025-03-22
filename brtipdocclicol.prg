// Programa   : BRTIPDOCCLICOL
// Fecha/Hora : 07/02/2020 05:54:18
// Propósito  : "Editar Columnas de  Tipos de Documento"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDoc)
   LOCAL aData,aFechas,cFileMem:="USER\BRTIPDOCCLICOL.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg  :=NIL //IF(oTIPDOCCLICOL:lTmdi,oTIPDOCCLICOL:oWnd,oTIPDOCCLICOL:oDlg)
   LOCAL nLin  :=0
   LOCAL nWidth:=0 // oTIPDOCCLICOL:oBrw:nWidth()

   oDp:cRunServer:=NIL

   IF Type("oTIPDOCCLICOL")="O" .AND. oTIPDOCCLICOL:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oTIPDOCCLICOL,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   DEFAULT cTipDoc:="FAV",;
           cWhere :="CTD_TIPDOC"+GetWhere("=",cTipDoc)+" AND CTD_FIELD"+GetWhere("=","MOV_IMPOTR")

   IF COUNT("DPTIPDOCCLICOL",cWhere)=0

      IF cTipDoc<>"FAV"
        EJECUTAR("DPTIPDOCCLICOLCLONE","FAV",cTipDoc,.F.)
      ENDIF

      IF COUNT("DPTIPDOCCLICOL",cWhere)=0
         EJECUTAR("DPTIPDOCCLICOLADD",cTipDoc,.T.)
      ENDIF

   ENDIF

   EJECUTAR("ISTABLEACENTOS","DPTIPDOCCLICOL","CTD_TITLE")

   cTitle:="Personalizar Columnas para Documento" +IF(Empty(cTitle),"",cTitle)

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

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,cTipDoc)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   IF !ValType(aData[1,5])="L" 
      EJECUTAR("DPCAMPOSADD","DPTIPDOCCLICOL","CTD_ACTIVO","L",1,0,"Campo Activo")
      MsgMemo("Campo CTD_ACTIVO, requiere se Lógico")
      EJECUTAR("DPTABLAGRID",3,"DPTIPDOCCLICOL")
      RETURN 
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oTIPDOCCLICOL
            
RETURN .T. 

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL oData,nFontSize

   oData    :=DATASET("DPTIPDOCCLI","USER")
   nFontSize:=oData:Get(cTipDoc,18)  
   oData:End()

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oTIPDOCCLICOL","BRTIPDOCCLICOL.EDT")
   oTIPDOCCLICOL:Windows(0,0,aCoors[3]-160,MIN(660,aCoors[4]-10),.T.) // Maximizado

   oTIPDOCCLICOL:cCodSuc  :=cCodSuc
   oTIPDOCCLICOL:lMsgBar  :=.F.
   oTIPDOCCLICOL:cPeriodo :=aPeriodos[nPeriodo]
   oTIPDOCCLICOL:cCodSuc  :=cCodSuc
   oTIPDOCCLICOL:nPeriodo :=nPeriodo
   oTIPDOCCLICOL:cNombre  :=""
   oTIPDOCCLICOL:dDesde   :=dDesde
   oTIPDOCCLICOL:cServer  :=cServer
   oTIPDOCCLICOL:dHasta   :=dHasta
   oTIPDOCCLICOL:cWhere   :=cWhere
   oTIPDOCCLICOL:cWhere_  :=cWhere_
   oTIPDOCCLICOL:cWhereQry:=""
   oTIPDOCCLICOL:cSql     :=oDp:cSql
   oTIPDOCCLICOL:oWhere   :=TWHERE():New(oTIPDOCCLICOL)
   oTIPDOCCLICOL:cCodPar  :=cCodPar // Código del Parámetro
   oTIPDOCCLICOL:lWhen    :=.T.
   oTIPDOCCLICOL:cTextTit :="" // Texto del Titulo Heredado
   oTIPDOCCLICOL:oDb      :=oDp:oDb
   oTIPDOCCLICOL:cBrwCod  :="TIPDOCCLICOL"
   oTIPDOCCLICOL:lTmdi    :=.T.
   oTIPDOCCLICOL:aHead    :={}
   oTIPDOCCLICOL:cTipDoc  :=cTipDoc
   oTIPDOCCLICOL:nFontSize:=nFontSize
   oTIPDOCCLICOL:SetScript("BRTIPDOCCLICOL")
 
   // Guarda los parámetros del Browse cuando cierra la ventana
   oTIPDOCCLICOL:bValid   :={|| EJECUTAR("BRWSAVEPAR",oTIPDOCCLICOL)}   

   oTIPDOCCLICOL:lBtnMenuBrw :=.F.
   oTIPDOCCLICOL:lBtnSave    :=.F.
   oTIPDOCCLICOL:lBtnCrystal :=.F.
   oTIPDOCCLICOL:lBtnRefresh :=.F.
   oTIPDOCCLICOL:lBtnHtml    :=.T.
   oTIPDOCCLICOL:lBtnExcel   :=.F.
   oTIPDOCCLICOL:lBtnPreview :=.T.
   oTIPDOCCLICOL:lBtnQuery   :=.F.
   oTIPDOCCLICOL:lBtnOptions :=.T.
   oTIPDOCCLICOL:lBtnPageDown:=.T.
   oTIPDOCCLICOL:lBtnPageUp  :=.T.
   oTIPDOCCLICOL:lBtnFilters :=.T.
   oTIPDOCCLICOL:lBtnFind    :=.T.

   oTIPDOCCLICOL:cTipDoc     :=cTipDoc
   oTIPDOCCLICOL:TDC_EDICOL  :=SQLGET("DPTIPDOCCLI","TDC_EDICOL","TDC_TIPO"+GetWhere("=",oTIPDOCCLICOL:cTipDoc))
   oTIPDOCCLICOL:TDC_PESPRI  :=SQLGET("DPTIPDOCCLI","TDC_PESPRI","TDC_TIPO"+GetWhere("=",oTIPDOCCLICOL:cTipDoc))

   oTIPDOCCLICOL:nClrPane1:=16774120
   oTIPDOCCLICOL:nClrPane2:=16769476 

   oTIPDOCCLICOL:nClrText :=CLR_BLACK
   oTIPDOCCLICOL:nClrText1:=6435072

   oTIPDOCCLICOL:oBrw:=TXBrowse():New( IF(oTIPDOCCLICOL:lTmdi,oTIPDOCCLICOL:oWnd,oTIPDOCCLICOL:oDlg ))
   oTIPDOCCLICOL:oBrw:SetArray( aData, .F. )
   oTIPDOCCLICOL:oBrw:SetFont(oFont)

   oTIPDOCCLICOL:oBrw:lFooter     := .T.
   oTIPDOCCLICOL:oBrw:lHScroll    := .T.
   oTIPDOCCLICOL:oBrw:nHeaderLines:= 2
   oTIPDOCCLICOL:oBrw:nDataLines  := 1
   oTIPDOCCLICOL:oBrw:nFooterLines:= 1

   oTIPDOCCLICOL:aData            :=ACLONE(aData)

   AEVAL(oTIPDOCCLICOL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oTIPDOCCLICOL:oBrw:aCols[1]
  oCol:cHeader      :='Columna'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oTIPDOCCLICOL:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oTIPDOCCLICOL:oBrw:aCols[2]
  oCol:cHeader      :='Titulo'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oTIPDOCCLICOL:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nEditType    :=1
  oCol:bOnPostEdit  :={|oCol,uValue|oTIPDOCCLICOL:PUTMONTO(oCol,uValue,2)}


  oCol:=oTIPDOCCLICOL:oBrw:aCols[3]
  oCol:cHeader      :='Ancho'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLICOL:oBrw:aArrayData ) } 
  oCol:nWidth       := 24
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,3],;
                              oCol  := oTIPDOCCLICOL:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)

  oCol:=oTIPDOCCLICOL:oBrw:aCols[4]
  oCol:cHeader      :='Formato'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oTIPDOCCLICOL:oBrw:aArrayData ) } 
  oCol:nWidth       := 192
  oCol:nEditType    :=1
  oCol:bOnPostEdit  :={|oCol,uValue|oTIPDOCCLICOL:PUTMONTO(oCol,uValue,4)}


//  oCol:nDataStrAlign:= AL_RIGHT 
//  oCol:nHeadStrAlign:= AL_RIGHT 
//  oCol:nFootStrAlign:= AL_RIGHT 
//  oCol:bStrData     :={|cData|cData:= oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,4],;
//                              PADR(cData,200)}


  oCol:=oTIPDOCCLICOL:oBrw:aCols[5]
  oCol:cHeader      :='Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLICOL:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oTIPDOCCLICOL:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,5],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}
  oCol:bLDClickData:={||oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,5]:=!oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,5],oTIPDOCCLICOL:oBrw:DrawLine(.T.)} 
  oCol:bStrData    :={||""}
  oCol:bLClickHeader:={||oDp:lSel:=!oTIPDOCCLICOL:oBrw:aArrayData[1,5],; 
  AEVAL(oTIPDOCCLICOL:oBrw:aArrayData,{|a,n| oTIPDOCCLICOL:oBrw:aArrayData[n,5]:=oDp:lSel}),oTIPDOCCLICOL:oBrw:Refresh(.T.)} 

  oTIPDOCCLICOL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

//    nClrText:=IF(oTIPDOCCLICOL:TDC_EDICOL,nClrText,oTIPDOCCLICOL:nClrText1),;


  oTIPDOCCLICOL:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oTIPDOCCLICOL:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                            nClrText:=iif( oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,5], oTIPDOCCLICOL:nClrText,oTIPDOCCLICOL:nClrText1 ),;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, oTIPDOCCLICOL:nClrPane1, oTIPDOCCLICOL:nClrPane2 ) } }

//   oTIPDOCCLICOL:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oTIPDOCCLICOL:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oTIPDOCCLICOL:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oTIPDOCCLICOL:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oTIPDOCCLICOL:oBrw:bLDblClick:={|oBrw|oTIPDOCCLICOL:RUNCLICK() }

   oTIPDOCCLICOL:oBrw:bChange:={||oTIPDOCCLICOL:BRWCHANGE()}
   oTIPDOCCLICOL:oBrw:CreateFromCode()


   oTIPDOCCLICOL:oWnd:oClient := oTIPDOCCLICOL:oBrw

   oTIPDOCCLICOL:Activate({||oTIPDOCCLICOL:oBar:=SETBOTBAR(oTIPDOCCLICOL:oWnd,55,55),oTIPDOCCLICOL:oBar:SetSize(nil,100,.T.)})

   oBar:=oTIPDOCCLICOL:oBar

   oTIPDOCCLICOL:oBrw:GoBottom(.T.)
   oTIPDOCCLICOL:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oTIPDOCCLICOL:oFontBtn   :=oFont    
   oTIPDOCCLICOL:nClrPaneBar:=oDp:nGris
   oTIPDOCCLICOL:oBrw:oLbx  :=oTIPDOCCLICOL

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            TOP PROMPT "Grabar"; 
            ACTION  oTIPDOCCLICOL:GRABARTIPDOC(.T.)

      oBtn:cToolTip:="Guardar"

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\run.BMP";
            TOP PROMPT "Ejecutar"; 
            ACTION  oTIPDOCCLICOL:GRABARTIPDOC(.F.)

      oBtn:cToolTip:="Ejecutar"



     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\programa.BMP";
            TOP PROMPT "Programa";
            ACTION oTIPDOCCLICOL:COLPROGRAMAR()

     oBtn:cToolTip:="Programar Columna"


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\IMPORTAR.BMP";
            TOP PROMPT "Importar";
            ACTION oTIPDOCCLICOL:CLONAR_COLS()

     oBtn:cToolTip:="Importar Definición de Columnas desde Otro Documento"

     oTIPDOCCLICOL:oBtnPaste:=oBtn

/*
      IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","TIPDOCCLICOL"))

        DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        FILENAME "BITMAPS\XBROWSE.BMP";
        TOP PROMPT "Detalles"; 
        ACTION  EJECUTAR("BRWRUNBRWLINK",oTIPDOCCLICOL:oBrw,"TIPDOCCLICOL",oTIPDOCCLICOL:cSql,oTIPDOCCLICOL:nPeriodo,oTIPDOCCLICOL:dDesde,oTIPDOCCLICOL:dHasta,oTIPDOCCLICOL)

        oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
        oTIPDOCCLICOL:oBtnRun:=oBtn

        oTIPDOCCLICOL:oBrw:bLDblClick:={||EVAL(oTIPDOCCLICOL:oBtnRun:bAction) }


     ENDIF
*/

/*
IF oTIPDOCCLICOL:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:oFrm)
ENDIF
*/

IF oTIPDOCCLICOL:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú"; 
           ACTION  (EJECUTAR("BRWBUILDHEAD",oTIPDOCCLICOL),;
                    EJECUTAR("DPBRWMENURUN",oTIPDOCCLICOL,oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:cBrwCod,oTIPDOCCLICOL:cTitle,oTIPDOCCLICOL:aHead));
          WHEN !Empty(oTIPDOCCLICOL:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oTIPDOCCLICOL:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oTIPDOCCLICOL:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oTIPDOCCLICOL:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oTIPDOCCLICOL:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oTIPDOCCLICOL:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oTIPDOCCLICOL:oBrw);
          WHEN LEN(oTIPDOCCLICOL:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oTIPDOCCLICOL:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION  oTIPDOCCLICOL:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oTIPDOCCLICOL:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oTIPDOCCLICOL)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oTIPDOCCLICOL:lBtnExcel

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION  (EJECUTAR("BRWTOEXCEL",oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:cTitle,oTIPDOCCLICOL:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oTIPDOCCLICOL:oBtnXls:=oBtn

ENDIF

IF oTIPDOCCLICOL:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (oTIPDOCCLICOL:HTMLHEAD(),EJECUTAR("BRWTOHTML",oTIPDOCCLICOL:oBrw,NIL,oTIPDOCCLICOL:cTitle,oTIPDOCCLICOL:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oTIPDOCCLICOL:oBtnHtml:=oBtn

ENDIF
 

IF oTIPDOCCLICOL:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview"; 
          ACTION  (EJECUTAR("BRWPREVIEW",oTIPDOCCLICOL:oBrw))

   oBtn:cToolTip:="Previsualización"

   oTIPDOCCLICOL:oBtnPreview:=oBtn

ENDIF
/*
   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRTIPDOCCLICOL")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
            ACTION  oTIPDOCCLICOL:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oTIPDOCCLICOL:oBtnPrint:=oBtn

   ENDIF
*/
IF oTIPDOCCLICOL:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oTIPDOCCLICOL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oTIPDOCCLICOL:oBrw:GoTop(),oTIPDOCCLICOL:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oTIPDOCCLICOL:oBrw:GoBottom(),oTIPDOCCLICOL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oTIPDOCCLICOL:Close()

   oTIPDOCCLICOL:oBrw:SetColor(0,oTIPDOCCLICOL:nClrPane1)

   EVAL(oTIPDOCCLICOL:oBrw:bChange)
 
   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   oTIPDOCCLICOL:oBar:=oBar

//   oBar:SetSize(NIL,110,.T.)

   nLin:=15 // 32+15
   //AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

   @ 55+0 ,nLin  SAY " "+oTIPDOCCLICOL:cTipDoc OF oBar;
                PIXEL BORDER SIZE 100,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

   @ 55+21,nlin SAY " "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oTIPDOCCLICOL:cTipDoc)) OF oBar;
                PIXEL BORDER SIZE 300,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
 
   @ 5+50,nlin+324 CHECKBOX oTIPDOCCLICOL:oTDC_EDICOL  VAR oTIPDOCCLICOL:TDC_EDICOL  PROMPT ANSITOOEM("Columnas Editables") OF oBar PIXEL SIZE 150,15;
                   ON CHANGE oTIPDOCCLICOL:UPDATETIPDOC() FONT oFont

   @ 5+50,nLin+120 CHECKBOX oTIPDOCCLICOL:oTDC_PESPRI  VAR oTIPDOCCLICOL:TDC_PESPRI  PROMPT ANSITOOEM("Peso Antes de Cantidad") OF oBar PIXEL SIZE 150,15;
                   ON CHANGE SQLUPDATE("DPTIPDOCCLI","TDC_PESPRI",oTIPDOCCLICOL:TDC_PESPRI,"TDC_TIPO"+GetWhere("=",oTIPDOCCLICOL:cTipDoc)) FONT oFont

   @ 55+20,140+290 GET oTIPDOCCLICOL:oFontSize  VAR oTIPDOCCLICOL:nFontSize;
                   VALID oTIPDOCCLICOL:VALFONT(oTIPDOCCLICOL:nFontSize) SPINNER PICTURE "999" RIGHT OF oBar SIZE 40,20 PIXEL FONT oFont

   @ 55+20,140+200 SAY " Tamaño Letra " OF oBar;
              PIXEL BORDER SIZE 87,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont RIGHT 

   oTIPDOCCLICOL:BRWRESTOREPAR()
  
RETURN .T.

FUNCTION VALFONT()
RETURN .T.

FUNCTION UPDATETIPDOC()

  IF(oTIPDOCCLICOL:TDC_EDICOL,oTIPDOCCLICOL:oBrw:Disable(),oTIPDOCCLICOL:oBrw:Enable())
  oTIPDOCCLICOL:oBrw:Refresh(.T.)

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

  oRep:=REPORTE("BRTIPDOCCLICOL",cWhere)
  oRep:cSql  :=oTIPDOCCLICOL:cSql
  oRep:cTitle:=oTIPDOCCLICOL:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oTIPDOCCLICOL:oPeriodo:nAt,cWhere

  oTIPDOCCLICOL:nPeriodo:=nPeriodo


  IF oTIPDOCCLICOL:oPeriodo:nAt=LEN(oTIPDOCCLICOL:oPeriodo:aItems)

     oTIPDOCCLICOL:oDesde:ForWhen(.T.)
     oTIPDOCCLICOL:oHasta:ForWhen(.T.)
     oTIPDOCCLICOL:oBtn  :ForWhen(.T.)

     DPFOCUS(oTIPDOCCLICOL:oDesde)

  ELSE

     oTIPDOCCLICOL:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oTIPDOCCLICOL:oDesde:VarPut(oTIPDOCCLICOL:aFechas[1] , .T. )
     oTIPDOCCLICOL:oHasta:VarPut(oTIPDOCCLICOL:aFechas[2] , .T. )

     oTIPDOCCLICOL:dDesde:=oTIPDOCCLICOL:aFechas[1]
     oTIPDOCCLICOL:dHasta:=oTIPDOCCLICOL:aFechas[2]

     cWhere:=oTIPDOCCLICOL:HACERWHERE(oTIPDOCCLICOL:dDesde,oTIPDOCCLICOL:dHasta,oTIPDOCCLICOL:cWhere,.T.)

     oTIPDOCCLICOL:LEERDATA(cWhere,oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:cServer)

  ENDIF

  oTIPDOCCLICOL:SAVEPERIODO()

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

     IF !Empty(oTIPDOCCLICOL:cWhereQry)
       cWhere:=cWhere + oTIPDOCCLICOL:cWhereQry
     ENDIF

     oTIPDOCCLICOL:LEERDATA(cWhere,oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,cTipDoc)
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

   cSql:=" SELECT "+;
         " CTD_FIELD ,"+;
         " CTD_TITLE ,"+;
         " CTD_SIZE  ,"+;
         " CTD_PICTUR,"+;
         " CTD_ACTIVO "+;
         " FROM DPTIPDOCCLICOL"+;
         " WHERE CTD_TIPDOC "+GetWhere("=",cTipDoc)+;
         " GROUP BY CTD_FIELD "+;
         " ORDER BY CTD_NUMPOS"        

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRTIPDOCCLICOL.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   // ViewArray(aData)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,'','',0,0})
   ENDIF

   AEVAL(aData,{|a,n| aData[n,4]:=PADR(a[4],250),;
                      aData[n,2]:=STRTRAN(aData[n,2],CRLF,";")})
   

   IF ValType(oBrw)="O"

      oTIPDOCCLICOL:cSql   :=cSql
      oTIPDOCCLICOL:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oTIPDOCCLICOL:oBrw:aCols[3]
      oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)
      oCol:=oTIPDOCCLICOL:oBrw:aCols[6]
      oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)

      oTIPDOCCLICOL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oTIPDOCCLICOL:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oTIPDOCCLICOL:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRTIPDOCCLICOL.MEM",V_nPeriodo:=oTIPDOCCLICOL:nPeriodo
  LOCAL V_dDesde:=oTIPDOCCLICOL:dDesde
  LOCAL V_dHasta:=oTIPDOCCLICOL:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oTIPDOCCLICOL)
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


    IF Type("oTIPDOCCLICOL")="O" .AND. oTIPDOCCLICOL:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oTIPDOCCLICOL:cWhere_),oTIPDOCCLICOL:cWhere_,oTIPDOCCLICOL:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oTIPDOCCLICOL:LEERDATA(oTIPDOCCLICOL:cWhere_,oTIPDOCCLICOL:oBrw,oTIPDOCCLICOL:cServer)
      oTIPDOCCLICOL:oWnd:Show()
      oTIPDOCCLICOL:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oTIPDOCCLICOL:aHead:=EJECUTAR("HTMLHEAD",oTIPDOCCLICOL)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oTIPDOCCLICOL)
RETURN .T.

FUNCTION GRABARTIPDOC(lClose)
 LOCAL aData := oTIPDOCCLICOL:oBrw:aArrayData,I,cWhere
 LOCAL aFiles,cFile
 LOCAL oData

 DEFAULT lClose:=.T.

 oData    :=DATASET("DPTIPDOCCLI","USER")
 oData:Set(oTIPDOCCLICOL:cTipDoc,oTIPDOCCLICOL:nFontSize)  
 oData:End()

 SQLUPDATE("DPTIPDOCCLI","TDC_ACTIVO",.T.,"TDC_TIPO"+GetWhere("=",oTIPDOCCLICOL:cTipDoc))

 FOR I=1 TO LEN(aData)

     cWhere:="CTD_TIPDOC"+GetWhere("=",oTIPDOCCLICOL:cTipDoc)+" AND "+;
             "CTD_FIELD" +GetWhere("=",aData[I,1]           )

     SQLUPDATE("DPTIPDOCCLICOL",{"CTD_TITLE","CTD_SIZE","CTD_PICTUR","CTD_ACTIVO"},;
                                {aData[I,2] ,aData[I,3],aData[I,4]  ,aData[I,5]  },;
                                 cWhere)

 NEXT I

 // debe remover el archivo del grid
 aFiles:=DIRECTORY("MYFORMS\DPDOCCLI_"+oTIPDOCCLICOL:cTipDoc+"*.GRID")
 FOR I=1 TO LEN(aFiles)
     cFile:="MYforms\"+aFiles[I,1]
     FERASE(cFile)
 NEXT I

 IF lClose
   oTIPDOCCLICOL:Close()
 ENDIF

 EJECUTAR("DPFACTURAV",oTIPDOCCLICOL:cTipDoc)
 
RETURN .T.

FUNCTION PUTMONTO(oCol,uValue,nCol)

//  DEFAULT nCol:=oCol:nAt

  oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,nCol]:=uValue
  oTIPDOCCLICOL:oBrw:DrawLine(.T.)

RETURN .T.


FUNCTION CLONAR_COLS()
  LOCAL cTipDoc,cWhere,cTitle:="Seleccionar Origen",cFind,aData,cSql,oBrw:=oTIPDOCCLICOL:oBrw
  LOCAL aTitle:={"Cód.","Descripción","Cant."}

  cWhere:= " INNER JOIN dptipdoccli ON CTD_TIPDOC=TDC_TIPO WHERE CTD_TIPDOC"+GetWhere("<>",oTIPDOCCLICOL:cTipDoc)

  cTipDoc:=EJECUTAR("REPBDLIST","dptipdocclicol","CTD_TIPDOC,TDC_DESCRI,COUNT(*) AS CUANTOS",NIL,cWhere,cTitle,aTitle,cFind,NIL,NIL,"CTD_TIPDOC",oTIPDOCCLICOL:oBtnPaste)

  IF !Empty(cTipDoc)

   cSql:=" SELECT "+;
         " CTD_FIELD ,"+;
         " CTD_TITLE ,"+;
         " CTD_SIZE  ,"+;
         " CTD_PICTUR,"+;
         " CTD_ACTIVO "+;
         " FROM DPTIPDOCCLICOL"+;
         " WHERE CTD_TIPDOC "+GetWhere("=",cTipDoc)+;
         " ORDER BY CTD_NUMPOS"+;
         " "
    aData:=ASQL(cSql)

    IF !Empty(aData)
      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
      oBrw:Refresh(.T.)
    ENDIF

  ENDIF

RETURN .T.

/*
// Programas columnas DpXbase
*/
FUNCTION COLPROGRAMAR()
    LOCAL aLine :=oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt]
    LOCAL cField:="CTD_MEMOEJ",bRun,cWhere,cMemo,cPrg:=MEMOREAD("DP\DPTIPDOCCLICOL_MEMOEJ.TXT")

    HrbLoad("DPXBASE.HRB") 

    oTIPDOCCLICOL:oBrw:aArrayData[oTIPDOCCLICOL:oBrw:nArrayAt,5]:=.T.
    oTIPDOCCLICOL:oBrw:Drawline(.T.)

    bRun  :={||NIL}

    cWhere:="CTD_TIPDOC"+GetWhere("=",oTIPDOCCLICOL:cTipDoc)+" AND "+;
            "CTD_FIELD "+GetWhere("=",aLine[1])

    cMemo :=SQLGET("DPTIPDOCCLICOL",cField,cWhere)
    cMemo :=IF(Empty(cMemo),cPrg,ALLTRIM(cMemo))

    IF Empty(cMemo)

       cMemo:=[/]+[/ Personalizar Validación ]+ALLTRIM(aLine[1])+" "+ALLTRIM(aLine[2])+CRLF+;
              [/]+[/ oCol:oGrid:SET("XCAMPO",uValue,.T.)  Asigna valor y refresca ]+CRLF+;
              [/]+[/ xValue:=oGrid:XCAMPO                 Leer variables  ]+CRLF+;
              [/]+[/ https://github.com/AdaptaProERP/kernel_source/blob/main/TGRIDCOL.PRG]+CRLF+;
              [/]+[/ https://github.com/AdaptaProERP/kernel_source/blob/main/TDOCGRID.PRG]+CRLF+;
              []+CRLF+;
              [#INCLUDE "DPXBASE.CH"   ]+CRLF+;
              []+CRLF+;
              [FUNCTION MAIN(oCol,nPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)]+CRLF+;
              [  LOCAL lResult:=.T.       ]+CRLF+;
              []+CRLF+;
              [RETURN lResult ]+CRLF+;
              [/]+[/EOF]

    ENDIF

    // cFile :="DP\DPPRECIOTIP_"+cField+".TXT"

    DPXBASEEDIT(3,oTIPDOCCLICOL:cTitle+" "+aLine[1],bRun,NIL,cMemo,"DPTIPDOCCLICOL",cField,cWhere)

RETURN .T.

// EOF
