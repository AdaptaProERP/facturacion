// Programa   : DPCLIENTESCEROCREA
// Fecha/Hora : 26/07/2022 17:24:49
// Propósito  : Crear Cliente Cero para documentos con Clientes ocasionales
// Creado Por : Juan navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,cRif,cNombre,cDir1,cDir2,cDir3,cMuni,cZona,cCodCla)
  LOCAL cWhere
  LOCAL oTable

  DEFAULT cCodSuc:=oDp:cSucursal

  IF cTipDoc=NIL
     RETURN .F.
  ENDIF

  cWhere :="CCG_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "CCG_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "CCG_NUMDOC"+GetWhere("=",cNumero)

  oTable:=OpenTable("SELECT * "+;
                    "FROM DPCLIENTESCERO WHERE "+cWhere,.T.)


  IF oTable:RecCount()=0
     oTable:cWhere:=""
     oTable:Append()
  ENDIF

  oTable:Replace("CCG_CODSUC",cCodSuc)
  oTable:Replace("CCG_TIPDOC",cTipDoc)
  oTable:Replace("CCG_NUMDOC",cNumero)
  oTable:Replace("CCG_RIF"   ,cRif   )
  oTable:Replace("CCG_NOMBRE",cNombre)
  oTable:Replace("CCG_DIR1"  ,cDir1  )
  oTable:Replace("CCG_DIR2"  ,cDir2  )
  oTable:Replace("CCG_DIR3"  ,cDir3  )
  oTable:Replace("CCG_DIR4"  ,cMuni  )
  oTable:Replace("CCG_DIR5"  ,cZona  )
  oTable:Replace("CCG_TEL1"  ,cTel   )
  oTable:Replace("CCG_TIPTRA","D"    )
  oTable:Replace("CCG_CODCLA",cCodCla) 
  oTable:Commit(oTable:cWhere)
  oTable:End()

RETURN .T.
// EOF
