// Programa   : ISDOCCLIIMPFISCALIMP
// Fecha/Hora : 07/08/2024 05:00:16
// Propósito  : Valida si la ultima factura FISCAL de impresora fiscal fué impresa. No ejecutó el pago, no fue impreso.
// Creado Por : Juan Navas
// Llamado por: DPDOCCLI, LOAD, INCLUIR
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,oDoc)
   LOCAL lImpreso:=.T.,lResp:=.T.,cWhere,cCodCli,cNomDoc
   LOCAL lValidar:=("BEMA"$oDp:cImpFiscal .AND. !oDp:lImpFisModVal)
   LOCAL nSaldo  :=0

   IF !lValidar
      RETURN .T.
   ENDIF

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cNumero)

   IF !ISSQLFIND("DPDOCCLI",cWhere)
      RETURN .T.
   ENDIF

   lImpreso:=SQLGET("DPDOCCLI","DOC_IMPRES,DOC_CODIGO",cWhere+" AND DOC_TIPTRA"+GetWhere("=","D"))
   cCodCli :=DPSQLROW(2)

   IF !lImpreso

      nSaldo:=SQLGET("DPDOCCLI","SUM(DOC_NETO*DOC_CXC)",cWhere+" AND DOC_ACT=1" )
      lResp :=.F.

      IF nSaldo>0 .AND. MsgNoYes("¿Desea Realizar Pago?","Documento Fiscal "+cTipDoc+"-"+cNumero+" no fue Impreso y no tiene pago")

         EJECUTAR("DPRECIBODIV",cCodCli)

         oDp:oCliRec:SETAUTOSELDOC() // Documento TIK autoseleccionado

         oDp:oCliRec:bAfterSave:=[EJECUTAR("DPDOCCLIPOSTPAG",]+;
                                 GetWhere("",cCodSuc)+[,]+;
                                 GetWhere("",cTipDoc)+[,]+;
                                 GetWhere("",cNumero)+[)]

         RETURN .F. // no puede continuar con la factura
      
      ENDIF

      IF MsgNoYes("¿Desea Eliminar el Registro?","Documento Fiscal "+cTipDoc+"-"+cNumero+" no fue Impreso")

         SQLDELETE("DPDOCCLI",cWhere)

         cWhere:="MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                 "MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                 "MOV_DOCUME"+GetWhere("=",cNumero)+" AND "+;
                 "MOV_APLORG"+GetWhere("=","V"    )

          SQLDELETE("DPMOVINV",cWhere)

          RETURN .T.
 
      ENDIF

/*
      IF MsgNoYes("Documento Fiscal "+cTipDoc+"-"+cNumero+" no fue Impreso","Desea Reutilizar su Contenido")
         oDoc:nOption:=3
         oDoc:Load(3)
      ENDIF
*/    

   ELSE

      cNomDoc:=IF(ValType(oDoc)="O",oDoc:cNomDoc,SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))
      MsgMemo("Documento "+cTipDoc+" "+CRLF+ALLTRIM(cNomDoc)+CRLF+" #"+cNumero+" ya fue registrado")
      lResp:=.F.
   ENDIF

RETURN lResp
