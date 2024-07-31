// Programa   : DPCLIENTESBRW
// Fecha/Hora : 13/06/2024 00:44:31
// Propósito  : Presentar lista de clientes por Fecha
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oTable,oFrm)
  LOCAL nAt,oBtnBrw,dDesde,dHasta,cWhere:=NIL,cTitle2:="",uValue,lResp,uValueIni
  LOCAL cList:="DPCLIENTES.BRW"

  IF oFrm=NIL
     RETURN NIL
  ENDIF

  nAt    :=ASCAN(oFrm:aButtons,{|a,n| a[7]="BROWSE"})
  oBtnBrw:=IF(nAt>0,oFrm:aButtons[nAt,1],NIL)
  dHasta :=SQLGETMAX("DPCLIENTES","CLI_FECHA")
  dDesde :=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPCLIENTES",cWhere,"CLI_FECHA",dDesde,dHasta,oBtnBrw,oFrm:cTitle)
     RETURN .T.
  ENDIF

  IF Empty(cTitle2)
     cTitle2:=" Rango "+F8(oDp:dFchIniDoc)+"-"+F8(oDp:dFchFinDoc)
  ENDIF

  SETDBSERVER(oFrm:oDb) 

  uValue   :=oTable:GetValue(oTable:cPrimary)
  uValueIni:=uValue
  cWhere   :=GetWhereAnd("CLI_FECHA",oDp:dFchIniDoc,oDp:dFchFinDoc)

  lResp    :=DPBRWPAG(cList,NIL,@uValue,oTable:cPrimary,.T.,cWhere,cTitle2,oFrm:oDb)

  SETDBSERVER()

  IF uValue<>uValueIni

    oTable:cSql:="SELECT * FROM "+oTable:cTable+" WHERE CLI_CODIGO"+GetWhere("=",uValue) + " LIMIT 1"

    oTable:Reload()

    oFrm:Load(0)

    EJECUTAR("DPSAVEFIND",oTable:cTable,oTable:cPrimary,uValue)

  ENDIF

RETURN .T.
// EOF