// Programa   : DPCLIENTESRECHUMLBX
// Fecha/Hora : 21/05/2019 04:53:13
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,cWhereIni,oGet)
  LOCAL cTitle
  LOCAL cWhere,oLbx,cNombre

  DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

  EJECUTAR("DPCLIENTESRECDEF")

  cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))

//  cTitle :=ALLTRIM(GetFromVar("{oDp:DPCLIENTESREC}"))+;
//                " ["+cCodCli+" "+ALLTRIM(cNombre)+"]"

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTESREC}"))+;
         " ["+oDp:DPCLIENTESREC_HUMANO+ "] ["+cCodCli+" "+ALLTRIM(cNombre)+"]"


  cWhere:="CRC_CODCLI"+GetWhere("=",cCodCli)+" AND CRC_TIPO"+GetWhere("=",oDp:DPCLIENTESREC_HUMANO)+;
          IF(Empty(cWhereIni),""," AND "+cWhereIni)

  oDp:aCargo:={"",cCodCli,"DPCLIENTES","",""}
  oLbx:=DPLBX("dpclientesrechumano.lbx",cTitle,cWhere)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5N£meroDoc
  oLbx:aCargo:=oDp:aCargo
  oLbx:cScope:=cWhere

RETURN .T.
// EOF
