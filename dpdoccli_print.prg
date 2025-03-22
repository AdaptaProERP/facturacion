// Programa   : DPDOCCLI_PRINT
// Fecha/Hora : 13/09/2022 03:39:45
// Propósito  : Imprimir Documento del Cliente
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,cSerFis,cImpFis,cCodCli)
   LOCAL cWhere,bBlq,oRep,cJson:="",cResp:="",cKey:="",cTipTra:="D"

   DEFAULT oDp:cImpFiscal:=""

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAV",;
           cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)),;
           cImpFis:=oDp:cImpFiscal

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D"    )

   IF Empty(cSerFis)
  
	 cSerFis:=SQLGET("DPDOCCLI","DOC_SERFIS,DOC_CODIGO",cWhere)
      cCodCli:=DPSQLROW(2)

   ENDIF

   DEFAULT oDp:cImpFiscal:="",;
           oDp:lImpFisModVal:=.F.

   IF Empty(cImpFis) .OR. Empty(oDp:cImpFiscal)

      oDp:cImpFiscal   :=SQLGET("DPSERIEFISCAL","SFI_IMPFIS,SFI_PUERTO,SFI_MODVAL,SFI_PAGADO","SFI_LETRA"+GetWhere("=",cSerFis))
      oDp:cImpFisCom   :=DPSQLROW(2,"" )
      oDp:lImpFisModVal:=DPSQLROW(3,.F.)
      oDp:lImpFisPago  :=DPSQLROW(4,.F.) // Imprimir si esta pagado

   ENDIF

   // 05/08/2024
   IF !Empty(cImpFis)
      oDp:cImpFiscal   :=cImpFis
   ENDIF

   SETBASEURLDX("") // no facturación Digital
 
   IF "DIG"$UPPER(oDp:cImpFiscal)

      IF Empty(oDp:cFavD_cPrg) .OR. Empty(oDp:cFavD_cUrl)
         EJECUTAR("DPSERIEFISCALLOAD") // Carga
      ENDIF

      SETBASEURLDX() // Asigna URL de facturación digital

      IF !Empty(oDp:cFavD_cPrg)

        oDp:cMsgError   :=""
        oDp:cMsgError2  :=""
        oDp:cMsgGetProce:=""

        EJECUTAR("DPEMPGETRIF") // RIF DE LA EMPRESA

        // obtiene los valores variable Divisa    
        DPDOCCLIIMP(cCodSuc,cTipDoc,NIL,cNumero,.F.)

        cJson:=EJECUTAR("RUNMEMO",oDp:cFavD_cPrg,cCodSuc,cTipDoc,cNumero)

        IF !Empty(cJson)
           cResp:=EJECUTAR("DPDOCCLIIMPDIG",cJson,1)
        ENDIF

      ELSE

        MsgMemo("Factura Digital requiere SCRIPT para Generar JSON"+CRLF+"Ejecute Nuevamente la Opción Imprimir","Defina SCRIPT")
        EJECUTAR("DPSERIEFISCALMNU",cSerFis)

        RETURN NIL

      ENDIF
      
   ENDIF

   IF Empty(oDp:cImpFiscal) .OR. "LIBRE"$UPPER(oDp:cImpFiscal) .OR. "NING"$UPPER(oDp:cImpFiscal) .OR. "NO-FISCAL"

      cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D"    )

  
      IF "CNTGRT"$GETLLAVE_DATA("LIC_CODIGO") .AND. !oDp:cCodEmp="0000"
         oDp:lCrystalDesign:=.F. // apaga crystal desing
         MsgMemo("Licencia Contable no está Autorizada para Emitir factura")
         RETURN .F.
      ENDIF

      IF !Empty(cNumero)

        oDp:cDocNumIni:=cNumero
        oDp:cDocNumFin:=cNumero

        oRep:=REPORTE("DOCCLI"+cTipDoc,cWhere)
        oRep:SetRango(1,cNumero,cNumero)

      ELSE

        oDp:cDocNumIni:=oDpCliMnu:cNumero
        oDp:cDocNumFin:=oDpCliMnu:cNumero
        REPORTE("DOCCLI"+cTipDoc,cWhere)

      ENDIF

      oDp:oGenRep:aCargo:=cTipDoc

      // bBlq:=[SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,"]+cWhere+[")] 25/02/2025

      cKey:=cCodSuc+","+cTipDoc+","+cNumero+","+cTipTra

      bBlq:=[IMPRIMIRDOCCLI("]+cWhere+[","]+cKey+[")]

      oDp:oGenRep:bPostRun:=BLOQUECOD(bBlq) 

      RETURN .F.

   ENDIF

   IF "EPSON"$UPPE(oDp:cImpFiscal) 
      EJECUTAR("DLL_EPSON",cTipDoc,cNumero)
      RETURN .T.
   ENDIF

   IF "BEMATECH"$UPPE(oDp:cImpFiscal) 
      EJECUTAR("DLL_BEMATECH",cCodSuc,cTipDoc,cNumero,nil,nil,nil,"")
      RETURN .T.
   ENDIF

   IF "TFHK_EXE"$ALLTRIM(UPPE(oDp:cImpFiscal))
      EJECUTAR("RUNEXE_TFHKA",cCodSuc,cTipDoc,cNumero)
      RETURN .T.
   ENDIF

   IF "TFHK_DLL"$ALLTRIM(UPPE(oDp:cImpFiscal))
      EJECUTAR("DLL_TFH",cCodSuc,cTipDoc,cNumero)
      RETURN .T.
   ENDIF

RETURN .F.
// EOF
