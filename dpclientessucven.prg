// Programa   : DPCLIENTESSUCVEN
// Fecha/Hora : 20/09/2017 03:14:02
// Propósito  : Asignar Codigo del Vendedor 
// Creado Por :
// Llamado por: Integridad referencial
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
LOCAL cSql

   cSql:=" UPDATE DPCLIENTESSUC "+;
         " INNER JOIN DPCLIENTES ON SDC_CODCLI=CLI_CODIGO"+;
         " SET SDC_CODVEN=CLI_CODVEN "+;
         " WHERE SDC_CODVEN IS NULL "

   OPENODBC(oDp:cDsnData):Execute(cSql)

RETURN NIL
// EOF
