// Programa   : DPFACTURAV
// Fecha/Hora : 22/11/2004 23:10:42
// Propósito  : Factura de Venta
// Creado Por : Juan Navas
// Llamado por: Ventas y Cuentas por Cobrar
// Aplicación : VENTA
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc,cNumeroD,lView,cLetra,cCodSuc,cCenCos,cCodAlm,cCodCli,cDocOrg)
  LOCAL I,aData:={},oGrid,oCol,cSql,cScope,aMonedas:={},T1:=SECONDS(),cFile,cRif
  LOCAL cTitle:="",cExcluye:="", bEstado
  LOCAL oFont,oFontG,oFontB
  LOCAL oSayDesc,oSayRef
  LOCAL aExt      :={".EDT",".SCG",".BRW"}
  LOCAL cFileEdt,cFileScg,cFileBrw,cFile,cModSer:="",cFileEdtO
  LOCAL dFechaS   :=EJECUTAR("DPFECHASRV") // Necesario para DPINV/INV_FCHACT/GRIDPOST
  LOCAL lPesado   :=.T. // Depende de los permisos IF(ISFIELD("DPUNDMED","UND_VARIA"),COUNT("DPUNDMED","UND_VARIA=1")>0,.F.)
  LOCAL cImpFiscal:="",cSerie:="",lLibVta
  LOCAL cSerieF   :="",cInvLbx,lExiLbx:=.F. // Serie Según tipo de Documento
  LOCAL aCoors    :=GetCoors( GetDesktopWindow() ),nTotCol:=0,nWidth:=0,nPos
  LOCAL lMoneta   :=.F.,nAt,lIVA,cImpFis:="",cModFis:=""
  LOCAL oDefCol   :=NIL,oBtn
  LOCAL oData,nFontSize,lDivisa // 31/07/2023 Documento creado totalmente en Divisa
  LOCAL aDataPagos:={}


  IF !lPesado
     lPesado:=COUNT("DPINV","INV_REQPES"+GetWhere("=","S"))>0
  ENDIF

  DEFAULT cTipDoc    :="TIK",;
          lView      :=.F.,;
          oDp:cCodEdt:="",;
          cCodSuc    :=oDp:cSucursal,;
          cCodAlm    :=oDp:cAlmacen,;
          cLetra     :="",;
          cDocOrg    :="V" 

  cTipDoc:=ALLTRIM(cTipDoc)

  oData    :=DATASET("DPTIPDOCCLI","USER")
  nFontSize:=oData:Get(cTipDoc,IF(Empty(oDp:cModeVideo),12,15))  
  oData:End()

  // Puerto Serial Impresora
  oDp:cImpFisCom:=""
  oDp:cModSerFis:=""
 

  // EJECUTAR("DPSERIEFISCALLOAD")
  oDp:cImpFiscal:=""


  lPesado:=IF(!ValType(lPesado)="L",.F.,lPesado)

  IF Type("oDocCli")="O" .AND. oDocCli:oWnd:hWnd>0
      EJECUTAR("BRRUNNEW",oDocCli,GetScript())
      RETURN oDocCli
  ENDIF

  IF cTipDoc="ANT"
    RETURN EJECUTAR("DOCCLIANT",cCodSuc,cTipDoc,cNumeroD)
  ENDIF

  
  DEFAULT oDp:nInvLotes:=COUNT("DPINV","INV_METCOS"+GetWhere("=","L")+" OR INV_METCOS"+GetWhere("=","C"))

  EJECUTAR("INVGETUNDMED","",.T.)
  // EJECUTAR("SETIVAPE") // Variables del IVA, Pago Electrónico
  
  oDefCol:=EJECUTAR("DPTIPDOCCLICOLPAR",cTipDoc)

  IF Empty(oDp:aUndMed)
     EJECUTAR("DPUNDMEDCREA")
     oDp:aUndMed:=ATABLE("SELECT UND_CODIGO FROM DPUNDMED WHERE UND_ACTIVO=1")
  ENDIF

  IF Empty(oDp:aUndMed)
     MensajeErr("No hay Unidades de Medida, Necesario para el Cuerpo del Documento ")
     RETURN .F.
  ENDIF

  IF Empty(oDp:aMonedas)

     IF !Empty(oDp:cMoneda)
       SQLUPDATE("DPTABMON","MON_ACTIVO",.T.,"MON_CODIGO"+GetWhere("=",oDp:cMoneda))
     ENDIF

     MensajeErr("No hay Monedas definidas o Activas, Necesarias para documentos del cliente")
     DPLBX("DPTABMON.LBX")

     RETURN .F.

  ENDIF

  oDp:aVarL:={}

  lLibVta  :=SQLGET("DPTIPDOCCLI","TDC_LIBVTA,TDC_SERIEF,TDC_EXIVAL,TDC_LBXEXI,TDC_MONETA,TDC_IVA,TDC_MONEDA","TDC_TIPO"+GetWhere("=",cTipDoc))
  cSerieF  :=DPSQLROW(2,"")
  lExiLbx  :=DPSQLROW(4,.F.)
  lMoneta  :=DPSQLROW(5,.T.)
  lIVA     :=DPSQLROW(6,.T.)
  lDivisa  :=DPSQLROW(7,.F.)

  // ? lDivisa,CLPCOPY(oDp:cSql),cSerieF,"cSerieF"

  cTitle:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))

  IF (cTipDoc="TIK" .OR. cTipDoc="DEV") 
     lLibVta:=.T. // Necesario para activar la impresora fiscal
  ENDIF

  IF lLibVta .AND. "NINGUNO"$UPPER(cSerieF) .AND. !lView

     MsgMemo("Tipo de Documento "+cTipDoc+"="+cTitle+CRLF+;
             "está vinculado con el Libro de ventas."+CRLF+"Requiere su respectiva SERIE FISCAL")

     IF ISTABMOD("DPDOCCLI")
       EJECUTAR("DPTIPDOCCLI",3,cTipDoc)
       RETURN .F.
     ENDIF

  ENDIF

  IF !lView .AND. cTipDoc<>"PLA"
    aDataPagos:=EJECUTAR("DPFACTURAV_ADATAPAGO")
  ENDIF


  IF !lLibVta 
     cSerieF:=""
  ENDIF

  IF !oDp:nVersion>5.1 .OR. lIVA .OR. lLibVta
     lMoneta:=.T.
  ENDIF

  cInvLbx:=IF(lExiLbx,ALLTRIM(DPSQLROW(3,""),"")) // Si No necesita existencia va vacio
  cInvLbx:=IF(cInvLbx="F","FIS",cInvLbx)
  cInvLbx:=IF(cInvLbx="L","LOG",cInvLbx)
  cInvLbx:=IF(cInvLbx="C","CON",cInvLbx)

  IF !EJECUTAR("DPPRIVVTALEE",cTipDoc,.T.) // Lee los Privilegios del Usuario
     RETURN .F.
  ENDIF

  // Requiere Serie Fiscal
  IF cTipDoc="FAV" .OR. cTipDoc="FAM" .OR. cTipDoc="CRE" .OR. cTipDoc="DEB" .OR. cTipDoc="TIK" .OR. cTipDoc="DEV"
     lLibVta:=.T.
  ENDIF
 

  IF Empty(cLetra) .AND. lLibVta .AND. !lView
     cLetra:=SQLGET("dptipdocclinum","TDN_SERFIS","TDN_CODSUC"+GetWhere("=",cCodSuc)+" AND TDN_TIPDOC"+GetWhere("=",cTipDoc))
  ENDIF

  // Buscamos Letra segun tipo de Documento 12/02/2025, busca factura digital o formato autorizado para este PC

  IF Empty(cLetra) .AND. lLibVta .AND. !lView

      cLetra:=SQLGET("DPTABXUSU","SFI_LETRA",[ INNER JOIN DPSERIEFISCAL ON TXU_CODIGO=SFI_LETRA AND SFI_ACTIVO=1 ]+;
                                             [ WHERE TXU_REFERE='SERIEFISCAL' AND TXU_PERMIS=1 AND TXU_PC]+GetWhere("=",oDp:cPcName))

  ENDIF

  IF !Empty(cLetra) .AND. lLibVta .AND. !lView

     IF cLetra<"00" .OR. cLetra>"99"
        EJECUTAR("RUNPDF","Series_Fiscales_para_Documentos_del_Cliente.pdf")
        // EJECUTAR("WEBRUN","https://adaptaproerp.com/series-fiscales/",.f.)
        MsgMemo("Serie Fiscal ["+cLetra+"] Inválida para realizar documentos fiscales","Ejecute la Implementación de la Serie Fiscal")
        DPLBX("DPSERIEFISCAL.LBX")
        RETURN NIL
     ENDIF

     cSerieF        :=SQLGET("DPSERIEFISCAL","SFI_MODELO,SFI_IMPFIS,SFI_PUERTO,SFI_PAGADO,SFI_ACTIVO","SFI_LETRA"+GetWhere("=",cLetra)+" AND SFI_ACTIVO=1")
     oDp:cModSerFis :=cSerieF // Modelo Serie Fiscal
     cImpFiscal     :=ALLTRIM(UPPER(DPSQLROW(2,"")))
     oDp:cImpFisCom :=ALLTRIM(UPPER(DPSQLROW(3,"")))
     oDp:lImpFisPago:=DPSQLROW(4,.F.) // Imprimir si esta pagado
     oDp:lSerActivo :=DPSQLROW(5,.F.)
 
     IF !oDp:lSerActivo
        EJECUTAR("RUNPDF","Series_Fiscales_para_Documentos_del_Cliente.pdf")
        MsgMemo("Serie Fiscal "+cLetra+" "+ALLTRIM(oDp:cModSerFis)+" "+oDp:cImpFisCom+" no está Activa","Por favor modificar el registre de Serie fiscal")
        oDp:oFrm:=EJECUTAR("DPSERIEFISCAL",3,cLetra)
        oDp:oFrm:oSFI_ACTIVO:VarPut(.T.,.T.)
        RETURN NIL
     ENDIF

     IF "NINGU"$UPPER(cImpFiscal)
        cImpFiscal:=""
     ENDIF

     cModSer    :=cImpFiscal // cSerie

     IF !("-NOFISCAL"$oDp:cImpFisCom)
       //  .OR. "DIG"$cImpFiscal 
       EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",cLetra))
     ENDIF

  ENDIF

  IF Empty(cLetra) .AND. ISDOCFISCAL(cTipDoc)
     MsgMemo("Documento Fiscal "+cTipDoc+" Requiere Asociación con Serie fiscal")
     DPLBX("DPTIPDOCCLI.LBX",NIL,"TDC_TIPO"+GetWhere("=",cTipDoc))
     RETURN NIL
  ENDIF

  IF !Empty(cModSer)

     cModSer:=ALLTRIM(cModSer)

     IF "_FISCAL"$cImpFiscal
       cTitle :=cTitle+" [ Serie "+cLetra+"="+ALLTRIM(oDp:cModSerFis)+" Medio="+cImpFiscal+" Puerto:"+oDp:cImpFisCom+" ]"
     ELSE
       cTitle :=cTitle+" [ Serie "+cLetra+"="+ALLTRIM(oDp:cModSerFis)+" Medio="+cImpFiscal+"]"
     ENDIF

  ELSE

    IF Empty(cModSer) .AND. lLibVta

     cTitle :=cTitle+" Serie Fiscal ["+cLetra+":"+ALLTRIM(oDp:cModSerFis)+" ]"

    ELSE

     IF !Empty(cSerieF) .AND. !Empty(cLetra)
        cTitle :=cTitle+" [ Serie="+ALLTRIM(cSerieF)+" - "+cLetra+" ]"
     ENDIF

   ENDIF

 ENDIF

  // AG20080401
  oDp:dFchIniDoc:=CTOD(SPACE(8))
  oDp:dFchFinDoc:=CTOD(SPACE(8))

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, nFontSize
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, nFontSize BOLD

  IF !ISDPSTD()

    cFileScg :="FORMS\DPDOCCLI_"+cTipDoc+aExt[2]
    cFileBrw :="FORMS\DPDOCCLI_"+cTipDoc+aExt[3]
    cFileEdt :="FORMS\DPDOCCLI_"+cTipDoc+oDp:cModeVideo+aExt[1]
    cFileEdtO:="FORMS\DPDOCCLI_FAV2"+aExt[1]

    IF !FILE(cFileScg)
       COPY FILE ("FORMS\DPDOCCLI_FAV.SCG") TO (cFileScg)
    ENDIF

    IF !FILE(cFileBrw)
       COPY FILE ("FORMS\DPDOCCLI_FAV.BRW") TO (cFileBrw)
    ENDIF


    FOR I=1 TO LEN(aExt)

      cFile:="FORMS\DPDOCCLI_"+cTipDoc+oDp:cModeVideo+aExt[I]

      IF !cTipDoc="FAV" .AND. lMoneta
       //  FERASE(cFile)
      ENDIF

      IF !FILE(cFile) .AND. cTipDoc<>"FAV"
        COPY FILE ("FORMS\DPDOCCLI_FAV"+oDp:cModeVideo+aExt[I]) TO (cFile)
      ENDIF

    NEXT I

    //IF FILE(cFileEdtO) .AND. cTipDoc<>"FAV"
    IF .T. .AND. cTipDoc<>"FAV" .AND. cTipDoc<>"PLA"
	  COPY FILE (cFileEdtO) TO (cFileEdt)
    ENDIF


  ELSE

    cFileEdt:="FORMS\DPDOCCLI_"+cTipDoc+oDp:cModeVideo+aExt[1]
    cFileScg:="FORMS\DPDOCCLI_"+cTipDoc+aExt[2]
    cFileBrw:="FORMS\DPDOCCLI_"+cTipDoc+aExt[3]

    IF !ISFILESTD(cFileEdt,.T.)
       cFileEdt:="FORMS\DPDOCCLI_FAV"+aExt[1]
       cFileScg:="FORMS\DPDOCCLI_FAV"+aExt[2]
       cFileBrw:="FORMS\DPDOCCLI_FAV"+aExt[3]
    ENDIF

    IF !ISFILESTD(cFileEdt,.T.)
       MensajeErr("No existe Componente "+cFileEdt)
       RETURN .F.
    ENDIF

  ENDIF

  IF !Empty(cCenCos)
    cTitle:=cTitle+" ["+oDp:XDPCENCOS+": "+GetWhere("",cCenCos)+" "+ALLTRIM(SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",cCenCos)))+" ]"
  ENDIF

  DOCENC(cTitle,"oDocCli",cFileEdt)

  cScope:="DOC_CODSUC"+GetWhere("=",cCodSuc      )+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
          "DOC_TIPTRA"+GetWhere("=","D"          )+" AND "+;
          "DOC_DOCORG"+GetWhere("=",cDocOrg      )

  IF !Empty(cCodCli)
     cScope:=cScope+" AND DOC_CODIGO"+GetWhere("=",cCodCli)
  ENDIF

  IF !Empty(cCenCos)
    cScope:=cScope+" AND DOC_CENCOS"+GetWhere("=",cCenCos)
  ENDIF

  IF !Empty(cNumeroD)
    cScope:=cScope+" AND DOC_NUMERO"+GetWhere("=",cNumeroD)
  ENDIF

  IF !Empty(cNumeroD) .AND. lView
    oDocCli:lMod:=.F.
    oDocCli:lInc:=.F.
    oDocCli:lEli:=.F.
  ENDIF

  // oDocCli:SETSCRIPT("DPFACTURAV")
  oDocCli:cTitle_:=cTitle
  oDocCli:lBar:=.T.
  oDocCli:SetScope(cScope)
  oDocCli:cScopeOrg    :=cScope // Necesario para Desfiltrar los documentos
  oDocCli:cScopeFind   :=cScope
  oDocCli:lLibVta      :=lLibVta
  oDocCli:cModFis      :=cImpFiscal  // Debe obtenerlo de la Serie Fiscal
  oDocCli:lImpFisModVal:=oDp:lImpFisModVal
  oDocCli:cPicture     :="999,999,999.99" // Muestra Existencia en VTAGRIDEXISTE
  oDocCli:nEpson       :=IF("EPSON"$oDocCli:cModFis,1,0) // JN 30/06/2020
  oDocCli:lUbicaFis    :=COUNT("dpinvubifisica")>0
  oDocCli:oScroll      :=NIL
  oDocCli:cDesFij      :=""
  oDocCli:oBrwPag      :=NIL
 
  oDocCli:nBtnWidth   :=oDp:nBtnWidth  +2 // 10
  oDocCli:nBtnHeight  :=oDp:nBarnHeight-9
  oDocCli:lBtnText    :=.T. // oDp:lBtnText
  oDocCli:lPagosFolder:=.T. // Pagos en el folder

  oDocCli:ADD("DOC_NUMGTR","")

  oDocCli:SetTable("DPDOCCLI","DOC_NUMERO",cScope, NIL, NIL,NIL,"DOC_NUMERO")

  oDocCli:cWhereRecord:=cScope
  oDocCli:aDataGrid  :={}
  oDocCli:lDivisaVer :=.F.
  oDocCli:nLenVen    :=LEN(ALLTRIM(SQLGETMAX("DPVENDEDOR","VEN_CODIGO")))
  oDocCli:cNomDoc    :=ALLTRIM(cTitle)
  oDocCli:nPar_CxC   :=0
  oDocCli:cValCodCli :=""
  oDocCli:aPrecios   :={}
  oDocCli:lPar_IVA   :=.T.
  oDocCli:lPar_Condic:=.T.
  oDocCli:DOC_FACAFE :=""
  oDocCli:DOC_ORIGEN :="V"
  oDocCli:cTerceros  :="N" // NO requiere Terceros
  oDocCli:lSelCodSuc :=.F. // Seleccionar Codigo Sucursal
  oDocCli:lImportAut :=.F.
  oDocCli:lIsProdAutm:=.T. // Indica si Tiene Productos Automáticos
  oDocCli:cNumTar    :=""  // Número de Tarea Automática
  oDocCli:lDpEquiv   :=(COUNT("DPEQUIV","WHERE 1=1 LIMIT 1")>0)  // Indica si tiene Equivalente para Agregar Barra
  oDocCli:cTipDoc    :=cTipDoc   // SYSANDES
  oDocCli:lValCodCli :=.F. // Activa los demas controles luego que sea Validado el Cliente
  oDocCli:cWhereCli  :="1=1" // LEFT(CLI_SITUAC,1)='A' OR LEFT(CLI_SITUAC,1)='C' OR LEFT(CLI_SITUAC,1)='P'"
  oDocCli:dFechaS    :=dFechaS
  oDocCli:cSerie     :=cSerie     // SQLGET("DPSERIEFISCAL","SFI_MODELO,SFI_SERIMP","SFI_LETRA"+GetWhere("=",cLetra))
  oDocCli:cImpFiscal :=cImpFiscal
  oDocCli:lImpFiscal :=!Empty(oDocCli:cImpFiscal) .AND. !("NINGUN"$UPPER(oDocCli:cImpFiscal))
  oDocCli:lPELock    :=.F.
  oDocCli:cInvLbx    :=cInvLbx
  oDocCli:lExiLbx    :=lExiLbx
  oDocCli:lAutoSize  :=(aCoors[4]>1200)
  oDocCli:lMoneta    :=lMoneta
  oDocCli:oRecibo    :=NIL
  oDocCli:cCodSuc    :=cCodSuc
  oDocCli:cDescri    :=SPACE(120)
  oDocCli:cCodVen    :=""
  oDocCli:oCliNombre :=NIL
  oDocCli:oEstado    :=NIL
  oDocCli:oVenNombre :=NIL
  oDocCli:oDOC_CODMON:=NIL
  oDocCli:oDOC_CODIGO:=NIL
  oDocCli:oDOC_CODVEN:=NIL
  oDocCli:cRif       :=NIL
  oDocCli:cCenCos    :=cCenCos
  oDocCli:lGetCodSuc :=.F. // Editar Codigo del Vendedor del Cliente
  oDocCli:oDOC_VALCAM:=NIL // Valor Cambiario
  oDocCli:cCodAlm    :=cCodAlm
  oDocCli:cTipOrg    :="" // Tipo de Documento Original
  oDocCli:cNumOrg    :="" // Numero de Documento Original
  oDocCli:oDefCol    :=oDefCol
  oDocCli:cCodMon    :=oDp:cCodMon
  oDocCli:lVenta     :=.T.
  oDocCli:cCodCli    :=cCodCli
  oDocCli:cCodCli_   :=cCodCli
  oDocCli:cDocOrg    :=cDocOrg
  oDocCli:cWhereCliF :="" // Buscar Clientes desde el campo Código
  oDocCli:lDivisa    :=lDivisa  // 31/07/2023 Pedido totalmente en Divisa
  oDocCli:oCol_MOV_MTODIV:=NIL
  oDocCli:lBtnIncRun :=.F. // EJECUTADO Botón Incluir
  oDocCli:lPostGrabar:=.F.
  oDocCli:oDOC_NUMFIS:=NIL
  // 7/2/2025, optimiza DPDOCCLIPOSGRA, no necesita volver a leer DPTIPDOCCLI
  // oDocCli:lRunPrint  :=.F. // Esta en la Opción Imprimir, no se puede ejecutar dos Veces
  oDocCli:lExpTot      :=SQLGET("DPTIPDOCCLI","TDC_IMPTOT,TDC_DOCDES","TDC_TIPO"+GetWhere("=",cTipDoc))
  oDocCli:cDocDes      :=DPSQLROW(2)
  oDocCli:cDocDes      :=IF("NINGUN"$UPPER(oDocCli:cDocDes) .OR. oDocCli:cDocDes==cTipDoc ,"",cDocDes)
  oDocCli:lChkIntRef   :=.F.          // 27/2/25 no valida integridad referencial con condicion de pago vacio 27/02/2025
  oDocCli:cFieldUsuario:="DOC_USUARI" // 27/2/25 Necesario para el Disparador
  oDocCli:aDataPagos   :=ACLONE(aDataPagos)
  oDocCli:oBrwPag      :=NIL
  oDocCli:nMtoIGTF     :=0
  oDocCli:nTotal       :=0


  oDocCli:SETOTROSDATOS()

//  IF (ISRELEASE("19.07") .OR. oDp:nVersion>=6) // AutoAjuste
    oDocCli:lAutoSize:=.T.
//  ELSE
//    oDocCli:lAutoSize:=.F.
//  ENDIF

  IF !lMoneta
     oDocCli:lAutoSize:=.F.
  ENDIF

  oDocCli:cPicDoc    :=oDp:Get(cTipDoc+"PICTUR")
  oDocCli:cPicFis    :=oDp:Get(cTipDoc+"PICFIS")

  oDocCli:lValSerfiscal:=.F. // Valida si tiene Series Fiscales


  IF lView
    oDocCli:cPicDoc:=SQLGET("DPTIPDOCCLI","TDC_PICTUR,TDC_PICFIS","TDC_TIPO"+GetWhere("=",cTipDoc))
    oDocCli:cPicFis:=DPSQLROW(2,"")
  ENDIF

  // Agregar en Clausula Where Para Actualizar el Registro
  // Utiliza Indice: DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_TIPTRA                                    
  oDocCli:cScope_Update:="DOC_TIPTRA"+GetWhere("=","D"    )+" AND "+;
                         "DOC_DOCORG"+GetWhere("=",cDocOrg)


//oDocCli:lPar_AutoImp_:=oDocCli:lPar_AutoImp

  oDocCli:CCG_RIF   :=""   // 25-08-2008 Marlon Ramos Evitar Error: "CCG_RIF sin declaraci¥n" en DPDOCNUMFIS cuando se usa una serie fiscal
  oDocCli:CCG_NOMBRE:=""   // 25-08-2008 Marlon Ramos Evitar Error: "CCG_NOMBRE sin declaraci¥n" en DPDOCNUMFIS cuando se usa una serie fiscal
  oDocCli:DOC_NUMACT:=""

  oDocCli:cNumeroD  :=""
  oDocCli:cLetra    :=cLetra
  oDocCli:cNumFis   :=""
  oDocCli:cFileEdt  :=cFileEdt
  oDocCli:cFileScg  :=cFileScg
  oDocCli:cFileBrw  :=cFileBrw

  STORE "" TO oDocCli:CCG_DIR1,oDocCli:CCG_DIR2,oDocCli:CCG_TEL1

  oDocCli:DOC_DESTIN :="N"

  oDocCli:nClrEstado:=0 // Color Estado
  oDocCli:bEstado   := {|oEstado|EJECUTAR("DPDOCCLIEDO",oDocCli:DOC_CODSUC,oDocCli:cTipDoc,;
                                          oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO,;
                                          NIL,oDocCli:DOC_CXC,oDocCli:DOC_NETO,oDocCli)}
 

  oDocCli:cVeces := 0    // 18-10-2008 Marlon Ramos

  EJECUTAR("DPDOCCLIPAR",oDocCli,cTipDoc)

  oDocCli:cConfirma    :=""

  IF ISDOCFISCAL(cTipDoc)
     oDocCli:lPar_EditNum:=.F. // no puede modificar numero del documento
     oDocCli:lPar_Fecha  :=.F. // no puede modificar la fecha
     oDocCli:cConfirma:="CONFORME"
  ENDIF

  oDocCli:lLimite     :=.F.  // Documento con Limites
  oDocCli:lPagEle     :=.F.  // Pago en formas electrónica
  oDocCli:nLimite     :=0    // Limite del Monto
  oDocCli:cTipPer     :="N"  // Personas Naturales
  oDocCli:nIvaGN      :=0    // Iva Aplicado
  oDocCli:cTitleCli   :=nil  // Titulo Ventana de Clientes
  oDocCli:lParAutoImp :=oDocCli:lPar_AutoImp // AutoImpresión de Factura
  oDocCli:dDesdeLim   :=CTOD("")
  oDocCli:dHastaLim   :=CTOD("")
  oDocCli:cTipIvaLim  :=""
  oDocCli:DOC_MTOBRU  :=0 // Calculado en DOCTOTAL Y Necesario para el IVA rebaj
  oDocCli:DOC_BAS_GN  :=0 // Monto para Determinar el IVA de Rebaja
  oDocCli:cTitleIni   :=oDocCli:cTitle
  oDocCli:cFieldAud   :="DOC_REGAUD"
  oDocCli:cDescri     :=SPACE(200)
  oDocCli:oScroll     :=NIL
  oDocCli:aVarL       :=ACLONE(oDp:aVarL)
 
  // Crea en las Variables Logicas
  //AEVAL(oDocCli:aVarL,{|a,n| oDocCli:Set("l"+a[1],a[4])}) // 13/06/2022
  AEVAL(oDocCli:aVarL,{|a,n| oDocCli:Set("l"+a[1],a[2])})

// oDocCli:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_TIPTRA,DOC_SERFIS" 
  oDocCli:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_TIPTRA"  // ,DOC_SERFIS=programa DOCFIND, no lo encuentra

// oDocCli:lMsgBar :=.F.
//  oDocCli:nBtnWidth:=42
  oDocCli:cBtnList :="xbrowse2.bmp"

  IF ISRELEASE("18.11")


    IF oDp:Get(cTipDoc+"CXC")<>0
      oDocCli:BtnSetMnu("BROWSE","Pendientes de Pago"   ,"BRWXPAG")  // Por Pago
      oDocCli:BtnSetMnu("BROWSE","Pagadas"              ,"BRWPAGD")  // Pagadas
    ELSE
      oDocCli:BtnSetMnu("BROWSE","Registros Activo"     ,"BRWXPAG")  // Activos
    ENDIF

    oDocCli:BtnSetMnu("BROWSE","Sin Anulados"         ,"BRWXNOA")  // No Anuladas

    oDocCli:BtnSetMnu("BROWSE","Anuladas"             ,"BRWANUL")  // Anuladas
    oDocCli:BtnSetMnu("BROWSE","Agrupado Por Cliente" ,"BRWXCLI")  // Por Cliente
    oDocCli:BtnSetMnu("BROWSE","Agrupado Por Vendedor","BRWXVEN")  // Por Vendedor
    oDocCli:BtnSetMnu("BROWSE","Agrupado Por Lote"    ,"BRWXLOT")  // Por Lotes
    oDocCli:BtnSetMnu("BROWSE","Agrupado Por Producto","BRWXINV")  // Por Lotes

    IF oDocCli:cTipDoc="FAV"
      oDocCli:BtnSetMnu("BROWSE","Ventas Anticipadas"   ,"BRWVTAA")  // Ventas Anticipadas
    ENDIF

    IF oDocCli:cTipDoc="FAV" .OR. oDocCli:cTipDoc="TIK" .OR. oDocCli:cTipDoc="DEV" .OR. oDocCli:cTipDoc="CRE"
      oDocCli:BtnSetMnu("BROWSE","Detalles de Documentos"   ,"BRTICKETPOS")  // Ventas Anticipadas
    ENDIF

    oDocCli:BtnSetMnu("BROWSE","Liberar Filtros"      ,"BRWXLIB")  // Liberar Filtro

  ENDIF

  IF oDocCli:lAutoSize

//  aCoors[4]:=MIN(aCoors[4],1560+100-10)
//  oDocCli:Windows(0,0,625,aCoors[4]-10)

    oDocCli:Windows(0,0,625,aCoors[4]-10)

  ELSE

    IF cTipDoc="PLA" .OR. !oDocCli:lMoneta
      oDocCli:Windows(0,0,625,860)
    ELSE
       oDocCli:Windows(0,0,625,1010)
    ENDIF

  ENDIF

  cScope:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
          "DOC_TIPTRA"+GetWhere("=","D")

  // Obtiene Numero de Documento Cuando No es Impresora Epson
  // 05/02/2023
  // Numero Impresora Epson debe guardarlo cuando imprime
  // IF oDocCli:nEpson=0
  //   oDocCli:SetIncremental("DOC_NUMERO",cScope,oDp:Get(cTipDoc+"NUMERO"))
  // ENDIF

  // 06/07/2024 innecesario, lo utiliza DOCNUMFIS
  //  oDocCli:SetIncremental("DOC_NUMERO",cScope,oDp:Get(cTipDoc+"NUMERO"))  

  oDocCli:SetMemo("DOC_NUMMEM","Memo ->Descripción Amplia")
  oDocCli:SetAdjuntos("DOC_FILMAI") // Vinculo con DPFILEEMP

  AEVAL(oDp:aVarL,{|a,n| oDocCli:Add("l"+a[1],.t.)})

  nAt:=ASCAN(oDp:aVarL,{|a,n| UPPER(a[1])="CREACLI"})

  IF oDp:Get(cTipDoc+"LCreaCli") .AND. !cTipDoc="PLA"

    oDocCli:AddBtnEdit("CLIENTE.BMP","Crear Cliente","(oDocCli:nOption=1 .OR. oDocCli:nOption=3 )",;
                               "EJECUTAR('DPCREACLI',oDocCli:oDOC_CODIGO)","OTHER")

    oDocCli:AddBtnEdit("RETIVA.BMP","Validar RIF","(oDocCli:nOption=1 .OR. oDocCli:nOption=3 )","oDocCli:VALRIF()","OTHER")

    oDocCli:AddBtnEdit("XEDIT.BMP","Nombre","(oDocCli:nOption=1 .OR. oDocCli:nOption=3 )","oDocCli:VALNOMBRE()","OTHER")


  ENDIF

  IF !(cTipDoc="PLA" .OR. !oDocCli:lMoneta)

    oDocCli:AddBtnEdit("xpeople2.bmp","Cliente Genérico","(oDocCli:nOption=1 .OR. oDocCli:nOption=3) .AND. oDocCli:DOC_CODIGO=STRZERO(0,10)",;
                                       "EJECUTAR('DPCLIENTESCERO',oDocCli,oDocCli:oDoc_CODIGO)","CLI")
  ELSE


    oDocCli:AddBtn("RUN.bmp","Crear Documento (Ctrl-P)","(oDocCli:nOption=0)",;
                   "oDocCli:CREARPLANTILLA()","CLI",,STR(DP_CTRL_P))

  ENDIF

  oDocCli:lPELock:=.F. // Bloque el Botón en las Devoluciones Importadas
  oDocCli:lPagEle:=.F.

  EJECUTAR("DPFACTURAV10IVA",oDocCli)

  IF lMoneta

  oDocCli:AddBtn("xexpediente.bmp","Gestión ->Expedientes (Ctrl-A)","(oDocCli:nOption=0)",;
                 "EJECUTAR('DPDOCCLIEXP',NIL,oDocCli:DOC_CODSUC,;
                                             oDocCli:DOC_TIPDOC,;
                                             oDocCli:DOC_CODIGO,;
                                             oDocCli:DOC_NUMERO,;
                                             'Expedientes'+oDocCli:cTitle)","CLI",,STR(DP_CTRL_A))
 
  oDocCli:AddBtn("favoritos.bmp","Agregar como Favorito (Ctrl-F)","(oDocCli:nOption=0)",;
                   "EJECUTAR('DPDOCCLIFAV',oDocCli:cTitle    ,;
                                           oDocCli:DOC_CODSUC,;
                                           oDocCli:DOC_TIPDOC,;
                                           oDocCli:DOC_CODIGO,;
                                           oDocCli:DOC_NUMERO,;
                                           oDocCli:cNomDoc   ,;
                                           oDocCli:oWnd      )","CLI",,STR(DP_CTRL_F))

/*
  oDocCli:AddBtn("divisas.bmp","Ver factura en Divisa","(oDocCli:nOption=0) ",;
                                     "oDocCli:ENDIVISA()","CLI")
*/

  oDocCli:AddBtn("MENU.bmp","Menú de Opciones (Ctrl-O)","(oDocCli:nOption=0)",;
                    "EJECUTAR('DPDOCCLIMNU',oDocCli:DOC_CODSUC ,;
                                            oDocCli:DOC_NUMERO ,;
                                            oDocCli:DOC_CODIGO ,;
                                            oDocCli:cNomDoc , oDocCli:DOC_TIPDOC , oDocCli,NIL,NIL,NIL,oDocCli:DOC_SERFIS )","CLI",,STR(DP_CTRL_O))

ENDIF

  IF !ValType(oDp:Get(cTipDoc+"RETISR"))="L"
    oDp:Set(cTipDoc+"RETISR",.F.)
  ENDIF

  IF !ValType(oDp:Get(cTipDoc+"RETIVA"))="L"
    oDp:Set(cTipDoc+"RETIVA",.F.)
  ENDIF

//?  oDp:Get(cTipDoc+"RETISR"),[oDp:Get(cTipDoc+"RETISR")]

  IF oDp:Get(cTipDoc+"RETISR")

    oDocCli:AddBtn("RETISLR.bmp","ISLR Retención ISLR","(oDocCli:nOption=0)",;
                   "EJECUTAR('DPDOCISLR',oDocCli:DOC_CODSUC,;
                                         oDocCli:DOC_TIPDOC,;
                                         oDocCli:DOC_CODIGO,;
                                         oDocCli:DOC_NUMERO,;
                                         oDocCli:cNomDoc   ,'V',;
                                         oDocCli:DOC_NETO)","CLI")
  ENDIF

  IF oDp:Get(cTipDoc+"RETIVA")

    oDocCli:AddBtn("RETIVA.bmp","RET-IVA Retención de IVA","(oDocCli:nOption=0)",;
                    "EJECUTAR('DPDOCCLIRTI' ,oDocCli:DOC_CODSUC,;
                                             oDocCli:DOC_TIPDOC,;
                                             oDocCli:DOC_CODIGO,;
                                             oDocCli:DOC_NUMERO,;
                                             oDocCli:cNomDoc     )","CLI")
  ENDIF

 
  IF oDocCli:lPar_REQDIG .AND. oDp:nVersion>=5

    oDocCli:AddBtn("ADJUNTAR.BMP","Adjunto -Digitalización","(oDocCli:nOption=0)",;
                   "EJECUTAR([DPDOCCLIDIG],oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO,.F.)","CLI")

  ENDIF

  IF !cTipDoc="PLA" .AND. .F.

    oDocCli:AddBtn("EMAIL.BMP","Enviar en Formato HTML por Correo","(oDocCli:nOption=0)",;
                   "oDocCli:DOCCLIMAIL(.F.)","CLI")

  ENDIF


/*
  IF oDp:nVersion>=5.1 .AND. ISRELEASE("16.08")

    oDocCli:AddBtn("PDF.BMP","Enviar en Formato PDF por Correo","(oDocCli:nOption=0)",;
                   "oDocCli:PRINTER_PDF(.T.)","CLI")

  ENDIF
*/

  oDocCli:lPagos:=.F.

  IF oDp:Get(cTipDoc+"PAGOS") 

     IF oDp:Get(cTipDoc+"CXC")<>0

/*
    oDocCli:AddBtn("RECPAGO.bmp","Recibo ->Recepción de Pagos (Ctrl-R)","(oDocCli:nOption=0)",;
                         "EJECUTAR('DPDOCCLIMNU',oDocCli:DOC_CODSUC ,;
                                                 oDocCli:DOC_NUMERO ,;
                                                 oDocCli:DOC_CODIGO ,;
                                                 oDocCli:cNomDoc , oDocCli:DOC_TIPDOC , oDocCli ,'RECIBO' )","CLI",,STR(DP_CTRL_O))
*/
      oDocCli:AddBtn("RECPAGO.bmp","Recibo ->Recepción de Pagos (Ctrl-R)","(oDocCli:nOption=0)",;
                     "oDocCli:RECIBO()","CLI",,STR(DP_CTRL_O))

    ELSE

      oDocCli:AddBtn("RECPAGO.bmp","Anticipo ->Recepción de Pagos (Ctrl-R)","(oDocCli:nOption=0)",;
                      "oDocCli:RECIBO()","CLI",,STR(DP_CTRL_O))


    ENDIF

    oDocCli:lPagos:=.T.

  ENDIF


/*
// Revisar si está actualizado, para no mostrar boton de contabilizar.
   cActual:=EJECUTAR("DPDOCVIEWCON",oForm:DOC_CODSUC,oForm:DOC_TIPDOC,oForm:DOC_CODIGO,oForm:DOC_NUMERO,"D",.T.,.F.)
*/

  IF oDp:Get(cTipDoc+"CXC")<>0

    oDocCli:AddBtn("CONTABILIDAD.bmp","Asientos ->Contabilizar","(oDocCli:nOption=0)",;
                   "EJECUTAR('DPDOCCLICONTAB',oDocCli)","CLI")


  ENDIF

  IF !ISDOCFISCAL(cTipDoc)

    oDocCli:AddBtn("paste.bmp","Replicar Documento (Ctrl-R)","(oDocCli:nOption=0)",;
                   "EJECUTAR('DPDOCCLIREPLIFRM',oDocCli:DOC_CODSUC,;
                                                oDocCli:DOC_TIPDOC,;
                                                oDocCli:DOC_CODIGO,;
                                                oDocCli:DOC_NUMERO,;
                                                oDocCli)","RPL",,STR(DP_CTRL_R))
  ENDIF

  oDocCli:cList:=NIL // AG20080401

  @ 14,0 SAYREF oDocCli:oSayNeto PROMPT IF(oDocCli:DOC_VALCAM<>1 .AND. !oDocCli:lDivisa,ALLTRIM(TRAN(ROUND(oDocCli:DOC_NETO/oDocCli:DOC_VALCAM,2),"99,999,999,999.99"))+"("+LEFT(oDocCli:DOC_CODMON,3)+")","")+" Neto" RIGHT SIZE 42,12 FONT oFontB RIGHT

  SayAction(oDocCli:oSayNeto,{||oDocCli:TOTALIZAR()})


  IF cTipDoc="PLA" .OR. !oDocCli:lMoneta

    EJECUTAR("DPFACTURAV_PLA",oDocCli)

  ELSE

    DPFACTURAV_HEAD()

    SETFOLDER( 2)

    oDocCli:oScroll:=oDocCli:SCROLLGET("DPDOCCLI",oDocCli:cFileScg,cExcluye)

    IF oDocCli:IsDef("oScroll")
     oDocCli:oScroll:SetEdit(.F.)
    ENDIF

    IIF(Empty(oDp:cModeVideo),oDocCli:oScroll:SetColSize(180,250,298),oDocCli:oScroll:SetColSize(230,290,320))

    oDocCli:oScroll:SetColorHead(CLR_BLACK,oDp:nLbxClrHeaderPane,oFontB)

    oDocCli:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 
    oDocCli:oScroll:SetColor(16773862 , CLR_BLACK , 2 , 16771538 , oFont ) 
    oDocCli:oScroll:SetColor(16773862 , CLR_GRAY  , 3 , 16771538 , oFont ) 

    EJECUTAR("DPFACTURAV_OTROS"   ,oDocCli)
    EJECUTAR("DPFACTURAV_TERCEROS",oDocCli)

    SETFOLDER( 0)

  ENDIF

  oDocCli:oNeto     :=NIL
  oDocCli:oDOCBASNET:=NIL
  oDocCli:oIVA      :=NIL
  oDocCli:oIVATEXT  :=NIL

  @ 00,50 SAY oDocCli:oProducto PROMPT SPACE(250)

  @ 12,50 SAY oDocCli:oNeto     PROMPT TRAN(oDocCli:DOC_NETO/IF(!oDocCli:lDivisaVer,1,oDocCli:DOC_VALCAM),"999,999,999,999,999,999.99") RIGHT

  @ 1,1 SAY oDocCli:oIVATEXT PROMPT "I.V.A."+IF(oDocCli:DOC_IVAREB>0,"-"+LSTR(oDocCli:DOC_IVAREB)+"%","")+"" RIGHT SIZE 42,12

//  @ 12,50 SAY oDocCli:oIVA PROMPT TRAN(oDocCli:nIva/IF(!oDocCli:lDivisaVer,1,oDocCli:DOC_VALCAM)  ,"999,999,999,999,999.99") RIGHT

  @ 12,50 SAY oDocCli:oIVA PROMPT TRAN(oDocCli:DOC_MTOIVA,"999,999,999,999,999.99") RIGHT

IF !cTipDoc="PLA"

  @ 14,1 SAY oDocCli:oBASIMPTEXT PROMPT "Bruto" RIGHT

  @ 14,50 SAY oDocCli:oDOCBASNET PROMPT TRAN((oDocCli:DOC_BASNET+oDocCli:DOC_MTOEXE)/IF(!oDocCli:lDivisaVer,1,oDocCli:DOC_VALCAM) ,"999,999,999,999,999.99") RIGHT

ELSE

  oDocCli:oNeto:Hide()
  oDocCli:oIVATEXT:Hide()
  oDocCli:oIVA:Hide()

ENDIF

 
  cSql:=" SELECT "+SELECTFROM("DPMOVINV",.F.)+;
        " ,IF(MOV_NUMMEM>0 AND MEM_DESCRI<>'',MEM_DESCRI,INV_DESCRI) AS INV_DESCRI, MOV_PRECIO-(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_MTODES,   "+;
        " MOV_PRECIO/DOC_VALCAM AS MOV_PREDIV,MOV_MTODIV,CRC_NOMBRE "+;
        " FROM DPMOVINV "+;
        " INNER JOIN DPDOCCLI      ON MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND MOV_DOCUME=DOC_NUMERO AND DOC_TIPTRA"+GetWhere("=","D")+;
        " LEFT  JOIN DPINV         ON MOV_CODIGO=INV_CODIGO "+;
        " LEFT  JOIN DPCLIENTESREC ON MOV_CODCTA=CRC_CODCLI AND MOV_LOTE=CRC_CODIGO "+;
        " LEFT  JOIN DPMEMO        ON MOV_NUMMEM=MEM_NUMERO "

//cScope:="MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND MOV_APLORG='V' AND MOV_INVACT=1 AND MOV_TIPO='I'"
// JN 15/09

  cScope:="MOV_APLORG='V' AND MOV_INVACT=1 AND MOV_TIPO='I'"

//  ? cSql,"cSql",cScope,"cScope"
//   cSql:=cSql+" GROUP BY MOV_ITEM "

  oGrid:=oDocCli:GridEdit( "DPMOVINV" ,"DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO" , "MOV_CODSUC,MOV_TIPDOC,MOV_DOCUME" , cSql , cScope ," GROUP BY MOV_ITEM ORDER BY MOV_ITEM " )

//  ? CLPCOPY(oDp:cSql)

  oGrid:cImport       :=0
  oGrid:cTipDoc       :=""
  oGrid:cNumDoc       :=""
  oGrid:nCxUnd        :="" // Necesario para las Und Med Variable
  oGrid:cPreReg       :="" // Requiere Precio Regulado
  oGrid:cCodBar       :="" // Código de Barra
  oGrid:cTipCom       :="" // Tipo de Componentes
  oGrid:nPrecio       :=0  // Precio
  oGrid:lImport       :=.F.
  oGrid:lPesado       :=lPesado // Indica si el Producto requiere Peso Variable
  oGrid:nPeso         :=0
  oGrid:cFieldAud     :="MOV_REGAUD" // Genera Auditoria de Registros Anulados o Modificados
  oGrid:lValExi       :=.T.
  oGrid:lHScroll      :=.T.
  oGrid:cFileEdit     :="MYFORMS\\DPDOCCLI_"+FileNoExt(cTipDoc+aExt[1])+".BRWG"
  oGrid:lReqPeso      :=.F.
  oGrid:cCodMon       :="" // Código de Moneda
  oGrid:nPeso         :=0  // Peso utilizado como unidad de medida
  oGrid:lUnd_Peso     :=.F.
  oGrid:cMedMul       :="" // 27/02/2023

  oGrid:lValExi    :=.T.
  oGrid:nCxUnd     :=0
  oGrid:lPesado    :=.F.
  oGrid:lUnd_Peso  :=.F.
  oGrid:MOV_PESO   :=0
  oGrid:nPeso      :=0


  IF oDefCol:MOV_PESO_ACTIVO
     oGrid:lPesado:=.T.
  ENDIF

  oGrid:cScript    :="DPFACTURAV"
//oGrid:aSize      := IIF(Empty(oDp:cModeVideo),{161,0,762,167},{177,4,890,230})
//oGrid:aSize      := {177,4,1130+50,330}
  oGrid:aSize      := {177+10,4,1024-30,330+10}

  IF oDocCli:lAutoSize
     oGrid:aSize      := {177+10,4,aCoors[4]-30,330-5} // Caso de OVECA NO VEN LOS TOTALES
  ENDIF

  IF oDocCli:cTipDoc="PLA"
     oGrid:aSize[1]:=100+20
     oGrid:aSize[3]:=900-100
     oGrid:aSize[4]:=oGrid:aSize[4]+20
  ENDIF

  oGrid:cCodBar    := "" // Codigo de Barra para DPCAPAPRECIOS

  oGrid:lTotal     :=.T.
  oGrid:aCodReco   :={}
  oGrid:aTallas    :={}
  oGrid:lComent    :=.F.
  oGrid:lMulti     :=.F. // si multiplica MOV_CXUND*MOV_CANTID*MOV_PRECIO (Caso Unidad de Medida Variable)
  oGrid:nMargin    :=65

  oGrid:nClrPane1   :=16775408
  oGrid:nClrPane2   :=16770764
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nClrTextH   :=0
//oGrid:nRecSelColor:=oDp:nGrid_ClrPaneH // 16763025 // 16763283
  oGrid:nRecSelColor:=oDp:nRecSelColor  // oDp:nLbxClrHeaderPane // 12578047 // 16763283

  oGrid:nIva        :=0        // Iva para los Precios
  oGrid:cTipIva     :=""
  oGrid:lTallas     :=.F.
  oGrid:cTallas     :=""
  oGrid:nExiste     :=0
  oGrid:nLotes      :=0 // Cantidad del Lote
  oGrid:nCostoLote  :=0 // Costo de Lotes
  oGrid:nPrecioLote :=0 // Precio del Lote
  oGrid:aComponentes:={}
  oGrid:lDcto       :=.F. // el ITEM es un descuento
  oGrid:lTransp     :=.F. // Transporte
  oGrid:oFont       :=oFont
  oGrid:oFontH      :=oFontB
  oGrid:bWhen       :="!EMPTY(oDocCli:DOC_CODIGO) .AND. !Empty(oDocCli:DOC_CODVEN) .AND. oDocCli:lValCodCli"
  oGrid:lPresave    :=.F.

  IF !lMoneta
    oGrid:bWhen       :=".T."
  ENDIF

  oGrid:bValid      :="!EMPTY(oDocCli:DOC_NUMERO) .AND. oGrid:lPresave"
  oGrid:cItem       :="MOV_ITEM"
  oGrid:cFieldAud   :="MOV_REGAUD" // Genera Auditoria de Registros Anulados o Modificados
  oGrid:cLoad       :="GRIDLOAD"
  oGrid:cPresave    :="GRIDPRESAVE"
  oGrid:cPostSave   :="GRIDPOSTSAVE"
  oGrid:cPreDelete  :="GRIDPREDELETE"
  oGrid:cPostDelete :="GRIDPOSTDELETE"
  oGrid:cIdMemo     :=oDp:cIdMemo
  oGrid:lBar        :=.F.

  // 27/04/2023
  oGrid:cPrimary    :=oGrid:cLinkGrid+","+oGrid:cItem
  oGrid:cKeyAudita  :=oGrid:cPrimary

  oGrid:SetMemo("MOV_NUMMEM","Descripción Amplia",1,1,100,200)

  IF oDp:nVersion>=5
    oGrid:SetAdjuntos("MOV_FILMAI")
  ENDIF

  oGrid:cUtiliz     :="" // Utilización del Producto
  oGrid:oItem       :=NIL
  oGrid:aUndMed     :={}
  oGrid:aEsquema    :={}

  oGrid:lInc:=oDoc:lIncItem
  oGrid:lCon:=oDoc:lConItem
  oGrid:lMod:=oDoc:lModItem
  oGrid:lEli:=oDoc:lEliItem

  oGrid:AddBtn("IMPORTAR.BMP","Importar (Ctrl-I)","oGrid:nOption=1",;
                [EJECUTAR("DPDOCCLIMNUIMP",oDocCli)],"IMP",STR(DP_CTRL_I))

  oGrid:AddBtn("GRUPOS2.BMP","Grupos (Ctrl-G)","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDGRUPOS"  ,oGrid)],"GRU",STR(DP_CTRL_G))

  oGrid:AddBtn("MARCA2.BMP","Marcas (Ctrl-K)","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDMARCAS"  ,oGrid)],"MAR",STR(DP_CTRL_T))

  oGrid:AddBtn("prestadordeservicios.bmp","Servicios (Ctrl-S)","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDSERVICIOS" ,oGrid)],"SER",STR(DP_CTRL_S))


  oGrid:AddBtn("XFIND2.BMP","Buscar (Ctrl-B)","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDBUSCAINV",oGrid)],"BUS",STR(DP_CTRL_B))

  oGrid:AddBtn("MEMO2.BMP","Agregar Comentario","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDADDMEMO",oGrid)],"BUS",STR(DP_CTRL_B))

  oGrid:AddBtn("COMPONENTE.BMP","Editar Componentes","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [EJECUTAR("GRIDEDITCOMP",oGrid)],"BUS",STR(DP_CTRL_B))

  oGrid:AddBtn("PRODUCTO2.BMP","Listar Productos con Lotes","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                [oGrid:BRLOTESDIS()],"LOT",NIL)

  IF COUNT("DPSUSTITUTOS")>0

     oGrid:AddBtn("SUSTITUTOS2.BMP","Sustitutos","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                  [oGrid:BRSUSTITUTOS()],"SUS",NIL)

  ENDIF


  IF oDp:lInvConsol .AND. !Empty(oDp:cWhereExi)
    oGrid:AddBtn("SUCURSAL.BMP","Existencia x "+GetFromVar("{oDp:xDPSUCURSAL}"),"oGrid:nOption=1 .OR. oGrid:nOption=3",;
                  [EJECUTAR("DPEXIXSUC",oGrid:MOV_CODIGO)],"SUC")
  ENDIF

  oGrid:AddBtn("centrodecosto2.bmp","Asignación de "+oDp:xDPCENCOS,"oGrid:nOption=1 .OR. oGrid:nOption=3",;
               "oDocCli:SETCENCOS()","CENCOS")

  IF !cTipDoc="PLA"

    oGrid:AddBtn("VENDEDORES2.BMP","Vendedor","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                  [oGrid:GRIDCODVEN()],"VEN")

    oGrid:AddBtn("DESCUENTO2.BMP","Descuentos","oGrid:nOption=1 .OR. oGrid:nOption=3 ",;
                 [EJECUTAR("DPDOCDESCITEM",oGrid,oGRID:MOV_CANTID*oGRID:MOV_PRECIO,oGrid:MOV_CDESC,!oGrid:nOption=0)],"OTR")

  ENDIF

  oGrid:cMetodo     :="P"
  oGrid:cAlmacen    :=""
  oGrid:cCadena     :=""
//oGrid:bChange     :='oDocCli:oProducto:SetText(oDocCli:cNameInv+": "+oGrid:INV_DESCRI)'
  oGrid:bChange     :='oDocCli:CHANGEGRID()'
  oGrid:nMaxDesc    :=0 // Descuento M ximo Seg£n Precios de Venta
  oGrid:cInvDescri  :=SPACE(40)
  oGrid:nCosto      :=0
  oGrid:lMulti      :=.F.
  oGrid:cExp        :=""
  oGrid:nHeaderLines:=2
  oGrid:nWidthTotal :=120+IIF(oDocCli:nPar_ItemDesc>0,0,12)

  oDp:oGrid        :=oGrid

  IF oDefCol:MOV_ITEM_ACTIVO
    oCol:=oGrid:AddCol("MOV_ITEM")
    oCol:cTitle   :="#"+CRLF+"Item"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=50
  ENDIF

  // Renglón Almacen
  IF oDocCli:lPar_Almace .AND.  oDocCli:lPar_DocAlm .AND. oDp:nAlmacen>1 .AND. oDefCol:MOV_CODALM_ACTIVO

    oCol:=oGrid:AddCol("MOV_CODALM")
    oCol:cTitle   :=oDefCol:MOV_CODALM_TITLE // "Cód"+CRLF+"Alm."
    oCol:bValid   :={||oGrid:VMOV_CODALM(oGrid:MOV_CODALM)}
    oCol:cMsgValid:="Almacén no Existe"
    oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),34,44)
    oCol:cListBox :="DPALMACEN.LBX"
    oCol:bRunOff  :={||EJECUTAR("DPALMACEN",2,oGrid:MOV_CODALM)}
    oCol:nEditType:=EDIT_GET_BUTTON
    oCol:cMemoRun :=oDefCol:MOV_CODALM_MEMOEJ

  ENDIF

  // Renglón Código
  oCol:=oGrid:AddCol("MOV_CODIGO")
  oCol:cTitle   :=oDefCol:MOV_CODIGO_TITLE // "Código"+CRLF+"Producto"
  oCol:bValid   :={||oGrid:cCadena:=oGrid:MOV_CODIGO,oGrid:VMOV_CODIGO(oGrid:MOV_CODIGO)}
  oCol:cMsgValid:="Producto no Existe"
  oCol:nWidth   :=120 //IIF(Empty(oDp:cModeVideo),110,140)
  oCol:cMemoRun :=oDefCol:MOV_CODIGO_MEMOEJ

// ? oDp:lAvicola,"oDp:lAvicola"



  IF oDocCli:lDpEquiv

    oCol:cListBox :="DPINVEQUIV.LBX"

  ELSE

    oCol:cListBox :="DPINV.LBX"

    IF !Empty(oDocCli:cInvLbx)
      oCol:cListBox :="DPINVEXI"+oDocCli:cInvLbx+".LBX"
    ENDIF

  ENDIF

  IF !Empty(oDoc:cPar_INVLBX)
     oCol:cListBox:=oDoc:cPar_INVLBX
  ENDIF
 
  

  oCol:cWhereListBox:="INV_ESTADO"+GetWhere("=","A")+" AND "+;
                      "(LEFT(INV_APLICA,1)"+GetWhere("=","V")+" OR LEFT(INV_APLICA,1)"+GetWhere("=","T")+")"+;
                      IIF(!Empty(oDoc:cWhereInv)," AND ","")+;
                      oDoc:cWhereInv

  oGrid:cWhereListInv:=oCol:cWhereListBox

  oCol:bPostEdit:='oGrid:ColCalc("INV_DESCRI")'
  oCol:bRunOff  :={||EJECUTAR("DPINV",0,oGrid:MOV_CODIGO)}
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:lItems   :=.T.
  oCol:bWhen    :=".T."
  oCol:cMemoRun :=oDefCol:INV_DESCRI_MEMOEJ



IF oDocCli:lMoneta

   IF oDefCol:MOV_SUCORG_ACTIVO
     oCol:=oGrid:AddCol("MOV_SUCORG")
     oCol:cTitle   :=oDefCol:MOV_SUCORG_TITLE // "Cód"+CRLF+"Alm."
     oCol:bValid   :={||oGrid:VMOV_SUCORG(oGrid:MOV_SUCORG)}
     oCol:cMsgValid:="Almacén no Existe"
     oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),34,44)
     oCol:cListBox :="DPSUCURSAL.LBX"
     oCol:bRunOff  :={||EJECUTAR("DPSUCURSAL",2,oGrid:MOV_SUCORG)}
     oCol:nEditType:=EDIT_GET_BUTTON

     oCol:cMemoRun :=oDefCol:MOV_SUCORG_MEMOEJ

  ENDIF

  IF oDefCol:MOV_ALMORG_ACTIVO
     oCol:=oGrid:AddCol("MOV_ALMORG")
     oCol:cTitle   :=oDefCol:MOV_ALMORG_TITLE // "Cód"+CRLF+"Alm."
     oCol:bValid   :={||oGrid:VMOV_ALMORG(oGrid:MOV_ALMORG)}
     oCol:cMsgValid:="Almacén no Existe"
     oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),34,44)
     oCol:cListBox :="DPALMACEN.LBX"
     oCol:bRunOff  :={||EJECUTAR("DPALMACEN",2,oGrid:MOV_ALMORG)}
     oCol:nEditType:=EDIT_GET_BUTTON
     oCol:cMemoRun :=oDefCol:MOV_ALMORG_MEMOEJ

  ENDIF


  IF oDefCol:MOV_CODCOM_ACTIVO

      oCol:=oGrid:AddCol("MOV_CODCOM")
      oCol:cTitle   :=oDefCol:MOV_CODCOM_TITLE // "Org"
      oCol:bWhen    :=".F."
      oCol:nWidth   :=40
      oCol:bRunOff  :={||oGrid:VERCODCOM()}

  ENDIF


  IF oDefCol:MOV_ASOTIP_ACTIVO

    oCol:=oGrid:AddCol("MOV_ASOTIP")
    oCol:cTitle   :=oDefCol:MOV_ASOTIP_TITLE // "Org"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=40
    oCol:bRunOff  :={||oGrid:VERDOCORG()}

  ENDIF

  IF oDefCol:MOV_ASODOC_ACTIVO

    oCol:=oGrid:AddCol("MOV_ASODOC")
    oCol:cTitle   :=oDefCol:MOV_ASODOC_TITLE // "Número"+CRLF+"Doc/Org"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=75

    oCol:bRunOff  :={||oGrid:VERDOCORG()}

  ENDIF

ENDIF

  // Renglón Descripción
  oCol:=oGrid:AddCol("INV_DESCRI")
  oCol:cTitle:="Descripción"
  oCol:bCalc :={||oGrid:cInvDescri}
  oCol:bWhen :=".F."
  oCol:nWidth:=430+IIF(oDocCli:lPar_Almace .AND. oDocCli:lPar_DocAlm .AND. oDp:nAlmacen>1,-4,34)+IIF(oDocCli:nPar_ItemDesc>0,0,30)-120

  IF cTipDoc="PLA"
    oCol:nWidth:=oCol:nWidth+100
  ENDIF

  oCol:bValid    :={||oGrid:VINV_DESCRI(oGrid:INV_DESCRI)}
  oCol:cMemoRun  :=oDefCol:INV_DESCRI_MEMOEJ


  // JN 29/02/2020 No es necesario fecha de entrega en la plantilla
  IF !lMoneta .AND. .F.
    // Renglón Descripción

    oCol:nWidth:=660+IIF(oDocCli:lPar_Almace .AND. oDocCli:lPar_DocAlm .AND. oDp:nAlmacen>1,-4,34)+IIF(oDocCli:nPar_ItemDesc>0,0,30)-120

    oCol:=oGrid:AddCol("MOV_FCHVEN")
    oCol:cTitle:="Fecha"+CRLF+"Entrega"
    oCol:bWhen :=".T."
    oCol:nWidth:=70
    oCol:bValid:={||.T.}
    oCol:nEditType:=EDIT_GET_BUTTON
    oCol:bAction  :={||EJECUTAR("GRIDFECHA",oGrid)}

  ENDIF


  IF oDefCol:MOV_FCHVEN_ACTIVO .AND. oDocCli:lMoneta // 01/09/2023

    oCol:=oGrid:AddCol("MOV_FCHVEN")
    oCol:cTitle    :=oDefCol:MOV_FCHVEN_TITLE
    oCol:nWidth    :=80
    oCol:bValid    :={||oGrid:VMOV_FCHVEN()}
    oCol:bWhen     :=".T." 
    oCol:nEditType :=EDIT_GET_BUTTON                 // 13/05/2023 Requiere binario
    oCol:bAction   :={||EJECUTAR("GRIDFECHA",oGrid)} // 13/05/2023
    oCol:cMemoRun  :=oDefCol:MOV_FCHVEN_MEMOEJ


  ENDIF


  // Renglón Medida
  oCol:=oGrid:AddCol("MOV_UNDMED")
  oCol:cTitle    :=oDefCol:MOV_UNDMED_TITLE // FIELDLABEL("DPMOVINV","MOV_UNDMED")

  IF LEN(oDp:aUndMed)>1 

    // oDp:oFrameDp:SetText(LSTR(LEN(aUndMed))

    oCol:nWidth    :=IIF(Empty(oDp:cModeVideo),50,60)
    oCol:aItems    :={ ||oGrid:BuildUndMed(.T.) }
    oCol:aItemsData:={ ||oGrid:BuildUndMed(.F.) }
    oCol:bValid    :={ ||oGrid:VMOV_UNDMED(oGrid:MOV_UNDMED) }
    oCol:bWhen     :="!EMPTY(oGrid:MOV_CODIGO) .AND. !(oGrid:cMetodo='C') .AND. !oGrid:lTallas  .AND. !(oGrid:cUtiliz$'HS')"

    oCol:cMemoRun  :=oDefCol:MOV_UNDMED_MEMOEJ

  ELSE

    oCol:bWhen    :=".F."

  ENDIF

  oCol:bPostEdit:={||EJECUTAR("VTAGRIDEXISTE",oGrid,.T.) }  // Fix:Jonathan


IF oDefCol:MOV_PESO_ACTIVO .AND. oDefCol:PESO_PRIMERO

  // Valida si la Unidad de Medida es Variable (Utiliza Peso)
  oCol:=oGrid:AddCol("MOV_PESO")
  oCol:cTitle    :=oDefCol:MOV_PESO_TITLE
  oCol:cPicture  := oDp:cPictPeso
  oCol:nWidth    :=80
  oCol:bValid    :={||oGrid:VMOV_PESO()}
  oCol:bWhen     :="oGrid:lReqPeso" // Depende del Campo INV_REQPES Requiere Peso

  IF !Empty(oDefCol:MOV_PESO_PICTURE)
     oCol:cPicture:=oDefCol:MOV_PESO_PICTURE
  ENDIF

  oCol:cMemoRun :=oDefCol:MOV_PESO_MEMOEJ
  oCol:bRunOff  :={|| oGrid:BRDETMOVSERDOC()}
  oCol:lTotal   :=.T.

ENDIF

  // Renglón Cantidad
  IF oDefCol:MOV_X_ACTIVO

    oCol:=oGrid:AddCol("MOV_X")
    oCol:cTitle   :=oDefCol:MOV_X_TITLE 
    oCol:lTotal   :=.T.
    oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                    "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                    " "
  

    oCol:bValid   :={||oGrid:VMOV_X()}
    oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
    oCol:cPicture := "999.99"
    //oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
    oCol:nWidth   :=40

     IF !Empty(oDefCol:MOV_X_PICTURE)
       oCol:cPicture:=oDefCol:MOV_X_PICTURE
     ENDIF

     oCol:cMemoRun:=oDefCol:MOV_X_MEMOEJ

  ENDIF

  // Renglón Cantidad
  IF oDefCol:MOV_Y_ACTIVO

    oCol:=oGrid:AddCol("MOV_Y")
    oCol:cTitle   :=oDefCol:MOV_Y_TITLE 
    oCol:lTotal   :=.T.
    oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                    "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                    " "

    oCol:bValid   :={||oGrid:VMOV_Y()}
    oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
    oCol:cPicture := "999.99"
    //oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
    oCol:nWidth   :=40

    IF !Empty(oDefCol:MOV_Y_PICTURE)
      oCol:cPicture:=oDefCol:MOV_Y_PICTURE
    ENDIF

     oCol:cMemoRun:=oDefCol:MOV_Y_MEMOEJ

  ENDIF

  // Renglón Cantidad
  IF oDefCol:MOV_Z_ACTIVO

    oCol:=oGrid:AddCol("MOV_Z")
    oCol:cTitle   :=oDefCol:MOV_Z_TITLE 
    oCol:lTotal   :=.T.
    oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                  "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                  " "

    oCol:bValid   :={||oGrid:VMOV_Z()}
    oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
    oCol:cPicture := "999.99"
    oCol:nWidth   :=40
    oCol:cMemoRun :=oDefCol:MOV_Z_MEMOEJ

    IF !Empty(oDefCol:MOV_Z_PICTURE)
      oCol:cPicture:=oDefCol:MOV_Z_PICTURE
    ENDIF

  ENDIF

  // Renglón Cantidad
  IF oDefCol:MOV_W_ACTIVO

     oCol:=oGrid:AddCol("MOV_W")
     oCol:cTitle   :=oDefCol:MOV_W_TITLE 
     oCol:lTotal   :=.T.
     oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                     "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                     " "

     oCol:bValid   :={||oGrid:VMOV_W()}
     oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
     oCol:cPicture := "999.99"
     oCol:nWidth   :=40
     oCol:cMemoRun :=oDefCol:MOV_W_MEMOEJ

     IF !Empty(oDefCol:MOV_W_PICTURE)
       oCol:cPicture:=oDefCol:MOV_W_PICTURE
     ENDIF

   ENDIF

   // Renglón Cantidad
   IF oDefCol:MOV_VOLUME_ACTIVO

     oCol:=oGrid:AddCol("MOV_VOLUME")
     oCol:cTitle   :=oDefCol:MOV_VOLUME_TITLE 
     oCol:lTotal   :=.T.
     oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                     "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                     " "

     oCol:bValid   :={||oGrid:VMOV_VOLUME()}
     oCol:cMsgValid:="Volumen debe ser Mayor que Cero"
     oCol:cPicture := "9999,999.99"
     oCol:nWidth   :=80
     oCol:cMemoRun :=oDefCol:MOV_VOLUME_MEMOEJ

     IF !Empty(oDefCol:MOV_VOLUME_PICTURE)
       oCol:cPicture:=oDefCol:MOV_VOLUME_PICTURE
     ENDIF

   ENDIF


IF oDp:lAvicola .AND. oDocCli:lMoneta .AND. oDefCol:MOV_CXUND_ACTIVO

  oCol:=oGrid:AddCol("MOV_CXUND")
  oCol:cTitle    :=oDefCol:MOV_CXUND_TITLE // FIELDLABEL("DPMOVINV","MOV_CXUND")
  oCol:nWidth    :=60
  // oCol:bWhen     :="oGrid:lPesado" // Sustituido por Campo Peso
  oCol:bValid   :={||oGrid:VMOV_CXUND()}

  oCol:cMemoRun :=oDefCol:MOV_CXUND_MEMOEJ

  IF !Empty(oDefCol:MOV_CXUND_PICTURE)
     oCol:cPicture:=oDefCol:MOV_CXUND_PICTURE
  ENDIF

ENDIF

  // Renglón Cantidad
  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle   :=oDefCol:MOV_CANTID_TITLE //FIELDLABEL("DPMOVINV","MOV_CANTID")
  oCol:lTotal   :=.T.
  oCol:bWhen    :=IIF(oDocCli:nPar_InvFis<>0,"!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:cMetodo$'SC' .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES)",;
                  "!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. Empty(oGrid:MOV_EXPRES) ")+;
                  " "

  oCol:bValid   :={||oGrid:VMOV_CANTID()}
  oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
  oCol:cPicture := oDp:cPictCanUnd  
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),55,70)+5
  oCol:cMemoRun :=oDefCol:MOV_CANTID_MEMOEJ


  IF !Empty(oDefCol:MOV_CANTID_PICTURE)
     oCol:cPicture:=oDefCol:MOV_CANTID_PICTURE
  ENDIF


IF !lMoneta
  oCol:bPostEdit:=NIL
ENDIF


IF oDocCli:lMoneta

//  IF oDp:nInvLotes>0 .AND. (oDoc:nPar_InvFis<>0 .OR. oDoc:nPar_InvLog<>0 .OR. oDoc:nPar_InvCon<>0) .AND. oDefCol:MOV_LOTE_ACTIVO
  IF oDefCol:MOV_LOTE_ACTIVO

    // Informativo
    oCol:=oGrid:AddCol("MOV_LOTE")
    oCol:cTitle    :=oDefCol:MOV_LOTE_TITLE // FIELDLABEL("DPMOVINV","MOV_LOTE")
    oCol:nWidth    :=80
    oCol:bWhen     :=".F."
    oCol:cMemoRun  :=oDefCol:MOV_LOTE_MEMOEJ

  ENDIF

  IF oDefCol:CRC_NOMBRE_ACTIVO 

    oCol:=oGrid:AddCol("CRC_NOMBRE")
    oCol:cTitle    :=oDefCol:CRC_NOMBRE_TITLE
    oCol:nWidth    :=80
    oCol:bWhen     :=".F."
    oCol:bRunOff  :={||NIL }
    oCol:lTotal   :=.F.
    oCol:cMemoRun  :=oDefCol:CRC_NOMBRE_MEMOEJ


  ENDIF


  // CantxUnd
  oCol:=oGrid:GetCol("MOV_CXUND",.F.)

  IF oCol=NIL .AND. oDefCol:MOV_CXUND_ACTIVO

    oCol:=oGrid:AddCol("MOV_CXUND")
    oCol:cTitle    :=oDefCol:MOV_CXUND_TITLE // FIELDLABEL("DPMOVINV","MOV_CXUND")
    oCol:nWidth    :=60
    oCol:bWhen     :="oGrid:lPesado"
    oCol:bValid   :={||oGrid:VMOV_CXUND()}

    IF !Empty(oDefCol:MOV_CXUND_PICTURE)
      oCol:cPicture:=oDefCol:MOV_CXUND_PICTURE
    ENDIF

    oCol:cMemoRun  :=oDefCol:MOV_CXUND_MEMOEJ


  ENDIF


IF oDefCol:MOV_PESO_ACTIVO .AND. !oDefCol:PESO_PRIMERO

  // Valida si la Unidad de Medida es Variable (Utiliza Peso)
  oCol:=oGrid:AddCol("MOV_PESO")
  oCol:cTitle    :=oDefCol:MOV_PESO_TITLE
//FIELDLABEL("DPMOVINV","MOV_PESO")
  oCol:cPicture  := oDp:cPictPeso
  oCol:nWidth    :=80
  oCol:bValid    :={||oGrid:VMOV_PESO()}
  oCol:bWhen     :="oGrid:lReqPeso" // Depende del Campo INV_REQPES Requiere Peso

  IF !Empty(oDefCol:MOV_PESO_PICTURE)
     oCol:cPicture:=oDefCol:MOV_PESO_PICTURE
  ENDIF

  oCol:bRunOff  :={|| oGrid:BRDETMOVSERDOC()}
  oCol:lTotal   :=.T.
  oCol:cMemoRun :=oDefCol:MOV_PESO_MEMOEJ

ENDIF

  // Renglón Precio
  oCol:=oGrid:AddCol("MOV_PRECIO")
  oCol:cTitle   :=oDefCol:MOV_PRECIO_TITLE // "Precio"+CRLF+"de Venta"
  oCol:bWhen    :="(!EMPTY(oGrid:MOV_CANTID) .AND. oDocCli:lPar_Precio .AND. oGrid:nPrecioLote=0 .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. !oGrid:cPreReg=[S])  "+;
                  " .OR. ALLTRIM(oGrid:MOV_CODIGO)==[-]"
  oCol:bValid   :="oGrid:VMOV_PRECIO(oGrid:MOV_PRECIO)"
  oCol:cPicture :=oDp:cPictPrecio
//  oCol:cPicture :=RIGHT(oDp:cPictPrecio, LEN(oDp:cPictPrecio)-7)   //08-03-2009 Marlon Ramos (Mostrar los Decimales del Precio, actualmente no se ven)
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),85,105+5)

  IF !Empty(oDefCol:MOV_PRECIO_PICTURE)
     oCol:cPicture:=oDefCol:MOV_PRECIO_PICTURE
  ENDIF

  oCol:cMemoRun :=oDefCol:MOV_PRECIO_MEMOEJ


  // Precio en Divisas
  IF oDefCol:MOV_PREDIV_ACTIVO

    oCol:=oGrid:AddCol("MOV_PREDIV")
    oCol:cTitle   :=oDefCol:MOV_PREDIV_TITLE // "Precio"+CRLF+"de Venta"
    oCol:bWhen    :="(!EMPTY(oGrid:MOV_CANTID) .AND. oDocCli:lPar_Precio .AND. oGrid:nPrecioLote=0 .AND. !oGrid:lDcto .AND. !oGrid:lTransp .AND. !oGrid:cPreReg=[S])  "+;
                  " .OR. ALLTRIM(oGrid:MOV_CODIGO)==[-]"
    oCol:bValid   :="oGrid:VMOV_PREDIV(.T.)"
    oCol:cPicture :=oDp:cPictPrecio
    oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
    oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),85,105+5)

    IF !Empty(oDefCol:MOV_PREDIV_PICTURE)
       oCol:cPicture:=oDefCol:MOV_PREDIV_PICTURE
    ENDIF

    oCol:cMemoRun :=oDefCol:MOV_PREDIV_MEMOEJ

  ENDIF


  // Quiere Visualizar cual fue la lista de Precios Utilizada
  // Lista de Precios

  IF oDefCol:MOV_LISTA_ACTIVO

    oCol:=oGrid:AddCol("MOV_LISTA")
    oCol:cTitle  :=oDefCol:MOV_LISTA_TITLE //"Lista"
    oCol:nWidth  :=39
    oCol:bWhen   :=".F."
    oCol:cMemoRun:=oDefCol:MOV_LISTA_MEMOEJ

  ENDIF

  IF oDefCol:MOV_TIPIVA_ACTIVO
     oCol:=oGrid:AddCol("MOV_TIPIVA")
     oCol:cTitle   :=oDefCol:MOV_TIPIVA_TITLE // "Tipo"+CRLF+"IVA"
     oCol:bWhen    :=".F."
     oCol:nWidth   :=40
  ENDIF

  IF oDefCol:MOV_IVA_ACTIVO
     oCol:=oGrid:AddCol("MOV_IVA")
     oCol:cTitle   :=oDefCol:MOV_IVA_TITLE // "%"+CRLF+"IVA"
     oCol:bWhen    :=".F."
     oCol:nWidth   :=60
  ENDIF


//  oCol:bValid   :={||oGrid:cCadena:=oGrid:MOV_CODIGO,oGrid:VMOV_CODIGO(oGrid:MOV_CODIGO)}
//  oCol:cMsgValid:="Producto no Existe"
//  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),110,140)
//  oCol:cListBox :="DPINV.LBX"

  // Valor de Incidencia

  IF oDp:nVersion>=6 .AND. .F.

    oCol:=oGrid:AddCol("MOV_MTOCLA")
    oCol:cTitle   :="Valor"+CRLF+"Incidente"
    oCol:bWhen    :=".F."
    /*
     oCol:bValid   :="oGrid:VMOV_PRECIO()"
     //oCol:cPicture :=oDp:cPictPrecio // FIELDPICTURE("DPMOVINV","MOV_PRECIO",.T.) ORIGINAL
     oCol:cPicture :=RIGHT(oDp:cPictPrecio, LEN(oDp:cPictPrecio)-7)   //08-03-2009 Marlon Ramos (Mostrar los Decimales del Precio, actualmente no se ven)
     oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
     oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),85,105)
    */
  ENDIF


  // Renglón Descuento
  IF oDocCli:nPar_ItemDesc >0 .AND. oDefCol:MOV_DESCUE_ACTIVO
    oCol:=oGrid:AddCol("MOV_DESCUE")
    oCol:cTitle   :=oDefCol:MOV_DESCUE_TITLE // "%D."
    oCol:bWhen    :="(!EMPTY(oGrid:MOV_CODIGO) .AND. (oDocCli:nPar_ItemDesc>0 .AND. !oGrid:lTransp)) .OR. oGrid:lDcto"
    oCol:bValid   :={||oGrid:VMOV_DESCUE()}
    oCol:cMsgValid:="Descuento Debe ser Positivo"
    oCol:cPicture :="999.99"
     oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
    oCol:nWidth:=IIF(Empty(oDp:cModeVideo),40,50)+IF(oDocCli:lAutoSize,20,0)

    IF oDp:cModeloPos="Farmacia"
      oCol:cListBox :={||oGrid:DESC_CASC(oGRID:MOV_CANTID*oGRID:MOV_COSTO)}
      oCol:nEditType:=EDIT_GET_BUTTON
    ENDIF

    oCol:cMemoRun:=oDefCol:MOV_DESCUE_MEMOEJ

  ENDIF

  // Renglón Total
  oCol:=oGrid:AddCol("MOV_TOTAL")
  oCol:cTitle   :=oDefCol:MOV_TOTAL_TITLE
  oCol:cPicture :=oDp:cPictTotRen // FIELDPICTURE("DPMOVINV","MOV_TOTAL",.T.)
//  oCol:bCalc    :={|nTotal|nTotal:=IF(oGrid:lPesado,oGRID:MOV_CXUND,oGRID:MOV_CANTID*IIF(!oGrid:lMulti,1,oGRID:MOV_CXUND))*oGRID:MOV_PRECIO,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}

  oCol:bCalc    :={|nTotal|nTotal:=IF(oGrid:lPesado,oGRID:MOV_PESO,oGRID:MOV_CANTID*IIF(!oGrid:lMulti,1,oGRID:MOV_PESO))*oGRID:MOV_PRECIO,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}
  oCol:bWhen    :={||oDocCli:lPar_TotRen .OR. (ALLTRIM(oGrid:MOV_CODIGO)==[-] .AND. oGrid:MOV_DESCUE=0)}


  // JN 8/11/2016 .AND. !EMPTY(oGrid:MOV_PRECIO)) .OR. (oGrid:lDcto .AND. oGrid:MOV_DESCUE=0) .OR. oGrid:lTransp .OR. oGrid:lComent}
  oCol:lTotal   :=.T.
  oCol:nWidth   :=120+IIF(oDocCli:nPar_ItemDesc>0,0,12)+0 // QUITAR 50
  oCol:bValid   :={||oGrid:VMOV_TOTAL(oGrid:MOV_TOTAL)}

  IF !Empty(oDefCol:MOV_TOTAL_PICTURE)
     oCol:cPicture:=oDefCol:MOV_TOTAL_PICTURE
  ENDIF


  /*
  // Total Divisa
  */

  oDocCli:oCol_MOV_MTODIV:=NIL

  IF oDefCol:MOV_MTODIV_ACTIVO

    oCol:bPostEdit:='oGrid:ColCalc("MOV_MTODIV")'

    oCol:=oGrid:AddCol("MOV_MTODIV")
    oDocCli:oCol_MOV_MTODIV:=oCol

    oCol:cTitle   :=oDefCol:MOV_MTODIV_TITLE
    oCol:cPicture :=oDp:cPictTotRen // FIELDPICTURE("DPMOVINV","MOV_MTODIV",.T.)

    oCol:bCalc    :={|nTotal|nTotal:=oGRID:MOV_TOTAL} // 31/07/2023

    IF !oDocCli:lDivisa .OR. .T.
      oCol:bCalc    :={|nTotal|nTotal:=ROUND(oGRID:MOV_TOTAL/oDocCli:DOC_VALCAM,2)}
    ENDIF

    // oCol:bWhen    :={||.F.} //  oDocCli:lPar_TotRen .OR. (ALLTRIM(oGrid:MOV_CODIGO)==[-] .AND. oGrid:MOV_DESCUE=0)}
    oCol:bWhen    :={||oDocCli:lPar_TotRenD .OR. (ALLTRIM(oGrid:MOV_CODIGO)==[-] .AND. oGrid:MOV_DESCUE=0)}

    // JN 8/11/2016 .AND. !EMPTY(oGrid:MOV_PRECIO)) .OR. (oGrid:lDcto .AND. oGrid:MOV_DESCUE=0) .OR. oGrid:lTransp .OR. oGrid:lComent}
    oCol:lTotal   :=.T.
    oCol:nWidth   :=120
    oCol:bValid   :={||oGrid:VMOV_MTODIV(oGrid:MOV_MTODIV)}

    IF !Empty(oDefCol:MOV_MTODIV_PICTURE)
      oCol:cPicture:=oDefCol:MOV_MTODIV_PICTURE
    ENDIF

  ENDIF

ENDIF

  oGrid:oSayOpc :=oDocCli:oProducto

  /*
  // Sobro o Falto espacio, Agrega Campos
  */


// 20/09/2022  IF oGrid:CalcWidth(0,0)<>0 .AND. oDocCli:lAutoSize
  IF .F.

    nWidth:=oGrid:CalcWidth(50,0)
    // Si tiene Espacio
    IF nWidth>30 .AND. oDefCol:MOV_ITEM_ACTIVO
    // IF oDefCol:MOV_ITEM_ACTIVO
      oCol:=oGrid:InsertCol("MOV_ITEM",NIL,1)
      oCol:cTitle   :="#"+CRLF+"Item"
      oCol:bWhen    :=".F."
      oCol:nWidth   :=41
    ENDIF

    nWidth:=oGrid:CalcWidth(30,0)

    // Si Falta le Quita a la Descripción
    IF nWidth>10 .AND. oDefCol:MOV_LISTA_ACTIVO
    // IF oDefCol:MOV_LISTA_ACTIVO

      oCol:=oGrid:InsertCol("MOV_LISTA",NIL,NIL,"MOV_PRECIO")
      oCol:cTitle   :="Lis-"+CRLF+"ta"
      oCol:bWhen    :=".F."
      oCol:nWidth   :=36
    ENDIF

    nWidth:=oGrid:CalcWidth(30,0)

    IF nWidth>100 .AND. oDefCol:MOV_MTODES_ACTIVO
    // IF oDefCol:MOV_MTODES_ACTIVO
       oCol:=oGrid:InsertCol("MOV_MTODES",NIL,NIL,"MOV_DESCUE")
       oCol:cTitle   :="Precio con"+CRLF+"Descuento"
       oCol:cPicture :="999,999,999,999.99"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=100
    ENDIF

    nWidth:=oGrid:CalcWidth(80,0)

    IF nWidth>=80 .AND. !Empty(oGrid:GetCol("MOV_MTODES",.F.)) .AND. oDefCol:MOV_TIPIVA_ACTIVO
       oCol:=oGrid:InsertCol("MOV_TIPIVA",NIL,NIL,"MOV_DESCUE")
       oCol:cTitle   :="Tipo"+CRLF+"IVA"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=40
    ENDIF


    nWidth:=oGrid:CalcWidth(80,0)

    IF nWidth>=80 .AND. !Empty(oGrid:GetCol("MOV_TIPIVA",.F.)) .AND. oDefCol:MOV_TIPIVA_ACTIVO
    // IF oDefCol:MOV_TIPIVA_ACTIVO
       oCol:=oGrid:InsertCol("MOV_IVA",NIL,NIL,"MOV_TIPIVA")
       oCol:cTitle   :="%"+CRLF+"IVA"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=60
    ENDIF

    nWidth:=oGrid:CalcWidth(40,0)

    IF nWidth>=40 .AND. oDefCol:MOV_ASOTIP_ACTIVO
       oCol:=oGrid:InsertCol("MOV_ASOTIP",NIL,NIL,"MOV_CODIGO")
       oCol:cTitle   :="Org"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=40
    ENDIF

    nWidth:=oGrid:CalcWidth(70,0)

    IF nWidth>=70 .AND. !Empty(oGrid:GetCol("MOV_ASOTIP",.F.)) .AND. oDefCol:MOV_ASODOC_ACTIVO
       oCol:=oGrid:InsertCol("MOV_ASODOC",NIL,NIL,"MOV_ASOTIP")
       oCol:cTitle   :="Número"+CRLF+"Doc/Org"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=75
    ENDIF

    // Lote
    nWidth:=oGrid:CalcWidth(80,0)

    IF nWidth>80 .AND. (oDoc:nPar_InvFis<>0 .OR. oDoc:nPar_InvCon<>0) .AND. oDefCol:MOV_LOTE_ACTIVO
       oCol:=oGrid:InsertCol("MOV_LOTE",NIL,NIL,"MOV_UNDMED")
       oCol:cTitle   :="Lote"
       oCol:bWhen    :=".F."
       oCol:nWidth   :=100
    ENDIF

    // Descripción se Ajustará segun el espacio Remanente, Podrá
    oCol:=oGrid:GetCol("INV_DESCRI")
    oCol:nWidth:=oCol:nWidth+oGrid:CalcWidth(0,0)

  ENDIF

  //oDocCli:lDesign:=.t.

  oDocCli:Activate({||oDocCli:DOCCLIINI()})

  IF aCoors[3]>600 

// para diseñar debe removerlo
    EJECUTAR("FRMMOVEDOWN",oDocCli:oIVA,oDocCli,{oGrid:oBrw})
//    EJECUTAR("DPFACTURAVMOVE",oDocCli)

    oDocCli:oFolder:SetSize(oDp:aCoors[4]-30,NIL,.T.)
    // oDocCli:oFolder:Move(oDocCli:oFolder:nTop()+10,oDocCli:oFolder:nLeft(),NIL,NIL,.T.)
    oDocCli:oFolder:CoorsUpdate()

    // oDocCli:oFolder:SetSize(oDp:aCoors[4]-30,NIL,.T.)

    IF ValType(oDocCli:oBrwPag)="O"
       oDocCli:oBrwPag:SetSize(oDp:aCoors[4]-35,oDocCli:oFolder:nHeight()-10,.T.)
    ENDIF

  ENDIF

  EVAL(oDocCli:aGrids[1]:oBrw:bChange)

//  oDocCli:oFolder:Move(oDocCli:oFolder:nTop()+10,oDocCli:oFolder:nLeft(),NIL,NIL,.T.)
//  oDocCli:oFolder:CoorsUpdate()

  oDocCli:oBar:SetSize(NIL,oDocCli:nBtnHeight,.T.)
  
//  AEVAL(oDocCli:oBar:aControls,{|o,n| o:SetSize(oDocCli:nBtnWidth-10,oDocCli:nBtnHeight-7,.T.)})

  IF !Empty(oDocCli:cCodCli_)
    CursorWait()
    oBtn:=oDocCli:aBtn[1,1]
    EVAL(oBtn:bAction)
  ENDIF

  IF ValType(oDocCli:oNeto)="O"

// oDocCli:oIVA:SetSize(100,100,300,100,.T.)
// oDocCli:oIVA:SetMove(100,100,200,300,.T.)

//    AEVAL({oDocCli:oNeto,oDocCli:oIVATEXT,oDocCli:oIVA},{|o,n| MsgMemo(o:ClassName(),o:GetText()), o:Move(o:nTop()+10,o:nLeft(),.T.),o:CoorsUpdate() })
//? "AQUI"
  ENDIF

  oDocCli:RECCOUNT(.T.)

  oDefCol:End()

RETURN oDocCli

FUNCTION DOCCLIINI()
  LOCAL nClrBlink := CLR_YELLOW   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL oFontB,oDlg,oCursor,oBtn,oFont,nCol:=20

  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -14 BOLD

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

  @360 + IIF(Empty(oDp:cModeVideo),0,160), 1 STSAY oDocCli:oSayMsgErr PROMPT oDocCli:cSayMsgErr OF oDocCli:oDlg PIXEL ;
           COLORS CLR_HRED SIZE 250, 19 FONT oFontB ;
           SHADED;
           BLINK nClrBlink, nInterval, nStop  

  oDocCli:oScroll:oBrw:SetColor(NIL,16775408)

  oDocCli:oSayMsgErr:Hide()
  oDocCli:lDocGen  :=.F.

  IF oDocCli:oScroll<>NIL
    oDocCli:oScroll:oBrw:Gotop()
  ENDIF

  IF !oDocCli:lMoneta
     oDocCli:oNeto:Hide()
     oDocCli:oIVA:Hide()
     oDocCli:oSayNeto:Hide()
     oDocCli:oIVATEXT:Hide()
//     oDocCli:oGroup:Hide()
  ENDIF

//  oDocCli:oFolder:aDialogs[3]:bWhen:={.F.}
//  oDocCli:oFolder:Refresh(.T.)
//  oDocCli:oDOC_CONDIC:bKeyDown:={|nKey| IIF(nKey=VK_F6, EVAL(oDocCli:oBtnCondic:bAction),NIL)}

  oDocCli:cCodCli:=oDocCli:cCodCli_

  IF LEN(oDocCli:oFolder:aDialogs)>4

     oDlg :=oDocCli:oFolder:aDialogs[5]

     DEFINE CURSOR oCursor HAND
     DEFINE BUTTONBAR oDocCli:oBarPago SIZE 45,45+3 OF oDlg 3D CURSOR oCursor


     DEFINE BUTTON oDocCli:oBntTodos;
           OF oDocCli:oBarPago;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\MATH.BMP";
           TOP PROMPT "Pagos"; 
           ACTION oDocCli:oBrwPag:SETFILTERPAGOS(oDocCli:oBrwPag,"")

     oDocCli:oBntTodos:cToolTip:="Ver solo Pagos"

     DEFINE BUTTON oBtn;
             OF oDocCli:oBarPago;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\PASTE.BMP";
             TOP PROMPT "Clonar";
             ACTION oDocCli:oBrwPag:RUNCLICK(.T.)

      oBtn:cToolTip:="Clona Instrumento de pago, en el requiere realizar pagos múltiples o fraccionados"


      DEFINE BUTTON oBtn;
             OF oDocCli:oBarPago;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\CAJAS.BMP";
             TOP PROMPT "Caja";
             ACTION oDocCli:oBrwPag:SETFILTERPAGOS(oDocCli:oBrwPag,"CAJ")

      oBtn:cToolTip:="Instrumentos de Caja"

      DEFINE BUTTON oBtn;
             OF oDocCli:oBarPago;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\BANCO.BMP";
             TOP PROMPT "Banco";
             ACTION oDocCli:oBrwPag:SETFILTERPAGOS(oDocCli:oBrwPag,"BCO")

      oBtn:cToolTip:="Instrumentos de Bancos"

      oDocCli:oBarPago:SetColor(CLR_BLACK,oDp:nGris)
      AEVAL(oDocCli:oBarPago:aControls,{|o,n| o:Move(4,o:nLeft(),42,40+2,.T.), ;
                                              nCol:=nCol+o:nWidth(),;
                                              o:SetColor(CLR_BLACK,oDp:nGris)})

      @    2,1+nCol SAY " Pagar "+oDp:cMoneda   +"  " OF oDocCli:oBarPago PIXEL FONT oFontB SIZE 90,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL RIGHT BORDER
      @ 23.0,1+nCol SAY " Pagar "+oDp:cMonedaExt+"  " OF oDocCli:oBarPago PIXEL FONT oFontB SIZE 90,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL RIGHT BORDER

      @    2,nCol+92 SAY oDocCli:oPagosBSD PROMPT FDP(oDocCli:nMtoReqBSD,"999,999,999,999.99") OF oDocCli:oBarPago PIXEL FONT oFontB SIZE 170,20 COLOR oDp:nClrYellowText,oDp:nClrYellow  PIXEL RIGHT BORDER
      @ 23.0,nCol+92 SAY oDocCli:oPagosUSD PROMPT FDP(oDocCli:nMtoReqUSD,"999,999,999,999.99") OF oDocCli:oBarPago PIXEL FONT oFontB SIZE 170,20 COLOR oDp:nClrYellowText,oDp:nClrYellow  PIXEL RIGHT BORDER

  ENDIF

RETURN .T.

FUNCTION PREDELETE(oForm,lDelete)
RETURN EJECUTAR("DPDOCCLIPREDEL",oForm,lDelete)

// PosBorrar
FUNCTION POSTDELETE()
LOCAL lResp:=EJECUTAR("DPDOCCLIPOSDEL",oDocCli)
 
// Cancelar
FUNCTION CANCEL()
   LOCAL lResp:=.F.,oDlg,I,oGet,U,oControl,oFolder
   oDocCli:cTitle:=oDocCli:cTitle_

   lResp:=EJECUTAR("DPDOCCLICANCEL",oDocCli)

   // Debe cerrar Formulario JN 11/05/2017
   IF oDocCli:nRecCount=0
      oDocCli:nOption:=0
      oDocCli:Close()
   ELSE
      oDocCli:nOption:=0
      oDocCli:LoadData(0)
      oDocCli:RECCOUNT(.F.) 
      Aeval(oDocCli:aGrids,{|oGrid|oGrid:NewJob(0,.T.)})
   ENDIF

   FOR I := 1 TO LEN(oDocCli:oDlg:aControls)

      oFolder:=oDocCli:oDlg:aControls[I]

      IF oFolder:ClassName()="TFOLDER"

         FOR U := 1 TO LEN(oFolder:aDialogs)
           oDlg:=oFolder:aDialogs[u]
           AEVAL(oDlg:aControls,{|o,n| o:ForWhen(.T.)})
         NEXT

      ELSE

         oFolder:ForWhen(.T.)

      ENDIF

   NEXT

RETURN lResp

// Carga los Datos
FUNCTION LOAD()
 LOCAL aControl:={oDocCli:oDOC_CODIGO,oDocCli:oDOC_CODVEN,oDocCli:oDOC_NUMERO,oDocCli:oDOC_FECHA}
 LOCAL lResp:=.F.

 oDocCli:aBtn[1,1]:ForWhen(.T.)    // decasa

 oDocCli:lValCodCli :=.F.
 oDocCli:lPELock    :=.F.
 oDocCli:lPagEle    :=.F.
 oDocCli:DOC_VTAANT :=CTOO(oDocCli:DOC_VTAANT,"L")
 oDocCli:DOC_DOCORG :=oDocCli:cDocOrg   
 oDocCli:_DOC_CODMON:=oDocCli:DOC_CODMON 
 oDocCli:DOC_NUMACT :=oDocCli:DOC_NUMERO 

 IF ValType(oDocCli:oRecibo)="O"
    oDocCli:oRecibo:Refresh(.T.)
 ENDIF

 IF oDocCli:nOption=1

   EJECUTAR("DPFACTURAV_SETFOLDER",oDocCli,.T.) // Debe resetear el pago

   oDocCli:nMtoIGTF   :=0 // RECIBO DE INGRESO
   oDocCli:nTotal     :=0 // RECIBO DE INGRESO

   oDocCli:DOC_CODSUC:=oDocCli:cCodSuc
   oDocCli:DOC_TIPDOC:=oDocCli:cTipDoc

   IF !oDocCli:lValSerfiscal .AND. !EJECUTAR("ISDPSERIEFISCAL_NUM",oDocCli:DOC_CODSUC,oDocCli:cLetra,oDocCli:DOC_TIPDOC)
      // no tiene series fiscales
      oDocCli:nOption:=0
      oDocCli:Cancel()
      oDocCli:LoadData(0)
      RETURN .F.
   ENDIF

   oDocCli:lValSerfiscal:=.T. // evita volver a Validarlo

   // oDocCli:DOC_NUMACT:=oDocCli:DOC_NUMERO // NUMERO DE FACTURA ACTUAL, CASO DE IMPRESORA FISCAL
   oDocCli:DOC_MTOCOM:=0 // necesario para CxC en divisas
   oDocCli:DOC_IVAREB:=0
   oDocCli:DOC_IVABAS:=0
   oDocCli:DOC_CODIGO:=CTOEMPTY(oDocCli:DOC_CODIGO)+SPACE(120) // Facilita Búsquedas
   oDocCli:DOC_NUMERO:=CTOEMPTY(oDocCli:DOC_NUMERO) // 
   oDocCli:DOC_BASNET:=0
   oDocCli:DOC_DIVISA:=oDocCli:lDivisa // 
   oDocCli:DIR_FLEDIV:=0
   oDocCli:DIR_ORDCOM:=SPACE(10)
   oDocCli:DIR_FCHORD:=CTOD("")
   oDocCli:DOC_TIPDOC:=oDocCli:cTipDoc

   IF !Empty(oDocCli:cCodCli_)
     CursorWait()
     oDocCli:oDOC_CODIGO:VarPut(oDocCli:cCodCli_,.T.)
     EVAL(oDocCli:oDOC_CODIGO:bValid) // KeyBoard(13)
     oDocCli:oDOC_CODIGO:bWhen:={||.F.}
     SysRefresh(.T.)
   ENDIF

   oDocCli:lPagEle   :=.F.

   IF oDocCli:lEditCli
      oDocCli:lValCodCli:=.T.
   ENDIF

   IF oDocCli:cTipDoc="PLA"

      EJECUTAR("DPCLIENTECEROCREAR")
      EJECUTAR("DPVENDEDOR_INDEF")

      oDocCli:DOC_CODIGO:=oDp:cCliCero // REPLI("0",10)
      oDocCli:DOC_CODVEN:=oDp:cCodVen

   ELSE

      oDocCli:oDOCBASNET:Refresh(.T.)

   ENDIF

//? oDocCli:cLetra,"oDocCli:cLetra","oDocCli:cModFis->",oDocCli:cModFis

   IF oDocCli:nPar_CxC<>0 .and.  oDocCli:lLibVta

     oDp:cImpFiscal:=oDocCli:cModFis

     IF Empty(oDocCli:cLetra)
       // MsgMemo("Acceda al Tipo de Documento "+oDocCli:cTipDoc,"Seleccione la Serie Fiscal","Es necesario Indicar la Serie Fiscal")

       MsgMemo("Acceda al Tipo de Documento ["+oDocCli:cTipDoc+"] y seleccione la Serie fiscal"+CRLF+"Desde la Aplicación Tributación Define las Series Fiscales",;
               "Es necesario Indicar la Serie Fiscal")

       IF ISTABMOD("DPSERIEFISCAL")
          DPLBX("DPSERIEFISCAL.LBX")
       ENDIF

       IF ISTABMOD("DPDOCCLI")
         EJECUTAR("DPTIPDOCCLI",3,oDocCli:cTipDoc,.T.)
         SysRefresh(.T.)
         DPFOCUS(oTIPDOCCLI:oTDC_SERIEF)
         oTIPDOCCLI:oFocus:=oTIPDOCCLI:oTDC_SERIEF
         oTIPDOCCLI:oTDC_SERIEF:Open()
         CursorArrow()
      ENDIF
   
      RETURN .F.

     ENDIF

     EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",oDocCli:cLetra))  // 05/08/2024

     oDocCli:DOC_SERFIS:=oDocCli:cLetra
     oDocCli:DOC_NUMFIS:=EJECUTAR("DPDOCCLIGETNUMFIS",oDocCli:DOC_CODSUC,oDocCli:cLetra,oDocCli:cTipDoc,oDocCli:DOC_NUMERO)

     IF ValType(oDocCli:oDOC_NUMFIS)="O"
        oDocCli:oDOC_NUMFIS:Refresh(.T.)
     ENDIF

     IF oDocCli:lBtnIncRun .AND. !EJECUTAR("ISDOCCLIIMPFISCALIMP",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMFIS,oDocCli)
        oDocCli:nOption:=0
        oDocCli:Cancel()
        oDocCli:LoadData(0)
        RETURN .F.
     ENDIF

     oDocCli:DOC_SUCCLI:=oDp:cCodTer
     oDocCli:DOC_CODMON:=oDp:cMoneda

     ComboIni(oDocCli:oDOC_CODMON)

     IF !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))
        oDocCli:oDOC_CODIGO:VarPut(CTOEMPTY(oDocCli:DOC_CODIGO),.T.)
     ENDIF

     IF Empty(oDocCli:DOC_CENCOS)
       oDocCli:DOC_CENCOS:=oDp:cCenCos
     ENDIF

   ENDIF

 ELSE

   oDocCli:lDivisa:= oDocCli:DOC_DIVISA
   oDocCli:lPagEle:=(oDocCli:DOC_IVAREB>0)

 ENDIF


 IF oDocCli:nOption=3

    // Modificar factura fiscal, la Ultima
    // 10/2/2025

    IF oDocCli:nOption=3 .AND. ASCAN({"FAV","DEB","CRE","NEN","DEV","TIK"},oDocCli:DOC_TIPDOC)>0

       // oDocCli:RECCOUNT(.T.)
      
       IF oDocCli:nRecno=oDocCli:nRecCount

         IF oDocCli:DOC_IMPRES
           MsgMemo("Documento "+oDocCli:DOC_TIPDOC+" "+oDocCli:DOC_NUMERO+CRLF+"Está Impreso","No puede Modificar")
           RETURN .F.
         ENDIF

       ELSE

         MsgMemo("Documento "+oDocCli:DOC_TIPDOC+" "+oDocCli:DOC_NUMERO+CRLF+"Sólo el Ultimo Registro","No puede Modificar")

       ENDIF

    ENDIF

    AEVAL(aControl,{|o,n| IF(o=NIL,NIL,EVAL(o:bValid))})
    oDocCli:lValCodCli:=.T.

    oDocCli:_DOC_CODMON:=oDocCli:DOC_CODMON

 ENDIF

 IF !EJECUTAR("DPDOCCLILOAD",oDocCli)
    RETURN .F.
 ENDIF

// 05/02/2023, numero documento fiscal lo asigna cuando se Imprime
/*
 IF (oDocCli:nEpson=1 .OR. "EPSON"$oDocCli:cModFis) .AND. oDocCli:nOption=1

   MsgRun("Abriendo Impresora EPSON "+oDp:cImpFisCom,"Procesando",{||lResp:=EJECUTAR("EPSONDLL-LOAD",oDocCli)})

   oDocCli:oDOC_NUMERO:Refresh(.T.)
   oDocCli:oDOC_NUMFIS:Refresh(.T.)


   IF !lResp
     // EJECUTAR("EPSONDLL-LOAD",oDocCli)
     oDocCli:CANCEL()
     oDocCli:LOAD(0)
     RETURN .F.
   ENDIF

 ENDIF
*/

 IF oDocCli:cTipDoc="PLA"

   oDocCli:cDescri:=SQLGET("DPMEMO","MEM_DESCRI","MEM_NUMERO"+GetWhere("=",oDocCli:DOC_NUMMEM))
   oDocCli:oDescri:Refresh(.T.)

   IF oDocCli:nOption=1
      oDocCli:oDOC_DESTIN:VarPut(oDp:cPrecio,.T.)
   ENDIF

   oDocCli:oFocus:=oDocCli:oDescri

 ENDIF

/*
 IF !EJECUTAR("DPDOCCLILOAD",oDocCli)
    RETURN .F.
 ENDIF
*/

 

 IF !Empty(oDocCli:cCenCos)
   oDocCli:SET("DOC_CENCOS",oDocCli:cCenCos,.T.)
 ENDIF

 IF !oDocCli:cTipDoc="PLA"
   oDocCli:oDOCBASNET:Refresh(.T.)
   oDocCli:oIVATEXT:Refresh(.T.)
 ENDIF

 oDocCli:aDataGrid:={}
 oDocCli:lDivisaVer:=.F.

 IF oDocCli:lDivisaVer
   oDocCli:ENDIVISA()
 ENDIF

RETURN .T.

FUNCTION POSTGRABAR()
 LOCAL nNumMem:=0,cWhere,oDb:=OpenOdbc(oDp:cDsnData)
 LOCAL oRecibo:=NIL
//,oFrmRecDiv,bBlq

 IF oGrid:cImport = 1 .AND. (oDocCli:cTipDoc="DEV" .OR. oDocCli:cTipDoc="CRE")
     
    SQLUPDATE("DPDOCCLI","DOC_FACAFE",oGrid:cNumDoc,"DOC_TIPDOC = '"+oDocCli:cTipDoc+"' AND DOC_NUMERO = '"+oDocCli:DOC_NUMERO+"'")
   
    oGrid:cImport    := 0
    oGrid:cTipDoc    :=""
    oGrid:cNumDoc    :=""

 ELSE

   // 27/02/2025 Activa el Disparador
/*
   cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC_)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC_)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO_)+[ AND DOC_TIPTRA="D" ]

    SQLUPDATE("DPDOCCLI","DOC_USUARI",oDp:cUsuario,cWhere)
*/
 ENDIF

 IF oDocCli:nOption=1

  cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
          "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO)+[ AND DOC_TIPTRA="D" ]

 ELSE

  cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC_)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC_)+" AND "+;
          "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO_)+[ AND DOC_TIPTRA="D" ]


 ENDIF

 SQLUPDATE("DPDOCCLI","DOC_USUARI",oDp:cUsuario,cWhere)

  IF oDocCli:cTipDoc="PLA"

   cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC_)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC_)+" AND "+;
           "MOV_CODCTA"+GetWhere("=",oDocCli:DOC_CODIGO_)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO_)+" AND MOV_INVACT=1 AND MOV_APLORG='V' "

   SQLUPDATE("DPMOVINV",{"MOV_CODMON","MOV_LISTA"},{oDocCli:DOC_CODMON,oDocCli:DOC_DESTIN},cWhere)

 ELSE

   cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
           "MOV_CODCTA"+GetWhere("=",oDocCli:DOC_CODIGO)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND MOV_INVACT=1 AND MOV_APLORG='V' "

   SQLUPDATE("DPMOVINV",{"MOV_USUARI"},{oDp:cUsuario},cWhere)

 ENDIF

 IF oDocCli:DOC_CODIGO=STRZERO(0,10) .AND. oDocCli:lMoneta
    EJECUTAR("DPCLICEROGRAB",oDocCli)
 ENDIF

 // Desactivado 07/07/2022
 // oDb:Execute("UPDATE DPMOVINV SET MOV_MTODIV=ROUND(MOV_TOTAL/"+LSTR(oDocCli:DOC_VALCAM)+",2) WHERE "+cWhere+" AND MOV_MTODIV=0" )

 oDocCli:SETFACAFE()
 EJECUTAR("DOCCLIAFTERSAVE",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO,NIL,oDocCli:nOption)

 // Crea el Recibo  y documentos de Caja
 IF ValType(oDocCli:oBrwPag)="O"
    EJECUTAR("DPFACTURAVTORECCLI",oDocCli)
 ENDIF

 // 06/06/2024
 // Primero Cobra y luego Imprime
 //
 IF !oDoc:lPar_FavPen

    EJECUTAR("DPRECIBODIV",oDocCli:DOC_CODIGO)

    oDp:oCliRec:cTipDoc:=oDocCli:DOC_TIPDOC // necesario para no crear Recibo, sino pago directo.
    oDp:oCliRec:cNumero:=oDocCli:DOC_NUMERO

    oDp:oCliRec:SETAUTOSELDOC() // Documento TIK autoseleccionado

    oDp:oCliRec:bAfterSave:=[EJECUTAR("DPDOCCLIPOSTPAG",]+;
                            GetWhere("",oDocCli:DOC_CODSUC)+[,]+;
                            GetWhere("",oDocCli:DOC_TIPDOC)+[,]+;
                            GetWhere("",oDocCli:DOC_NUMERO)+[,]+;
                            GetWhere("",oDocCli:DOC_SERFIS)+[,]+;
                            GetWhere("",oDocCli:cModFis   )+[)]
//    oDocCli:Cancel()
//    oDocCli:nOption:=0

 ENDIF

/*
 IF oDocCli:nOption=1
    EJECUTAR("DOCCLICREACEN",oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO)
 ENDIF
*/

 oDocCli:RECCOUNT(.T.)

RETURN EJECUTAR("DPDOCCLIPOSGRA",oDocCli)

FUNCTION GRIDLOAD()
//   LOCAL oCol:=oGrid:GetCol("MOV_ITEM")

   IF oGrid:nOption=3
      oDocCli:lValCodCli:=.T.
   ENDIF

   IF oGrid:nOption=1
      oCol:=oGrid:Set("MOV_ITEM",STRZERO(oGrid:RecCount(),5),.T.)
      oGrid:SetColPos("MOV_CODIGO")
   ENDIF

   IF(oDocCli:oSayNeto  =NIL,NIL,oDocCli:oSayNeto:Refresh(.T.))
   IF(oDocCli:oDOCBASNET=NIL,NIL,oDocCli:oDOCBASNET:Refresh(.F.))

RETURN EJECUTAR("VTAGRIDLOAD",oGrid)

// Pregrabar
FUNCTION GRIDPRESAVE()
   
   IF !Empty(oDocCli:cCenCos)
      oGrid:MOV_CENCOS:=oDocCli:cCenCos
   ENDIF

   IF Empty(oGrid:MOV_CENCOS)
      oGrid:MOV_CENCOS:=oDp:cCenCos
   ENDIF

   oGrid:SET("MOV_MTODIV",oGrid:MOV_MTODIV)

RETURN EJECUTAR("VTAGRIDPRESAVE",oGrid)

// Grabación del Item
FUNCTION GRIDPOSTSAVE()
RETURN EJECUTAR("VTAGRIDPOSSAV",oGrid)

// Ejecución Antes de Eliminar el Item
FUNCTION GRIDPREDELETE()
RETURN EJECUTAR("VTAGRIDPREDEL",oGrid)

// PostGrabar
FUNCTION GRIDPOSTDELETE()
  LOCAL lResp:=EJECUTAR("VTAGRIDPOSDEL",oGrid)
   
  IF lResp .AND. oDocCli:DOC_NETO>0 .AND. oDocCli:lPagEle
     oDocCli:SETIVA10(.T.)
  ENDIF

RETURN lResp


// Valida Código de Almacen
FUNCTION VMOV_CODALM(cCodAlm)
RETURN EJECUTAR("VTAGRIDVALALM",oGrid)

// Valida Código del Producto
FUNCTION VMOV_CODIGO(cCodInv)

   // debe validar numeracion impresora fiscal
   IF oDocCli:DOC_NETO=0
//      oGrid:INCIMPFIS()
   ENDIF

   IF oGrid:lComent
      RETURN .T.
   ENDIF

   //EJECUTAR("VTAGRIDVALUND",oGrid,oGrid:MOV_UNDMED)

   IF !EJECUTAR("VTAGRIDVALCOD",oGrid)

      //Se inactivo para que al buscar una cadena llame a dpinv.lbx TJ
      //EJECUTAR("GRIDBUSCAINV",oGrid,oGrid:cCadena)

      RETURN .F. // EJECUTAR("VTAGRIDVALCOD",oGrid)
   ENDIF

   // EJECUTAR("VTAGRIDVALUND",oGrid,oGrid:MOV_UNDMED)
   oGrid:REFRESH_UNDMED()
   oGrid:CAL_PREDIV() // Calcular Precio en Divisa

RETURN .T.
// RETURN  EJECUTAR("VTAGRIDVALCOD",oGrid)

// Valida Descripción del Producto
FUNCTION VINV_DESCRI(cCodInv)
RETURN  EJECUTAR("VTAGRIDVALTEX",oGrid)

// Unidad de Medida
FUNCTION VMOV_UNDMED(cUndMed)
RETURN EJECUTAR("VTAGRIDVALUND",oGrid,cUndMed)

// Valida Cantidad
FUNCTION VMOV_CANTID()
RETURN EJECUTAR("VTAGRIDVALCAN",oGrid)

// Valida Cantidad
FUNCTION VMOV_PESO()
RETURN EJECUTAR("VTAGRIDVALPESO",oGrid)


// Valida Descuento
FUNCTION VMOV_PRECIO(nPrecio)
  LOCAL oGrid  :=oDocCli:aGrids[1]
  LOCAL lResp:=.T.

  lResp:=EJECUTAR("VTAGRIDVALPRE",oGrid)

   oGrid:SET("MOV_PRECIO",nPrecio,.T.)
   oGrid:MOV_PRECIO:=nPrecio

   oGrid:CAL_PREDIV(nPrecio)

RETURN lResp

/*
// Calcular Precio en Divisas
*/
FUNCTION CAL_PREDIV(nPrecioBs)
  LOCAL oGrid   :=oDocCli:aGrids[1]
  LOCAL nPrecioD:=ROUND(oGrid:MOV_PRECIO/oDocCli:DOC_VALCAM,2)
  LOCAL oCol :=oGrid:GetCol("MOV_CXUND",.F.)
  LOCAL oColT:=oGrid:GetCol("MOV_TOTAL",.F.)

  IF !nPrecioBs=NIL 
     nPrecioD:=ROUND(nPrecioBs/oDocCli:DOC_VALCAM,2)
  ENDIF

  oGrid:SET("MOV_PREDIV",nPrecioD,.T.)
  oGrid:MOV_PREDIV:=nPrecioD

  IF ValType(oColT)="O"
     oGrid:ColCalc("MOV_TOTAL")
  ENDIF

  // oCol:=oGrid:GetCol("MOV_MTODIV",.F.)
  oCol:=oDocCli:oCol_MOV_MTODIV // 25/01/2023

  IF ValType(oCol)="O"
     oGrid:ColCalc("MOV_MTODIV")
  ENDIF

RETURN .T.

// Valida Descuento
FUNCTION VMOV_DESCUE()
  LOCAL lRet:=EJECUTAR("VTAGRIDVALDES",oGrid)
  LOCAL  nMtoDesc  :=oGrid:MOV_PRECIO-(oGrid:MOV_PRECIO*(oGrid:MOV_DESCUE/100))


   oGrid:Set("MOV_MTODES",nMtoDesc,.T.)

RETURN lRet

// Valida Descuento
FUNCTION VMOV_TOTAL()
RETURN EJECUTAR("VTAGRIDVALTOT",oGrid)

FUNCTION VMOV_CXUND()
RETURN EJECUTAR("VTAGRIDVALCXUND",oGrid)


// Construye las Opciones
FUNCTION BuildUndMed(lData)
  LOCAL aItem:={}

  // multiples Unidades de Medida 27/02/2023

  IF oGrid:cMedMul="S"
   //aItem:=EJECUTAR("INVGETUNDMED",oGrid:MOV_CODIGO,lData,NIL,oGrid)
   aItem:=aTable("SELECT UND_CODIGO FROM DPUNDMED WHERE UND_ACTIVO=1 ORDER BY UND_CANUND",.F.)
  ELSE
   aItem:=EJECUTAR("INVGETUNDMEDPRECIO",oGrid:MOV_CODIGO,lData,NIL,oGrid)
  ENDIF

  oGrid:aUndMed:=ACLONE(aItem) // Unidades de Medida

  IF (EMPTY(oGrid:MOV_UNDMED).AND.!Empty(aItem)) .OR. LEN(aItem)=1
    oGrid:Set("MOV_UNDMED",aItem[1],.T.)
  ENDIF

RETURN aItem

// Realiza el Trabajo de Depuración
FUNCTION DOCMOVDEPURA()
RETURN .T.

// Debe Generar el Número del Documento
FUNCTION BUILDNUMDOC()
RETURN .T.

FUNCTION PRINTER()
   
   // 15/09/2022, Utiliza impresora fiscal	
/*
7/2/2025 EJECUTADO DESDE DPDOCCLIPOSGRA, autoimpresión      
   IF oDocCli:lLibVta .AND. 	EJECUTAR("DPDOCCLI_PRINT",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO,oDocCli:DOC_SERFIS)
      RETURN 
   ENDIF
*/
   // si es documento fiscal, solicita numero de

   IF oDocCli:lLibVta .AND.	Empty(oDocCli:DOC_NUMFIS)
      EJECUTAR("DPDOCNUMFIS",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO)
   ENDIF

   EJECUTAR("DPDOCCLI_PRINT",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO,oDocCli:DOC_SERFIS,oDocCli:cModFis)


//   oDocCli:PRINTER_PDF(.F.)

RETURN NIL

// Imprimir
/*
7/2/2025 EJECUTADO DESDE DPDOCCLIPOSGRA, autoimpresión
FUNCTION PRINTER_PDF(lPdf)
  LOCAL cSerie:=MYSQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF","TDC_TIPO"+GetWhere("=",oDocCli:DOC_TIPDOC))
  LOCAL cHora :=MYSQLGET("DPDOCCLI","DOC_HORA",oDocCli:cWhere)  // 07-08-2008 Marlon Ramos
  LOCAL bBlq,oRep
  LOCAL cTitle
  LOCAL cCodRep:="DOCCLI"+oDocCli:DOC_TIPDOC

  DEFAULT lPdf:=.F.

  oDp:cDocNumIni:=oDocCli:DOC_NUMERO
  oDp:cDocNumFin:=oDocCli:DOC_NUMERO

  // Asignar Factura Afectada
  oDocCli:SETFACAFE()

  IF !oDocCli:lDocGen .AND. ISSQLFIND("DPREPORTES","REP_CODIGO"+GetWhere("=",cCodRep))

    oRep:=REPORTE(cCodRep,"DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                                              "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND DOC_TIPTRA"+GetWhere("=","D"))

  ELSE

    cCodRep:="DOCCLIGEN"

    oRep:=REPORTE("DOCCLIGEN","DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                              "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND DOC_TIPTRA"+GetWhere("=","D"),;
                             ,,oDocCli:cNomDoc)
  ENDIF

  IF !ValType(oRep)="O"
	MensajeErr("Reporte "+cCodRep+" no pudo ser Ejecutado")
     RETURN NIL
  ENDIF

  oDp:oGenRep:aCargo  :=oDocCli:DOC_TIPDOC

  oRep:aCargo:=oDocCli:DOC_TIPDOC

  IF lPdf

     oRep:SETCREXPORT() // Solo Muestra los Reportes Crystal para CREXPORT

     oRep:aCargo  :=oDocCli:DOC_TIPDOC
     oRep:cTipDoc :=oDocCli:DOC_TIPDOC
     oRep:cCodCli :=oDocCli:DOC_CODIGO
     oRep:cNumDoc :=oDocCli:DOC_NUMERO
     oRep:cCodSuc :=oDocCli:DOC_CODSUC
     oRep:cNomCli :=EVAL(oDocCli:oCliNombre:bSetGet)

     oRep:cFileOut:=oDocCli:DOC_TIPDOC+"-"+oDocCli:DOC_NUMERO+".PDF"
     oRep:cTitle  :=oDocCli:cNomDoc

//+" "+oDocCli:DOC_NUMERO+" ["+oRep:cCodCli+"]="+oRep:cNomCli
// ? oRep:cTitle

     bBlq:=[EJECUTAR("BRCLIPERMAILPDF",NIL,oDp:oGenRep:cCodCli,NIL,NIL,oDp:oGenRep:cTitle,oDp:oGenRep:cCodSuc,oDp:oGenRep:cTipDoc,oDp:oGenRep:cNumDoc,oDp:oGenRep:cFileOut)]

  ELSE

     bBlq:=[SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,"]+oDocCli:cWhere+[")]
 
  ENDIF

  oDp:oGenRep:bPostRun:=BLOQUECOD(bBlq) //{|| SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,oDocCli:cWhere)}

RETURN .T.
*/

// Imprimir
// Consulta del Documento
FUNCTION VIEW()
  LOCAL cFile:="DPXBASE\DPDOCCLI"+oDocCli:cTipDoc+"CON"

  IF FILE(cFile+".DXB") .OR. FILE(cFile+".DXBX")
    EJECUTAR("DPDOCCLI"+oDocCli:cTipDoc+"CON",oDocCli)
  ELSE
    EJECUTAR("DPDOCCLIFAVCON",oDocCli)
  ENDIF
RETURN

// Pre-Grabar
FUNCTION PREGRABAR(oForm,lSave)

   // necesario guardar la serie fiscal
   oDocCli:DOC_SERFIS:=oDocCli:cLetra
   IF oDocCli:nIva=0
      oDocCli:DOC_MTOEXE:=oDocCli:DOC_NETO
   ENDIF


   IF (oDocCli:cTipDoc="PLA" .AND. (!Empty(oDocCli:cDescri) .OR. oDocCli:DOC_NUMMEM>0))

     oDocCli:aMemo[9]:=oDocCli:cDescri
     oDocCli:DOC_NUMMEM:=DPMEMOSAVE(oDocCli:aMemo[7],oDocCli:aMemo[8],oDocCli:aMemo[9])
 
   ENDIF

   IF oDocCli:cTipDoc="PLA"

     oDocCli:DOC_CODVEN:=SQLGET("DPVENDEDOR","VEN_CODIGO")
     oDocCli:DOC_CODIGO:=REPLI("0",10)
     oDocCli:DOC_CENCOS:=oDp:cCenCos
 
   ENDIF

   IF Empty(oGrid:MOV_CODIGO)
     oForm:aGrids[1]:CancelEdit()
   ENDIF
 
   IF !Empty(oDocCli:cCenCos)
      oDocCli:DOC_CENCOS:=oDocCli:cCenCos
   ENDIF

   IF Empty(oDocCli:DOC_CENCOS)
      oDocCli:DOC_CENCOS:=oDp:cCenCos
   ENDIF

   oDocCli:DOC_DIVISA:=oDocCli:lDivisa
   oDocCli:DOC_MTODIV:=oDocCli:DOC_NETO // En Tipo de documento Indicar que NO ES DIVISA

   IF !oDocCli:lDivisa
      oDocCli:DOC_MTODIV:=ROUND(oDocCli:DOC_NETO/oDocCli:DOC_VALCAM,2) 
   ENDIF

   oDocCli:DOC_USUARI:="INC" // Para el disparado

   EJECUTAR("DPDOCCLIOTRDATSAVE",oDocCli)
   
   // Valida los pagos del Banco
RETURN EJECUTAR("DPDOCCLIPREGRA",oDocCli,lSave)


// Consultar Cliente
FUNCTION CONCLIENTE()
  LOCAL lFound:=.F.

  lFound:=!Empty(oDocCli:DOC_CODIGO) .AND. MYSQLGET("DPCLIENTES","CLI_CODIGO","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))=oDocCli:DOC_CODIGO

  IF lFound  
//  EJECUTAR("DPCLIENTESCON",oDocCli,oDocCli:DOC_CODIGO)
    EJECUTAR("DPCLIENTES",0,oDocCli:DOC_CODIGO)
  ENDIF

  IF !lFound .AND. oDocCli:nOption<>0
    EVAL(oDocCli:oDOC_CODIGO:bAction) // Lista los Clientes
  ENDIF

  oDocCli:Prepare()
RETURN .T.

// Consultar Cliente
FUNCTION CONVENDEDOR()
  LOCAL lFound:=.F.

  lFound:=!Empty(oDocCli:DOC_CODVEN) .AND. MYSQLGET("DPVENDEDOR","VEN_CODIGO","VEN_CODIGO"+GetWhere("=",oDocCli:DOC_CODVEN))=oDocCli:DOC_CODVEN

  IF lFound  
    EJECUTAR("DPVENDEDORCON",oDocCli:DOC_CODVEN)
  ENDIF

  IF !lFound .AND. oDocCli:nOption<>0
    EVAL(oDocCli:oDOC_CODVEN:bAction) // Lista los Clientes
  ENDIF
RETURN .T.

// Consultar Moneda
FUNCTION CONMONEDA()
  ? "CONMONEDA"
RETURN .T.

FUNCTION RUNDESC()
  LOCAL nBruto:=0,nDesc

  nBruto:=oDocCli:aGrids[1]:GetTotal("MOV_TOTAL")

  nDesc :=EJECUTAR("DPDOCDESC",oDocCli,nBruto,oDocCli:DOC_DESCCO,!oDocCli:nOption=0)

  oDocCli:Prepare()
RETURN .T.

// Totalizar
FUNCTION TOTALIZAR(lEdit)

//  IF oDocCli:DOC_NETO=0
//    RETURN .F.
//  ENDIF

  DEFAULT lEdit:=oDocCli:nOption>0

  EJECUTAR("DOCTOTAL",oDocCli , .T. ,NIL , NIL , .T.,lEdit) // oDocCli:nOption>0)

RETURN .T.

FUNCTION DOCCODVEN()
  LOCAL lResp:=.T.

/*
  IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oDocCli:DOC_CODVEN))
      CERO(oDocCli:DOC_CODVEN,NIL,.T.)
  ENDIF
*/

  oDocCli:SeekTable("DPVENDEDOR",oDocCli:oDOC_CODVEN,"VEN_CODIGO",NIL,"VEN_NOMBRE",;
                  oDocCli:oVenNombre,"VEN_SITUAC='A'")

  oDoc:lSelCodSuc:=.F.  // Volver a Solicitar Sucursal
  SysRefresh(.T.)

RETURN lResp

FUNCTION ISLR(oDpCli)

  IF UPPER(ALLTRIM(EVAL(oDpCli:bEstado<>"Pagado")))

    EJECUTAR('DPDOCISLR',oDocCli:DOC_CODSUC,;
                         oDocCli:DOC_TIPDOC,;
                         oDocCli:DOC_CODIGO,;
                         oDocCli:DOC_NUMERO,;
                         oDocCli:cNomDoc     )
  ENDIF

RETURN .T.

// Se ejecuta desde Comprobante de Pago
FUNCTION UPDATEPAGO()
  LOCAL cEstado:=SQLGET("DPDOCCLI","DOC_ESTADO",oDocCli:cWhere)

  IF !Empty(cEstado)
    oDocCli:DOC_ESTADO:=cEstado
  ENDIF

  oDocCli:oEstado:Refresh(.T.)  
RETURN .T.

FUNCTION GRIDCODVEN()
  LOCAL cCodVen

  cCodVen:=EJECUTAR("REPBDLIST","DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE",.T.,"VEN_SITUAC='A'";
                   ,"Seleccionar "+oDP:xDPVENDEDOR,NIL,oGrid:MOV_CODVEN)

  IF !EMPTY(cCodVen)
    oGrid:SET("MOV_CODVEN",cCodVen)
  ENDIF

RETURN .T.

/*
// AG20080401. Browser
*/
FUNCTION LIST(cWhereEdo,cTitle2)
  LOCAL cWhere:="",dDesde,dHasta
  LOCAL cWhereEdo:=""
  LOCAL nAt:=ASCAN(oDocCli:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oDocCli:aBtn[nAt,1],NIL)

  DEFAULT cWhereEdo:="",;
          cTitle2  :=""

  // Esta Filtrado
  IF !(oDocCli:cScope==oDocCli:cScopeOrg)

     cWhere :=oDocCli:cScope+IF(Empty(cWhereEdo),""," AND ")+cWhereEdo

//   cTitle2:=oDocCli:cTitle
     cTitle2:=oDocCli:cTitle+ IF(Empty(cTitle2),""," ["+cTitle2+"]")
     oDocCli:ListBrw(cWhere,oDocCli:cFileBrw,cTitle2)
     RETURN NIL
  ENDIF

  cWhere:="     DOC_CODSUC"+GetWhere("=",oDocCli:cCodSuc   )+;
          " AND DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+;
          " AND DOC_TIPTRA='D' AND DOC_DOCORG"+GetWhere("=",oDocCli:cDocOrg)+IF(Empty(cWhereEdo),""," AND ")+cWhereEdo

  dHasta:=SQLGETMAX(oDocCli:cTable,"DOC_FECHA",oDocCli:cScope+IF(Empty(cWhereEdo),""," AND ")+cWhereEdo)

// ? oDp:cSql

  dDesde:=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPDOCCLI",cWhere,"DOC_FECHA",dDesde,dHasta,oBtnBrw,oDocCli:cTitle)
      RETURN .T.
  ENDIF

  cWhere:="     DOC_CODSUC"+GetWhere("=",oDocCli:cCodSuc   )+;
          " AND DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+;
          " AND DOC_TIPTRA='D' AND DOC_DOCORG"+GetWhere("=",oDocCli:cDocOrg)+IF(Empty(cWhereEdo),""," AND ")+cWhereEdo

  IF !Empty(oDp:dFchIniDoc)
     cWhere:=cWhere+"  AND (DOC_FECHA"+GetWhere(">=",oDp:dFchIniDoc)+" AND DOC_FECHA"+GetWhere("<=",oDp:dFchFinDoc)+")"
  ENDIF

// ? cWhere,"cWhere"
//  cWhere:=""

  IF Empty(cTitle2)
     cTitle2:=" Rango "+F8(oDp:dFchIniDoc)+"-"+F8(oDp:dFchFinDoc)
  ENDIF

  cTitle2:=oDocCli:cTitle+ IF(Empty(cTitle2),""," ["+cTitle2+" ]")

  oDocCli:ListBrw(cWhere,oDocCli:cFileBrw,cTitle2)

RETURN .T.

// 18-10-2008 Marlon Ramos (Consecutivo diferente para cada impresora Fiscal)
FUNCTION CREA_CONS(cTipDoc)
LOCAL nLen, cNumero, cWhere
/*
 IF cTipDoc="FAV" .OR. (cTipDoc="DEV" .OR. cTipDoc="CRE")

  // S+¦lo para Facturas y Devoluciones
   IF oDocCli:nOption = 1     // Incluir
      IF (MYSQLGET("DPEQUIPOSPOS","EPV_IP,EPV_SERIEF,EPV_NUMERO","EPV_IP"+GetWhere("=",oDp:cPcName))=oDp:cIpLocal) .AND. oDocCli:cVeces = 0
         oDp:cTkSerie :=oDp:aRow[2]
         oDp:cTkNumero:=oDp:aRow[3]

         cWhere:="     DOC_CODSUC"+GetWhere("=",oDocCli:cCodSuc)+;
                 " AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
                 " AND DOC_TIPTRA='D' "
     
         cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere+" AND LEFT(DOC_NUMERO,1)"+GetWhere("=",oDp:cTkSerie))
         IF Empty(cNumero)
            cNumero:=oDp:cTkNumero
         ENDIF
         nLen:=10-LEN(ALLTRIM(oDp:cTkSerie))
         cNumero:=RIGHT(cNumero,nLen)
         cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen)
         oDp:cTkNumero:=cNumero
         oDocCli:DOC_NUMERO:=cNumero
         oDocCli:oDOC_NUMERO:Refresh()
         oDocCli:cVeces := oDocCli:cVeces  +1

      ENDIF
   ENDIF

   RETURN .T.    // Evitar que se edite el numero  cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen)

 ENDIF
*/
RETURN .T.

FUNCTION DOCCODTER()
  LOCAL lResp:=.T.

  oDocCli:SeekTable("DPTERCEROS",oDocCli:oDOC_SUCCLI,"TDC_CODIGO",NIL,"TDC_NOMBRE",;
                  oDocCli:oTerNombre,"TDC_ACTIVO=1")

  oDocCli:oTerNombre:Refresh(.T.)

  IF oDocCli:cTerceros="S" .AND. oDocCli:DOC_SUCCLI=oDp:cCodter
     MensajeErr("Debe Utilizar "+oDp:xDPTERCEROS+" Diferente a "+oDp:cCodter)
     RETURN .F.
  ENDIF

  oDoc:lSelCodSuc:=.F.  // Volver a Solicitar Sucursal
  SysRefresh(.T.)

RETURN lResp

FUNCTION CONTERCEROS()
RETURN .T.

/*
// Presentar Condiciones de Pago
*/
FUNCTION VALCONDIC()
  LOCAL cCodigo:=SQLGET("DPCONDPAGO","CPG_CODIGO,CPG_DIAS","CPG_CODIGO"+GetWhere("=",oDocCli:DOC_CONDIC))

  IF !Empty(oDp:aRow)
     oDocCli:oDOC_PLAZO:VarPut(oDp:aRow[2],.T.)
  ENDIF

  IF !ISSQLFIND("DPCONDPAGO","CPG_CODIGO"+GetWhere("=",oDocCli:DOC_CONDIC))
     EVAL(oDocCli:oDOC_CONDIC:bAction)
     RETURN .F.
  ENDIF

? "AQUI SE CONDICIONA"

RETURN .T.

FUNCTION VALCODCLI(lLost)
   LOCAL cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                 "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                 "DOC_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO)+" AND "+;
                 "DOC_TIPTRA"+GetWhere("=","D")
   LOCAL cUltFac,cCondic,cRif,cCodigo,cWhereCli:=""
   LOCAL cCodMon,nCant

   oDocCli:cWhereCliF:="" // Buscar Cliente 20/07/2023

   IF oDocCli:oCliNombre=NIL
      RETURN .T.
   ENDIF

   IF !Empty(oDocCli:DOC_CODIGO) .AND. oDocCli:nOption=1 .AND. !oDocCli:INCIMPFIS()
      RETURN .F.
   ENDIF

/*
   // impresora Fiscal
   EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",oDocCli:cLetra))  // 05/08/2024

   oDocCli:DOC_SERFIS:=oDocCli:cLetra
   oDocCli:DOC_NUMFIS:=EJECUTAR("DPDOCCLIGETNUMFIS",oDocCli:DOC_CODSUC,oDocCli:cLetra,oDocCli:cTipDoc,oDocCli:DOC_NUMERO)
   oDocCli:oDOC_NUMFIS:Refresh(.T.)

   IF !EJECUTAR("ISDOCCLIIMPFISCALIMP",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMFIS,oDocCli)
      RETURN .F.
   ENDIF
*/

   /*
   // 18/11/2020
   // Busca el Cliente según RIF
   */

   DEFAULT oDocCli:cCodMon:=oDp:cMonedaExt

  // oDocCli:DOC_CODVEN
   

   oDocCli:oCliNombre:Refresh(.T.)

   IF Empty(oDocCli:DOC_CODIGO) .AND. lLost
      RETURN .F.
   ENDIF

   oDocCli:oCliNombre:Refresh(.T.)

   IF Empty(oDocCli:DOC_CODIGO)
     oDocCli:oDOC_CODIGO:KeyBoard(VK_F6)
     RETURN .F.
   ENDIF

   IF oDp:Get(oDocCli:DOC_TIPDOC+"LCreaCli")=NIL
      oDp:Set(oDocCli:DOC_TIPDOC+"LCreaCli",.T.)
   ENDIF

   // 20/07/2023
   // buscar clientes según nombre
/*
   IF !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))
      // No encontrado
      cWhereCli:="CLI_NOMBRE LIKE "+GetWhere("","%"+ALLTRIM(oDocCli:DOC_CODIGO)+"%")
? cWhereCli,ISSQLFIND("DPCLIENTES",cWhereCli),oDp:cSql
   ENDIF
*/

   EJECUTAR("VALFINDCODENAME",oDocCli:oDOC_CODIGO,"DPCLIENTES","CLI_CODIGO","CLI_NOMBRE") 

   IF oDp:Get(oDocCli:DOC_TIPDOC+"LCreaCli") .AND. !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))

      // Busca Similares
      cWhereCli:="CLI_CODIGO LIKE "+GetWhere("","%"+ALLTRIM(oDocCli:DOC_CODIGO)+"%")+" OR "+;
                 "CLI_RIF    LIKE "+GetWhere("","%"+ALLTRIM(oDocCli:DOC_CODIGO)+"%")

      cWhereCli:=cWhereCli+" OR "+EJECUTAR("GETWHERELIKE","DPCLIENTES","CLI_NOMBRE",oDocCli:DOC_CODIGO,"CLI_CODIGO")

      nCant  := COUNT("DPCLIENTES",cWhereCli)

      cCodigo:=""

      IF nCant=1

         cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO",cWhereCli)
         oDocCli:oDOC_CODIGO:VarPut(cCodigo,.T.)
         oDocCli:DOC_CODIGO:=cCodigo
         oDocCli:oDOC_CODIGO:KeyBoard(13)

      ENDIF

      IF Empty(cCodigo) .AND. nCant>1
         // COUNT("DPCLIENTES",cWhereCli)>0 20/07/2023

         cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","CLI_CODIGO,CLI_NOMBRE",.F.,cWhereCli,NIL,NIL,oDocCli:DOC_CODIGO,NIL,NIL,"CLI_CODIGO",oDocCli:oDOC_CODIGO)

         IF !Empty(cCodigo) .AND. ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",cCodigo))
           oDocCli:oDOC_CODIGO:VarPut(cCodigo,.T.)
           oDocCli:DOC_CODIGO:=cCodigo
         ENDIF

      ELSE

         cRif:=cCodigo

      ENDIF

      IF Empty(cCodigo) .AND. !EJECUTAR("DPCREACLI",oDocCli:oDOC_CODIGO,oDocCli:DOC_CODIGO)
         RETURN .F.
      ENDIF

      IF !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))
         RETURN .F.
      ENDIF

   ENDIF


   oDocCli:lValCodCli:=(EJECUTAR("DPCEROCLI",oDocCli:DOC_CODIGO,oDocCli:oDOC_CODIGO) .AND. ;
                        EJECUTAR("DPDOCCLIVALCLI",oDocCli:oDOC_CODIGO,oDocCli, oDocCli:oCliNombre ))

/*
// 18/09/2023. Esto viene validado, DPDOCCLIVALCLI
   IF oDocCli:nOption=1 .AND. !Empty(oDocCli:cCodMon) .AND. ISSQLFIND("DPTABMON","MON_CODIGO"+GetWhere("=",oDocCli:cCodMon))
      oDocCli:oDOC_CODMON:VarPut(oDocCli:cCodMon,.T.)
      COMBOINI(oDocCli:oDOC_CODMON)
      EVAL(oDocCli:oDOC_CODMON:bValid)

   ENDIF
*/

   IF(oDocCli:oIVATEXT=NIL,NIL,oDocCli:oIVATEXT:Refresh(.T.))

   IF oDocCli:lPagEle
      oDocCli:SETIVA10(.T.)
   ENDIF

   IF  oDocCli:lValCodCli
      oDocCli:lValCodCli:=EJECUTAR("DPDOCCLISUC",oDocCli,oDocCli:oDOC_CODIGO)
   ENDIF

   IF oDocCli:lValCodCli

     cUltFac:=SQLGET("DPDOCCLI","DOC_NUMERO,DOC_CONDIC",cWhere+" ORDER BY CONCAT(DOC_FECHA,DOC_HORA) DESC LIMIT 1")
     cCondic:=DPSQLROW(2)

     IF !Empty(cCondic)
       oDocCli:oDOC_CONDIC:VarPut(cCondic,.T.)
     ENDIF

   ENDIF

   IF Empty(oDocCli:DOC_CODVEN)
      oDocCli:lPar_CodVen:=.T.
      oDocCli:lValCodCli :=.T.
   ENDIF

   oDocCli:oDOC_FECHA:ForWhen(.T.)
   oDocCli:oDOC_CODVEN:ForWhen(.T.)
   oDocCli:oDOC_CONDIC:ForWhen(.T.)
   oDocCli:oDOC_NUMERO:ForWhen(.T.)

   IF ISALLDIGIT(ALLTRIM(oDocCli:DOC_CODVEN))
      oDocCli:DOC_CODVEN:=STRZERO(VAL(oDocCli:DOC_CODVEN),oDocCli:nLenVen) // LEN(oDocCli:DOC_CODVEN))
      oDocCli:oDOC_CODVEN:VarPut(oDocCli:DOC_CODVEN,.T.)

      IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oDocCli:DOC_CODVEN))
         EVAL(oDocCli:oDOC_CODVEN:bValid)
      ENDIF

//? "AQUI LO BUSCA",oDocCli:nLenVen,ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oDocCli:DOC_CODVEN))

   ENDIF

   IF Empty(oDocCli:DOC_CODVEN)
      EVAL(oDocCli:oDOC_CODVEN:bAction)
      RETURN .F.
   ENDIF
    
   IF !EJECUTAR("DPFOCUSWHEN",oDocCli:oDOC_CODIGO)
      oDocCli:aGrids[1]:GotFocus()
   ENDIF

   IF !oDocCli:lValCodCli
     oDocCli:oDOC_CODIGO:KeyBoard(VK_F6)
   ENDIF

/*
// 08/08/2023, incidencia cliente Plogel cogigo 170, no permite persona Gubernamental
   IF oDocCli:lLimite .AND. !(oDocCli:DOC_CODIGO==REPLI("0",10))

      cRif:=SQLGET("DPCLIENTES","CLI_RIF,CLI_TIPPER","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))

      oDocCli:cTipPer:=DPSQLROW(2)

      IF !("JG"$oDocCli:cTipPer)

        IF LEFT(cRif,1)="V"
          cTipPer:="N"
        ELSE
          oDocCli:oDOC_CODIGO:MsgErr("Factura requiere RIF de Persona Natural")
          RETURN .F.
        ENDIF

      ENDIF
 
   ENDIF
*/
   oDocCli:oVenNombre:Refresh(.T.)

RETURN oDocCli:lValCodCli

FUNCTION BRLOTESDIS()
     LOCAL cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:cCodSuc)
     oGrid:GetCol("MOV_CODIGO"):ListBox(.F.,"DPINVLOTES.LBX",cWhere)

RETURN .T.

/*
// Asignación de Centro de Costos JN 07/04/2014
*/
FUNCTION SETCENCOS()
   LOCAL cWhere :="CEN_ACTIVO=1 AND CEN_CODSUC"+GetWhere("=",oDocCli:cCodSuc)
   LOCAL cCodCen:=EJECUTAR("REPBDLIST","DPCENCOS","CEN_CODIGO,CEN_DESCRI",.F.,cWhere,NIL,NIL,oGrid:MOV_CENCOS)

   oGrid:SET("MOV_CENCOS",cCodCen,.T.)

RETURN NIL

FUNCTIO VALRIF()

  IF Empty(oDocCli:DOC_CODIGO) .OR. Empty(SQLGET("DPCLIENTES","CLI_CODIGO","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO)))
     MensajeErr("Es Necesario Indicar Código")
     RETURN .T.
  ENDIF

  EJECUTAR("BRCLINOVALRIF","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO),NIL,NIL,NIL,NIL,"Validar RIF "+oDocCli:DOC_CODIGO)

RETURN

FUNCTION DOCCLIMAIL(lPdf)
  LOCAL cTitle   :=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDocCli:DOC_TIPDOC)))+" Número "+oDocCli:DOC_NUMERO
  LOCAL cDescri  :=DPSQLROW(1,"")
  LOCAL cWhereDoc:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                   "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                   "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
                   "DOC_TIPTRA"+GetWhere("=","D")

  LOCAL cTipDocDef:="DPDOCCLIHTML"

// +oDocCli:DOC_TIPDOC

  DEFAULT lPdf:=.F.

  IF lPdf
    EJECUTAR("BRCLIPERMAILPDF",cTipDocDef,oDocCli:DOC_CODIGO,NIL,cWhereDoc,cTitle,oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO)
  ELSE

    IF !EJECUTAR("DPFORMATOSPRNCOPY","DPDOCCLIHTML",cTipDocDef,cDescri) // Copia el Formato en caso de no Existir sin tipo de Documento
       RETURN .F.
    ENDIF

    EJECUTAR("BRCLIPERMAIL",cTipDocDef,oDocCli:DOC_CODIGO,NIL,cWhereDoc,cTitle,oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO)

  ENDIF

RETURN .T.

FUNCTION RECIBO()
   LOCAL oRecibo,cWhere,nSaldo,nPagado,cWhereC,cWhereB
   LOCAL lAnticipo:=(oDocCli:DOC_CXC=0) // Pedidos solicita pedidos

   cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
           "DOC_ACT=1 "

   IF !lAnticipo

     // busca los pagos en Caja y Bancos
     IF oDocCli:DOC_TIPDOC="TIK"

       cWhereC:="CAJ_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                "CAJ_ORIGEN"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                "CAJ_DOCASO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND CAJ_ACT=1"

       cWhereB:="MOB_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                "MOB_ORIGEN"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                "MOB_DOCASO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND MOB_ACT=1" 

       nPagado:=SQLGET("DPCAJAMOV"    ,"SUM(CAJ_MONTO)",cWhereC)+;
                SQLGET("DPCTABANCOMOV","SUM(MOB_MONTO)",cWhereB)

     ELSE

       nPagado:=SQLGET("DPDOCCLI","SUM(DOC_NETO*DOC_CXC)",cWhere+[ AND DOC_TIPTRA="P"])

     ENDIF

     IF nPagado<>0
       nSaldo:=SQLGET("DPDOCCLI","SUM(DOC_NETO*DOC_CXC)",cWhere+[ AND DOC_TIPTRA="P"])
       RETURN EJECUTAR("DPDOCCLIVIEWPAG",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO,NIL,nSaldo>0)
     ENDIF

   ENDIF

   oRecibo:=EJECUTAR("DPDOCCLIPAG2",oDocCli:DOC_CODSUC,;
                                    oDocCli:DOC_TIPDOC,;
                                    oDocCli:DOC_CODIGO,;
                                    oDocCli:DOC_NUMERO,;
                                    oDocCli:cNomDoc,;
                                    oDocCli:DOC_CODVEN,;
                                    lAnticipo,;
                                    oDocCli:lPagEle,NIL,oDocCli:DOC_CODMON,0,oDocCli:DOC_MTODIV)

   oRecibo:=oDp:oCliRec
   oRecibo:lSaveAndClose:=.T.

   // JN 05/05/2017 (Guardar, Cobrar (Cerra) e Imprimir
   IF (oRecibo:lPagEle .AND. SQLGET("DPCLIENTES","CLI_TIPPER","CLI_CODIGO"+GetWhere("=",oDocCli:DOC_CODIGO))="N") .OR. oDp:Get(oDocCli:DOC_TIPDOC+"LRecPag")


     oRecibo:cRunGrabar:=[EJECUTAR("DPFACTURAV_PRINT",.F.,]+;
                         GetWhere("",oDocCli:DOC_CODSUC)+","+;
                         GetWhere("",oDocCli:DOC_TIPDOC)+","+;
                         GetWhere("",oDocCli:DOC_CODIGO)+","+;
                         GetWhere("",oDocCli:DOC_NUMERO)+","+;
                         ["]+oDocCli:cWhere+["]         +","+;
                         [NIL,]+IF(oDocCli:lDocGen,".T.",".F.")+[,NIL)]

     IF oRecibo:lPagEle
       oRecibo:oWnd:SetText(oRecibo:cTitle+" [ Pagos con Instrumentos Electrónicos ]")
     ENDIF

   ENDIF

RETURN

/*
// Asignar IVA 10% Beneficio Tributario
*/
FUNCTION SETIVA10(lCalc)

    IF !oDocCli:lMoneta
       RETURN .T.
    ENDIF
 
    IF oDocCli:nOption=1
       RETURN NIL
    ENDIF

    oDocCli:DOC_MTOBRU:=oDocCli:aGrids[1]:GETTOTAL("MOV_TOTAL")

RETURN EJECUTAR("SETIVA10FAV",lCalc)

/*
// Asignar IVA 10% Beneficio Tributario
*/
FUNCTION SETIVA10(lCalc)

     IF !oDocCli:lMoneta
        RETURN .T.
     ENDIF
 
    oDocCli:DOC_MTOBRU:=oDocCli:aGrids[1]:GETTOTAL("MOV_TOTAL")

RETURN EJECUTAR("SETIVA10FAV",lCalc)

/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXVEN()
RETURN EJECUTAR("DPFACTURAV_BRWXVEN",oDocCli)


FUNCTION BRWXCLI()
RETURN EJECUTAR("DPFACTURAV_BRWXCLI",oDocCli)

FUNCTION BRWXPAG()
  LOCAL cWhere:="LEFT(DOC_ESTADO,1)"+GetWhere("=","A")
RETURN oDocCli:LIST(cWhere,"Pendientes por Pago")

FUNCTION BRWXINV()
RETURN EJECUTAR("DPFACTURAV_XINV",oDocCli)

FUNCTION BRWVTAA()
LOCAL cWhere:="DOC_VTAANT=1"
RETURN oDocCli:LIST(cWhere,"Ventas Anticipada")


FUNCTION BRWXLOT()
RETURN EJECUTAR("DPFACTURAV_XLOT",oDocCli)


FUNCTION BRWPAGD()
  LOCAL cWhere:="LEFT(DOC_ESTADO,1)"+GetWhere("=","P")

  oDocCli:LIST(cWhere,"Pagadas")

RETURN .T.

FUNCTION BRWXNOA()
  LOCAL cWhere:="DOC_ACT"+GetWhere("=",1)

  oDocCli:LIST(cWhere,"Sin Anulados")

RETURN .T.

FUNCTION BRWANUL()
  oDocCli:LIST("DOC_ACT"+GetWhere("=",0),"Anuladas")
RETURN .T.

FUNCTION BRSUSTITUTOS()
  EJECUTAR("GRIDSUSTITUTOS",oGrid)
RETURN .T.

FUNCTION BRWXLIB()

     CursorWait()
     oDocCli:cScope:=oDocCli:cScopeOrg
     oDocCli:RECCOUNT(.T.)
     oDocCli:RECCOUNT(.F.)

RETURN .T.

FUNCTION BRTICKETPOS()
  LOCAL cWhere:=NIL,nPeriodo,dDesde:=CTOD(""),dHasta:=CTOD(""),cTitle:=NIL,lZeta:=NIL,cLetra

RETURN EJECUTAR("BRTICKETPOS",cWhere,oDocCli:DOC_CODSUC,oDp:nDiario,dDesde,dHasta,cTitle,lZeta,oDocCli:cLetra)


FUNCTION GRIDVIEW()

  EJECUTAR("DPINVCON",NIL,oGrid:MOV_CODIGO)

RETURN .T.

FUNCTION VERRECIBO()
  LOCAL oCliRec

  IF Empty(oDocCli:DOC_RECNUM)

    oCliRec:=EJECUTAR("DPDOCCLIPAG2",oDocCli:DOC_CODSUC,;
                                     oDocCli:DOC_TIPDOC,;
                                     oDocCli:DOC_CODIGO,;
                                     oDocCli:DOC_NUMERO,;
                                     NIL               ,;
                                     oDocCli:DOC_CODVEN,;
                                     .F.               ,;
                                     .F.           )

    oCliRec:=oDp:oCliRec

    oCliRec:oFrmDoc:=oDocCli

    RETURN .T.

  ENDIF
 
  CursorWait()

  EJECUTAR("DPRECIBOSCLI",.F.,NIL,oDocCli:cCodSuc,NIL,"REC_NUMERO"+GetWhere("=",oDocCli:DOC_RECNUM),.T.)

RETURN .T.

FUNCTION VALCODMON()

  oDocCli:oDOC_SAYMON:Refresh(.T.)

RETURN .T.

FUNCTION VALLISTA()
RETURN .T.

FUNCTION CREARPLANTILLA()
   // cCodSuc,cTipDoc,cNumero,cTipDes
   EJECUTAR("CREADOCCLIPLA",oDocCli:cCodSuc,oDocCli:cTipDoc,oDocCli:DOC_NUMERO,oDocCli:DOC_TIPAFE)

RETURN .T.

FUNCION SETOTROSDATOS(lCrear)
  LOCAL oTable:=OpenTable("SELECT * FROM DPDOCCLIDIR",.F.)

  AEVAL(oTable:aFields,{|a,n| oDocCli:Set(a[1]    ,oTable:FieldGet(n)),;
                              oDocCli:Add("O"+a[1],oTable:FieldGet(n))})

  oDocCli:DIR_ORDCOM:=SPACE(10)
  oDocCli:DIR_FCHORD:=CTOD("")
  oDocCli:DIR_FCHORD:=CTOD("")
  oDocCli:aFieldsOtr:=ACLONE(oTable:aFields)
  oTable:End()

RETURN NIL

FUNCTION SETFACAFE()
   LOCAL cNumDoc:="",cWhere
 
   IF oDocCli:DOC_TIPDOC="CRE" .AND. Empty(oDocCli:DOC_FACAFE)

     cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
             "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
             "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
             "MOV_APLORG"+GetWhere("=","V"               )+" AND "+;
             "MOV_INVACT=1"

     cNumDoc:=SQLGET("DPMOVINV","MOV_ASODOC",cWhere)

     cWhere:="DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D"               )

     SQLUPDATE("DPDOCCLI","DOC_FACAFE",cNumDoc,cWhere)

   ENDIF

RETURN

FUNCTION VALTIPDOC()

  oDocCli:oDOC_SAYDES:Refresh(.T.)

RETURN .T.


/*
// Validar Codigo de Sucursal
*/
FUNCTION DOCSUCCLI()
 
  IF !ISSQLFIND("DPCLIENTESSUC","SDC_CODCLI"+GetWhere("=",oDocCli:DOC_CODIGO)+" AND SDC_CODIGO"+GetWhere("=",oDocCli:DOC_SUCCLI))
     oDocCli:oDOC_SUCCLI:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  oDocCli:oSAY_SUCCLI:Refresh(.T.)


RETURN .T.

FUNCTION CONSUCCLI()

//  ? "CONSUCCLI"

RETURN .T.

FUNCTION SUCXCLIENTE()

  LOCAL cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTESSUC}"))+;
                " ["+oDocCli:DOC_CODIGO+" "+ALLTRIM(oDocCli:oCliNombre:GetText())+"]"
  LOCAL cWhere,oLbx

  cWhere:="SDC_CODCLI"+GetWhere("=",oDocCli:DOC_CODIGO)

  oDp:aCargo:={"",oDocCli:DOC_CODIGO,"DPCLIENTES","",""}
  oLbx:=DPLBX("DPCLIENTESSUC.LBX",cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_SUCCLI)
  oLbx:GetValue("SDC_CODIGO",oDocCli:oDOC_SUCCLI)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5N£meroDoc
  oLbx:aCargo:=oDp:aCargo
  oLbx:cScope:=cWhere

RETURN .T.

FUNCTION VDOC_VALCAM()
RETURN .T.

FUNCTION VERDOCORG()

  IF Empty(oGrid:MOV_ASOTIP)
     RETURN NIL
  ENDIF

  CursorWait()

  EJECUTAR("DPFACTURAV",oGrid:MOV_ASOTIP,oGrid:MOV_ASODOC)

RETURN .T.

FUNCTION ENDIVISA()
  LOCAL oCol,nTotal,nAt:=oGrid:oBrw:nArrayAt,nRowSel:=oGrid:oBrw:nRowSel
  LOCAL nPrecio

  IF Empty(oDocCli:aDataGrid)

    oDocCli:aDataGrid :=ACLONE(oGrid:oBrw:aArrayData)
    oDocCli:lDivisaVer:=.T.

  ELSE

    oGrid:oBrw:aArrayData:=ACLONE(oDocCli:aDataGrid)
    oDocCli:lDivisaVer:=.F.
    oDocCli:aDataGrid:={}

  ENDIF


  IF oDocCli:lDivisaVer

    nTotal :=oGrid:GetCol("MOV_TOTAL"):nCol
    nPrecio:=oGrid:GetCol("MOV_PRECIO"):nCol

    AEVAL(oGrid:oBrw:aArrayData,{|a,n| oGrid:oBrw:aArrayData[n,nTotal] :=a[nTotal ]/oDocCli:DOC_VALCAM,;
                                       oGrid:oBrw:aArrayData[n,nPrecio]:=a[nPrecio]/oDocCli:DOC_VALCAM})
  ENDIF

  oGrid:oBrw:Refresh(.T.)
  oGrid:oBrw:nArrayAt:=nAt
  oGrid:oBrw:nRowSel :=nRowSel

  oGrid:ShowTotal()

  oDocCli:oNeto:Refresh(.T.)
  oDocCli:oIVA:Refresh(.T.)
  oDocCli:oDOCBASNET:Refresh(.T.)

RETURN .T.

FUNCTION BRDETMOVSERDOC()
  LOCAL cWhere,cCodSuc,nPeriodo:=NIL,dDesde:=NIL,dHasta:=NIL,cTitle:=oDocCli:DOC_TIPDOC,cCodigo:=oGrid:MOV_CODIGO

  cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
          "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
          "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
          "MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO  )+" AND "+;
          "MOV_LOTE  "+GetWhere("=",oGrid:MOV_LOTE    )+" AND "+;
          "MOV_ITEM"  +GetWhere("=",oGrid:MOV_ITEM)


 cWhere:="MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
          "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
          "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
          "MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO  )+" AND "+;
          "MOV_ITEM"  +GetWhere("=",oGrid:MOV_ITEM)



   cTitle:=" Número "+oDocCli:DOC_NUMERO+" Lote : "+oGrid:MOV_LOTE

RETURN EJECUTAR("BRDETMOVSERDOC",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodigo,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO)

FUNCTION DPFACTURAV_HEAD()
  LOCAL oFontB,cTitle
  LOCAL cNumero

//  IF oDocCli=NIL
//     RETURN NIL
//  ENDIF

/*
  IF Type("oDocCli")="O" .AND. oDocCli:oWnd:hWnd>0
      EJECUTAR("BRRUNNEW",oDocCli,GetScript())
      RETURN NIL
  ENDIF
*/
  IF !ValType(oDocCli:cPicDoc)="C"
     oDocCli:cPicDoc:=NIL
  ENDIF

  cNumero:=oDocCli:DOC_NUMERO

// ? oDocCli:DOC_TIPDOC,"oDocCli:DOC_TIPDOC",oDocCli:cTipDoc,"oDocCli:cTipDoc"

  cTitle:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))
 
  IF !oDp:cTipDoc="PLA"

     oDocCli:cPagos:="Anticipo"

     IF ISDOCFISCAL(cTipDoc) .AND. cTipDoc<>"NEN"
       oDocCli:cPagos:="Pago"
     ENDIF

     // oDp:bFolderInit:={|oDlg,nOption| EJECUTAR("DPFACTURAVFOLDER",oDlg,nOption) }

     @ 1.35, 0 FOLDER oDocCli:oFolder ITEMS cTitle,"Campos Definibles","Datos Adicionales - Fletes","Terceros",oDocCli:cPagos OF oDocCli:oDlg SIZE 490,61

     // oDp:bFolderInit:={|| NIL }

  ELSE
     @ 1.35, 0 FOLDER oDocCli:oFolder ITEMS cTitle,"Campos Definibles" OF oDocCli:oDlg SIZE 490,61
  ENDIF

  oDocCli:aSizeFolder:={}
  oDocCli:oFolder:bChange:={|| oDocCli:FOLDERCHANGE()}
  SETFOLDER( 1)

  // Nombre del Cliente
  @ 1.0,0 SAY oSayRef PROMPT oDocCli:cNameCli+":" SIZE 42,12 FONT oFontB RIGHT

  SayAction(oSayRef,{||oDocCli:CONCLIENTE()})

  // Nombre del Vendedor
  @ 1.0,0 SAY oSayRef PROMPT oDocCli:cNameVen+":" SIZE 42,12 FONT oFontB RIGHT
     
  SayAction(oSayRef,{||oDocCli:CONVENDEDOR()})

  // Moneda
  // @ 1.0,0 SAY oSayRef PROMPT oDocCli:cNameMon+":" SIZE 42,12 FONT oFontB RIGHT

  @ 1.0,0 SAY oSayRef PROMPT "Valor:" SIZE 42,12 FONT oFontB RIGHT



  SayAction(oSayRef,{||DpLbx("DPTABMON.LBX")})

  // Descuento
  @ 1.0,0 SAY oSayDesc PROMPT "%Dcto:" SIZE 42,12 FONT oFontB RIGHT

  SayAction(oSayDesc,{||oDocCli:RUNDESC()})

  IF cTipDoc="NEN" .OR. cTipDoc="GDC"
    @ 2.2,10 SAY "Motivo:" RIGHT SIZE 42,20
  ELSE
    @ 2.2,10 SAY "Condición:" RIGHT SIZE 42,20
  ENDIF

  @ 2.2,28 SAY "Plazo:"     RIGHT SIZE 42,20
  @ 0.1,50 SAY "Número:"    RIGHT
  @ 0.8,50 SAY "Fecha:"     RIGHT
  @ 1.5,50 SAY "Estado:"    RIGHT

  @ .1,06 BMPGET oDocCli:oDOC_CODIGO VAR oDocCli:DOC_CODIGO;
                 VALID oDocCli:VALCODCLI(.F.);
                 NAME "BITMAPS\CLIENTE2.BMP";
                 ACTION (oDocCli:cWhereCliF:=IF(Empty(oDocCli:DOC_CODIGO),""," AND "+EJECUTAR("GETWHERELIKE","DPCLIENTES","CLI_NOMBRE",oDocCli:DOC_CODIGO)),;
                         oDpLbx:=DpLbx("DPCLIENTES",oDocCli:cTitleCli,oDocCli:cWhereCli+oDocCli:cWhereCliF,NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_CODIGO),;
                         oDpLbx:GetValue("CLI_CODIGO",oDocCli:oDOC_CODIGO));
                 WHEN (AccessField("DPDOCCLI","DOC_CODIGO",oDocCli:nOption);
                      .AND. oDocCli:nOption!=0 ;
                      .AND. oDocCli:lPar_CodCli;
                      .AND. oDocCli:lEditCli   ;
                      .AND. IIF(oDocCli:nOption=3 .AND. !oDocCli:lPar_CamCodCli,.F.,.T.));
                 SIZE 48,10

  oDocCli:oDOC_CODIGO:cToolTip:="Indique Código  F6:Catálogo"
  oDocCli:oDOC_CODIGO:cMsg    :=oDocCli:oDOC_CODIGO:cToolTip

  oDocCli:oDOC_CODIGO:bGotFocus:={|| IF(!Empty(oDocCli:DOC_CODIGO),NIL, oDocCli:VALCODCLI(.T.))}
 
  @ .9,06 BMPGET oDocCli:oDOC_CODVEN VAR oDocCli:DOC_CODVEN;
                 VALID oDocCli:DOCCODVEN();
                 NAME "BITMAPS\VENDEDORES2.BMP";
                 ACTION (oDpLbx:=DpLbx("DPVENDEDOR",NIL,"LEFT(VEN_SITUAC,1)='A'",NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_CODVEN,oDocCli:oWnd),;
                        oDpLbx:GetValue("VEN_CODIGO",oDocCli:oDOC_CODVEN));
                 WHEN (AccessField("DPDOCCLI","DOC_CODVEN",oDocCli:nOption);
                      .AND. oDocCli:lValCodCli ;
                      .AND. oDocCli:nOption!=0 .AND. oDocCli:lPar_CodVen);
                 SIZE 28,10


  @ .9,06 BMPGET oDocCli:oDOC_SUCCLI VAR oDocCli:DOC_SUCCLI;
                 VALID oDocCli:DOCSUCCLI();
                 NAME "BITMAPS\VENDEDORES2.BMP";
                 ACTION (oDocCli:SUCXCLIENTE());
                 WHEN (AccessField("DPDOCCLI","DOC_SUCCLI",oDocCli:nOption);
                      .AND. oDocCli:lValCodCli ;
                      .AND. oDocCli:nOption!=0 .AND. oDocCli:lGetCodSuc);
                 SIZE 28,10

  @ 1.6, 06.0 COMBOBOX oDocCli:oDOC_CODMON VAR oDocCli:DOC_CODMON ITEMS oDp:aMonedas;
                       VALID EJECUTAR("DPDOCCLIVALCAM",oDocCli);
                       ON CHANGE EJECUTAR("DPDOCCLIVALCAM",oDocCli);
                       WHEN (LEN(oDocCli:oDOC_CODMON:aItems)>1 .AND.;
                             oDocCli:lPar_Moneda .AND.;
                             AccessField("DPDOCCLI","DOC_CODMON",oDocCli:nOption) .AND.;
                             oDocCli:lValCodCli .AND.;
                             oDocCli:nOption!=0 .AND.;
                             oDocCli:lPar_SelMon) SIZE 100,NIL
 


  ComboIni(oDocCli:oDOC_CODMON)

  @ 2.6,6  GET oDocCli:oDOC_DCTO VAR oDocCli:DOC_DCTO PICTURE "999.99";
           VALID EJECUTAR("DPDOCCLIVALDES",oDocCli:DOC_DCTO,oDocCli);
           WHEN (AccessField("DPDOCCLI","DOC_DCTO",oDocCli:nOption);
                .AND. oDocCli:lValCodCli ;
                .AND. oDocCli:nOption!=0.AND. oDocCli:nPar_Desc>0 .AND. EMPTY(oDocCli:DOC_DESCCO));
           SIZE 20,10 RIGHT


  @ 2.6,13  BMPGET oDocCli:oDOC_CONDIC VAR oDocCli:DOC_CONDIC;
            NAME "BITMAPS\\XFIND2.BMP";
            ACTION (oDpLbx:=DpLbx("DPCONDPAGO",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_CONDIC,oDocCli:oWnd),;
                    oDpLbx:GetValue("CPG_CODIGO",oDocCli:oDOC_CONDIC));
            VALID oDocCli:VALCONDIC();
            WHEN (AccessField("DPDOCCLI","DOC_CONDIC",oDocCli:nOption);
                 .AND. oDocCli:lValCodCli ;
                 .AND. oDocCli:nOption!=0 .AND. oDocCli:lPar_Cond);
            SIZE 20,10

                                               
  @ 2.6,26.5 GET oDocCli:oDOC_PLAZO  VAR oDocCli:DOC_PLAZO PICT "999";
             VALID MensajeErr("Plazo no Permitido",NIL,{||oDocCli:DOC_PLAZO<=oDocCli:nPar_MaxDias});
             WHEN (AccessField("DPDOCCLI","DOC_PLAZO",oDocCli:nOption);
                  .AND. oDocCli:lValCodCli ;
                  .AND. oDocCli:nOption!=0 .AND. oDocCli:lPar_Plazo);
             SIZE 18,10 RIGHT

// .AND. oDocCli:nOption!=0 .AND. oDocCli:nPar_MaxDias>0);




  @ 0.0,17 SAY oDocCli:oCliNombre PROMPT EJECUTAR("VTACLINOMBRE",oDocCli) SIZE 140,09

  @ 0.7,17 SAY oDocCli:oVenNombre ;
           PROMPT MYSQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oDocCli:DOC_CODVEN)) ;
           SIZE 120,09

//? oDocCli:DOC_NUMERO,"ValType",ValType(oDocCli:DOC_NUMERO)

  @ 0.0,43 GET oDocCli:oDOC_NUMERO VAR oDocCli:DOC_NUMERO;
           PICTURE oDocCli:cPicDoc;
           VALID CERO(oDocCli:DOC_NUMERO) .AND. EJECUTAR("DPDOCCLIVALNUM",oDocCli);
           WHEN oDocCli:Crea_Cons(oDocCli:cTipDoc) .AND. (AccessField("DPDOCCLI","DOC_NUMERO",oDocCli:nOption);
                .AND. oDocCli:lValCodCli ;
                .AND. oDocCli:nOption!=0 .AND. oDocCli:lPar_EditNum);
           SIZE 35,10

  @ 0.9,43 BMPGET oDocCli:oDOC_FECHA  VAR oDocCli:DOC_FECHA ;
           PICTURE oDp:cFormatoFecha;
           NAME "BITMAPS\\Calendar.bmp";
           ACTION LbxDate(oDocCli:oDOC_FECHA ,oDocCli:DOC_FECHA);
           VALID (EJECUTAR("DPVALFECHA",oDocCli:DOC_FECHA,oDocCli:lPar_ValFch,.T.) .AND. ;
                  EJECUTAR("DPDOCCLIVALCAM",oDocCli));
           WHEN (AccessField("DPDOCMOV","DOC_FECHA",oDocCli:nOption);
                .AND. oDocCli:lValCodCli ;
                .AND. oDocCli:nOption!=0.AND. oDocCli:lPar_Fecha);
           SIZE 41,10

  @ 1.5,57 SAY oDocCli:oEstado PROMPT EVAL(oDocCli:bEstado)

  @ 0.7,17 SAY oDocCli:oTerNombre ;
           PROMPT "TER"+SQLGET("DPTERCEROS","TDC_NOMBRE","TDC_CODIGO"+GetWhere("=",oDocCli:DOC_SUCCLI)) ;
           SIZE 120,09

  // Nombre del Tercero
  @ 1.0,0 SAY oSayRef PROMPT oDp:xDPCLIENTESSUC+":" SIZE 42,12 FONT oFontB RIGHT
     
  SayAction(oSayRef,{||oDocCli:CONSUCCLI()})

  @ 1,60 SAY oDp:xDPTABMON+":" RIGHT
  @ 3,80 SAY oDocCli:oSAY_SUCCLI PROMPT SQLGET("DPCLIENTESSUC","SDC_NOMBRE","SDC_CODCLI"+GetWhere("=",oDocCli:DOC_CODIGO)+" AND "+;
                                                                            "SDC_CODIGO"+GetWhere("=",oDocCli:DOC_SUCCLI))

  IF oDocCli:lPar_LibVta

     @ 1.0,60 SAY "# Fiscal:" RIGHT

     IF "BEMA"$oDp:cImpFiscal
       @ 3.0,80 SAY oDocCli:oDOC_NUMFIS PROMPT oDocCli:DOC_NUMFIS
     ELSE 
       @ 3.0,80 SAY oDocCli:oDOC_NUMFIS PROMPT oDocCli:DOC_SERFIS+"-"+RIGHT(oDocCli:DOC_NUMFIS,8)
     ENDIF

     @ 2,80 CHECKBOX oDocCli:oDOC_VTAANT  VAR  oDocCli:DOC_VTAANT;
            PROMPT " Venta Anticipada";
            WHEN (AccessField("DPDOCMOV","DOC_FECHA",oDocCli:nOption) .AND. oDocCli:DOC_NETO=0) UPDATE

     oDocCli:oDOC_VTAANT:cMsg    :="Venta Anticipada"
     oDocCli:oDOC_VTAANT:cToolTip:="Venta Anticipada"

  ENDIF

  IF oDocCli:lPagos

    @ 1.5,50 SAYREF oDocCli:oRecibo PROMPT " "+oDocCli:DOC_RECNUM
    SayAction(oDocCli:oRecibo,{||oDocCli:VERRECIBO()})
    @ 5.0,60 SAY "#Recibo:" RIGHT

  ENDIF


  @ 2.6,26.5 GET oDocCli:oDOC_VALCAM  VAR oDocCli:DOC_VALCAM PICT oDp:cPictValCam;
             VALID oDocCli:VDOC_VALCAM();
             WHEN (AccessField("DPDOCCLI","DOC_VALCAM",oDocCli:nOption);
                  .AND. oDocCli:lValCodCli .AND. oDocCli:lPar_ValCam;
                  .AND. oDocCli:nOption!=0);
             SIZE 18,10 RIGHT

  oDocCli:oBrwPag:=EJECUTAR("DPFACTURAVBRWPAG",oDocCli)

RETURN NIL
/*
// Validar Precio en Divisas
*/
FUNCTION VMOV_PREDIV(lEnter)
  LOCAL nPrecio:=ROUND(oGrid:MOV_PREDIV*oDocCli:DOC_VALCAM,2)
  LOCAL nTotDiv:=0
  LOCAL oCol   :=NIL // 28/02/2023 oGrid:GetCol("MOV_MTODIV")

  DEFAULT lEnter:=.F.

  // Ecuación basada en el precio del Dolar
  IF oGrid:lPesado .AND. lEnter
     nTotDiv:=oGrid:MOV_PREDIV*oGrid:MOV_PESO
     nPrecio:=(nTotDiv*oDocCli:DOC_VALCAM)/oGrid:MOV_PESO
  ENDIF

  IF !oGrid:lPesado .AND. lEnter
     nTotDiv:=oGrid:MOV_PREDIV*oGrid:MOV_CANTID
     nPrecio:=(nTotDiv*oDocCli:DOC_VALCAM)/oGrid:MOV_CANTID
  ENDIF

  // Calcula el Precio en Bs
  IF oGrid:MOV_PREDIV<>0
     oGrid:SET("MOV_PRECIO",nPrecio,.T.)
     oGrid:ColCalc("MOV_TOTAL")

     IF ValType(oCol)="O"
       oGrid:ColCalc("MOV_MTODIV")
     ENDIF
  ENDIF

RETURN .T.

FUNCTION CHANGEGRID()
  LOCAL oTable,nLen:=120 // LEN(oDocCli:oProducto:GetText())
  LOCAL cDescri:=PADR(oDocCli:cNameInv+": "+oGrid:INV_DESCRI,nLen)
 
  IF oDocCli:lUbicaFis

     oTable:=OpenTable("SELECT * FROM VIEW_INVUBICAFISICA WHERE UBI_CODINV"+GetWhere("=",oGrid:MOV_CODIGO)+" LIMIT 1",.T.)

     IF oTable:RecCount()>0

       cDescri:="U:"+ALLTRIM(oTable:UBI_DESCRI)+" ALM:"+oTable:UBI_CODALM+" P:"+ALLTRIM(oTable:UBI_PASILL)+;
                " A:"+ALLTRIM(oTable:UBI_ANAQUE)+;
                " N:"+ALLTRIM(oTable:UBI_NIVEL )+;
                " S:"+ALLTRIM(oTable:UBI_SUBNIV)

      cDescri:=LEFT(cDescri,nLen)

     ENDIF
     oTable:End()

  ENDIF

  oDocCli:oProducto:SetText(cDescri)

RETURN .T.

FUNCTION VMOV_MTODIV()
RETURN .T.

FUNCTION REFRESH_UNDMED()
  LOCAL oCol  :=oGrid:GetCol("MOV_UNDMED")
  LOCAL aItems:=oGrid:BuildUndMed(.T.)

  IF LEN(aItems)>1 

    // oDp:oFrameDp:SetText(LSTR(LEN(aUndMed))
    oCol:nWidth    :=IIF(Empty(oDp:cModeVideo),50,60)
    oCol:aItems    :={ ||oGrid:BuildUndMed(.T.) }
    oCol:aItemsData:={ ||oGrid:BuildUndMed(.F.) }
    oCol:bValid    :={ ||oGrid:VMOV_UNDMED(oGrid:MOV_UNDMED) }
    oCol:bWhen     :="!EMPTY(oGrid:MOV_CODIGO) .AND. !(oGrid:cMetodo='C') .AND. !oGrid:lTallas  .AND. !(oGrid:cUtiliz$'HS')"
    oCol:bWhen     :=".T."  // 27/02/2023
  ELSE

    oCol:bWhen    :=".F."

  ENDIF

RETURN .T.

FUNCTION VMOV_FCHVEN()
RETURN .T.

FUNCTION GETWHERECLI()

  oDocCli:cWhereCliF:=IF(Empty(oDocCli:DOC_CODIGO),"",EJECUTAR("GETWHERELIKE","DPCLIENTES","CLI_NOMBRE",oDocCli:DOC_CODIGO))
//? oDocCli:cWhereCliF

RETURN oDocCli:cWhereCliF

FUNCTION VMOV_X()
   LOCAL oCol  :=oGrid:GetCol("MOV_X")
   LOCAL lValid:=.T.

   IF !Empty(oCol:cMemoRun)
      lValid:=oCol:RunMemo()
   ELSE
     EJECUTAR("GRIDCALXYZW",oGrid,uValue)
   ENDIF

RETURN lValid

FUNCTION VMOV_Y()
   LOCAL oCol:=oGrid:GetCol("MOV_Y")
   LOCAL lValid:=.T.

   IF !Empty(oCol:cMemoRun)
      lValid:=oCol:RunMemo()
   ELSE
     EJECUTAR("GRIDCALXYZW",oGrid,uValue)
   ENDIF

RETURN lValid
                     
FUNCTION VMOV_Z(uValue)
   LOCAL oCol  :=oGrid:GetCol("MOV_Z")
   LOCAL lValid:=.T.

   IF !Empty(oCol:cMemoRun)
      lValid:=oCol:RunMemo()
   ELSE
      EJECUTAR("GRIDCALXYZW",oGrid,uValue)
   ENDIF

RETURN lValid

FUNCTION VMOV_W(uValue)
   EJECUTAR("GRIDCALXYZW",oGrid,uValue)
RETURN .T.

FUNCTION VERCODCOM()
   ? "VERCODCOM"
RETURN .T.

/*
// TOMAR EL NUMERO DESDE LA IMPRESORA FISCAL
*/
FUNCTION INCIMPFIS()
RETURN EJECUTAR("INCIMPFIS",oDocCli)

/*
// Valida Sucursal de Origen
*/
FUNCTION VMOV_SUCORG()
RETURN .T.

/*
// Almacén Origen
*/
FUNCTION VMOV_ALMORG()
RETURN .T.

FUNCTION CONFORME()
  LOCAL lResp

  // si la factura requiere pago y no tiene pagos, va al folder pagos
  IF oDocCli:lPagos .AND. oDocCli:nMtoPag<oDoc:DOC_NETO
     oDocCli:oFolder:SetOption(5)
     RETURN .F.
  ENDIF

  // Validar Pagos con Bancos
  IF ValType(oDocCli:oBrwPag)="O" .AND. !oDocCli:oBrwPag:VALPAGOBANCOS(oDocCli:oBrwPag)

     IF oDocCli:cPagoFilter<>"BCO"
        oDocCli:oBrwPag:SETFILTERPAGOS(oDocCli:oBrwPag,"BCO")
     ENDIF

     RETURN .F.
  ENDIF

 
  oDocCli:oFolder:SetOption(1)
  lResp:=EJECUTAR("DOCCLICONFIRMA",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_NUMERO,oDocCli:DOC_CODIGO,oDocCli:DOC_SERFIS,oDocCli:cNomDoc)

RETURN lResp

FUNCTION VALNOMBRE()
  EJECUTAR("DPCLIENTESEDITRIF",oDocCli:DOC_CODIGO,oDocCli:oDOC_CODIGO,NIL,oDocCli:oCliNombre)
RETURN .T.

FUNCTION FOLDERCHANGE()
RETURN EJECUTAR("DPFACTURAV_SETFOLDER",oDocCli)

// EOF
