// Programa   : EXPDPCLIENTES
// Fecha/Hora : 06/01/2011 01:49:55
// Propósito  : Exportar Clientes
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL oTable

   oTable:=OpenTable("SELECT * FROM DPCLIENTES",.T.)
   oTable:CTODBF("ejemplo\dpclientes.dbf")
   OTable:END()

RETURN NIL
// EOF


