// Programa   : DPCLIENTESREC
// Fecha/Hora : 20/11/2019 04:44:26
// Propósito  : Recursos del Cliente
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,cWhere,oGet)

   DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

// ,NIL,"TPP_ACTIVO=1",NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_DESTIN,NIL)
   IF .T.
      EJECUTAR("DPCLIENTESRECVEHLBX",cCodCli,cWhere,oGet)
   ENDIF

// ? cCodCli

RETURN .T.
// EOF
