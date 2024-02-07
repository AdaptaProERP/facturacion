// Programa   : BRCONTOFAV
// Fecha/Hora : 07/02/2024 15:17:00
// Propósito  : "Facturación de Productos a Consignación"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDes,cCodCli,cSucCli)
   LOCAL aData,aFechas,cFileMem:="USER\BRCONTOFAV.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={},cSqlOrg

   oDp:cRunServer:=NIL

   IF Type("oCONTOFAV")="O" .AND. oCONTOFAV:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCONTOFAV,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Facturación de Productos a Consignación" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   DEFAULT cTipDes:="FAV",;
           cCodCli:=SQLGET("DPDOCCLI","DOC_CODIGO","DOC_TIPDOC"+GetWhere("=","CON"))


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

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales
   cSqlOrg:=oDp:cSql

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCONTOFAV

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCONTOFAV","BRCONTOFAV.EDT")
// oCONTOFAV:CreateWindow(0,0,100,550)
   oCONTOFAV:Windows(0,0,aCoors[3]-160,MIN(1504,aCoors[4]-10),.T.) // Maximizado

   oCONTOFAV:cCodSuc    :=cCodSuc
   oCONTOFAV:lMsgBar    :=.F.
   oCONTOFAV:cPeriodo   :=aPeriodos[nPeriodo]
   oCONTOFAV:cCodSuc    :=cCodSuc
   oCONTOFAV:nPeriodo   :=nPeriodo
   oCONTOFAV:cNombre    :=""
   oCONTOFAV:dDesde     :=dDesde
   oCONTOFAV:cServer    :=cServer
   oCONTOFAV:dHasta     :=dHasta
   oCONTOFAV:cWhere     :=cWhere
   oCONTOFAV:cWhere_    :=cWhere_
   oCONTOFAV:cWhereQry  :=""
   oCONTOFAV:cSql       :=oDp:cSql
   oCONTOFAV:oWhere     :=TWHERE():New(oCONTOFAV)
   oCONTOFAV:cCodPar    :=cCodPar // Código del Parámetro
   oCONTOFAV:lWhen      :=.T.
   oCONTOFAV:cTextTit   :="" // Texto del Titulo Heredado
   oCONTOFAV:oDb        :=oDp:oDb
   oCONTOFAV:cBrwCod    :="CONTOFAV"
   oCONTOFAV:lTmdi      :=.T.
   oCONTOFAV:aHead      :={}
   oCONTOFAV:lBarDef    :=.T. // Activar Modo Diseño.
   oCONTOFAV:aFields    :=ACLONE(aFields)
   oCONTOFAV:cCodCli    :=cCodCli
   oCONTOFAV:dFecha     :=oDp:dFecha
   oCONTOFAV:cCodMon    :=SQLGET("DPCLIENTES","CLI_CODMON,CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
   oCONTOFAV:cNombre    :=DPSQLROW(2)
   oCONTOFAV:cTipDes    :=cTipDes
   oCONTOFAV:cNumero    :=EJECUTAR("DPDOCCLIGETNUM",cTipDes)
   oCONTOFAV:nValCam    :=EJECUTAR("DPGETVALCAM",oCONTOFAV:cCodMon,oCONTOFAV:dFecha)
   oCONTOFAV:nMonto     :=0
   oCONTOFAV:cSUCCLI    :=cSucCli
   oCONTOFAV:nCantSucCli:=COUNT("DPCLIENTESSUC","SDC_CODCLI"+GetWhere("=",oCONTOFAV:cCodCli))
   oCONTOFAV:cNombreDoc :=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oCONTOFAV:cTipDes)))
   oCONTOFAV:nMontoBs   :=0
   oCONTOFAV:nDesc      :=0
   oCONTOFAV:nRecarg    :=0
   oCONTOFAV:nDocOtros  :=0
   oCONTOFAV:cSqlOrg    :=cSqlOrg

   AEVAL(oDp:aFields,{|a,n| oCONTOFAV:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCONTOFAV:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCONTOFAV)}

   oCONTOFAV:lBtnRun     :=.F.
   oCONTOFAV:lBtnMenuBrw :=.F.
   oCONTOFAV:lBtnSave    :=.F.
   oCONTOFAV:lBtnCrystal :=.F.
   oCONTOFAV:lBtnRefresh :=.F.
   oCONTOFAV:lBtnHtml    :=.T.
   oCONTOFAV:lBtnExcel   :=.T.
   oCONTOFAV:lBtnPreview :=.T.
   oCONTOFAV:lBtnQuery   :=.F.
   oCONTOFAV:lBtnOptions :=.T.
   oCONTOFAV:lBtnPageDown:=.T.
   oCONTOFAV:lBtnPageUp  :=.T.
   oCONTOFAV:lBtnFilters :=.T.
   oCONTOFAV:lBtnFind    :=.T.
   oCONTOFAV:lBtnColor   :=.T.
   oCONTOFAV:lBtnZoom    :=.F.
   oCONTOFAV:lBtnNew     :=.F.

   oCONTOFAV:nClrPane1:=16775408
   oCONTOFAV:nClrPane2:=16771797

   oCONTOFAV:nClrText :=0
   oCONTOFAV:nClrText1:=12016384
   oCONTOFAV:nClrText2:=0
   oCONTOFAV:nClrText3:=0

   oCONTOFAV:oBrw:=TXBrowse():New( IF(oCONTOFAV:lTmdi,oCONTOFAV:oWnd,oCONTOFAV:oDlg ))
   oCONTOFAV:oBrw:SetArray( aData, .F. )
   oCONTOFAV:oBrw:SetFont(oFont)

   oCONTOFAV:oBrw:lFooter     := .T.
   oCONTOFAV:oBrw:lHScroll    := .T.
   oCONTOFAV:oBrw:nHeaderLines:= 2
   oCONTOFAV:oBrw:nDataLines  := 1
   oCONTOFAV:oBrw:nFooterLines:= 1

   oCONTOFAV:aData            :=ACLONE(aData)

   AEVAL(oCONTOFAV:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  // Campo: MOV_CODIGO
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CODIGO]
  oCol:cHeader      :='Código'+CRLF+'Producto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100

  // Campo: INV_DESCRI
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_INV_DESCRI]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

  // Campo: MOV_UNDMED
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_UNDMED]
  oCol:cHeader      :='Unidad'+CRLF+'Medida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  // Campo: MOV_CANCON
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANCON]
  oCol:cHeader      :='Cantidad'+CRLF+'Consignada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_CANCON],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANCON],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_CANCON],oCol:cEditPicture)

  // Campo: MOV_DIVCON
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVCON]
  oCol:cHeader      :='Monto'+CRLF+'Consignado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_DIVCON],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVCON],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_DIVCON],oCol:cEditPicture)

  // Campo: MOV_CANFAV
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANFAV]
  oCol:cHeader      :='Cantidad'+CRLF+'Facturada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_CANFAV],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANFAV],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_CANFAV],oCol:cEditPicture)

  // Campo: MOV_DIVFAV
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVFAV]
  oCol:cHeader      :='Monto'+CRLF+'Facturado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_DIVFAV],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVFAV],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_DIVFAV],oCol:cEditPicture)


  // Campo: MOV_CANEXP
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANEXP]
  oCol:cHeader      :='Cant. por'+CRLF+'Facturar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_CANEXP],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANEXP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_CANEXP],oCol:cEditPicture)
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue,nKey| oCONTOFAV:VALCANEXP(oCol,uValue,nKey)}
   oCol:oDataFont    :=oFontB


  // Campo: MOV_PREDIV
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_PREDIV]
  oCol:cHeader      :='Precio'+CRLF+oDp:cMonedaExt
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_PREDIV],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_PREDIV],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_PREDIV],oCol:cEditPicture)


  // Campo: MOV_DIVEXP
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVEXP]
  oCol:cHeader      :='Total por'+CRLF+'Facturar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_DIVEXP],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_DIVEXP],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_DIVEXP],oCol:cEditPicture)


  // Campo: LOGICO
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_LOGICO]
  oCol:cHeader      :='Ok'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 20
  // Campo: LOGICO
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oCONTOFAV:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oCONTOFAV:COL_LOGICO],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}
  oCol:bLDClickData:={||oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_LOGICO]:=!oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_LOGICO],;
                        oCONTOFAV:RUNCLICK(),oCONTOFAV:oBrw:DrawLine(.T.)} 
  oCol:bStrData    :={||""}
  oCol:bLClickHeader:={||oDp:lSel:=!oCONTOFAV:oBrw:aArrayData[1,cIdCol],; 
  AEVAL(oCONTOFAV:oBrw:aArrayData,{|a,n| oCONTOFAV:oBrw:aArrayData[n,oCONTOFAV:COL_LOGICO]:=oDp:lSel}),oCONTOFAV:oBrw:Refresh(.T.)} 


  // Campo: MOV_TOTAL
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_TOTAL]
  oCol:cHeader      :='Monto'+CRLF+'Total '+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_TOTAL],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_TOTAL],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_TOTAL],oCol:cEditPicture)

 // Campo: MOV_TOTAL
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_MTODIV]
  oCol:cHeader      :='Monto'+CRLF+'Total '+oDp:cMonedaExt
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_MTODIV],;
                              oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_MTODIV],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCONTOFAV:COL_MOV_MTODIV],oCol:cEditPicture)


 // Campo: MOV_TIPIVA
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_TIPIVA]
  oCol:cHeader      :='IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 50

// Campo: MOV_IVA
  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_IVA]
  oCol:cHeader      :='%'+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_IVA],;
                               oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_IVA],;
                               FDP(nMonto,oCol:cEditPicture)}

  oCol:=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CXUND]
  oCol:cHeader      :='Cant.'+CRLF+'X Und.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCONTOFAV:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt,oCONTOFAV:COL_MOV_CXUND],;
                               oCol  := oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CXUND],;
                               FDP(nMonto,oCol:cEditPicture)}

  oCONTOFAV:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oCONTOFAV:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCONTOFAV:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCONTOFAV:nClrText,;
                                                 nClrText:=IF(aLine[oCONTOFAV:COL_LOGICO],oCONTOFAV:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCONTOFAV:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCONTOFAV:nClrPane1, oCONTOFAV:nClrPane2 ) } }

//   oCONTOFAV:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCONTOFAV:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCONTOFAV:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCONTOFAV:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCONTOFAV:oBrw:bLDblClick:={|oBrw|oCONTOFAV:RUNCLICK() }

   oCONTOFAV:oBrw:bChange:={||oCONTOFAV:BRWCHANGE()}
   oCONTOFAV:oBrw:CreateFromCode()

   oCONTOFAV:oWnd:oClient := oCONTOFAV:oBrw

   oCONTOFAV:Activate({||oCONTOFAV:ViewDatBar()})

   oCONTOFAV:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCONTOFAV:lTmdi,oCONTOFAV:oWnd,oCONTOFAV:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCONTOFAV:oBrw:nWidth()

   oCONTOFAV:oBrw:GoBottom(.T.)
   oCONTOFAV:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCONTOFAV.EDT")
//     oCONTOFAV:oBrw:Move(44,0,1504+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCONTOFAV:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCONTOFAV:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCONTOFAV:oBrw:oLbx  :=oCONTOFAV    // MDI:GOTFOCUS()

// Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          TOP PROMPT "Guardar";
          WHEN oCONTOFAV:nMonto>0;
          ACTION oCONTOFAV:BRWSAVEDOC()

   oBtn:cToolTip:="Incluir"

   oCONTOFAV:oBtnSave:=oBtn

   IF .F. .AND. Empty(oCONTOFAV:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCONTOFAV:oBrw,oCONTOFAV:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

/*
   IF Empty(oCONTOFAV:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CONTOFAV")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CONTOFAV"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCONTOFAV:oBrw,"CONTOFAV",oCONTOFAV:cSql,oCONTOFAV:nPeriodo,oCONTOFAV:dDesde,oCONTOFAV:dHasta,oCONTOFAV)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCONTOFAV:oBtnRun:=oBtn



       oCONTOFAV:oBrw:bLDblClick:={||EVAL(oCONTOFAV:oBtnRun:bAction) }


   ENDIF




IF oCONTOFAV:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCONTOFAV");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCONTOFAV:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCONTOFAV:lBtnColor

     oCONTOFAV:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCONTOFAV:oBrw,oCONTOFAV,oCONTOFAV:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCONTOFAV,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCONTOFAV,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCONTOFAV:oBtnColor:=oBtn

ENDIF

IF oCONTOFAV:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oCONTOFAV:oBrw,oCONTOFAV:oFrm)
ENDIF

IF oCONTOFAV:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCONTOFAV),;
                  EJECUTAR("DPBRWMENURUN",oCONTOFAV,oCONTOFAV:oBrw,oCONTOFAV:cBrwCod,oCONTOFAV:cTitle,oCONTOFAV:aHead));
          WHEN !Empty(oCONTOFAV:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCONTOFAV:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCONTOFAV:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCONTOFAV:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCONTOFAV:oBrw,oCONTOFAV);
          ACTION EJECUTAR("BRWSETFILTER",oCONTOFAV:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCONTOFAV:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCONTOFAV:oBrw);
          WHEN LEN(oCONTOFAV:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCONTOFAV:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCONTOFAV:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCONTOFAV:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCONTOFAV)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCONTOFAV:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCONTOFAV:oBrw,oCONTOFAV:cTitle,oCONTOFAV:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCONTOFAV:oBtnXls:=oBtn

ENDIF

IF oCONTOFAV:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCONTOFAV:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCONTOFAV:oBrw,NIL,oCONTOFAV:cTitle,oCONTOFAV:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCONTOFAV:oBtnHtml:=oBtn

ENDIF


IF oCONTOFAV:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCONTOFAV:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCONTOFAV:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCONTOFAV")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCONTOFAV:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCONTOFAV:oBtnPrint:=oBtn

   ENDIF

IF oCONTOFAV:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCONTOFAV:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oCONTOFAV:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oCONTOFAV:oWnd:IsZoomed(),oCONTOFAV:oWnd:Restore(),oCONTOFAV:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCONTOFAV:oBrw:GoTop(),oCONTOFAV:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCONTOFAV:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCONTOFAV:oBrw:PageDown(),oCONTOFAV:oBrw:Setfocus())

  ENDIF

  IF  oCONTOFAV:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCONTOFAV:oBrw:PageUp(),oCONTOFAV:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCONTOFAV:oBrw:GoBottom(),oCONTOFAV:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCONTOFAV:Close()

  oCONTOFAV:oBrw:SetColor(0,oCONTOFAV:nClrPane1)

  IF oDp:lBtnText
     oCONTOFAV:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCONTOFAV:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCONTOFAV:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCONTOFAV:oBar:=oBar

  oBar:SetSize(NIL,80+20+15+44,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  nCol:=20
  nLin:=20+20

  @ nLin+27,nCol+001 SAY " Cliente " OF oBar;
                     BORDER SIZE 074,20;
                     COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

  @ nLin+48,nCol+001 SAY " Número " OF oBar;
                       BORDER SIZE 074,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

  @ nLin+48,nCol+240 SAY " Fiscal " OF oBar;
                       BORDER SIZE 074,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

  @ nLin+69,nCol+001 SAY " Fecha " OF oBar;
                       BORDER SIZE 074,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

  @ nLin+27,nCol+080   SAY " "+oCONTOFAV:cCodCli+" " OF oBar;
                       BORDER SIZE 070+20,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

  @ nLin+48,nCol+080   SAY " "+oCONTOFAV:cNumero+" " OF oBar;
                       BORDER SIZE 070+20,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

  @ nLin+69,nCol+080 BMPGET oCONTOFAV:oFecha  VAR oCONTOFAV:dFecha;
                     PIXEL;
                     NAME "BITMAPS\find22.bmp";
                     ACTION LbxDate(oCONTOFAV:oFecha,oCONTOFAV:dFecha);
                     VALID oAVINOTENTDET:VALFECHA();
                     SIZE 84,20;
                     WHEN oCONTOFAV:lWhen ;
                     OF oBar;
                     FONT oFont

  @ nLin+27,nCol+148+24 SAY " "+oCONTOFAV:cNombre+" " OF oBar;
                        BORDER SIZE 320,20;
                        COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

  @ nLin+90,nCol+001 SAY " Sucursal "  RIGHT OF oBar BORDER SIZE 74,20;
                     PIXEL FONT oFont COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  // 04/08/2022
  @ nLin+90,nCol+080  BMPGET oCONTOFAV:oSucCli VAR oCONTOFAV:cSucCli OF oBar;
                      VALID oCONTOFAV:VALSUCCLI();
                      NAME "BITMAPS\CLIENTE2.BMP"; 
                      ACTION oCONTOFAV:LBXSUCXCLI();
                      SIZE 60,20 PIXEL FONT oFont;
                      WHEN oCONTOFAV:nCantSucCli>0

  oCONTOFAV:oSucCli:bKeyDown:={|nKey| IF(nKey=13,oCONTOFAV:VALSUCCLI(),NIL)}

  @ nLin+90,nCol+148+24 SAY oCONTOFAV:oSAY_SUCCLI PROMPT  " "+SQLGET("DPCLIENTESSUC","SDC_NOMBRE","SDC_CODCLI"+GetWhere("=",oCONTOFAV:cCodCli)+" AND "+;
                                                                                              "SDC_CODIGO"+GetWhere("=",oCONTOFAV:cSucCli));
                                                           SIZE 300,20 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL FONT oFont BORDER
  nCol:=200+360
  nLin:=2+20+20+25+0

  @ nLin+0,nCol+60 BMPGET oCONTOFAV:oCodMon  VAR oCONTOFAV:cCodMon;
                 PIXEL;
                 NAME "BITMAPS\find22.bmp";
                 ACTION (oDpLbx:=DpLbx("DPTABMON",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oCONTOFAV:oCodMon,NIL),;
                         oDpLbx:GetValue("MON_CODIGO",oCONTOFAV:oCodMon));
                 VALID oAVINOTENTDET:VALCODMON();
                 SIZE 40,20;
                 WHEN oCONTOFAV:lWhen ;
                 OF oBar;
                 FONT oFont

  oCONTOFAV:oCodMon:bLostFocus:={|| oCONTOFAV:VALCODMON()}

  @ oCONTOFAV:oCodMon:nTop,nCol-55+60 SAY oDp:xDPTABMON+" " OF oBar BORDER SIZE 54,20 PIXEL;
                               BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ oCONTOFAV:oCodMon:nTop,nCol+60+60 SAY oCONTOFAV:oSayCodMon PROMPT " "+SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oCONTOFAV:cCodMon));
                                      OF oBar PIXEL SIZE 220+40,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  @ oCONTOFAV:oCodMon:nTop+22,nCol-60+4+60 GET oCONTOFAV:oSayValCam VAR oCONTOFAV:nValCam PICTURE oDp:cPictValCam;
                                       OF oBar PIXEL SIZE 120,20  FONT oFont RIGHT;
                                       VALID oCONTOFAV:VALDIVISA()

  oCONTOFAV:oSayValCam:bKeyDown:={|nKey| IF(nKey=13,oCONTOFAV:VALDIVISA(),NIL)}

  nCol:=200+270
  nLin:=05

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -16 BOLD

  @ nLin+10,nCol+148+40 SAY " "+oCONTOFAV:cTipDes+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oCONTOFAV:cTipDes))+" " OF oBar;
                        BORDER SIZE 320,20;
                        COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

  BMPGETBTN(oCONTOFAV:oCodMon,oFont,13)
  BMPGETBTN(oCONTOFAV:oFecha ,oFont,13)
  BMPGETBTN(oCONTOFAV:oSucCli,oFont,13)

  oCONTOFAV:oSucCli:ForWhen(.T.)

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL oCol     :=oCONTOFAV:oBrw:aCols[oCONTOFAV:COL_MOV_CANEXP]
  LOCAL aLine    :=oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt]
  LOCAL uValue   :=aLine[oCONTOFAV:COL_MOV_CANEXP],nKey:=NIL
  LOCAL nCantxFav:=aLine[oCONTOFAV:COL_MOV_CANCON]-aLine[oCONTOFAV:COL_MOV_CANFAV]

  IF !aLine[oCONTOFAV:COL_LOGICO]
     uValue:=0
  ELSE
     uValue:=nCantxFav
  ENDIF

  oCONTOFAV:VALCANEXP(oCol,uValue,nKey,aLine[oCONTOFAV:COL_LOGICO])
  
RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRCONTOFAV",cWhere)
  oRep:cSql  :=oCONTOFAV:cSql
  oRep:cTitle:=oCONTOFAV:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCONTOFAV:oPeriodo:nAt,cWhere

  oCONTOFAV:nPeriodo:=nPeriodo


  IF oCONTOFAV:oPeriodo:nAt=LEN(oCONTOFAV:oPeriodo:aItems)

     oCONTOFAV:oDesde:ForWhen(.T.)
     oCONTOFAV:oHasta:ForWhen(.T.)
     oCONTOFAV:oBtn  :ForWhen(.T.)

     DPFOCUS(oCONTOFAV:oDesde)

  ELSE

     oCONTOFAV:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCONTOFAV:oDesde:VarPut(oCONTOFAV:aFechas[1] , .T. )
     oCONTOFAV:oHasta:VarPut(oCONTOFAV:aFechas[2] , .T. )

     oCONTOFAV:dDesde:=oCONTOFAV:aFechas[1]
     oCONTOFAV:dHasta:=oCONTOFAV:aFechas[2]

     cWhere:=oCONTOFAV:HACERWHERE(oCONTOFAV:dDesde,oCONTOFAV:dHasta,oCONTOFAV:cWhere,.T.)

     oCONTOFAV:LEERDATA(cWhere,oCONTOFAV:oBrw,oCONTOFAV:cServer,oCONTOFAV)

  ENDIF

  oCONTOFAV:SAVEPERIODO()

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

     IF !Empty(oCONTOFAV:cWhereQry)
       cWhere:=cWhere + oCONTOFAV:cWhereQry
     ENDIF

     oCONTOFAV:LEERDATA(cWhere,oCONTOFAV:oBrw,oCONTOFAV:cServer,oCONTOFAV)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCONTOFAV)
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
          " MOV_CODIGO, "+;
          " INV_DESCRI, "+;
          " MOV_UNDMED, "+;
          " SUM(IF(MOV_TIPDOC='CON',MOV_CANTID*MOV_FISICO*-1,0)) AS MOV_CANCON, "+;
          " SUM(IF(MOV_TIPDOC='CON',MOV_MTODIV*MOV_FISICO*-1,0)) AS MOV_DIVCON, "+;
             " SUM(IF(MOV_ASOTIP='CON' AND MOV_TIPDOC='FAV',MOV_CANTID*MOV_CONTAB*-1,0)) AS MOV_CANFAV, "+;
          " SUM(IF(MOV_ASOTIP='CON' AND MOV_TIPDOC='FAV',MOV_MTODIV*MOV_CONTAB*-1,0)) AS MOV_DIVFAV, "+;
          " SUM(IF(MOV_TIPDOC='CON',MOV_CANTID*MOV_FISICO*-1,0)-IF(MOV_ASOTIP='CON' AND MOV_TIPDOC='FAV',MOV_CANTID*MOV_CONTAB*-1,0)) AS MOV_CANEXP, "+;
          " MOV_PREDIV, "+;
          " SUM(IF(MOV_TIPDOC='CON',MOV_MTODIV*MOV_FISICO*-1,0)) AS MOV_DIVEXP, "+;
          " 0 AS LOGICO,0 AS MOV_TOTAL,0 AS MOV_MTODIV,MOV_TIPIVA,MOV_IVA,MOV_CXUND "+;
          " FROM "+;
          " DPMOVINV "+;
          " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
          " WHERE MOV_APLORG='V' AND (MOV_TIPDOC='CON' OR MOV_TIPDOC='FAV' OR MOV_TIPDOC='NEN' OR MOV_TIPDOC='CRE') AND MOV_INVACT=1 "+;
          " GROUP BY MOV_CODIGO,MOV_PREDIV,MOV_TIPIVA "+;
          " HAVING MOV_CANEXP>0"+;
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

   DPWRITE("TEMP\BRCONTOFAV.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',0,0,0,0,0,0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCONTOFAV:cSql   :=cSql
      oCONTOFAV:cWhere_:=cWhere

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
      AEVAL(oCONTOFAV:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCONTOFAV:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCONTOFAV.MEM",V_nPeriodo:=oCONTOFAV:nPeriodo
  LOCAL V_dDesde:=oCONTOFAV:dDesde
  LOCAL V_dHasta:=oCONTOFAV:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCONTOFAV)
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


    IF Type("oCONTOFAV")="O" .AND. oCONTOFAV:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCONTOFAV:cWhere_),oCONTOFAV:cWhere_,oCONTOFAV:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCONTOFAV:LEERDATA(oCONTOFAV:cWhere_,oCONTOFAV:oBrw,oCONTOFAV:cServer,oCONTOFAV)
      oCONTOFAV:oWnd:Show()
      oCONTOFAV:oWnd:Restore()

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

   oCONTOFAV:aHead:=EJECUTAR("HTMLHEAD",oCONTOFAV)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCONTOFAV)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oCONTOFAV:oBrw:aArrayData[oCONTOFAV:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oCONTOFAV:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oCONTOFAV:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oCONTOFAV:oBrw,.F.)

  oCONTOFAV:oBrw:nColSel:=1
  oCONTOFAV:oBrw:GoBottom()
  oCONTOFAV:oBrw:Refresh(.F.)
  oCONTOFAV:oBrw:nArrayAt:=LEN(oCONTOFAV:oBrw:aArrayData)
  oCONTOFAV:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oCONTOFAV:oBrw)

RETURN .T.

FUNCTION VALCODMON(lRefresh)

   DEFAULT lRefresh:=.F.
 
   oCONTOFAV:nValCam:=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oCONTOFAV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oCONTOFAV:dFecha))

   oCONTOFAV:oSayCodMon:Refresh(.T.) 
   oCONTOFAV:oSayValCam:Refresh(.T.)
 
   IF !ISSQLFIND("DPTABMON","MON_CODIGO"+GetWhere("=",oCONTOFAV:cCodMon))
      EVAL(oCONTOFAV:oCodMon:bAction)
      RETURN .F.
   ENDIF

   IF lRefresh
     oCONTOFAV:HACERWHERE(oCONTOFAV:dDesde,oCONTOFAV:dHasta,oCONTOFAV:cWhere,.T.)
   ENDIF

RETURN .T.

FUNCTION VALDIVISA()

/*
    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO"   ,"HMN_FECHA"         ,"HMN_VALOR"          ,"HMN_HORA " },;
                                       {oDp:cMonedaBcv,oCONTOFAV:dFecha,oCONTOFAV:nValCam  ,"00:00:00"},;
                                        NIL,.T.,"HMN_CODIGO"+GetWhere("=",oDp:cMonedaExt)+" AND HMN_FECHA"+GetWhere("=",oCONTOFAV:dFecha))
*/
RETURN .T.

FUNCTION VALFECHA()
RETURN .T.

FUNCTION VALSUCCLI()

  IF !ISSQLFIND("DPCLIENTESSUC","SDC_CODCLI"+GetWhere("=",oCONTOFAV:cCodCli)+" AND SDC_CODIGO"+GetWhere("=",oCONTOFAV:cSUCCLI))
     oCONTOFAV:oSucCli:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  oCONTOFAV:oSAY_SUCCLI:Refresh(.T.)

RETURN .T.


FUNCTION LBXSUCXCLI()
  LOCAL cWhere,oLbx
  LOCAL cNombre:=oCONTOFAV:cNombre //EVAL(oCONTOFAV:oNombre:bSetGet)
  LOCAL cTitle :=ALLTRIM(GetFromVar("{oDp:DPCLIENTESSUC}"))+;
                 " ["+oCONTOFAV:cCodCli+" "+ALLTRIM(cNombre)+"]"

  cWhere:="SDC_CODCLI"+GetWhere("=",oCONTOFAV:cCodCli)
  cTitle:=CTOO(cTitle,"C")

  oDp:aCargo:={"",oCONTOFAV:cCodCli,"DPCLIENTES","",""}
  oLbx:=DPLBX("DPCLIENTESSUC.LBX",cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oCONTOFAV:oSucCli)

  IF ValType(oLbx)="O"
     oLbx:GetValue("SDC_CODIGO",oCONTOFAV:oSucCli)
     oLbx:aCargo:=oDp:aCargo
     oLbx:cScope:=cWhere
  ENDIF

RETURN .T.

/*
// GUARDAR VALOR EN EL CAMPO
*/
FUNCTION PUTFIELDVALUE(oCol,uValue,nCol,nKey,nLen,lNext,lTotal,lSave)
   LOCAL cField,aLine
   LOCAL cWhere:="" 

   DEFAULT nCol  :=oCol:nPos,;
           lNext :=.F.,;
           lTotal:=!Empty(oCol:cFooter),;
           lSave :=.F.

   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
   oCONTOFAV:oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION VALCANEXP(oCol,uValue,nKey,lOk)
   LOCAL aLine    := oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]
   LOCAL nCantxFav:=aLine[oCONTOFAV:COL_MOV_CANCON]-aLine[oCONTOFAV:COL_MOV_CANFAV]
   LOCAL aTotales :={}

   IF uValue>nCantXFav
     EJECUTAR("XSCGMSGERR",oCol:oBrw,"Cantidad "+LSTR(uValue)+" no puede ser Superior "+LSTR(nCantXFav),"Validación")
     RETURN .T.
   ENDIF

   DEFAULT lOk:=!(uValue=0)

   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oCONTOFAV:COL_LOGICO]    :=lOk
   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oCONTOFAV:COL_MOV_TOTAL ]:=ROUND(uValue*aLine[oCONTOFAV:COL_MOV_PREDIV]*oCONTOFAV:nValCam,2)
   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oCONTOFAV:COL_MOV_MTODIV]:=ROUND(uValue*aLine[oCONTOFAV:COL_MOV_PREDIV],2)

   oCONTOFAV:PUTFIELDVALUE(oCol,uValue,oCONTOFAV:COL_MOV_CANEXP,nKey,NIL,.T.)

   aTotales:=EJECUTAR("BRWCALTOTALES",oCol:oBrw,.F.)

   oCONTOFAV:nMonto  :=aTotales[oCONTOFAV:COL_MOV_MTODIV]
   oCONTOFAV:nMontoBs:=aTotales[oCONTOFAV:COL_MOV_TOTAL ]


   oCONTOFAV:oBtnSave:ForWhen(.T.)
// ? oCONTOFAV:nMonto,"oCONTOFAV:nMonto"

RETURN .T.

FUNCTION BRWSAVEDOC()
   LOCAL nCxC:=EJECUTAR("DPTIPCXC",oCONTOFAV:cTipDes),oTable:=NIL,cWhere
   LOCAL oMovInv,aData,I,oDoc
   LOCAL cCodInv,nCantid,nPrecio,cUndMed,cTipIva,cItem,nPorIva,nCxUnd,nCostoD,cLote
   LOCAL nFisico:=0,nLogico:=0,nContab:=-1 // Descontará Contablemente el Producto
   LOCAL oMovOrg // Origen de la Consignación

   oCONTOFAV:cNumero    :=EJECUTAR("DPDOCCLIGETNUM",oCONTOFAV:cTipDes)

   IF !MsgNoYes("Generar "+oCONTOFAV:cNombreDoc+" #"+oCONTOFAV:cNumero+CRLF+"Monto: "+ALLTRIM(FDP(oCONTOFAV:nMonto,"999,999,999,999.99"))+oDp:cMonedaExt+" + IVA" ,"Crear Documento")
      RETURN .F.
   ENDIF
    
   CursorWait()

   oCONTOFAV:cNumero    :=EJECUTAR("DPDOCCLIGETNUM",oCONTOFAV:cTipDes)

   aData  :=ACLONE(oCONTOFAV:oBrw:aArrayData)
   aData  :=ADEPURA(aData,{|a,n| !a[oCONTOFAV:COL_LOGICO]})
   oMovInv:=OpenTable("SELECT * FROM DPMOVINV",.F.)

   EJECUTAR("DPDOCCLICREA",NIL,oCONTOFAV:cTipDes,oCONTOFAV:cNumero,oCONTOFAV:cCodCli,oCONTOFAV:dFecha,oCONTOFAV:cCodMon,"V",NIL,oCONTOFAV:nMonto,0,oCONTOFAV:nValCam,oCONTOFAV:dFecha,NIL,oTable,"N",nCxC)

   cWhere:=" MOV_CODSUC"+GetWhere("=",oCONTOFAV:cCodSuc)+" AND "+;
           " MOV_TIPDOC"+GetWhere("=",oCONTOFAV:cTipDes)+" AND "+;
           " MOV_DOCUME"+GetWhere("=",oCONTOFAV:cNumero)+" AND "+;
           " MOV_APLORG"+GetWhere("=","V"    )

   

   FOR I=1 TO LEN(aData)

      cCodInv:=aData[I,oCONTOFAV:COL_MOV_CODIGO]
      nCantid:=aData[I,oCONTOFAV:COL_MOV_CANEXP]
      nPrecio:=ROUND(aData[I,oCONTOFAV:COL_MOV_PREDIV]*oCONTOFAV:nValCam,2)
      cUndMed:=aData[I,oCONTOFAV:COL_MOV_UNDMED]
      cTipIva:=aData[I,oCONTOFAV:COL_MOV_TIPIVA]
      nPorIva:=aData[I,oCONTOFAV:COL_MOV_IVA   ]
      nCxUnd :=aData[I,oCONTOFAV:COL_MOV_CXUND]
      nCostoD:=0 // Costo
      cLote  :=""

      cItem:=STRZERO(I,5)

      EJECUTAR("DPMOVINVCREA",oCONTOFAV:cCodSuc,oCONTOFAV:cTipDes,oCONTOFAV:cNumero,cCodInv,nCantid,nPrecio,cUndMed,nCxUnd,nCostoD,cLote,oCONTOFAV:dFecha,"V",oCONTOFAV:dFecha,;
               oCONTOFAV:cCodCli,cTipIva,nPorIva,oCONTOFAV:nValCam,oMovInv,oDp:cLista,0,cItem)

      SQLUPDATE("DPMOVINV",{"MOV_PREDIV","MOV_ASOTIP","MOV_FISICO","MOV_LOGICO","MOV_CONTAB"},;
                           {aData[I,oCONTOFAV:COL_MOV_PREDIV],"CON",nFisico,nLogico,nContab},;
               cWhere+" AND MOV_ITEM"+GetWhere("=",cItem))

   NEXT I

   oMovInv:End()

   oCONTOFAV:Close()

   EJECUTAR("DPDOCCLIIMP",oCONTOFAV:cCodSuc,oCONTOFAV:cTipDes,oCONTOFAV:cCodCli,oCONTOFAV:cNumero,.T.,oCONTOFAV:nDesc,oCONTOFAV:nRecarg,oCONTOFAV:nDocOtros,"V")

   oDoc:=EJECUTAR("DPFACTURAV",oCONTOFAV:cTipDes,oCONTOFAV:cNumero)

   EJECUTAR("DOCCLIAFTERSAVE",oCONTOFAV:cCodSuc,oCONTOFAV:cTipDes,oCONTOFAV:cCodCli,oCONTOFAV:cNumero)

   // Complementa los datos del documento

RETURN .T.


// EOF

