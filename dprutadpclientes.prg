// Programa   : DPRUTADPCLIENTES
// Fecha/Hora : 07/07/2017 15:12:31
// Propósito  : Realiza la Asignación de oDp:cCodRuta con DPCLIENTES
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   EJECUTAR("DPRUTAINDEF")

   IF !Empty(oDp:cCodRuta)
      SQLUPDATE("DPCLIENTES","CLI_CODRUT",oDp:cCodRuta,"CLI_CODRUT IS NULL OR CLI_CODRUT"+GetWhere("=",""))
   ENDIF
 
RETURN NIL
// EOF


