// Programa   : DPCLIENTESTORIF
// Fecha/Hora : 23/04/2017 20:06:49
// Propósito  : Crear registros de DPRIF que no esten en la tabla de DPCLIENTES
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
   LOCAL oTable,oRif,cRif,nRif:=0,cMemo:="",cFileTxt:=oDp:cEmpCod+"DPCLIENTES.TXT",cRif_:="",cLine:="",cMemo:="",nNumMem:=0,cWhere
   LOCAL oRifU,oDb:=OpenOdbc(oDp:cDsnData),cSql
   /*
   // Ubicamos al Proveedor con RIF Vacios
   */

oDp:lCliToRif:=.F.

   IF !oDp:lCliToRif .AND. Empty(cCodCli)
      RETURN .F.
   ENDIF

   CursorWait()

IF Empty(cCodCli)

//    cSql:="SET FOREIGN_KEY_CHECKS = 0"
 //    oDb:EXECUTE(cSql)

    IF COUNT("DPCLIENTES","CLI_RIF"+GetWhere("=",""))>0
       cSql:=[ DELETE dprif   FROM dprif  JOIN DPCLIENTES ON RIF_ID=CLI_RIF]
       oDb:EXECUTE(cSql)
    ENDIF

    cSql:=[UPDATE dpclientes SET CLI_RIF=CLI_CODIGO WHERE CLI_RIF="" ]
    oDb:EXECUTE(cSql)

    oTable:=OpenTable("SELECT CLI_CODIGO,CLI_RIF FROM DPCLIENTES WHERE CLI_RIF"+GetWhere("=",""))

    WHILE !oTable:Eof()

      nRif++
      cRif:=STRZERO(nRif,9)

      cRif:=oTable:CLI_CODIGO

      IF ISSQLFIND("DPCLIENTES","CLI_RIF"+GetWhere("=",cRif))
         oTable:DbSkip()
         LOOP
      ENDIF
 
      cLine:=oTable:CLI_CODIGO+CHR(9)+oTable:CLI_RIF+CHR(9)+cRif
      cMemo:=cMemo+IF(Empty(cMemo),"",CRLF)+cLine

      SQLDELETE("DPRIF","RIF_ID"+GetWhere("=",cRif))
      SQLUPDATE("DPCLIENTES",{"CLI_RIF","CLI_RIFVAL"},{cRif,.F.},"CLI_CODIGO"+GetWhere("=",oTable:CLI_CODIGO))

      nRif++
      oTable:DbSkip()

   ENDDO

   oTable:End()

   /*
   // Ubicamos al Proveedor con RIF Repetidos
   */

   oTable:=OpenTable("SELECT CLI_RIF,COUNT(*) FROM DPCLIENTES GROUP BY CLI_RIF HAVING COUNT(*)>1 ")

   IF oTable:RecCount()>0
      lMkDir("ERRORLOG")
      oTable:CTOHTML("ERRORLOG\CLIENTESCONRIFREPETIDOS.HTML")
      // EJECUTAR("DPDROP_FK","DPCLIENTES")
      // EJECUTAR("DPDROP_PK","DPCLIENTES")
      // oTable:Browse()
   ENDIF

   // 
   // Genera incidencias cuando trata de ser importado, recomendacion, realizar una copia en la tabla, aplicarle un correlativo y luego migrarla hacia adaptapro.
   // 

   WHILE !oTable:Eof() .AND. oDp:lCliToRif

      oRif:=OpenTable("SELECT DPCLIENTES.CLI_CODIGO,DPCLIENTES.CLI_RIF FROM DPCLIENTES WHERE DPCLIENTES.CLI_RIF"+GetWhere("=",oTable:CLI_RIF),.T.)
      oRif:Execute("SET FOREIGN_KEY_CHECKS = 0")

      WHILE !oRif:Eof()

          cRif_:=oRif:CLI_RIF

          WHILE !oRif:Eof() .AND. oRif:CLI_RIF=cRif_  .AND. oRif:RecNo()<oRif:RecCount()

            nRif++
            cRif:=STRZERO(nRif,9)

            IF ISSQLFIND("DPCLIENTES","CLI_RIF"+GetWhere("=",cRif))
              LOOP
            ENDIF

            cLine:=oRif:CLI_CODIGO+CHR(9)+oTable:CLI_RIF+CHR(9)+cRif
            cMemo:=cMemo+IF(Empty(cMemo),"",CRLF)+cLine

//          SQLUPDATE("DPCLIENTES",{"CLI_RIF","CLI_RIFVAL"},{cRif,.F.},"CLI_CODIGO"+GetWhere("=",oRif:CLI_CODIGO))
            SQLUPDATE("DPCLIENTES",{"CLI_RIF","CLI_RIFVAL"},{cRif,.F.},"CLI_RIF"+GetWhere("=",cRif_)+" LIMIT 1")

            oRif:DbSkip()

          ENDDO

          oRif:DbSkip()

      ENDDO

     oTable:DbSkip()

   ENDDO

   oTable:End()

   IF !Empty(cMemo)

     DPWRITE(cFileTxt,cMemo)
 
     cWhere:="MEM_DESCRI"+GetWhere("=",cFileTxt)

     oTable:=OpenTable("SELECT * FROM DPMEMO WHERE "+cWhere,.T.)

     IF oTable:RecCount()=0
       nNumMem:=SQLINCREMENTAL("DPMEMO","MEM_NUMERO")
       oTable:AppendBlank()
       oTable:cWhere:=""
     ELSE
       cMemo :=ALLTRIM(oTable:MEM_MEMO)+CRLF+cMemo
       nNumMem:=oTable:MEM_NUMERO
     ENDIF

     oTable:Replace("MEM_MEMO"  ,cMemo   )
     oTable:Replace("MEM_DESCRI",cFileTxt)
     oTable:Replace("MEM_NUMERO",nNumMem )
     oTable:Commit(oTable:cWhere)
     oTable:lAuditar:=.F.
     oTable:End()

   ENDIF

   CursorWait()

ENDIF

   cWhere:=IF(Empty(cCodCli)," RIF_ID IS NULL "," CLI_CODIGO"+GetWhere("=",cCodCli))

   IF Empty(cCodCli)
      DpMsgRun("Creando Registro RIF Desde Clientes",NIL,"Leyendo Clientes")
   ENDIF

   oTable:=OpenTable("SELECT CLI_CODIGO,DPCLIENTES.CLI_RIF,CLI_TIPPER,CLI_RESIDE,CLI_NOMBRE FROM DPCLIENTES LEFT JOIN DPRIF ON DPCLIENTES.CLI_RIF=RIF_ID WHERE "+cWhere+" ORDER BY CLI_CODIGO ",.T.)

// oTable:Browse()
	
   IF Empty(cCodCli)
     DpMsgSetTotal(oTable:RecCount())
   ENDIF

// ? CLPCOPY(oTable:cSql)
// oTable:Browse()
// oTable:End()

   // oRif  :=OpenTable("SELECT * FROM DPRIF",.F.)
   oRif:=OpenTable("DPRIF",.F.)
   oRif:SetInsert(100)

   WHILE !oTable:Eof() .AND. oDp:lCliToRif


        cRif:=oTable:CLI_RIF

        IF Empty(cCodCli) .AND. oTable:Recno()%40=0
          DpMsgSet(oTable:Recno(),.T.,NIL,"Cliente:"+oTable:CLI_CODIGO+" "+LSTR(RATA(oTable:RecNo()),oTable:RecCount()))
        ENDIF

  
        oRif:AppendBlank()
        oRif:Replace("RIF_ID"  ,cRif)
        oRif:Replace("RIF_CLIENTE",.T.)
        oRif:Replace("RIF_TIPPER",oTable:CLI_TIPPER)
        oRif:Replace("RIF_RESIDE",oTable:CLI_RESIDE="S" .OR. Empty(oTable:CLI_RESIDE))
        oRif:Replace("RIF_NOMBRE",oTable:CLI_NOMBRE)
        oRif:lAuditar:=.F.
        oRif:Commit()


/*
        cRif:=STRTRAN(oTable:CLI_RIF,"-","")
        cRif:=STRTRAN(cRif          ," ","")
        cRif:=STRTRAN(cRif          ,".","")
        cRif:=ALLTRIM(cRif)

        
        IF !ISSQLFIND("DPCLIENTES","CLI_RIF"+GetWhere("=",cRif))
          SQLUPDATE("DPCLIENTES","CLI_RIF",cRif,"CLI_CODIGO"+GetWhere("=",oTable:CLI_CODIGO))
          oTable:Replace("CLI_RIF",cRif)
        ELSE
          cRif:=oTable:CLI_RIF
        ENDIF

        IF oTable:Recno()%10=0
           SysRefresh(.T.)
        ENDIF

        IF !ISSQLFIND("DPRIF","RIF_ID"+GetWhere("=",cRif)) 

//.AND. COUNT("DPRIF","RIF_ID"+GetWhere("=",cRif))=0

          oRif:AppendBlank()
          oRif:Replace("RIF_ID"  ,cRif)
          oRif:Replace("RIF_CLIENTE",.T.)
          oRif:Replace("RIF_TIPPER",oTable:CLI_TIPPER)
          oRif:Replace("RIF_RESIDE",oTable:CLI_RESIDE="S" .OR. Empty(oTable:CLI_RESIDE))
          oRif:Replace("RIF_NOMBRE",oTable:CLI_NOMBRE)
          oRif:lAuditar:=.F.
          oRif:Commit()

        ELSE

          oRifU:=OpenTable("SELECT * FROM DPRIF WHERE RIF_ID"+GetWhere("=",cRif))
          oRifU:Replace("RIF_ID"  ,cRif)
          oRifU:Replace("RIF_CLIENTE",.T.)
          oRifU:Replace("RIF_TIPPER",oTable:CLI_TIPPER)
          oRifU:Replace("RIF_RESIDE",oTable:CLI_RESIDE="S" .OR. Empty(oTable:CLI_RESIDE))
          oRifU:Replace("RIF_NOMBRE",oTable:CLI_NOMBRE)
          oRifU:lAuditar:=.F.
          oRifU:Commit()
          oRifU:End()

          /// SQLUPDATE("DPRIF",{"RIF_CLIENTE","RIF_TIPPER","RIF_RESIDE","RIF_NOMBRE"},{.T.,oTable:CLI_TIPPER,oTable:CLI_RESIDE="S" .OR. Empty(oTable:CLI_RESIDE),oTable:CLI_NOMBRE},"RIF_ID"+GetWhere("=",cRif))

        ENDIF
*/

        oTable:DbSkip()

    ENDDO

    oRif:End()
    oTable:End()

RETURN NIL
// EOF
