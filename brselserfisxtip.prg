// Programa   : BRSELSERFISXTIP
// Fecha/Hora : 20/02/2025 17:30:22
// Propósito  : "Asignar Serie Fiscal en Tipo de Documento"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cLetra,lDelete,lTodos)
   LOCAL aData,aFechas,cFileMem:="USER\BRSELSERFISXTIP.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde :=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer  :=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={},cImpFis:="",cWhereI:="",cCodSucF:="",lCodSuc:=.F.

   oDp:cRunServer:=NIL

   IF Type("oSELSERFISXTIP")="O" .AND. oSELSERFISXTIP:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oSELSERFISXTIP,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF

   DEFAULT lDelete:=.F.,;
           lTodos :=.T.

   IF !lDelete 
     cTitle:="Asignar Serie Fiscal con Tipo de Documento" +IF(Empty(cTitle),"",cTitle)
   ELSE
     cTitle:="Remover vinculo de Serie Fiscal con Tipos de Documentos" +IF(Empty(cTitle),"",cTitle)
   ENDIF

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD(""),;
           lDelete :=.F.

   DEFAULT cLetra:=SQLGET("DPSERIEFISCAL","SFI_LETRA","SFI_ACTIVO=1")

   cImpFis :=SQLGET("DPSERIEFISCAL","SFI_IMPFIS,SFI_CODSUC","SFI_LETRA"+GetWhere("=",cLetra))
   cCodSucF:=DPSQLROW(2)

   // Solo FAV,DEB,CRE
   DEFAULT cWhere:=""

//   ? cImpFis,cCodSucF
/*
   IF "CONTIN"$cImpFis .OR."FORMATO"$cImpFis .OR. "LIBRE"$cImpFis

      lCodSuc:=.T.
      cWhere :=cWhere+IF(Empty(cWhere),""," AND ")+;
              [ NOT (]+;
              GetWhereOr("TDN_TIPDOC",{"TIK","DEV","FAM","DBM","CRM"})+;
              [)]

   ENDIF
*/


/*
   // FORMATO y CONTIGENCIA la MISMA SUCURSAL
   IF "CONTIN"$cImpFis .OR."FORMATO"$cImpFis .OR. "LIBRE"$cImpFis

      lCodSuc:=.T.

      cWhere :=cWhere+IF(Empty(cWhere),""," AND ")+[ SFI_CODSUC]+GetWhere("=",cCodSuc)

      cWhereI:=[  (NOT (]+GetWhereOr("TDN_TIPDOC",{"TIK","DEV","FAM","DBM","CRM"}) +;
               [   AND SFI_IMPFIS LIKE "%_IMPFIS%")) ]

   ENDIF

   // DIGITAL
   IF "DIGI"$cImpFis 

      lCodSuc:=.F.
      cWhereI:=[ NOT (]+GetWhereOr("TDN_TIPDOC",{"TIK","DEV","FAM","DBM","CRM"}) + [ AND SFI_IMPFIS LIKE "%_IMPFIS%") ]

? cWhereI

   ENDIF
*/

   IF !Emtpy(cWhereI)
     lTodos:=.F.
     // cWhere:=IF(Empty(cWhere),""," AND ")+cWhereI
   ENDIF

   // ? cWhereI,cWhere

   // Obtiene el Código del Parámetro


   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   // Solo FAV,DEB,CRE
   DEFAULT cWhere:=""

/*
   IF "DIGI"$cImpFis
      cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+GetWhereOr("TDC_TIPO",{"FAV","DEB","CRE","NEN","GDD"})
   ENDIF
*/

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL,cImpFis,lDelete,lTodos)

/*
ViewArray(aData)


RETURN .T.

   IF lCodSuc
      ADEPURA(aData,{|a,n| !a[1]=cCodSuc})
      ADDTIPDOC("DEB",.T.)
      ADDTIPDOC("CRE",.T.)
      ADDTIPDOC("FAV",.T.)
      ADDTIPDOC("NEN",.T.)
   ENDIF
*/

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oSELSERFISXTIP

RETURN .T.

/*
FUNCTION ADDTIPDOC(cTipDoc,lActivo)
  LOCAL nAt  :=ASCAN(aData,{|a,n| a[3]==cTipDoc})
  LOCAL aLine:=ACLONE(aData[1])

  IF nAt=0
     aLine[3]:=cTipDoc
     aLine[4]:=SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc))
     aLine[5]:=CTOEMPTY(aLine[5])
     aLine[6]:=IF(lActivo,aLine[6],CTOEMPTY(aLine[6]))
     aLine[7]:=IF(lActivo,aLine[7],CTOEMPTY(aLine[7]))
     aLine[8]:=IF(lActivo,aLine[8],CTOEMPTY(aLine[8]))
     aLine[9]:=lActivo //  CTOEMPTY(aLine[9])
     AADD(aData,aLine)
  ENDIF

RETURN .T.
*/

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB 
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oSELSERFISXTIP","BRSELSERFISXTIP.EDT")
// oSELSERFISXTIP:CreateWindow(0,0,100,550)
   oSELSERFISXTIP:Windows(0,0,aCoors[3]-160,MIN(3613,aCoors[4]-10),.T.) // Maximizado

   oSELSERFISXTIP:cLetra   :=cLetra
   oSELSERFISXTIP:lDelete  :=lDelete
   oSELSERFISXTIP:cSerieF  :=SQLGET("DPSERIEFISCAL","SFI_MODELO,SFI_IMPFIS","SFI_LETRA"+GetWhere("=",cLetra))
   oSELSERFISXTIP:cImpFis  :=cImpFis // DPSQLROW(2)
   oSELSERFISXTIP:cCodSuc  :=cCodSuc
   oSELSERFISXTIP:lMsgBar  :=.F.
   oSELSERFISXTIP:cPeriodo :=aPeriodos[nPeriodo]
   oSELSERFISXTIP:cCodSuc  :=cCodSuc
   oSELSERFISXTIP:nPeriodo :=nPeriodo
   oSELSERFISXTIP:cNombre  :=""
   oSELSERFISXTIP:dDesde   :=dDesde
   oSELSERFISXTIP:cServer  :=cServer
   oSELSERFISXTIP:dHasta   :=dHasta
   oSELSERFISXTIP:cWhere   :=cWhere
   oSELSERFISXTIP:cWhere_  :=cWhere_
   oSELSERFISXTIP:cWhereQry:=""
   oSELSERFISXTIP:cSql     :=oDp:cSql
   oSELSERFISXTIP:oWhere   :=TWHERE():New(oSELSERFISXTIP)
   oSELSERFISXTIP:cCodPar  :=cCodPar // Código del Parámetro
   oSELSERFISXTIP:lWhen    :=.T.
   oSELSERFISXTIP:cTextTit :="" // Texto del Titulo Heredado
   oSELSERFISXTIP:oDb      :=oDp:oDb
   oSELSERFISXTIP:cBrwCod  :="SELSERFISXTIP"
   oSELSERFISXTIP:lTmdi    :=.T.
   oSELSERFISXTIP:aHead    :={}
   oSELSERFISXTIP:lBarDef  :=.T. // Activar Modo Diseño.
   oSELSERFISXTIP:aFields  :=ACLONE(aFields)

   oSELSERFISXTIP:nClrPane1:=oDp:nClrPane1
   oSELSERFISXTIP:nClrPane2:=oDp:nClrPane2

   oSELSERFISXTIP:nClrText1:=0
   oSELSERFISXTIP:nClrText2:=0
   oSELSERFISXTIP:nClrText3:=0
   oSELSERFISXTIP:nClrText4:=0
   oSELSERFISXTIP:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oSELSERFISXTIP:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oSELSERFISXTIP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oSELSERFISXTIP)}

   oSELSERFISXTIP:lBtnRun     :=.F.
   oSELSERFISXTIP:lBtnMenuBrw :=.F.
   oSELSERFISXTIP:lBtnSave    :=.F.
   oSELSERFISXTIP:lBtnCrystal :=.F.
   oSELSERFISXTIP:lBtnRefresh :=.F.
   oSELSERFISXTIP:lBtnHtml    :=.T.
   oSELSERFISXTIP:lBtnExcel   :=.T.
   oSELSERFISXTIP:lBtnPreview :=.T.
   oSELSERFISXTIP:lBtnQuery   :=.F.
   oSELSERFISXTIP:lBtnOptions :=.T.
   oSELSERFISXTIP:lBtnPageDown:=.T.
   oSELSERFISXTIP:lBtnPageUp  :=.T.
   oSELSERFISXTIP:lBtnFilters :=.T.
   oSELSERFISXTIP:lBtnFind    :=.T.
   oSELSERFISXTIP:lBtnColor   :=.T.
   oSELSERFISXTIP:lBtnZoom    :=.F.
   oSELSERFISXTIP:lBtnNew     :=.F.


   oSELSERFISXTIP:nClrPane1:=16775408
   oSELSERFISXTIP:nClrPane2:=16771797

   oSELSERFISXTIP:nClrText :=0
   oSELSERFISXTIP:nClrText1:=0
   oSELSERFISXTIP:nClrText2:=0
   oSELSERFISXTIP:nClrText3:=0

   oSELSERFISXTIP:oBrw:=TXBrowse():New( IF(oSELSERFISXTIP:lTmdi,oSELSERFISXTIP:oWnd,oSELSERFISXTIP:oDlg ))
   oSELSERFISXTIP:oBrw:SetArray( aData, .F. )
   oSELSERFISXTIP:oBrw:SetFont(oFont)

   oSELSERFISXTIP:oBrw:lFooter     := .T.
   oSELSERFISXTIP:oBrw:lHScroll    := .T.
   oSELSERFISXTIP:oBrw:nHeaderLines:= 2
   oSELSERFISXTIP:oBrw:nDataLines  := 1
   oSELSERFISXTIP:oBrw:nFooterLines:= 1

   oSELSERFISXTIP:aData            :=ACLONE(aData)

   AEVAL(oSELSERFISXTIP:oBrw:aCols,{|oCol,n|oCol:oHeaderFont:=oFontB, oCol:nPos:=n})
   

  // Campo: TSF_CODSUC
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDN_CODSUC]
  oCol:cHeader      :='Cód.'+CRLF+'Suc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  // Campo: SUC_DESCRI
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_SUC_DESCRI]
  oCol:cHeader      :='Sucursal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: TDC_TIPO
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDN_TIPDOC]
  oCol:cHeader      :='Tipo'+CRLF+'Doc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: TDC_DESCRI
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDC_DESCRI]
  oCol:cHeader      :='Descripción del Documento.'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 180
  oCol:bClrStd      := {|nClrText,uValue|uValue:=oSELSERFISXTIP:oBrw:aArrayData[oSELSERFISXTIP:oBrw:nArrayAt,oSELSERFISXTIP:COL_TDC_DESCRI],;
                       nClrText:=COLOR_OPTIONS("DPTIPDOCCLI","TDC_DESCRI",uValue),;
                       {nClrText,iif( oSELSERFISXTIP:oBrw:nArrayAt%2=0, oSELSERFISXTIP:nClrPane1, oSELSERFISXTIP:nClrPane2 ) } } 

  // Campo: TDC_NUMERO
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDN_NUMERO]
  oCol:cHeader      :='Ultimo'+CRLF+"Número"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

// Campo: TDC_PICTUR
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDN_PICTUR]
  oCol:cHeader      :='Formato'+CRLF+""
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: TXU_ACTIVO
  oCol:=oSELSERFISXTIP:oBrw:aCols[oSELSERFISXTIP:COL_TDN_ACTIVO]

  IF lDelete
//    oCol:cHeader      :='Eliminar'
  ELSE
    oCol:cHeader      :='Asignar'
  ENDIF

  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSELSERFISXTIP:oBrw:aArrayData ) } 
  oCol:nWidth       := 45
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oSELSERFISXTIP:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oSELSERFISXTIP:COL_TDN_ACTIVO],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}
  oCol:bLDClickData:={||oSELSERFISXTIP:oBrw:aArrayData[oSELSERFISXTIP:oBrw:nArrayAt,oSELSERFISXTIP:COL_TDN_ACTIVO]:=!oSELSERFISXTIP:oBrw:aArrayData[oSELSERFISXTIP:oBrw:nArrayAt,oSELSERFISXTIP:COL_TDN_ACTIVO],oSELSERFISXTIP:oBrw:DrawLine(.T.)} 
  oCol:bStrData    :={||""}
  oCol:bLClickHeader:={||oDp:lSel:=!oSELSERFISXTIP:oBrw:aArrayData[1,oSELSERFISXTIP:COL_TDN_ACTIVO],; 
  AEVAL(oSELSERFISXTIP:oBrw:aArrayData,{|a,n| oSELSERFISXTIP:oBrw:aArrayData[n,oSELSERFISXTIP:COL_TDN_ACTIVO]:=oDp:lSel}),oSELSERFISXTIP:oBrw:Refresh(.T.)} 





   oSELSERFISXTIP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oSELSERFISXTIP:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oSELSERFISXTIP:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oSELSERFISXTIP:nClrText,;
                                                 nClrText:=IF(.F.,oSELSERFISXTIP:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oSELSERFISXTIP:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oSELSERFISXTIP:nClrPane1, oSELSERFISXTIP:nClrPane2 ) } }

//   oSELSERFISXTIP:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oSELSERFISXTIP:oBrw:bClrFooter            := {|| {0,14671839 }}

   oSELSERFISXTIP:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSELSERFISXTIP:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oSELSERFISXTIP:oBrw:bLDblClick:={|oBrw|oSELSERFISXTIP:RUNCLICK() }

   oSELSERFISXTIP:oBrw:bChange:={||oSELSERFISXTIP:BRWCHANGE()}
   oSELSERFISXTIP:oBrw:CreateFromCode()

   oSELSERFISXTIP:oWnd:oClient := oSELSERFISXTIP:oBrw


   oSELSERFISXTIP:Activate({||oSELSERFISXTIP:ViewDatBar()})

   oSELSERFISXTIP:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oSELSERFISXTIP:lTmdi,oSELSERFISXTIP:oWnd,oSELSERFISXTIP:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oSELSERFISXTIP:oBrw:nWidth()

   oSELSERFISXTIP:oBrw:GoBottom(.T.)
   oSELSERFISXTIP:oBrw:Refresh(.T.)

   IF !File("FORMS\BRSELSERFISXTIP.EDT")
     oSELSERFISXTIP:oBrw:Move(44,0,3613+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oSELSERFISXTIP:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oSELSERFISXTIP:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oSELSERFISXTIP:oBrw:oLbx  :=oSELSERFISXTIP    // MDI:GOTFOCUS()


 // Emanager no Incluye consulta de Vinculos

   IF  oSELSERFISXTIP:lDelete 

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XDELETE.BMP";
            TOP PROMPT "Remover";
            ACTION oSELSERFISXTIP:BRWGRABAR()

     oBtn:cToolTip:="Grabar"



   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            TOP PROMPT "Grabar";
            ACTION oSELSERFISXTIP:BRWGRABAR()

     oBtn:cToolTip:="Grabar"

   ENDIF

   oSELSERFISXTIP:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\SERIALES.bmp";
           TOP PROMPT "Talonarios";
           ACTION oSELSERFISXTIP:TALONARIOS()

   oBtn:cToolTip:="Ingresar Talonarios"

   DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\XEDIT.BMP",NIL,"BITMAPS\XEDITG.BMP";
           TOP PROMPT "Modificar";
           ACTION oSELSERFISXTIP:DPTIPDOCCLI()

   oBtn:cToolTip:="Modificar"

//   oSELSERFISXTIP:oBtnEdit:=oBtn


   IF oSELSERFISXTIP:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oSELSERFISXTIP:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oSELSERFISXTIP:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oSELSERFISXTIP:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","SELSERFISXTIP")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","SELSERFISXTIP"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oSELSERFISXTIP:oBrw,"SELSERFISXTIP",oSELSERFISXTIP:cSql,oSELSERFISXTIP:nPeriodo,oSELSERFISXTIP:dDesde,oSELSERFISXTIP:dHasta,oSELSERFISXTIP)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oSELSERFISXTIP:oBtnRun:=oBtn



       oSELSERFISXTIP:oBrw:bLDblClick:={||EVAL(oSELSERFISXTIP:oBtnRun:bAction) }


   ENDIF




IF oSELSERFISXTIP:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oSELSERFISXTIP");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oSELSERFISXTIP:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oSELSERFISXTIP:lBtnColor

     oSELSERFISXTIP:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oSELSERFISXTIP:oBrw,oSELSERFISXTIP,oSELSERFISXTIP:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oSELSERFISXTIP,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oSELSERFISXTIP,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oSELSERFISXTIP:oBtnColor:=oBtn

ENDIF
/*
IF oSELSERFISXTIP:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oSELSERFISXTIP:oBrw,oSELSERFISXTIP:oFrm)
ENDIF
*/

IF oSELSERFISXTIP:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oSELSERFISXTIP),;
                  EJECUTAR("DPBRWMENURUN",oSELSERFISXTIP,oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cBrwCod,oSELSERFISXTIP:cTitle,oSELSERFISXTIP:aHead));
          WHEN !Empty(oSELSERFISXTIP:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oSELSERFISXTIP:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oSELSERFISXTIP:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oSELSERFISXTIP:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oSELSERFISXTIP:oBrw,oSELSERFISXTIP);
          ACTION EJECUTAR("BRWSETFILTER",oSELSERFISXTIP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oSELSERFISXTIP:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oSELSERFISXTIP:oBrw);
          WHEN LEN(oSELSERFISXTIP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oSELSERFISXTIP:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oSELSERFISXTIP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oSELSERFISXTIP:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oSELSERFISXTIP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oSELSERFISXTIP:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cTitle,oSELSERFISXTIP:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oSELSERFISXTIP:oBtnXls:=oBtn

ENDIF

IF oSELSERFISXTIP:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oSELSERFISXTIP:HTMLHEAD(),EJECUTAR("BRWTOHTML",oSELSERFISXTIP:oBrw,NIL,oSELSERFISXTIP:cTitle,oSELSERFISXTIP:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oSELSERFISXTIP:oBtnHtml:=oBtn

ENDIF


IF oSELSERFISXTIP:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oSELSERFISXTIP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oSELSERFISXTIP:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRSELSERFISXTIP")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oSELSERFISXTIP:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oSELSERFISXTIP:oBtnPrint:=oBtn

   ENDIF

IF oSELSERFISXTIP:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oSELSERFISXTIP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oSELSERFISXTIP:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oSELSERFISXTIP:oWnd:IsZoomed(),oSELSERFISXTIP:oWnd:Restore(),oSELSERFISXTIP:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oSELSERFISXTIP:oBrw:GoTop(),oSELSERFISXTIP:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oSELSERFISXTIP:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oSELSERFISXTIP:oBrw:PageDown(),oSELSERFISXTIP:oBrw:Setfocus())

  ENDIF

  IF  oSELSERFISXTIP:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oSELSERFISXTIP:oBrw:PageUp(),oSELSERFISXTIP:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oSELSERFISXTIP:oBrw:GoBottom(),oSELSERFISXTIP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oSELSERFISXTIP:Close()

  oSELSERFISXTIP:oBrw:SetColor(0,oSELSERFISXTIP:nClrPane1)



  IF oDp:lBtnText
     oSELSERFISXTIP:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oSELSERFISXTIP:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oSELSERFISXTIP:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBar:SetSize(NIL,95,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 68,015 SAY " Serie " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59,20

  @ 68,310 SAY " Medio " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59,20

  @ 68,015+60 SAY " "+oSELSERFISXTIP:cLetra+"-"+ALLTRIM(oSELSERFISXTIP:cSerieF)+" " OF oBar ;
           BORDER  PIXEL;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20

  @ 68,310+60 SAY " "+ALLTRIM(oSELSERFISXTIP:cImpFis)+" " OF oBar ;
           BORDER  PIXEL;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20



  oSELSERFISXTIP:oBar:=oBar

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

  oRep:=REPORTE("BRSELSERFISXTIP",cWhere)
  oRep:cSql  :=oSELSERFISXTIP:cSql
  oRep:cTitle:=oSELSERFISXTIP:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oSELSERFISXTIP:oPeriodo:nAt,cWhere

  oSELSERFISXTIP:nPeriodo:=nPeriodo


  IF oSELSERFISXTIP:oPeriodo:nAt=LEN(oSELSERFISXTIP:oPeriodo:aItems)

     oSELSERFISXTIP:oDesde:ForWhen(.T.)
     oSELSERFISXTIP:oHasta:ForWhen(.T.)
     oSELSERFISXTIP:oBtn  :ForWhen(.T.)

     DPFOCUS(oSELSERFISXTIP:oDesde)

  ELSE

     oSELSERFISXTIP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oSELSERFISXTIP:oDesde:VarPut(oSELSERFISXTIP:aFechas[1] , .T. )
     oSELSERFISXTIP:oHasta:VarPut(oSELSERFISXTIP:aFechas[2] , .T. )

     oSELSERFISXTIP:dDesde:=oSELSERFISXTIP:aFechas[1]
     oSELSERFISXTIP:dHasta:=oSELSERFISXTIP:aFechas[2]

     cWhere:=oSELSERFISXTIP:HACERWHERE(oSELSERFISXTIP:dDesde,oSELSERFISXTIP:dHasta,oSELSERFISXTIP:cWhere,.T.)

     oSELSERFISXTIP:LEERDATA(cWhere,oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cServer,oSELSERFISXTIP)

  ENDIF

  oSELSERFISXTIP:SAVEPERIODO()

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

     IF !Empty(oSELSERFISXTIP:cWhereQry)
       cWhere:=cWhere + oSELSERFISXTIP:cWhereQry
     ENDIF

     oSELSERFISXTIP:LEERDATA(cWhere,oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cServer,oSELSERFISXTIP)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oSELSERFISXTIP,cImpFis,lDelete,lTodos)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb,oTable
   LOCAL nAt,nRowSel
   LOCAL U,I,nAt
   LOCAL aSucursal:={}
   LOCAL aTipDoc  :={}

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

/*
   IF !lDelete

     aSucursal:=ASQL("SELECT SUC_CODIGO,SUC_DESCRI FROM DPSUCURSAL  WHERE SUC_ACTIVO=1 AND SUC_EMPRES=0")

     IF "DIG"$cImpFis .OR. "LIB"$cImpFis

       aTipDoc  :=ASQL("SELECT TDC_TIPO  ,TDC_DESCRI FROM DPTIPDOCCLI WHERE TDC_ACTIVO=1 AND "+;
                       GetWhereOr("TDC_TIPO",{"FAV","DEB","CRE","NEN","GDD"}))

     ENDIF

   ENDIF

*/
   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   EJECUTAR("UNIQUETABLAS","dptipdocclinum","TDN_CODSUC,TDN_TIPDOC,TDN_SERFIS")

   SETDOCFISCAL(NIL,.T.)

   cSql:=[ SELECT  TDN_CODSUC,SUC_DESCRI,TDN_TIPDOC,TDC_DESCRI,TDN_NUMERO,TDN_PICTUR,TDN_ACTIVO ]+;
         [ FROM dptipdocclinum ]+CRLF+;
         [ INNER JOIN dpseriefiscaL ON TDN_SERFIS=SFI_LETRA  ]+CRLF+;
         [ INNER JOIN dpsucursal    ON TDN_CODSUC=SUC_CODIGO ]+CRLF+;
         [ INNER JOIN dptipdoccli   ON TDN_TIPDOC=TDC_TIPO   ]+CRLF+;
         [ WHERE TDC_LIBVTA=1 OR 1=1 ]+CRLF+;
         [ ORDER BY TDN_CODSUC,TDN_TIPDOC ]

//      [ WHERE (TDC_LIBVTA=1 OR TDN_TIPDOC="NEN" OR TDN_TIPDOC="GDD") AND TDC_ACTIVO=1  ]+CRLF+;

   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

// ? CLPCOPY(cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRSELSERFISXTIP.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF

/*
   AEVAL(aData,{|a,n| aData[n,9]:=(a[9]=1)})
   aLines:=ACLONE(aData[1])

   AEVAL(aLines,{|a,n| aLines[n]:=CTOEMPTY(a)})

   AADD(aSucursal,{oDp:cSucursal,SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",oDp:cSucursal))})

   IF !lTodos
      aSucursal:={}
   ENDIF

   FOR I=1 TO LEN(aSucursal)

     FOR U=1 TO LEN(aTipDoc)

         nAt:=ASCAN(aData,{|a,n| a[1]==aSucursal[I,1] .AND. a[3]=aTipDoc[U,1]})

         IF nAt=0

           aLines[1]:=aSucursal[I,1]
           aLines[2]:=aSucursal[I,2]
           aLines[3]:=aTipDoc[U,1]
           aLines[4]:=aTipDoc[U,2]
           aLines[9]:=.F.


           AADD(aData,ACLONE(aLines))

         ENDIF

     NEXT U

   NEXT I
*/

   aData:=ASORT(aData,,, { |x, y| x[1]+x[3] < y[1]+y[3] })

   aData:=ADEPURA(aData,{|a,n| Empty(a[4])}) 

   IF ValType(oBrw)="O"

      oSELSERFISXTIP:cSql   :=cSql
      oSELSERFISXTIP:cWhere_:=cWhere

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
      AEVAL(oSELSERFISXTIP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oSELSERFISXTIP:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRSELSERFISXTIP.MEM",V_nPeriodo:=oSELSERFISXTIP:nPeriodo
  LOCAL V_dDesde:=oSELSERFISXTIP:dDesde
  LOCAL V_dHasta:=oSELSERFISXTIP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oSELSERFISXTIP)
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


    IF Type("oSELSERFISXTIP")="O" .AND. oSELSERFISXTIP:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oSELSERFISXTIP:cWhere_),oSELSERFISXTIP:cWhere_,oSELSERFISXTIP:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oSELSERFISXTIP:LEERDATA(oSELSERFISXTIP:cWhere_,oSELSERFISXTIP:oBrw,oSELSERFISXTIP:cServer,oSELSERFISXTIP)
      oSELSERFISXTIP:oWnd:Show()
      oSELSERFISXTIP:oWnd:Restore()

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

   oSELSERFISXTIP:aHead:=EJECUTAR("HTMLHEAD",oSELSERFISXTIP)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oSELSERFISXTIP)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oSELSERFISXTIP:oBrw:aArrayData[oSELSERFISXTIP:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oSELSERFISXTIP:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oSELSERFISXTIP:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oSELSERFISXTIP:oBrw,.F.)

  oSELSERFISXTIP:oBrw:nColSel:=1
  oSELSERFISXTIP:oBrw:GoBottom()
  oSELSERFISXTIP:oBrw:Refresh(.F.)
  oSELSERFISXTIP:oBrw:nArrayAt:=LEN(oSELSERFISXTIP:oBrw:aArrayData)
  oSELSERFISXTIP:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oSELSERFISXTIP:oBrw)

RETURN .T.

FUNCTION BRWGRABAR()
  LOCAL I,cCodSuc,cTipDoc,cWhere:="",cName,cGroup,nLen:=LEN(oSELSERFISXTIP:cSerieF)
  LOCAL aTodos :=ACLONE(oSELSERFISXTIP:oBrw:aArrayData)
  LOCAL aData  :=ACLONE(oSELSERFISXTIP:oBrw:aArrayData)
  LOCAL nCol   :=oSELSERFISXTIP:COL_TDN_ACTIVO
  LOCAL nCantid:=0

/*
  ADEPURA(aData,{|a,n|!a[nCol]})

  IF Empty(aData)
    oSELSERFISXTIP:oBtnSave:MsgErr("Debe seleccionar el Tipo de Documento",IIF(oSELSERFISXTIP:lDelete,"Desvincular","Grabar"),300,120)
    oSELSERFISXTIP:oBrw:aArrayData:=ACLONE(aTodos)
    oSELSERFISXTIP:oBrw:Refresh(.T.)
    RETURN .T.
  ENDIF

  oSELSERFISXTIP:oBrw:aArrayData:=ACLONE(aData)

  FOR I=1 TO LEN(oSELSERFISXTIP:oBrw:aArrayData)

     IF oSELSERFISXTIP:oBrw:aArrayData[I,nCol]
       oSELSERFISXTIP:oBrw:aArrayData[I,oSELSERFISXTIP:COL_TDN_SERFIS]:=oSELSERFISXTIP:cLetra
       oSELSERFISXTIP:oBrw:aArrayData[I,oSELSERFISXTIP:COL_SFI_MODELO]:=oSELSERFISXTIP:cSerieF
       nCantid++
     ENDIF

  NEXT I

  oSELSERFISXTIP:oBrw:Refresh(.T.)

  IF nCantid>1 .AND. ("FORMATO"$oSELSERFISXTIP:cImpFis .OR. "CONTIN"$oSELSERFISXTIP:cImpFis) .AND. !oSELSERFISXTIP:lDelete
    oSELSERFISXTIP:oBtnSave:MsgErr("Medio Fiscal: "+oSELSERFISXTIP:cImpFis+CRLF+"Sólo puede ser Asignado a un solo tipo de documento","Grabar",300+100,120+50)
    oSELSERFISXTIP:oBrw:aArrayData:=ACLONE(aTodos)
    oSELSERFISXTIP:oBrw:Refresh(.T.)
    RETURN .F.
  ENDIF

  IF !MsgNoYes("Desea Grabar "+LSTR(LEN(aData))+" Serie Fiscales")
     oSELSERFISXTIP:oBrw:aArrayData:=ACLONE(aTodos)
     oSELSERFISXTIP:oBrw:Refresh(.T.)
     RETURN .T.
  ENDIF
  
  CursorWait()

  SQLUPDATE("DPSERIEFISCAL","SFI_ACTIVO",.T.,"SFI_LETRA"+GetWhere("=",oSELSERFISXTIP:cLetra))

  FOR I=1 TO LEN(aData)

     cCodSuc:=aData[I,1]
     cTipDoc:=aData[I,3]
     cWhere :="TDN_TIPDOC"+GetWhere("=",cCodSuc)+" AND "+;
              "TDN_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
              "TDN_SERFIS"+GetWhere("=", oSELSERFISXTIP:cLetra)

     IF oSELSERFISXTIP:lDelete

       SQLDELETE("dptipdocclinum",cWhere)

     ELSE

       EJECUTAR("CREATERECORD","dptipdocclinum",{"TDN_CODSUC","TDN_TIPDOC","TDN_SERFIS"          ,"TDN_LEN","TDN_ACTIVO"},;
                                                {cCodSuc     ,cTipDoc     , oSELSERFISXTIP:cLetra,nLen     ,.T.         },;
                                                NIL,.T.,cWhere)
     ENDIF

  NEXT I

 //  RELEASEDATASET() // Resetea DATASET

  oSELSERFISXTIP:Close()

  EJECUTAR("DPSERIEFISCALDEPURA") // Depura lo que no se necesita
*/

  // EJECUTA FORMULARIO FACTURA

  EJECUTAR("DPSERIEFISCAL_NUMREG",oSELSERFISXTIP:cCodSuc,oSELSERFISXTIP:cLetra)

//  EJECUTAR("dpseriefiscal_numlbx",oSELSERFISXTIP:cCodSuc,oSELSERFISXTIP:cLetra)

  oSELSERFISXTIP:Close()

  EJECUTAR("DPFACTURAV","FAV")

RETURN .T.

FUNCTION DPTIPDOCCLI()
    LOCAL aLine  :=oSELSERFISXTIP:oBrw:aArrayData[oSELSERFISXTIP:oBrw:nArrayAt]
    LOCAL cTipDoc:=aLine[3],lRunDoc:=NIL,cCodSuc:=aLine[1]

    EJECUTAR("DPTIPDOCCLI",3,cTipDoc,lRunDoc,cCodSuc,oSELSERFISXTIP:cLetra)

    oSELSERFISXTIP:Close()

RETURN NIL

FUNCTION TALONARIOS()

   EJECUTAR("dpseriefiscal_numlbx",oSELSERFISXTIP:cCodSuc,oSELSERFISXTIP:cLetra)

RETURN .T.
// EOF

