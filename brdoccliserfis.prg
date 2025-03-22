// Programa   : BRDOCCLISERFIS
// Fecha/Hora : 02/03/2025 04:24:42
// Propósito  : "Resumen de Documentos por Series Fiscales"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDOCCLISERFIS.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oDOCCLISERFIS")="O" .AND. oDOCCLISERFIS:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDOCCLISERFIS,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Resumen de Documentos por Series Fiscales" +IF(Empty(cTitle),"",cTitle)

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

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dDesde,dDesde,dHasta)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dDesde,dDesde,dHasta)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oDOCCLISERFIS

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oDOCCLISERFIS","BRDOCCLISERFIS.EDT")
// oDOCCLISERFIS:CreateWindow(0,0,100,550)
   oDOCCLISERFIS:Windows(0,0,aCoors[3]-160,MIN(909,aCoors[4]-10),.T.) // Maximizado



   oDOCCLISERFIS:cCodSuc  :=cCodSuc
   oDOCCLISERFIS:lMsgBar  :=.F.
   oDOCCLISERFIS:cPeriodo :=aPeriodos[nPeriodo]
   oDOCCLISERFIS:cCodSuc  :=cCodSuc
   oDOCCLISERFIS:nPeriodo :=nPeriodo
   oDOCCLISERFIS:cNombre  :=""
   oDOCCLISERFIS:dDesde   :=dDesde
   oDOCCLISERFIS:cServer  :=cServer
   oDOCCLISERFIS:dHasta   :=dHasta
   oDOCCLISERFIS:cWhere   :=cWhere
   oDOCCLISERFIS:cWhere_  :=cWhere_
   oDOCCLISERFIS:cWhereQry:=""
   oDOCCLISERFIS:cSql     :=oDp:cSql
   oDOCCLISERFIS:oWhere   :=TWHERE():New(oDOCCLISERFIS)
   oDOCCLISERFIS:cCodPar  :=cCodPar // Código del Parámetro
   oDOCCLISERFIS:lWhen    :=.T.
   oDOCCLISERFIS:cTextTit :="" // Texto del Titulo Heredado
   oDOCCLISERFIS:oDb      :=oDp:oDb
   oDOCCLISERFIS:cBrwCod  :="DOCCLISERFIS"
   oDOCCLISERFIS:lTmdi    :=.T.
   oDOCCLISERFIS:aHead    :={}
   oDOCCLISERFIS:lBarDef  :=.T. // Activar Modo Diseño.
   oDOCCLISERFIS:aFields  :=ACLONE(aFields)

   oDOCCLISERFIS:nClrPane1:=oDp:nClrPane1
   oDOCCLISERFIS:nClrPane2:=oDp:nClrPane2

   oDOCCLISERFIS:nClrText1:=0
   oDOCCLISERFIS:nClrText2:=0
   oDOCCLISERFIS:nClrText3:=0
   oDOCCLISERFIS:nClrText4:=0
   oDOCCLISERFIS:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oDOCCLISERFIS:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oDOCCLISERFIS:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDOCCLISERFIS)}

   oDOCCLISERFIS:lBtnRun     :=.F.
   oDOCCLISERFIS:lBtnMenuBrw :=.F.
   oDOCCLISERFIS:lBtnSave    :=.F.
   oDOCCLISERFIS:lBtnCrystal :=.F.
   oDOCCLISERFIS:lBtnRefresh :=.F.
   oDOCCLISERFIS:lBtnHtml    :=.T.
   oDOCCLISERFIS:lBtnExcel   :=.T.
   oDOCCLISERFIS:lBtnPreview :=.T.
   oDOCCLISERFIS:lBtnQuery   :=.F.
   oDOCCLISERFIS:lBtnOptions :=.T.
   oDOCCLISERFIS:lBtnPageDown:=.T.
   oDOCCLISERFIS:lBtnPageUp  :=.T.
   oDOCCLISERFIS:lBtnFilters :=.T.
   oDOCCLISERFIS:lBtnFind    :=.T.
   oDOCCLISERFIS:lBtnColor   :=.T.
   oDOCCLISERFIS:lBtnZoom    :=.F.
   oDOCCLISERFIS:lBtnNew     :=.F.


   oDOCCLISERFIS:nClrPane1:=16775408
   oDOCCLISERFIS:nClrPane2:=16771797

   oDOCCLISERFIS:nClrText :=0
   oDOCCLISERFIS:nClrText1:=0
   oDOCCLISERFIS:nClrText2:=0
   oDOCCLISERFIS:nClrText3:=0




   oDOCCLISERFIS:oBrw:=TXBrowse():New( IF(oDOCCLISERFIS:lTmdi,oDOCCLISERFIS:oWnd,oDOCCLISERFIS:oDlg ))
   oDOCCLISERFIS:oBrw:SetArray( aData, .F. )
   oDOCCLISERFIS:oBrw:SetFont(oFont)

   oDOCCLISERFIS:oBrw:lFooter     := .T.
   oDOCCLISERFIS:oBrw:lHScroll    := .T.
   oDOCCLISERFIS:oBrw:nHeaderLines:= 2
   oDOCCLISERFIS:oBrw:nDataLines  := 1
   oDOCCLISERFIS:oBrw:nFooterLines:= 1




   oDOCCLISERFIS:aData            :=ACLONE(aData)

   AEVAL(oDOCCLISERFIS:oBrw:aCols,{|oCol,n|oCol:oHeaderFont:=oFontB, oCol:nPos:=n})

   

  // Campo: DOC_CODSUC
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_CODSUC]
  oCol:cHeader      :='Cód.'+CRLF+'Suc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  // Campo: SUC_DESCRI
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_SUC_DESCRI]
  oCol:cHeader      :='Sucursal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: DOC_TIPDOC
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_TIPDOC]
  oCol:cHeader      :='Tipo'+CRLF+'Doc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 32
oCol:bClrStd  := {|nClrText,uValue|uValue:=oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,3],;
                     nClrText:=COLOR_OPTIONS("DPDOCCLI            ","DOC_TIPDOC",uValue),;
                     {nClrText,iif( oDOCCLISERFIS:oBrw:nArrayAt%2=0, oDOCCLISERFIS:nClrPane1, oDOCCLISERFIS:nClrPane2 ) } } 

  // Campo: TDC_DESCRI
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_TDC_DESCRI]
  oCol:cHeader      :='Tipo de Documento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
oCol:bClrStd  := {|nClrText,uValue|uValue:=oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,4],;
                     nClrText:=COLOR_OPTIONS("DPTIPDOCPRO         ","TDC_DESCRI",uValue),;
                     {nClrText,iif( oDOCCLISERFIS:oBrw:nArrayAt%2=0, oDOCCLISERFIS:nClrPane1, oDOCCLISERFIS:nClrPane2 ) } } 

  // Campo: DOC_SERFIS
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_SERFIS]
  oCol:cHeader      :='#'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: SFI_MODELO
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_SFI_MODELO]
  oCol:cHeader      :='Serie'+CRLF+'Fiscal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  // Campo: SFI_IMPFIS
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_SFI_IMPFIS]
  oCol:cHeader      :='Medio'+CRLF+'Fiscal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 96
oCol:bClrStd  := {|nClrText,uValue|uValue:=oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,7],;
                     nClrText:=COLOR_OPTIONS("DPSERIEFISCAL","SFI_IMPFIS",uValue),;
                     {nClrText,iif( oDOCCLISERFIS:oBrw:nArrayAt%2=0, oDOCCLISERFIS:nClrPane1, oDOCCLISERFIS:nClrPane2 ) } } 

  // Campo: DOC_DESDE
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_DESDE]
  oCol:cHeader      :='Número'+CRLF+'Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: DOC_HASTA
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_HASTA]
  oCol:cHeader      :='Número'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: DOC_FCHINI
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_FCHINI]
  oCol:cHeader      :='Fecha'+CRLF+'Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: DOC_FCHFIN
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_DOC_FCHFIN]
  oCol:cHeader      :='Fecha'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CUANTOS
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_CUANTOS]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,oDOCCLISERFIS:COL_CUANTOS],;
                              oCol  := oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_CUANTOS],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oDOCCLISERFIS:COL_CUANTOS],oCol:cEditPicture)


  // Campo: SFI_ACTIVO
  oCol:=oDOCCLISERFIS:oBrw:aCols[oDOCCLISERFIS:COL_SFI_ACTIVO]
  oCol:cHeader      :='Serie'+CRLF+'Activa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLISERFIS:oBrw:aArrayData ) } 
  oCol:nWidth       :=45
  // Campo: SFI_ACTIVO
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oDOCCLISERFIS:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oDOCCLISERFIS:COL_SFI_ACTIVO],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}
 oCol:bLDClickData:={||oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,oDOCCLISERFIS:COL_SFI_ACTIVO]:=!oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt,oDOCCLISERFIS:COL_SFI_ACTIVO],oDOCCLISERFIS:oBrw:DrawLine(.T.)} 
 oCol:bStrData    :={||""}
 oCol:bLClickHeader:={||oDp:lSel:=!oDOCCLISERFIS:oBrw:aArrayData[1,cIdCol],; 
 AEVAL(oDOCCLISERFIS:oBrw:aArrayData,{|a,n| oDOCCLISERFIS:oBrw:aArrayData[n,oDOCCLISERFIS:COL_SFI_ACTIVO]:=oDp:lSel}),oDOCCLISERFIS:oBrw:Refresh(.T.)} 

   oDOCCLISERFIS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDOCCLISERFIS:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oDOCCLISERFIS:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oDOCCLISERFIS:nClrText,;
                                                 nClrText:=IF(.F.,oDOCCLISERFIS:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oDOCCLISERFIS:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oDOCCLISERFIS:nClrPane1, oDOCCLISERFIS:nClrPane2 ) } }

//   oDOCCLISERFIS:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oDOCCLISERFIS:oBrw:bClrFooter            := {|| {0,14671839 }}

   oDOCCLISERFIS:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDOCCLISERFIS:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oDOCCLISERFIS:oBrw:bLDblClick:={|oBrw|oDOCCLISERFIS:RUNCLICK() }

   oDOCCLISERFIS:oBrw:bChange:={||oDOCCLISERFIS:BRWCHANGE()}
   oDOCCLISERFIS:oBrw:CreateFromCode()


   oDOCCLISERFIS:oWnd:oClient := oDOCCLISERFIS:oBrw



   oDOCCLISERFIS:Activate({||oDOCCLISERFIS:ViewDatBar()})

   oDOCCLISERFIS:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDOCCLISERFIS:lTmdi,oDOCCLISERFIS:oWnd,oDOCCLISERFIS:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oDOCCLISERFIS:oBrw:nWidth()

   oDOCCLISERFIS:oBrw:GoBottom(.T.)
   oDOCCLISERFIS:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDOCCLISERFIS.EDT")
     oDOCCLISERFIS:oBrw:Move(44,0,909+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oDOCCLISERFIS:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oDOCCLISERFIS:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oDOCCLISERFIS:oBrw:oLbx  :=oDOCCLISERFIS    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF oDOCCLISERFIS:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oDOCCLISERFIS:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oDOCCLISERFIS:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oDOCCLISERFIS:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DOCCLISERFIS")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCCLISERFIS"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDOCCLISERFIS:oBrw,"DOCCLISERFIS",oDOCCLISERFIS:cSql,oDOCCLISERFIS:nPeriodo,oDOCCLISERFIS:dDesde,oDOCCLISERFIS:dHasta,oDOCCLISERFIS)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDOCCLISERFIS:oBtnRun:=oBtn



       oDOCCLISERFIS:oBrw:bLDblClick:={||EVAL(oDOCCLISERFIS:oBtnRun:bAction) }


   ENDIF




IF oDOCCLISERFIS:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oDOCCLISERFIS");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oDOCCLISERFIS:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oDOCCLISERFIS:lBtnColor

     oDOCCLISERFIS:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oDOCCLISERFIS:oBrw,oDOCCLISERFIS,oDOCCLISERFIS:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oDOCCLISERFIS,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oDOCCLISERFIS,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oDOCCLISERFIS:oBtnColor:=oBtn

ENDIF

IF oDOCCLISERFIS:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oDOCCLISERFIS:oBrw,oDOCCLISERFIS:oFrm)
ENDIF

IF oDOCCLISERFIS:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oDOCCLISERFIS),;
                  EJECUTAR("DPBRWMENURUN",oDOCCLISERFIS,oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cBrwCod,oDOCCLISERFIS:cTitle,oDOCCLISERFIS:aHead));
          WHEN !Empty(oDOCCLISERFIS:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oDOCCLISERFIS:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oDOCCLISERFIS:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oDOCCLISERFIS:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oDOCCLISERFIS:oBrw,oDOCCLISERFIS);
          ACTION EJECUTAR("BRWSETFILTER",oDOCCLISERFIS:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oDOCCLISERFIS:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oDOCCLISERFIS:oBrw);
          WHEN LEN(oDOCCLISERFIS:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oDOCCLISERFIS:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oDOCCLISERFIS:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oDOCCLISERFIS:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oDOCCLISERFIS)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oDOCCLISERFIS:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cTitle,oDOCCLISERFIS:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDOCCLISERFIS:oBtnXls:=oBtn

ENDIF

IF oDOCCLISERFIS:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oDOCCLISERFIS:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDOCCLISERFIS:oBrw,NIL,oDOCCLISERFIS:cTitle,oDOCCLISERFIS:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDOCCLISERFIS:oBtnHtml:=oBtn

ENDIF


IF oDOCCLISERFIS:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oDOCCLISERFIS:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDOCCLISERFIS:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCCLISERFIS")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oDOCCLISERFIS:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDOCCLISERFIS:oBtnPrint:=oBtn

   ENDIF

IF oDOCCLISERFIS:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oDOCCLISERFIS:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oDOCCLISERFIS:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oDOCCLISERFIS:oWnd:IsZoomed(),oDOCCLISERFIS:oWnd:Restore(),oDOCCLISERFIS:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oDOCCLISERFIS:oBrw:GoTop(),oDOCCLISERFIS:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oDOCCLISERFIS:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oDOCCLISERFIS:oBrw:PageDown(),oDOCCLISERFIS:oBrw:Setfocus())

  ENDIF

  IF  oDOCCLISERFIS:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oDOCCLISERFIS:oBrw:PageUp(),oDOCCLISERFIS:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oDOCCLISERFIS:oBrw:GoBottom(),oDOCCLISERFIS:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oDOCCLISERFIS:Close()

  oDOCCLISERFIS:oBrw:SetColor(0,oDOCCLISERFIS:nClrPane1)

  IF oDp:lBtnText
     oDOCCLISERFIS:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oDOCCLISERFIS:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oDOCCLISERFIS:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDOCCLISERFIS:oBar:=oBar

    nCol:=549
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oDOCCLISERFIS:oPeriodo  VAR oDOCCLISERFIS:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDOCCLISERFIS:LEEFECHAS();
                WHEN oDOCCLISERFIS:lWhen


  ComboIni(oDOCCLISERFIS:oPeriodo )

  @ nLin, nCol+103 BUTTON oDOCCLISERFIS:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCCLISERFIS:oPeriodo:nAt,oDOCCLISERFIS:oDesde,oDOCCLISERFIS:oHasta,-1),;
                         EVAL(oDOCCLISERFIS:oBtn:bAction));
                WHEN oDOCCLISERFIS:lWhen


  @ nLin, nCol+130 BUTTON oDOCCLISERFIS:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCCLISERFIS:oPeriodo:nAt,oDOCCLISERFIS:oDesde,oDOCCLISERFIS:oHasta,+1),;
                         EVAL(oDOCCLISERFIS:oBtn:bAction));
                WHEN oDOCCLISERFIS:lWhen


  @ nLin, nCol+160 BMPGET oDOCCLISERFIS:oDesde  VAR oDOCCLISERFIS:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCCLISERFIS:oDesde ,oDOCCLISERFIS:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oDOCCLISERFIS:oPeriodo:nAt=LEN(oDOCCLISERFIS:oPeriodo:aItems) .AND. oDOCCLISERFIS:lWhen ;
                FONT oFont

   oDOCCLISERFIS:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oDOCCLISERFIS:oHasta  VAR oDOCCLISERFIS:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCCLISERFIS:oHasta,oDOCCLISERFIS:dHasta);
                SIZE 76-2,24;
                WHEN oDOCCLISERFIS:oPeriodo:nAt=LEN(oDOCCLISERFIS:oPeriodo:aItems) .AND. oDOCCLISERFIS:lWhen ;
                OF oBar;
                FONT oFont

   oDOCCLISERFIS:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oDOCCLISERFIS:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDOCCLISERFIS:oPeriodo:nAt=LEN(oDOCCLISERFIS:oPeriodo:aItems);
               ACTION oDOCCLISERFIS:HACERWHERE(oDOCCLISERFIS:dDesde,oDOCCLISERFIS:dHasta,oDOCCLISERFIS:cWhere,.T.);
               WHEN oDOCCLISERFIS:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})



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

  oRep:=REPORTE("BRDOCCLISERFIS",cWhere)
  oRep:cSql  :=oDOCCLISERFIS:cSql
  oRep:cTitle:=oDOCCLISERFIS:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDOCCLISERFIS:oPeriodo:nAt,cWhere

  oDOCCLISERFIS:nPeriodo:=nPeriodo


  IF oDOCCLISERFIS:oPeriodo:nAt=LEN(oDOCCLISERFIS:oPeriodo:aItems)

     oDOCCLISERFIS:oDesde:ForWhen(.T.)
     oDOCCLISERFIS:oHasta:ForWhen(.T.)
     oDOCCLISERFIS:oBtn  :ForWhen(.T.)

     DPFOCUS(oDOCCLISERFIS:oDesde)

  ELSE

     oDOCCLISERFIS:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDOCCLISERFIS:oDesde:VarPut(oDOCCLISERFIS:aFechas[1] , .T. )
     oDOCCLISERFIS:oHasta:VarPut(oDOCCLISERFIS:aFechas[2] , .T. )

     oDOCCLISERFIS:dDesde:=oDOCCLISERFIS:aFechas[1]
     oDOCCLISERFIS:dHasta:=oDOCCLISERFIS:aFechas[2]

     cWhere:=oDOCCLISERFIS:HACERWHERE(oDOCCLISERFIS:dDesde,oDOCCLISERFIS:dHasta,oDOCCLISERFIS:cWhere,.T.)

     oDOCCLISERFIS:LEERDATA(cWhere,oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cServer,oDOCCLISERFIS)

  ENDIF

  oDOCCLISERFIS:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDOCCLI.DOC_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDOCCLISERFIS:cWhereQry)
       cWhere:=cWhere + oDOCCLISERFIS:cWhereQry
     ENDIF

     oDOCCLISERFIS:LEERDATA(cWhere,oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cServer,oDOCCLISERFIS)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oDOCCLISERFIS)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb,oTable
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
          " DOC_CODSUC, "+;
          " SUC_DESCRI,"+;
          " DOC_TIPDOC, "+;
          " TDC_DESCRI, "+;
          " DOC_SERFIS, "+;
          " SFI_MODELO, "+;
          " SFI_IMPFIS, "+;
          " MIN(DOC_NUMERO) AS DOC_DESDE, "+;
          " MAX(DOC_NUMERO) AS DOC_HASTA, "+;
          " MIN(DOC_FECHA)  AS DOC_FCHINI, "+;
          " MAX(DOC_FECHA)  AS DOC_FCHFIN, "+;
          " COUNT(*) AS CUANTOS, "+;
          " SFI_ACTIVO "+;
          " FROM DPSERIEFISCAL "+;
          " INNER JOIN DPDOCCLI    ON DOC_SERFIS=SFI_LETRA "+;
          " INNER JOIN DPSUCURSAL  ON SFI_CODSUC=SUC_CODIGO "+;
          " INNER JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO "+;
          " WHERE DOC_TIPTRA='D' AND DOC_SERFIS<>'' AND (DOC_TIPDOC='FAV' OR DOC_TIPDOC='CRE' OR DOC_TIPDOC='DEB' OR DOC_TIPDOC='DEV' OR DOC_TIPDOC='TIK') "+;
          " GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_SERFIS "+;
          " ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_SERFIS"+;
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

   DPWRITE("TEMP\BRDOCCLISERFIS.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','','','','','',CTOD(""),CTOD(""),0,0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,3]:=SAYOPTIONS("DPDOCCLI","DOC_TIPDOC",a[3]),;
          aData[n,4]:=SAYOPTIONS("DPTIPDOCPRO","TDC_DESCRI",a[4]),;
          aData[n,7]:=SAYOPTIONS("DPSERIEFISCAL","SFI_IMPFIS",a[7])})

   IF ValType(oBrw)="O"

      oDOCCLISERFIS:cSql   :=cSql
      oDOCCLISERFIS:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:aData     :=NIL
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oDOCCLISERFIS:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDOCCLISERFIS:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCCLISERFIS.MEM",V_nPeriodo:=oDOCCLISERFIS:nPeriodo
  LOCAL V_dDesde:=oDOCCLISERFIS:dDesde
  LOCAL V_dHasta:=oDOCCLISERFIS:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDOCCLISERFIS)
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


    IF Type("oDOCCLISERFIS")="O" .AND. oDOCCLISERFIS:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDOCCLISERFIS:cWhere_),oDOCCLISERFIS:cWhere_,oDOCCLISERFIS:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oDOCCLISERFIS:LEERDATA(oDOCCLISERFIS:cWhere_,oDOCCLISERFIS:oBrw,oDOCCLISERFIS:cServer,oDOCCLISERFIS)
      oDOCCLISERFIS:oWnd:Show()
      oDOCCLISERFIS:oWnd:Restore()

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

   oDOCCLISERFIS:aHead:=EJECUTAR("HTMLHEAD",oDOCCLISERFIS)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oDOCCLISERFIS)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oDOCCLISERFIS:oBrw:aArrayData[oDOCCLISERFIS:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oDOCCLISERFIS:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oDOCCLISERFIS:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oDOCCLISERFIS:oBrw,.F.)

  oDOCCLISERFIS:oBrw:nColSel:=1
  oDOCCLISERFIS:oBrw:GoBottom()
  oDOCCLISERFIS:oBrw:Refresh(.F.)
  oDOCCLISERFIS:oBrw:nArrayAt:=LEN(oDOCCLISERFIS:oBrw:aArrayData)
  oDOCCLISERFIS:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oDOCCLISERFIS:oBrw)

RETURN .T.


/*
// Genera Correspondencia Masiva
*/


// EOF

