// Programa   : DPDOCCLIIMPDIGJSON
// Fecha/Hora : 12/08/2005 15:29:42
// Propósito  : Impresion Digital
// Creado Por : Juan Navas
// Llamado por: DOCTOTAL
// Aplicación : Ventas
// Tabla      : DPDOCCLIIVA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cJsonE,cJsonM,cJsonP,cTitleM,cTitleP)
  LOCAL cJson:="",nAt

  DEFAULT cTitleM:="cuerpofactura",;
          cTitleP:="formasdepago",;
          cJsonE :="",;
          cJsonM :="",;
          cJsonP :=""

  cTitleM:=["]+cTitleM+[": ]+""
  cTitleP:=["]+cTitleP+[": ]+""

  nAt   :=RAT("}",cJsonM)
  cJsonM:=LEFT(cJsonM,nAt-1)+CRLF+"}"
 
  nAt   :=RAT("}",cJsonP)
  cJsonP:=LEFT(cJsonP,nAt-1)+CRLF+"}"



  nAt    :=RAT("}",cJsonE)
  cJson  :=LEFT(cJsonE,nAt-1)+CRLF+;
           cTitleM+"[ "+CRLF+SPACE(5)+;
           cJsonM+CRLF+"],"+CRLF+;
           cTitleP+"[ "+CRLF+SPACE(5)+;
           cJsonP+CRLF+"],"+CRLF

   nAt   :=RAT(",",cJson)
   cJson:=LEFT(cJson,nAt-1)+CRLF+"}"

RETURN cJson
// eof
