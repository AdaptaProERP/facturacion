// Programa   : BRTIPDOCCLITOT
// Fecha/Hora : 28/01/2025 20:52:39
// Propósito  : "Fiscalizador Totales Diario por tipo de Documento"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRTIPDOCCLITOT.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oTIPDOCCLITOT")="O" .AND. oTIPDOCCLITOT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oTIPDOCCLITOT,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Fiscalizador Totales Diario por tipo de Documento" +IF(Empty(cTitle),"",cTitle)

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

// ViewArray(aData)
// return 

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oTIPDOCCLITOT

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oTIPDOCCLITOT","BRTIPDOCCLITOT.EDT")
// oTIPDOCCLITOT:CreateWindow(0,0,100,550)
   oTIPDOCCLITOT:Windows(0,0,aCoors[3]-160,MIN(1854,aCoors[4]-10),.T.) // Maximizado



   oTIPDOCCLITOT:cCodSuc  :=cCodSuc
   oTIPDOCCLITOT:lMsgBar  :=.F.
   oTIPDOCCLITOT:cPeriodo :=aPeriodos[nPeriodo]
   oTIPDOCCLITOT:cCodSuc  :=cCodSuc
   oTIPDOCCLITOT:nPeriodo :=nPeriodo
   oTIPDOCCLITOT:cNombre  :=""
   oTIPDOCCLITOT:dDesde   :=dDesde
   oTIPDOCCLITOT:cServer  :=cServer
   oTIPDOCCLITOT:dHasta   :=dHasta
   oTIPDOCCLITOT:cWhere   :=cWhere
   oTIPDOCCLITOT:cWhere_  :=cWhere_
   oTIPDOCCLITOT:cWhereQry:=""
   oTIPDOCCLITOT:cSql     :=oDp:cSql
   oTIPDOCCLITOT:oWhere   :=TWHERE():New(oTIPDOCCLITOT)
   oTIPDOCCLITOT:cCodPar  :=cCodPar // Código del Parámetro
   oTIPDOCCLITOT:lWhen    :=.T.
   oTIPDOCCLITOT:cTextTit :="" // Texto del Titulo Heredado
   oTIPDOCCLITOT:oDb      :=oDp:oDb
   oTIPDOCCLITOT:cBrwCod  :="TIPDOCCLITOT"
   oTIPDOCCLITOT:lTmdi    :=.T.
   oTIPDOCCLITOT:aHead    :={}
   oTIPDOCCLITOT:lBarDef  :=.T. // Activar Modo Diseño.
   oTIPDOCCLITOT:aFields  :=ACLONE(aFields)

   oTIPDOCCLITOT:nClrPane1:=oDp:nClrPane1
   oTIPDOCCLITOT:nClrPane2:=oDp:nClrPane2

   oTIPDOCCLITOT:nClrText1:=0
   oTIPDOCCLITOT:nClrText2:=0
   oTIPDOCCLITOT:nClrText3:=0
   oTIPDOCCLITOT:nClrText4:=0
   oTIPDOCCLITOT:nClrText5:=0


   AEVAL(oDp:aFields,{|a,n| oTIPDOCCLITOT:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oTIPDOCCLITOT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oTIPDOCCLITOT)}

   oTIPDOCCLITOT:lBtnRun     :=.F.
   oTIPDOCCLITOT:lBtnMenuBrw :=.F.
   oTIPDOCCLITOT:lBtnSave    :=.F.
   oTIPDOCCLITOT:lBtnCrystal :=.F.
   oTIPDOCCLITOT:lBtnRefresh :=.F.
   oTIPDOCCLITOT:lBtnHtml    :=.T.
   oTIPDOCCLITOT:lBtnExcel   :=.T.
   oTIPDOCCLITOT:lBtnPreview :=.T.
   oTIPDOCCLITOT:lBtnQuery   :=.F.
   oTIPDOCCLITOT:lBtnOptions :=.T.
   oTIPDOCCLITOT:lBtnPageDown:=.T.
   oTIPDOCCLITOT:lBtnPageUp  :=.T.
   oTIPDOCCLITOT:lBtnFilters :=.T.
   oTIPDOCCLITOT:lBtnFind    :=.T.
   oTIPDOCCLITOT:lBtnColor   :=.T.
   oTIPDOCCLITOT:lBtnZoom    :=.F.
   oTIPDOCCLITOT:lBtnNew     :=.F.


   oTIPDOCCLITOT:nClrPane1:=16775408
   oTIPDOCCLITOT:nClrPane2:=16771797

   oTIPDOCCLITOT:nClrText :=0
   oTIPDOCCLITOT:nClrText1:=0
   oTIPDOCCLITOT:nClrText2:=0
   oTIPDOCCLITOT:nClrText3:=0




   oTIPDOCCLITOT:oBrw:=TXBrowse():New( IF(oTIPDOCCLITOT:lTmdi,oTIPDOCCLITOT:oWnd,oTIPDOCCLITOT:oDlg ))
   oTIPDOCCLITOT:oBrw:SetArray( aData, .F. )
   oTIPDOCCLITOT:oBrw:SetFont(oFont)

   oTIPDOCCLITOT:oBrw:lFooter     := .T.
   oTIPDOCCLITOT:oBrw:lHScroll    := .T.
   oTIPDOCCLITOT:oBrw:nHeaderLines:= 3
   oTIPDOCCLITOT:oBrw:nDataLines  := 1
   oTIPDOCCLITOT:oBrw:nFooterLines:= 1




   oTIPDOCCLITOT:aData            :=ACLONE(aData)

   AEVAL(oTIPDOCCLITOT:oBrw:aCols,{|oCol,n|oCol:oHeaderFont:=oFontB, oCol:nPos:=n})

   

  // Campo: TDT_CODSUC
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_CODSUC]
  oCol:cHeader      :='Cód.'+CRLF+'Suc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  // Campo: TDT_FECHA
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_FECHA]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: TDT_SERFIS
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_SERFIS]
  oCol:cHeader      :='Serie'+CRLF+'Fiscal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: TDT_TIPDOC
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_TIPDOC]
  oCol:cHeader      :='Tipo'+CRLF+'Doc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: TDC_DESCRI
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDC_DESCRI]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
oCol:bClrStd  := {|nClrText,uValue|uValue:=oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,5],;
                     nClrText:=COLOR_OPTIONS("DPTIPDOCPRO         ","TDC_DESCRI",uValue),;
                     {nClrText,iif( oTIPDOCCLITOT:oBrw:nArrayAt%2=0, oTIPDOCCLITOT:nClrPane1, oTIPDOCCLITOT:nClrPane2 ) } } 

  // Campo: TDT_BASIMP
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_BASIMP]
  oCol:cHeader      :='Base'+CRLF+'Imponible'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_BASIMP],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_BASIMP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_BASIMP],oCol:cEditPicture)


  // Campo: TDT_MTOIVA
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTOIVA]
  oCol:cHeader      :='Monto'+CRLF+'IVA'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_MTOIVA],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTOIVA],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_MTOIVA],oCol:cEditPicture)


  // Campo: TDT_MTOEXE
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTOEXE]
  oCol:cHeader      :='Monto'+CRLF+'Exento'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_MTOEXE],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_MTOEXE],oCol:cEditPicture)


  // Campo: TDT_MTONET
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTONET]
  oCol:cHeader      :='Monto'+CRLF+'Neto'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_MTONET],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_MTONET],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_MTONET],oCol:cEditPicture)


  // Campo: TDT_CANTID
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_CANTID]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_CANTID],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_CANTID],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_CANTID],oCol:cEditPicture)


  // Campo: TDT_CANMOV
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_CANMOV]
  oCol:cHeader      :='Reg.'+CRLF+'Items'+CRLF+'Total'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_TDT_CANMOV],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_CANMOV],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_TDT_CANMOV],oCol:cEditPicture)


  // Campo: LOGICO
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_LOGICO]
  oCol:cHeader      :='Total'+CRLF+'Vs'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  // Campo: LOGICO
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oTIPDOCCLITOT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oTIPDOCCLITOT:COL_LOGICO],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}

  // Campo: RDF_BASIMP
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_BASIMP]
  oCol:cHeader      :='Base'+CRLF+'Imponible'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_RDF_BASIMP],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_BASIMP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_RDF_BASIMP],oCol:cEditPicture)


  // Campo: RDF_MTOIVA
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTOIVA]
  oCol:cHeader      :='Monto'+CRLF+'IVA'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_RDF_MTOIVA],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTOIVA],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_RDF_MTOIVA],oCol:cEditPicture)


  // Campo: RDF_MTOEXE
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTOEXE]
  oCol:cHeader      :='Monto'+CRLF+'Exento'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_RDF_MTOEXE],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_RDF_MTOEXE],oCol:cEditPicture)


  // Campo: RDF_MTONET
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTONET]
  oCol:cHeader      :='Monto'+CRLF+'Neto'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_RDF_MTONET],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_MTONET],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_RDF_MTONET],oCol:cEditPicture)


  // Campo: RDF_CANDOC
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_CANDOC]
  oCol:cHeader      :='Cant.'+CRLF+'Doc.'+CRLF+'Data'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_RDF_CANDOC],;
                                    oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_RDF_CANDOC],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_RDF_CANDOC],oCol:cEditPicture)


  // Campo: LOGICO2
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_LOGICO2]
  oCol:cHeader      :='Data'+CRLF+"Vs"+CRLF+'Clave'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 45
  // Campo: LOGICO2
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oTIPDOCCLITOT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oTIPDOCCLITOT:COL_LOGICO2],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}

  // Campo: BASIMP
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_BASIMP]
  oCol:cHeader      :='Base'+CRLF+'Imponible'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_BASIMP],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_BASIMP],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_BASIMP],oCol:cEditPicture)


  // Campo: MTOIVA
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTOIVA]
  oCol:cHeader      :='Monto'+CRLF+'IVA'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_MTOIVA],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTOIVA],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_MTOIVA],oCol:cEditPicture)


  // Campo: MTOEXE
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTOEXE]
  oCol:cHeader      :='Monto'+CRLF+'Exento'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_MTOEXE],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTOEXE],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_MTOEXE],oCol:cEditPicture)


  // Campo: MTONET
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTONET]
  oCol:cHeader      :='Monto'+CRLF+'Neto'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_MTONET],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_MTONET],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_MTONET],oCol:cEditPicture)


  // Campo: CANDOC
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_CANDOC]
  oCol:cHeader      :='Cant.'+CRLF+'Doc.'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_CANDOC],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_CANDOC],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_CANDOC],oCol:cEditPicture)


  // Campo: CANMOV
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_CANMOV]
  oCol:cHeader      :='Cant.'+CRLF+'Mov.'+CRLF+'Clave'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt,oTIPDOCCLITOT:COL_CANMOV],;
                              oCol  := oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_CANMOV],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[oTIPDOCCLITOT:COL_CANMOV],oCol:cEditPicture)

/*
  // Campo: TDT_ENCRIP
  oCol:=oTIPDOCCLITOT:oBrw:aCols[oTIPDOCCLITOT:COL_TDT_ENCRIP]
  oCol:cHeader      :='Encriptado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTIPDOCCLITOT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
*/
   oTIPDOCCLITOT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oTIPDOCCLITOT:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oTIPDOCCLITOT:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oTIPDOCCLITOT:nClrText,;
                                                 nClrText:=IF(.F.,oTIPDOCCLITOT:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oTIPDOCCLITOT:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oTIPDOCCLITOT:nClrPane1, oTIPDOCCLITOT:nClrPane2 ) } }

//   oTIPDOCCLITOT:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oTIPDOCCLITOT:oBrw:bClrFooter            := {|| {0,14671839 }}

   oTIPDOCCLITOT:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oTIPDOCCLITOT:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oTIPDOCCLITOT:oBrw:bLDblClick:={|oBrw|oTIPDOCCLITOT:RUNCLICK() }

/*
   AEVAL(oTIPDOCCLITOT:oBrw:aCols,{|a,n,oCol|oCol:=oTIPDOCCLITOT:oBrw:aCols[n],;
                                             oCol:cHeader:=oCol:cHeader+":"+LSTR(n)})
*/
   oTIPDOCCLITOT:oBrw:bChange:={||oTIPDOCCLITOT:BRWCHANGE()}
   oTIPDOCCLITOT:oBrw:CreateFromCode()


   oTIPDOCCLITOT:oWnd:oClient := oTIPDOCCLITOT:oBrw



   oTIPDOCCLITOT:Activate({||oTIPDOCCLITOT:ViewDatBar()})

   oTIPDOCCLITOT:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oTIPDOCCLITOT:lTmdi,oTIPDOCCLITOT:oWnd,oTIPDOCCLITOT:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oTIPDOCCLITOT:oBrw:nWidth()

   oTIPDOCCLITOT:oBrw:GoBottom(.T.)
   oTIPDOCCLITOT:oBrw:Refresh(.T.)

   IF !File("FORMS\BRTIPDOCCLITOT.EDT")
     oTIPDOCCLITOT:oBrw:Move(44,0,1854+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oTIPDOCCLITOT:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oTIPDOCCLITOT:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oTIPDOCCLITOT:oBrw:oLbx  :=oTIPDOCCLITOT    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF oTIPDOCCLITOT:lBtnNew

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP";
             TOP PROMPT "Incluir";
             ACTION oTIPDOCCLITOT:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"

   ENDIF

   IF .F. .AND. Empty(oTIPDOCCLITOT:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oTIPDOCCLITOT:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","TIPDOCCLITOT")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","TIPDOCCLITOT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oTIPDOCCLITOT:oBrw,"TIPDOCCLITOT",oTIPDOCCLITOT:cSql,oTIPDOCCLITOT:nPeriodo,oTIPDOCCLITOT:dDesde,oTIPDOCCLITOT:dHasta,oTIPDOCCLITOT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oTIPDOCCLITOT:oBtnRun:=oBtn



       oTIPDOCCLITOT:oBrw:bLDblClick:={||EVAL(oTIPDOCCLITOT:oBtnRun:bAction) }


   ENDIF




IF oTIPDOCCLITOT:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oTIPDOCCLITOT");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oTIPDOCCLITOT:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oTIPDOCCLITOT:lBtnColor

     oTIPDOCCLITOT:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT,oTIPDOCCLITOT:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oTIPDOCCLITOT,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oTIPDOCCLITOT,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oTIPDOCCLITOT:oBtnColor:=oBtn

ENDIF

IF oTIPDOCCLITOT:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:oFrm)
ENDIF

IF oTIPDOCCLITOT:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oTIPDOCCLITOT),;
                  EJECUTAR("DPBRWMENURUN",oTIPDOCCLITOT,oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cBrwCod,oTIPDOCCLITOT:cTitle,oTIPDOCCLITOT:aHead));
          WHEN !Empty(oTIPDOCCLITOT:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oTIPDOCCLITOT:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oTIPDOCCLITOT:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oTIPDOCCLITOT:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT);
          ACTION EJECUTAR("BRWSETFILTER",oTIPDOCCLITOT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oTIPDOCCLITOT:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oTIPDOCCLITOT:oBrw);
          WHEN LEN(oTIPDOCCLITOT:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oTIPDOCCLITOT:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oTIPDOCCLITOT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oTIPDOCCLITOT:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oTIPDOCCLITOT)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oTIPDOCCLITOT:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cTitle,oTIPDOCCLITOT:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oTIPDOCCLITOT:oBtnXls:=oBtn

ENDIF

IF oTIPDOCCLITOT:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oTIPDOCCLITOT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oTIPDOCCLITOT:oBrw,NIL,oTIPDOCCLITOT:cTitle,oTIPDOCCLITOT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oTIPDOCCLITOT:oBtnHtml:=oBtn

ENDIF


IF oTIPDOCCLITOT:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oTIPDOCCLITOT:oBrw))

   oBtn:cToolTip:="Previsualización"

   oTIPDOCCLITOT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRTIPDOCCLITOT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oTIPDOCCLITOT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oTIPDOCCLITOT:oBtnPrint:=oBtn

   ENDIF

IF oTIPDOCCLITOT:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oTIPDOCCLITOT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

  IF oTIPDOCCLITOT:lBtnZoom

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\ZOOM.BMP";
           TOP PROMPT "Zoom";
           ACTION IF(oTIPDOCCLITOT:oWnd:IsZoomed(),oTIPDOCCLITOT:oWnd:Restore(),oTIPDOCCLITOT:oWnd:Maximize())

    oBtn:cToolTip:="Maximizar"

 ENDIF





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oTIPDOCCLITOT:oBrw:GoTop(),oTIPDOCCLITOT:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oTIPDOCCLITOT:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oTIPDOCCLITOT:oBrw:PageDown(),oTIPDOCCLITOT:oBrw:Setfocus())

  ENDIF

  IF  oTIPDOCCLITOT:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oTIPDOCCLITOT:oBrw:PageUp(),oTIPDOCCLITOT:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oTIPDOCCLITOT:oBrw:GoBottom(),oTIPDOCCLITOT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oTIPDOCCLITOT:Close()

  oTIPDOCCLITOT:oBrw:SetColor(0,oTIPDOCCLITOT:nClrPane1)

  IF oDp:lBtnText
     oTIPDOCCLITOT:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oTIPDOCCLITOT:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oTIPDOCCLITOT:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oTIPDOCCLITOT:oBar:=oBar

  // nCol:=1494
  //nLin:=<NLIN> // 08
  // Controles se Inician luego del Ultimo Boton
  
  oBar:SetSize(NIL,100,NIL,.T.)
  nCol:=15
  nLin:=70

  // AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oTIPDOCCLITOT:oPeriodo  VAR oTIPDOCCLITOT:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oTIPDOCCLITOT:LEEFECHAS();
                WHEN oTIPDOCCLITOT:lWhen


  ComboIni(oTIPDOCCLITOT:oPeriodo )

  @ nLin, nCol+103 BUTTON oTIPDOCCLITOT:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oTIPDOCCLITOT:oPeriodo:nAt,oTIPDOCCLITOT:oDesde,oTIPDOCCLITOT:oHasta,-1),;
                         EVAL(oTIPDOCCLITOT:oBtn:bAction));
                WHEN oTIPDOCCLITOT:lWhen


  @ nLin, nCol+130 BUTTON oTIPDOCCLITOT:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oTIPDOCCLITOT:oPeriodo:nAt,oTIPDOCCLITOT:oDesde,oTIPDOCCLITOT:oHasta,+1),;
                         EVAL(oTIPDOCCLITOT:oBtn:bAction));
                WHEN oTIPDOCCLITOT:lWhen


  @ nLin, nCol+160 BMPGET oTIPDOCCLITOT:oDesde  VAR oTIPDOCCLITOT:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oTIPDOCCLITOT:oDesde ,oTIPDOCCLITOT:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oTIPDOCCLITOT:oPeriodo:nAt=LEN(oTIPDOCCLITOT:oPeriodo:aItems) .AND. oTIPDOCCLITOT:lWhen ;
                FONT oFont

   oTIPDOCCLITOT:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oTIPDOCCLITOT:oHasta  VAR oTIPDOCCLITOT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oTIPDOCCLITOT:oHasta,oTIPDOCCLITOT:dHasta);
                SIZE 76-2,24;
                WHEN oTIPDOCCLITOT:oPeriodo:nAt=LEN(oTIPDOCCLITOT:oPeriodo:aItems) .AND. oTIPDOCCLITOT:lWhen ;
                OF oBar;
                FONT oFont

   oTIPDOCCLITOT:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oTIPDOCCLITOT:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oTIPDOCCLITOT:oPeriodo:nAt=LEN(oTIPDOCCLITOT:oPeriodo:aItems);
               ACTION oTIPDOCCLITOT:HACERWHERE(oTIPDOCCLITOT:dDesde,oTIPDOCCLITOT:dHasta,oTIPDOCCLITOT:cWhere,.T.);
               WHEN oTIPDOCCLITOT:lWhen

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

  oRep:=REPORTE("BRTIPDOCCLITOT",cWhere)
  oRep:cSql  :=oTIPDOCCLITOT:cSql
  oRep:cTitle:=oTIPDOCCLITOT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oTIPDOCCLITOT:oPeriodo:nAt,cWhere

  oTIPDOCCLITOT:nPeriodo:=nPeriodo


  IF oTIPDOCCLITOT:oPeriodo:nAt=LEN(oTIPDOCCLITOT:oPeriodo:aItems)

     oTIPDOCCLITOT:oDesde:ForWhen(.T.)
     oTIPDOCCLITOT:oHasta:ForWhen(.T.)
     oTIPDOCCLITOT:oBtn  :ForWhen(.T.)

     DPFOCUS(oTIPDOCCLITOT:oDesde)

  ELSE

     oTIPDOCCLITOT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oTIPDOCCLITOT:oDesde:VarPut(oTIPDOCCLITOT:aFechas[1] , .T. )
     oTIPDOCCLITOT:oHasta:VarPut(oTIPDOCCLITOT:aFechas[2] , .T. )

     oTIPDOCCLITOT:dDesde:=oTIPDOCCLITOT:aFechas[1]
     oTIPDOCCLITOT:dHasta:=oTIPDOCCLITOT:aFechas[2]

     cWhere:=oTIPDOCCLITOT:HACERWHERE(oTIPDOCCLITOT:dDesde,oTIPDOCCLITOT:dHasta,oTIPDOCCLITOT:cWhere,.T.)

     oTIPDOCCLITOT:LEERDATA(cWhere,oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cServer,oTIPDOCCLITOT)

  ENDIF

  oTIPDOCCLITOT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:="",aLine:={}

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPTIPDOCCLITOT.TDT_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPTIPDOCCLITOT.TDT_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPTIPDOCCLITOT.TDT_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oTIPDOCCLITOT:cWhereQry)
       cWhere:=cWhere + oTIPDOCCLITOT:cWhereQry
     ENDIF

     oTIPDOCCLITOT:LEERDATA(cWhere,oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cServer,oTIPDOCCLITOT)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oTIPDOCCLITOT)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb,oTable
   LOCAL nAt,nRowSel
   LOCAL aLine:={},I,lResp:=.F.

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

   cSql:=" SELECT"+;
          " TDT_CODSUC,"+;
          " TDT_FECHA,"+;
          " TDT_SERFIS,"+;
          " TDT_TIPDOC,"+;
          " TDC_DESCRI,"+;
          " TDT_BASIMP,"+;
          " TDT_MTOIVA,"+;
          " TDT_MTOEXE,"+;
          " TDT_MTONET,"+;
          " TDT_CANTID,"+;
          " TDT_CANMOV,"+;
          " IF(TDT_BASIMP=RDF_BASIMP AND TDT_MTOIVA=RDF_MTOIVA AND  TDT_MTOEXE=RDF_MTOEXE AND TDT_MTONET=RDF_MTONET AND TDT_CANTID=RDF_CANDOC,1,0)   AS LOGICO,"+;
          " RDF_BASIMP,"+;
          " RDF_MTOIVA,"+;
          " RDF_MTOEXE,"+;
          " RDF_MTONET,"+;
          " RDF_CANDOC,"+;
          " 0 AS LOGICO2,"+;
          " 0 AS BASIMP,"+;
          " 0 AS MTOIVA,"+;
          " 0 AS MTOEXE,"+;
          " 0 AS MTONET,"+;
          " 0 AS CANDOC,"+;
          " 0 AS CANMOV,"+;
          " TDT_ENCRIP"+;
          " FROM DPTIPDOCCLITOT"+;
          " INNER JOIN DPTIPDOCCLI ON TDT_TIPDOC=TDC_TIPO"+;
          " LEFT  JOIN VIEW_DPDOCCLI_RDF ON TDT_CODSUC=RDF_CODSUC AND TDT_TIPDOC=RDF_TIPDOC AND TDT_FECHA=RDF_FECHA AND TDT_SERFIS=RDF_SERFIS               "+;
          " ORDER BY CONCAT(TDT_FECHA,TDT_TIPDOC) DESC "+;
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

   DPWRITE("TEMP\BRTIPDOCCLITOT.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF

   FOR I=1 TO LEN(aData)


      // Compara las el Totalizador con la Base de Datos
      lResp   :=(aData[I,06]==aData[I,13].AND. ;
                 aData[I,07]==aData[I,14] .AND. ;
                 aData[I,08]==aData[I,15] .AND. ;
                 aData[I,09]==aData[I,16] .AND. ;
                 aData[I,10]==aData[I,17])

      aData[I,12]:=lResp // Validación

      aLine   :=ENCRIPT(aData[I,25],.F.)
      aLine   :=_VECTOR(aLine,",")

      IF Empty(aLine)
         aLine:={0,0,0,0,0,0,0} // no tiene totalizador. aqui pasó algo.
      ENDIF


      aLine[1]:=CTOO(aLine[1],"N")
      aLine[2]:=CTOO(aLine[2],"N")
      aLine[3]:=CTOO(aLine[3],"N")
      aLine[4]:=CTOO(aLine[4],"N")
      aLine[5]:=CTOO(aLine[5],"N")
      aLine[6]:=CTOO(aLine[6],"N")
      aLine[7]:=CTOO(aLine[7],"N")

      aData[I,19]:=aLine[1]
      aData[I,20]:=aLine[2]
      aData[I,21]:=aLine[3]
      aData[I,22]:=aLine[4]
      aData[I,23]:=aLine[5]
      aData[I,24]:=aLine[6]

      // Compara Data Vs Encriptamiento

      lResp   :=(aData[I,19]==aData[I,13] .AND. ;
                 aData[I,20]==aData[I,14] .AND. ;
                 aData[I,21]==aData[I,15] .AND. ;
                 aData[I,22]==aData[I,16] .AND. ;
                 aData[I,23]==aData[5,17])

     aData[I,18]:=lResp // Data Vs Encriptamiento

   NEXT I

   AEVAL(aData,{|a,n| aData[n]:=ASIZE(aData[n],24)})

   IF ValType(oBrw)="O"

      oTIPDOCCLITOT:cSql   :=cSql
      oTIPDOCCLITOT:cWhere_:=cWhere

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
      AEVAL(oTIPDOCCLITOT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oTIPDOCCLITOT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRTIPDOCCLITOT.MEM",V_nPeriodo:=oTIPDOCCLITOT:nPeriodo
  LOCAL V_dDesde:=oTIPDOCCLITOT:dDesde
  LOCAL V_dHasta:=oTIPDOCCLITOT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oTIPDOCCLITOT)
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


    IF Type("oTIPDOCCLITOT")="O" .AND. oTIPDOCCLITOT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oTIPDOCCLITOT:cWhere_),oTIPDOCCLITOT:cWhere_,oTIPDOCCLITOT:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oTIPDOCCLITOT:LEERDATA(oTIPDOCCLITOT:cWhere_,oTIPDOCCLITOT:oBrw,oTIPDOCCLITOT:cServer,oTIPDOCCLITOT)
      oTIPDOCCLITOT:oWnd:Show()
      oTIPDOCCLITOT:oWnd:Restore()

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

   oTIPDOCCLITOT:aHead:=EJECUTAR("HTMLHEAD",oTIPDOCCLITOT)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oTIPDOCCLITOT)
RETURN .T.

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oTIPDOCCLITOT:oBrw:aArrayData[oTIPDOCCLITOT:oBrw:nArrayAt])
  LOCAL nAt    :=ASCAN(oTIPDOCCLITOT:oBrw:aArrayData,{|a,n| Empty(a[1])})

  IF nAt>0
     RETURN .F.
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  AADD(oTIPDOCCLITOT:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oTIPDOCCLITOT:oBrw,.F.)

  oTIPDOCCLITOT:oBrw:nColSel:=1
  oTIPDOCCLITOT:oBrw:GoBottom()
  oTIPDOCCLITOT:oBrw:Refresh(.F.)
  oTIPDOCCLITOT:oBrw:nArrayAt:=LEN(oTIPDOCCLITOT:oBrw:aArrayData)
  oTIPDOCCLITOT:aLineCopy    :=ACLONE(aLine)

  DPFOCUS(oTIPDOCCLITOT:oBrw)

RETURN .T.


/*
// Genera Correspondencia Masiva
*/


// EOF

