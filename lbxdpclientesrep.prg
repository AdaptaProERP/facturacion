// Programa   : LBXDPCLIENTESREP
// Fecha/Hora : 16/03/2019 07:23:41
// Prop�sito  : Emitir Reporte desde LBX de Clientes
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oLbx,oCursor)
   LOCAL cWhere,cTitle
  
   IF oLbx=NIL
      RETURN NIL
   ENDIF


   IF !Empty(oLbx:aParam[1])
      cWhere:="CLI_CODVEN"+GetWhere("=",oLbx:aParam[1])
      cTitle:="Clientes del Vendedor "+oLbx:aParam[1]+" "+SQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oLbx:aParam[1]))
   ENDIF

   REPORTE("DPLISCLIENTE",cWhere,NIL,NIL,cTitle)
  
RETURN NIL
// EOF
