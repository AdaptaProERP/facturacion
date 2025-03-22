// Programa   : VTACLINOMBRE
// Fecha/Hora : 09/10/2005 11:31:10
// Propósito  : Mostrar Nombre del CLiente
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc,cCodigo)
  LOCAL cNombre:="",cRif:="",nLen

  DEFAULT cCodigo:=oDoc:DOC_CODIGO

  IF !ValType(cCodigo)="C"
//? cCodigo,"oDoc:DOC_CODIGO"
    RETURN .F.
  ENDIF


  IF cCodigo=STRZERO(0,10)

    IF oDoc:nOption=1
        RETURN oDoc:CCG_NOMBRE
    ENDIF

    cNombre:=SQLGET("DPCLIENTESCERO","CCG_NOMBRE,CCG_RIF","CCG_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                                                  "CCG_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                                                  "CCG_NUMDOC"+GetWhere("=",oDoc:DOC_NUMERO))

    cRif   :=DPSQLROW(2,"")
    cNombre:=ALLTRIM(cNombre)+" RIF "+cRif

  ELSE

    cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_RIF","CLI_CODIGO"+GetWhere("=",oDoc:DOC_CODIGO)) 
    cRif   :=DPSQLROW(2,"")

  ENDIF

  nLen   :=LEN(cNombre)
  IF ALLTRIM(cCodigo)<>ALLTRIM(cRif)
    cNombre:=ALLTRIM(cNombre)+" RIF:"+cRif
  ENDIF

RETURN cNombre
// EOF
