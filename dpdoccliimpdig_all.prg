// Programa   : DPDOCCLIIMPDIG_ALL
// Fecha/Hora : 12/08/2005 15:29:42
// Propósito  : Impresion Digital
// Creado Por : Juan Navas
// Llamado por: DOCTOTAL
// Aplicación : Ventas
// Tabla      : DPDOCCLIIVA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero)
   LOCAL oDocCli,cWhere,oTable,cJsonE:="",cSql,cLine,cIni,cJsonM:="",cJsonP:="",nAt,cJson:="",oTable
   LOCAL aTipDoc:={"FAV","DEB","CRE","GDD","NEN"} // Tipo de documento (factura=1, Nota de débito=2, nota de crédito=3, Guía de despacho=4, Nota de Entrega = 5) 
   LOCAL nTipDoc:=1,cRif:=""

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAV",;
           cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND DOC_TIPTRA"+GetWhere("=","D"))

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")

   DPDOCCLIIMP(cCodSuc,cTipDoc,NIL,cNumero,.F.)

   cSql:=[ SELECT ]+;
         [ DOC_NUMERO    AS numerointerno,    ]+CRLF+;
         [ "J-404524142" AS rif,              ]+CRLF+;
         [ DOC_NUMERO    AS trackingid,       ]+CRLF+;
         [ CLI_NOMBRE    AS nombrecliente,    ]+CRLF+;
         [ ]+LSTR(nTipDoc,1)+[ AS idtipodocumento,]+CRLF+;
         [ CLI_RIF       AS rifcedulacliente, ]+CRLF+;
         [ CLI_EMAIL     AS emailcliente    , ]+CRLF+;
         [ CONCAT(CLI_AREA," ",CLI_TEL1," ",CLI_TEL2," ",CLI_TEL3," ",CLI_TEL4) AS telefonocliente,]+CRLF+;
         [ CONCAT(CLI_DIR1," ",CLI_DIR2," ",CLI_DIR3," ",CLI_DIR4) AS direccioncliente,]+CRLF+;
         [ 3            AS idtipocedulacliente,]+CRLF+;
         [ DOC_NETO-DOC_MTOIVA  AS subtotal  ,]+CRLF+; 
         [ DOC_MTOEXE           AS exento    ,]+CRLF+;
         [ ]+LSTR(oDp:POR_GN,19,2)+[ AS tasag     ,]+CRLF+;
         [ ]+LSTR(oDp:BAS_GN,19,2)+[ AS baseg     ,]+CRLF+;
         [ ]+LSTR(oDp:IVA_GN,19,2)+[ AS impuestog ,]+CRLF+;
         [ ]+LSTR(oDp:POR_RD,19,2)+[ AS tasar     ,]+CRLF+;
         [ ]+LSTR(oDp:BAS_RD,19,2)+[ AS baser     ,]+CRLF+;
         [ ]+LSTR(oDp:IVA_RD,19,2)+[ AS impuestor ,]+CRLF+;
         [ ]+LSTR(oDp:POR_S1,19,2)+[ AS tasaa ,]+CRLF+;
         [ ]+LSTR(oDp:BAS_S1,19,2)+[ AS basea ,]+CRLF+;
         [ ]+LSTR(oDp:IVA_S1,19,2)+[ AS impuestoa ,]+CRLF+;
         [ 0.00                 AS tasaigtf    ,]+CRLF+;
         [ 0.00                 AS baseigtf    ,]+CRLF+;
         [ 0.00                 AS impuestoigtf,]+CRLF+;
         [ DOC_NETO             AS total       ,]+CRLF+;
         [ 1                    AS sendmail    ,]+CRLF+;
         [ "]+cCodSuc+["        AS sucursal    ,]+CRLF+;
         [ "bs"                 AS moneda      ,]+CRLF+;
         [ DOC_VALCAM           AS tasacambio  ,]+CRLF+;
         [ ""                   AS observacion ,]+CRLF+;
         [ CONCAT(DOC_FECHA," ",DOC_HORA) AS fecha_emision]+CRLF+;
         [ FROM DPDOCCLI ]+;
         [ INNER JOIN DPCLIENTES ON DOC_CODIGO=CLI_CODIGO ]+;
         [ WHERE ]+cWhere

   
//   oTable:=OpenTable(cSql,.T.)
   cJsonE:=EJECUTAR("TTABLETOJSON",cSql,NIL,",")
//   oTable:End()

   cSql:=[SELECT ]+;
         [ DOC_CONDIC  AS forma,]+CRLF+;
         [ DOC_NETO  AS monto ]+CRLF+;
         [ FROM DPDOCCLI ]+;
         [ WHERE ]+cWhere
    
   cJsonP:=EJECUTAR("TTABLETOJSON",cSql)

   cWhere:="MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",cNumero)+" AND "+;
           "MOV_APLORG"+GetWhere("=","V")

   cSql:=[SELECT ]+;
         [ MOV_CODIGO  AS codigo,     ]+CRLF+;
         [ INV_DESCRI  AS descripcion,]+CRLF+;
         [ MEM_DESCRI  AS comentario, ]+CRLF+;
         [ MOV_PRECIO  AS precio,     ]+CRLF+;
         [ MOV_CANTID  AS cantidad,   ]+CRLF+;
         [ MOV_IVA     AS tasa,       ]+CRLF+;
         [ MOV_DESCUE     AS descuento,  ]+CRLF+;
         [ IF(MOV_IVA=0,"true","false") AS exento,]+CRLF+;
         [ MOV_TOTAL   AS monto       ]+CRLF+;
         [ FROM DPMOVINV ]+;
         [ INNER JOIN DPINV  ON MOV_CODIGO=INV_CODIGO ]+;
         [ LEFT  JOIN DPMEMO ON INV_NUMMEM=MEM_NUMERO ]+;
         [ WHERE ]+cWhere
    
  cJsonM:=EJECUTAR("TTABLETOJSON",cSql,10)
  cJson :=EJECUTAR("DPDOCCLIIMPDIGJSON",cJsonE,cJsonM,cJsonP,"cuerpofactura","formasdepago")

  dpwrite("factura.txt",cJson)

//? CLPCOPY(cJson)

  EJECUTAR("TESTFACTURADIGITAL","factura.txt")
   
RETURN .F.
// EOF

