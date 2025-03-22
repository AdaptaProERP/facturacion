// Programa   : DPRECGRABARCLI
// Fecha/Hora : 27/01/2023 03:20:44
// Propósito  : Grabar Recibo de Ingreso
// Creado Por : Juan Navas
// Llamado por: DPRECIBODIV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION RECGRABAR(oRecDiv)
  LOCAL cNumero,oRecibo,cRecibo,oDoc,I,cWhere,oNew,oEdoBco
  LOCAL aData :=ACLONE(oRecDiv:oBrw:aArrayData)
  LOCAL nAt1  :=oRecDiv:oBrw:nArrayAt
  LOCAL nRow1 :=oRecDiv:oBrw:nRowSel
  LOCAL aData2:=ACLONE(oRecDiv:oBrwD:aArrayData)
  LOCAL nAt2  :=oRecDiv:oBrwD:nArrayAt
  LOCAL nRow2 :=oRecDiv:oBrwD:nRowSel
  LOCAL cCodBco,cNumero,cCtaBco,cTipDoc,nMonto,dFecha,cWhere,nMtoDiv:=0,nValCam
  LOCAL oTable,nIDB:=0,nMonto:=0
  LOCAL nSigno 
  LOCAL cCodMon
  LOCAL cNombre:=oRecDiv:cNomCli
  LOCAL nValCam:=oRecDiv:nValCam,aTotal,aLine,nPlazo,cNumFav:="",lDifCam:=.F.
  LOCAL cRecNum:="",cSerie:="",cImpFis:="",lImpreso:=.T.
  LOCAL cImpFisOld:=oDp:cImpFiscal
  LOCAL lUpdate:=.F.,cCodSuc:=oDp:cSucursal,cNumRec
  LOCAL cTipDoc // Recibo, Pago o Proveedor
  LOCAL cText

  oRecDiv:cCodCli:=oRecDiv:cCodigo

  IF !EJECUTAR("DPRECIBODIVVALBCO",oRecDiv)
     RETURN .F.
  ENDIF

  // cNumero:=SQLINCREMENTAL("DPRECIBOSCLI","REC_NUMERO","REC_CODSUC"+GetWhere("=",oRecDiv:cCodSuc))

  IF !Empty(oRecDiv:cNumRec)
     cNumero:=oRecDiv:cNumRec
     cNumRec:=cNumero
     lUpdate:=.T.
  ELSE
     cNumero:=EJECUTAR("RECNUMERO",oRecDiv:cCodSuc,oRecDiv:cLetra)
     cNumRec:=cNumero
  ENDIF

  cText:="Desea "+IF(lUpdate,"Actualizar","Crear")+" Recibo Número "+cNumero

  IF oRecDiv:cTipDoc="TIK"

     cTipDoc:=oRecDiv:cTipDoc
     cNumRec:=oRecDiv:cNumero // Aqui debe utilizar el numero del Ticket
     // cNumero:=oRecDiv:cNumRec
     cNumero:=oRecDiv:cNumero
     cText  :="Desea Registrar Pago "+cTipDoc+" "+ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))+" #"+oRecDiv:cNumero

  ENDIF

  IF !MsgNoYes(cText)

      oRecDiv:oBrw:aArrayData:=ACLONE(aData)
      oRecDiv:oBrw:Refresh(.F.)
      oRecDiv:oBrw:nArrayAt:=nAt1
      oRecDiv:oBrw:nRowSel :=nRow1
 
      oRecDiv:oBrwD:aArrayData:=ACLONE(aData2)
      oRecDiv:oBrwD:Refresh(.F.)
      oRecDiv:oBrwD:nArrayAt:=nAt2
      oRecDiv:oBrwD:nRowSel :=nRow2

      RETURN .F.

  ENDIF

  CursorWait()

  oRecDiv:cCodVen:=IF(Empty(oRecDiv:cCodVen),STRZERO(1,6),oRecDiv:cCodVen)

  cCodSuc:=oRecDiv:cCodSuc

  IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oRecDiv:cCodVen))
    EJECUTAR("DPVENDEDORCREA",oRecDiv:cCodVen,"Recuperado Recibo "+cNumero+" Ingreso en Divisas ")
    SQLUPDATE("DPCLIENTES","CLI_CODVEN",oRecDiv:cCodVen,"CLI_CODIGO"+GetWhere("=",oRecDiv:cCodigo))
  ENDIF

// ? oRecDiv:cTipDoc,"cTipDoc, AQUI EN DPRECGRABARCLI",cNumRec,"TICKET"

  IF lUpdate

    // Inactiva los Pagos realizados
    cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "DOC_RECNUM"+GetWhere("=",cNumRec)+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","P"    )

    IF cTipDoc="TIK"

      cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumRec)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","P"    )

    ENDIF

    SQLUPDATE("DPDOCCLI","DOC_ACT",0,cWhere)

    cWhere:="CAJ_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "CAJ_ORIGEN"+GetWhere("=",cTipDoc)+" AND "+;
            "CAJ_DOCASO"+GetWhere("=",cNumRec)

    SQLUPDATE("DPCAJAMOV","CAJ_ACT",0,cWhere)

    cWhere:="MOB_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "MOB_ORIGEN"+GetWhere("=",cTipDoc)+" AND "+;
            "MOB_DOCASO"+GetWhere("=",cNumRec)

    SQLUPDATE("DPCTABANCOMOV","MOB_ACT",0,cWhere)
          
    oRecibo:=OpenTable(" SELECT * FROM DPRECIBOSCLI "+;
                       " WHERE REC_CODSUC"+GetWhere("=",oRecDiv:cCodSuc)+" AND REC_NUMERO"+GetWhere("=",cNumero),.T.)

  ELSE

    oRecibo:=OpenTable("SELECT * FROM DPRECIBOSCLI",.F.)
    oRecibo:AppendBlank()
    oRecibo:Replace("REC_NUMERO",cNumero)
    oRecibo:cWhere:=""

  ENDIF

  oRecibo:EXECUTE(" SET FOREIGN_KEY_CHECKS = 0")
  oRecibo:lAuditar:=.F.
  oRecibo:Replace("REC_FECHA" ,oRecDiv:dFecha  )
  oRecibo:Replace("REC_HORA"  ,oRecDiv:cHora   )
  oRecibo:Replace("REC_CODCOB",oRecDiv:cCodVen )
  oRecibo:Replace("REC_CODMON",oRecDiv:cCodMon )
  oRecibo:Replace("REC_CODIGO",oRecDiv:cCodigo )
  oRecibo:Replace("REC_TIPPAG",IF(oRecDiv:lAnticipo,"A","P"))
  oRecibo:Replace("REC_CODSUC",oRecDiv:cCodSuc ) // oDp:cSucursal   )
  oRecibo:Replace("REC_CENCOS",oRecDiv:cCenCos ) // oDp:cCenCos     )
  oRecibo:Replace("REC_ESTADO","Activo"        )
  oRecibo:Replace("REC_CODCAJ",oRecDiv:cCodCaja)
  oRecibo:Replace("REC_VALCAM",oRecDiv:nValCam )
  oRecibo:Replace("REC_ACT"   ,1               )
  oRecibo:Replace("REC_LETRA" ,oRecDiv:cLetra  )
  oRecibo:Replace("REC_FCHREG",oRecDiv:dFchReg )
  oRecibo:Replace("REC_NUMORG",""              ) // registro origen
  oRecibo:Replace("REC_MONTO" ,oRecDiv:nMtoPag )

  oRecibo:Replace("REC_TIPORG",oRecDiv:REC_TIPORG)
  oRecibo:Replace("REC_NUMORG",oRecDiv:REC_NUMORG)
  oRecibo:Replace("REC_DIFCAM",oRecDiv:lDifCambiario)

  // ticket no genera Registro

  IF !cTipDoc="TIK"
    oRecibo:lTicket:=.F.
    oRecibo:cTipDoc:=""
    oRecibo:Commit(oRecibo:cWhere)
  ELSE
    oRecibo:lTicket:=.T.
    oRecibo:cTipDoc:="TIK"
  ENDIF
  
//  aData:=IF(oRecDiv:lAnticipo,{},ACLONE(oRecDiv:oBrwD:aArrayData))

  oRecDiv:oRecibo:=oRecibo

  aData :=ACLONE(oRecDiv:oBrw:aArrayData)

  // 06/06/2023, el diferencial cambiario de las cuotas debe ser sumado a la base
  aData2 :=ADEPURA(aData2,{|a,n| !a[11]})

  FOR I=1 TO LEN(aData2)

     // IF aData2[I,1]="CUO" .OR. aData2[I,1]="ALQ" 
     IF aData2[I,1]=oDp:cTipDocClb .OR. aData2[I,1]=oDp:cTipDocAlq
        aData2[I,10]:=0
     ENDIF

  NEXT I

  // Recalcula el Diferencial Cambiario de las facturas/Deb/Créd
  IF oRecDiv:nMtoDifCam<>0
     aTotal :=ATOTALES(aData2)
     oRecDiv:nMtoDifCam:=aTotal[10]
  ENDIF

  aData2:=ACLONE(oRecDiv:oBrwD:aArrayData)

  CursorWait()

  // 03/08/2023
  IF !Empty(oRecDiv:REC_TIPORG)

    cWhere  :="DOC_CODSUC"+GetWhere("=",oRecDiv:cCodSuc   )+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oRecDiv:REC_TIPORG)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oRecDiv:REC_NUMORG)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D")

    lImpreso:=SQLGET("DPDOCCLI","DOC_IMPRES,DOC_SERFIS",cWhere)
    cSerie  :=DPSQLROW(2)

    
    IF !lImpreso

      EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",cSerie))
      cImpFis:=oDp:cImpFiscal

      IF oRecDiv:REC_TIPORG="CUO"
         // Buscar facturas creadas desde las Cuotas
      ENDIF

// ? "DEBE IMPRIMIR AL FINALIZAR EL RECIBO",cSerie,cImpFis,"cSerie,cImpFis"

      aData :=ACLONE(oRecDiv:oBrwD:aArrayData)
      ADEPURA(aData,{|a,n| !a[11]})
      AEVAL(aData,{|a,n| EJECUTAR("DPDOCCLI_PRINT",oRecDiv:cCodSuc,a[1],a[3],cSerie,cImpFis)})

//    ViewArray(aData)
//    EJECUTAR("DPDOCCLI_PRINT",oRecDiv:cCodSuc,oRecDiv:REC_TIPORG,oRecDiv:REC_NUMORG,cSerie,cImpFis)

    ENDIF

  ENDIF

  IF !oRecDiv:lCruce

    EJECUTAR("DPRECIBODIVBANCO",oRecDiv,oRecDiv:cCodSuc,aData,cNumero,oRecDiv:cCodigo,oRecDiv:cCodCaja,oRecDiv:dFecha,oRecDiv:cNomCli,NIL,oRecibo)
    EJECUTAR("DPRECIBODIVCAJA" ,oRecDiv,oRecDiv:cCodSuc,aData,cNumero,oRecDiv:cCodigo,oRecDiv:cCodCaja,oRecDiv:dFecha,oRecDiv:cNomCli)

  ENDIF

  IF !oRecDiv:lAnticipo

    IF oRecDiv:cTipDes="OIN"
      EJECUTAR("DPRECIBODIV_CREAOIN", oRecibo:REC_NUMERO,ACLONE(oRecDiv:oBrwD:aArrayData),oRecibo:REC_CODIGO, oRecibo:REC_FECHA)
    ENDIF

    aData :=ACLONE(oRecDiv:oBrwD:aArrayData)

    IF !oRecibo:lTicket

       EJECUTAR("DPRECIBODIVDOC"  ,oRecDiv,oRecDiv:cCodSuc,aData,cNumero,oRecDiv:dFecha,oRecDiv:cCenCos,oRecDiv:nValCam,oRecDiv:cCodVen,oRecDiv:cRunData)

    ELSE

       SQLUPDATE("DPDOCCLI","DOC_CXC",0,"DOC_CODSUC"+GetWhere("=",oRecDiv:cCodSuc)+" AND "+;
                                        "DOC_TIPDOC"+GetWhere("=",oRecDiv:cTipDoc)+" AND "+;
                                        "DOC_NUMERO"+GetWhere("=",cNumRec        ))

// ? oDp:cSql,"cSql"

    ENDIF

    IF oRecDiv:lPagoC 

       cNumFav:=EJECUTAR("DPRECIBODIVCUOFAV",oRecDiv:cCodSuc,cNumero,oRecDiv:aTipDoc[1],oRecDiv:cTipDes)

       // Originado desde Punto de Venta
       // Manda a Imprimir en la Impresora Fiscal
       IF !Empty(cNumFav)
          EJECUTAR("DPDOCCLIIMP",oRecDiv:cCodSuc,oRecDiv:cTipDes,NIL,cNumFav,.T.,NIL,NIL,NIL,"V")
          EJECUTAR("DPDOCCLI_PRINT",oRecDiv:cCodSuc,oRecDiv:cTipDes,cNumFav,NIL)
       ENDIF

    ELSE

      // Impresora Fiscal, debe buscar en las series fiscales
      IF Empty(cSerie)
        cSerie :=SQLGET("DPSERIEFISCAL","SFI_LETRA,SFI_IMPFIS","SFI_PCNAME"+GetWhere("=",oDp:cPcName))
      ENDIF

      // 16/11/2022
      // Si pago Impresora Fiscal

      DEFAULT oDp:cTipDocClb:="CUO"

      IF Empty(oRecDiv:cTipDes)
         oRecDiv:cTipDes:=SQLGET("DPTIPDOCCLI","TDC_DOCDES","TDC_TIPO"+GetWhere("=",oDp:cTipDocClb))
      ENDIF

      IF Empty(cSerie)
        cSerie:=SQLGET("dptipdoccli","SFI_LETRA","INNER JOIN dpseriefiscal ON TDC_SERIEF=SFI_MODELO  WHERE TDC_TIPO"+GetWhere("=",oRecDiv:cTipDes))
      ENDIF

      cImpFis:=SQLGET("DPSERIEFISCAL","SFI_IMPFIS,SFI_MODVAL","SFI_LETRA"+GetWhere("=",cSerie))
      cImpFis:=ALLTRIM(UPPER(cImpFis))

      // 15/05/2023 Asume impresora fiscal 
      oDp:cImpFiscal:=cImpFis

      EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",cSerie))

      cImpFis:=oDp:cImpFiscal

      IF !"NIN"$cImpFis .AND. !Empty(cImpFis) .AND. Empty(oRecDiv:cTipDes)
        oRecDiv:cTipDes:="TIK"
      ENDIF

      // condominio no genera facturas desde CUOTAS si desde alquileres
      // ? oDp:lCondominio,"oDp:lCondominio",oDp:cTipDocClb,oRecDiv:cTipDes

      IF !Empty(oRecDiv:cTipDes) .AND. !oDp:lCondominio .AND. Empty(cNumFav)

        cNumFav:=EJECUTAR("DPRECIBODIVCUOFAV",oRecDiv:cCodSuc,cNumero,oDp:cTipDocClb,oRecDiv:cTipDes)

        IF Empty(cNumFav)

          cNumFav:=EJECUTAR("DPRECIBODIVCUOFAV",oRecDiv:cCodSuc,cNumero,oDp:cTipDocAlq,oRecDiv:cTipDes)

// ? "aqui no se puede repetir",cNumFav

        ENDIF

      ENDIF

      // oDp:cImpFiscal:=cImpFisOld // 15/05/2024

    ENDIF

    // Caso de pago centralizado debe evaluar el tipo de documento seleccionado

  ELSE
 
    // CREAR REGISTRO DE ANTICIPO

  ENDIF

  CursorWait()

  // Busca si existe registro de traspaso

  IF ISSQLFIND("DPDOCCLI","DOC_CODSUC"+GetWhere("=",oRecibo:REC_CODSUC)+" AND DOC_TIPDOC"+GetWhere("=",oDp:cTipDocTra))
     EJECUTAR("CBLTRATOFAV",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO)
  ENDIF

  IF !oRecDiv:lAnticipo

    // Crear Diferencial Cambiario
    IF oRecDiv:nMtoIGTF>0 .AND. !oRecibo:lTicket
      EJECUTAR("DPRECIBODIVDIFCAM",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,.F.,oRecDiv:nMtoIGTF,oRecDiv:lIGTFCXC,oRecDiv:cRunData,.T.,oRecDiv)
    ENDIF

    IF oRecDiv:nMtoDifCam<>0
       lDifCam:=EJECUTAR("DPRECIBODIVDIFCAM",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,.F.,oRecDiv:nMtoDifCam,NIL,oRecDiv:cRunData,.F.,oRecDiv)
    ENDIF

    IF oRecDiv:dFchReg<>oRecDiv:dFecha
      cRecNum:=EJECUTAR("DPRECIBODIVFCHTRAN",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,oRecDiv:cLetraDes)
      EJECUTAR("BRRECIBODIVDOCR",NIL,oRecDiv:cCodSuc,NIL,NIL,NIL,NIL,oRecibo:REC_NUMERO,cRecNum)
    ENDIF

    IF (lDifCam .OR. oRecDiv:nMtoIGTF>0) .AND. Empty(oRecDiv:bAfterSave)

       EJECUTAR("BRRECIBODIVDOCR",NIL,oRecDiv:cCodSuc,NIL,NIL,NIL,NIL,oRecibo:REC_NUMERO,cRecNum)

    ENDIF

    IF .T.

      IF Empty(cNumFav)
         // 02/08/2023 
         IF lImpreso .AND. Empty(oRecDiv:bAfterSave)
           EJECUTAR("DPRECIBOSCLI",.F.,NIL,oRecDiv:cCodSuc,oRecDiv:cCodigo,"REC_NUMERO"+GetWhere("=",cNumero),.T.)
         ENDIF

      ELSE

         IF oRecDiv:cTipDes="TIK" .OR. oRecDiv:cTipDes="FAV"

           SQLUPDATE("DPDOCCLI","DOC_SERFIS",cSerie,"DOC_CODSUC"+GetWhere("=",oRecDiv:cCodSuc)+" AND "+;
                                                    "DOC_TIPDOC"+GetWhere("=",oRecDiv:cTipDes)+" AND "+;
                                                    "DOC_NUMERO"+GetWhere("=",cNumFav        ))

           EJECUTAR("DPDOCCLI_PRINT",oRecDiv:cCodSuc,oRecDiv:cTipDes,NIL,cSerie,cImpFis)

         ELSE

           EJECUTAR("VERDOCCLI",oRecDiv:cCodSuc,oRecDiv:cTipDes,oRecDiv:cCodigo,cNumFav,"D")

         ENDIF

       ENDIF

    ENDIF

  ELSE
 

    EJECUTAR("DPRECIBODIVANT",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,oRecDiv:nMtoPag) // crear Anticipo

    IF oRecDiv:nMtoIGTF>0
      EJECUTAR("DPRECIBODIVDIFCAM",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,.F.,oRecDiv:nMtoIGTF,oRecDiv:lIGTFCXC,oRecDiv:cRunData,.T.,oRecDiv)
    ENDIF

    EJECUTAR("DPRECIBOSCLI",.F.,NIL,oRecDiv:cCodSuc,oRecDiv:cCodigo,"REC_NUMERO"+GetWhere("=",cNumero),.T.)

    IF oRecDiv:nMtoIGTF>0
       EJECUTAR("BRRECIBODIVDOCR",NIL,oRecDiv:cCodSuc,NIL,NIL,NIL,NIL,oRecibo:REC_NUMERO,cRecNum)
    ENDIF

  ENDIF

  // Crea Anticipo por Excedente del Pago
  IF oRecDiv:lDifAnticipo .AND. oRecDiv:nMtoAnticipo>0
     EJECUTAR("DPRECIBODIVANT",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,oRecDiv:nMtoAnticipo) 
  ENDIF

  //
  // Gestion de Sociedades, copiara los documentos hacia la empresa Origen
  // JN 16/03/2023
  // 
  IF !Empty(oRecDiv:cRunData)
     EJECUTAR("GS_RECIBOSCLITODB",oRecibo:REC_CODSUC,oRecibo:REC_NUMERO,oDp:cDsnData,oRecDiv:cRunData)
  ENDIF


  oRecibo:EXECUTE(" SET FOREIGN_KEY_CHECKS = 1")
  oRecibo:End()

  IF oRecDiv:lPagoC
    // Pago Centralizado, recarga los documentos
    oRecDiv:LEERDOCCLI(oRecDiv:cCodigo,oRecDiv:aTipDoc,NIL,oRecDiv:lAnticipo,oRecDiv:lPagoC,oRecDiv:oBrwD)
    oRecDiv:CALTOTAL()
    oRecDiv:SETSUGERIDO()
  ELSE
    oRecDiv:RECRESET()
  ENDIF

  IF !oRecDiv:lCruce .AND. !oRecDiv:lPagoC
     oRecDiv:Close()
  ENDIF

RETURN .T.
// EOF
