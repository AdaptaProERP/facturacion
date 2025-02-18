// Programa   : SQLDELETE_DPDOCCLI
// Fecha/Hora : 09/02/2025 11:43:30
// Propósito  : REMOVER REGISTROS
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cWhere,lChkInt,oOdbc,lSay)
   LOCAL cTable   :="DPDOCCLI",cSql,oTable,nCuantos:=0
   LOCAL aTipDoc  :={"FAV","DEB","CRE","NEN","DEV","TIK"}
   LOCAL cWhereDoc:=GetWhereOr("DOC_TIPDOC",aTipDoc)+" AND DOC_TIPTRA"+GetWhere("=","D")

   DEFAULT cWhere:="DOC_TIPTRA"+GetWhere("=","D")

   IF !Empty(cWhere)
      cWhere:=cWhere+" AND "+cWhereDoc
   ELSE
      cWhere:=cWhereDoc
   ENDIF

   nCuantos:=COUNT(cTable,cWhere)

? nCuantos,cTable,oDp:cSql


//   cSql:="SELECT * FROM "+cTable+" WHERE "+cWhere
//
//   oTable:=OpenTable(cSql,.T.)
//   oTable:Browse()
// ? oTable:ClassName(),cWhere,cSql
//   oTable:End()

RETURN .T.
// EOF
