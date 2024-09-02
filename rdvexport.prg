// Programa   : RDVEXPORT
// Fecha/Hora : 30/08/2024 03:12:36
// Propósito  : Exportar Transacciones de Ventas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cRif)

    DEFAULT cCodSuc :=oDp:cSucursal,;
            nPeriodo:=oDp:nMensual,;
            dDesde  :=FCHINIMES(oDp:dFecha),;
            dHasta  :=FCHFINMES(oDp:dFecha),;
            cRif    :=oDp:cRif

// ?  cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cRif

   RDVEXPORT(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)

RETURN .T.

/*
// Exportar RDV
*/
FUNCTION RDVEXPORT(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cDir,cRif)
   LOCAL aTablas:={},cInner:="",oTable,I,cFileDbf,cFileFpt,aFiles:={},cFileZip,cSql

   DEFAULT cDir:=oDp:cBin+"diarioventas\"

   LMKDIR(cDir)

   cFileZip:=cDir+"rdv_"+cCodSuc+".zip"

   AADD(aTablas,{"dpdoccli"," WHERE DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)})

   // Clientes
   cInner:=" INNER JOIN DPDOCCLI ON DOC_CODIGO=CLI_CODIGO AND "+;
           " DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)+" GROUP BY CLI_CODIGO "


   AADD(aTablas,{"dpclientes",cInner}	)


   // Vendedores
   cInner:=" INNER JOIN DPDOCCLI ON DOC_CODVEN=VEN_CODIGO AND "+;
           " DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)+" GROUP BY VEN_CODIGO "

   AADD(aTablas,{"dpvendedor",cInner}	)

   AADD(aTablas,{"dpreciboscli" ," WHERE REC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("REC_FECHA",dDesde,dHasta)})
   AADD(aTablas,{"dpcajamov"    ," WHERE CAJ_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("CAJ_FECHA",dDesde,dHasta)})
   AADD(aTablas,{"dpctabancomov"," WHERE MOB_CODSUC"+GetWhere("=",cCodSuc)+" AND "+GetWhereAnd("MOB_FECHA",dDesde,dHasta)})
 
//   ViewArray(aTablas)

   FOR I=1 TO LEN(aTablas)

     cFileDbf:=lower(cDir+aTablas[I,1]+".dbf")
     cFileFpt:=lower(cDir+aTablas[I,1]+".fpt")

     cSql    :="SELECT * FROM "+aTablas[I,1]+" "+aTablas[I,2]
     oTable  :=OpenTable(cSql,.T.)

     oTable:CTODBF(cFileDbf)
     oTable:End()

     AADD(aFiles,cFileDbf)

     IF FILE(cFileFpt)
        AADD(aFiles,cFileFpt)
     ENDIF

// ? I,cSql,cFileDbf

   NEXT I

   HB_ZipFile( cFileZip, aFiles, 9,,.T., NIL, .F., .F. )

//    ViewArray(aFiles)
// ? cFileZip,FILE(cFileZip),oDp:cRifLic

   IF FILE(cFileZip)
     aFiles:={}
     AADD(aFiles,{cFileZip})
 
     oDp:lMYSQLCHKCONN:=.F.

// ? "DESACTIVAMOS MYSQLCH"
//   ErrorSys(.T.)

     UP_PERSONALIZA(aFiles)
    
// ? "SUBIDO EN ADAPTAPRO SERVER,"
   ENDIF

RETURN .T.
