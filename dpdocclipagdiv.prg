// Programa   : DPDOCCLIPAGDIV
// Fecha/Hora : 19/07/2022 09:43:39
// Propósito  : Obtener el Pago de Divisa para calcular el IGTF de la factura, caso de la impresora fiscal
// Creado Por : Juan navas
// Llamado por: DLL_EPSON
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,cRecibo)
  LOCAL cWhere,nDivisa:=0,nCol:=2

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="TIK",;
          cNumero:=SQLGETMAX("DPDOCCLI","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc))

  IF Empty(cRecibo)

    cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","P")

     cRecibo:=SQLGET("DPDOCCLI","DOC_RECNUM",cWhere)

  ENDIF

  // CBTE IGTF Requiere el recibo segun documento, algunas ocasiones queda en CxC
  IF Empty(cRecibo) .AND. cTipDoc="IGT"

    cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","D")

    cRecibo:=SQLGET("DPDOCCLI","DOC_RECNUM",cWhere)

  ENDIF

  IF !Empty(cRecibo)

    cWhere:="CAJ_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "CAJ_ORIGEN"+GetWhere("=","REC"  )+" AND "+;
            "CAJ_DOCASO"+GetWhere("=",cRecibo)+" AND "+;
            "CAJ_ACT=1 "

  ELSE

    cWhere:="CAJ_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "CAJ_ORIGEN"+GetWhere("=",cTipDoc)+" AND "+;
            "CAJ_NUMERO"+GetWhere("=",cNumero)+" AND "+;
            "CAJ_ACT=1 "

  ENDIF

  nDivisa     :=SQLGET("DPCAJAMOV","SUM(IF(CAJ_MTODIV>0,CAJ_MONTO,0)),SUM(CAJ_MTOITF),"+;
                "SUM(IF(CAJ_MTODIV=0,CAJ_MONTO,0)),SUM(CAJ_MTODIV) AS CAJ_MTODIV",cWhere) // Impresora Fiscal lo Calcula

  oDp:cRecibo :=cRecibo       // Recibo de Ingreso
  oDp:nPagIGTF:=DPSQLROW(2,0) // Calculado en IGTF Recibos de Ingreso
  oDp:nPagoBs :=DPSQLROW(3,0) // Calculado en Bs Recibos de Ingreso
  oDp:nPagoDiv:=DPSQLROW(4,0) // Calculado en USD
  oDp:nDivisa :=nDivisa

// ? oDp:nPagoDiv,nDivisa,CLPCOPY(oDp:cSql)

RETURN nDivisa
// EOF
