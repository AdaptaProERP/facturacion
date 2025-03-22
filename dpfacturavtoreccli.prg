// Programa   : DPFACTURAVTORECCLI
// Fecha/Hora : 27/01/2023 03:20:44
// Propósito  : Grabar Recibo de Ingreso creado en facturación
// Creado Por : Juan Navas
// Llamado por: DPRECIBODIV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION RECGRABAR(oDocFav)
  LOCAL aData:={}
  LOCAL cNumero,oRecibo,cRecibo,oDoc,I,cWhere,oNew,oEdoBco

  aData :=ACLONE(oDocFav:oBrwPag:aArrayData)
  ADEPURA(aData,{|a,n| a[5]=0})

  // no tiene pagos
  IF Empty(aData)
     RETURN .F.
  ENDIF

  cNumero:=EJECUTAR("RECNUMERO",oDocFav:cCodSuc,oDocFav:cLetra)

  oRecibo:=OpenTable("SELECT * FROM DPRECIBOSCLI",.F.)
  oRecibo:AppendBlank()
  oRecibo:Replace("REC_NUMERO",cNumero)
  oRecibo:cWhere:=""

  oRecibo:EXECUTE(" SET FOREIGN_KEY_CHECKS = 0")
  oRecibo:lAuditar:=.F.
  oRecibo:Replace("REC_FECHA" ,oDocFav:DOC_FECHA )
  oRecibo:Replace("REC_HORA"  ,oDocFav:DOC_HORA  )
  oRecibo:Replace("REC_CODCOB",oDocFav:DOC_CODVEN)
  oRecibo:Replace("REC_CODMON",oDocFav:DOC_CODMON)
  oRecibo:Replace("REC_CODIGO",oDocFav:DOC_CODIGO)
  oRecibo:Replace("REC_TIPPAG",IF(oDocFav:lAnticipo,"A","P"))
  oRecibo:Replace("REC_CODSUC",oDocFav:DOC_CODSUC) // oDp:cSucursal   )
  oRecibo:Replace("REC_CENCOS",oDocFav:DOC_CENCOS) // oDp:cCenCos     )
  oRecibo:Replace("REC_ESTADO","Activo"          )
  oRecibo:Replace("REC_ACT"   ,1                 )
  oRecibo:Replace("REC_LETRA" ,oDocFav:DOC_SERFIS)
  oRecibo:Replace("REC_FCHREG",oDocFav:DOC_FECHA )
  oRecibo:Replace("REC_MTOIVA",oDocFav:DOC_MTOIVA) // Monto Pagado + IGTF
  oRecibo:Replace("REC_TIPDOC",oDocFav:DOC_TIPDOC)
  oRecibo:Replace("REC_NUMDOC",oDocFav:DOC_NUMERO)

  oRecibo:Replace("REC_MONTO" ,oDocFav:nMtoPag   ) // Monto Pagado + IGTF
  oRecibo:Replace("REC_MTOITF",oDocFav:nMtoIGTF  ) // oDoc:nMtoIGTF
  oRecibo:Replace("REC_CODCAJ",oDocFav:cCodCaja  ) //oDp:cCodCaja
  oRecibo:Replace("REC_VALCAM",oDocFav:nValCam   ) // Dolar utilizado para el Pago

  oRecibo:Replace("REC_DIFCAM",oDocFav:lDifCambiario)

  // ticket no genera Registro de recibo de ingreso

  IF !oDocFav:DOC_TIPDOC="TIK"
    oRecibo:lTicket:=.F.
    oRecibo:cTipDoc:=""
    oRecibo:Commit(oRecibo:cWhere)
  ELSE
    oRecibo:lTicket:=.T.
    oRecibo:cTipDoc:="TIK"
  ENDIF
  
  oDocFav:oRecibo:=oRecibo
 
  oDocCli:cNomCli :=oDocCli:oCliNombre:GetText()
  oDocCli:lCliente:=.T.

  EJECUTAR("DPRECIBODIVBANCO",oDocFav,oDocFav:DOC_CODSUC,ACLONE(aData),cNumero,oDocFav:DOC_CODIGO,oDocFav:cCodCaja,oDocFav:DOC_FECHA,oDocFav:cNomCli,NIL,oRecibo)
  EJECUTAR("DPRECIBODIVCAJA" ,oDocFav,oDocFav:DOC_CODSUC,ACLONE(aData),cNumero,oDocFav:DOC_CODIGO,oDocFav:cCodCaja,oDocFav:DOC_FECHA,oDocFav:cNomCli)

  // numero del Recibo de Ingreso
  cWhere:="DOC_CODSUC"+GetWhere("=",oDocFav:DOC_CODSUC)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",oDocFav:DOC_TIPDOC)+" AND "+;
          "DOC_NUMERO"+GetWhere("=",oDocFav:DOC_NUMERO)+" AND "+;
          "DOC_TIPTRA"+GetWhere("=","D")

  SQLUPDATE("DPDOCCLI","DOC_RECNUM",cNumero,cWhere)

  oRecibo:End()

? oDp:cSql

RETURN .T.
// EOF

