// Programa   : DOCCLIAFTERSAVE
// Fecha/Hora : 01/11/2021 18:42:11
// Propósito  : Post-Grabar
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cDirTo,nOption)
   LOCAL cTipPro:="XXJ",cSql,cDb,cTipDes,oTable
   LOCAL cRif,cCodEmp,oDoc,oMov,oInv,oCli

   DEFAULT cTipDoc:="FAV",;
           cDirTo :="DATAEXPORT\",;
           nOption:=1

//   IF !ISRELEASE("21.10")
//       RETURN .T.
//   ENDIF

   IF nOption=3
// 06/06/2024 hace lento el sistema alfta volumen de registro      EJECUTAR("DPMOVINVREPETIDOS",cCodSuc,cTipDoc,cCodigo,cNumero)
   ENDIF

   cNumero:=ALLTRIM(cNumero)

  

   cTipPro:=SQLGET("DPTIPDOCCLI","TDC_TIPPRO,TDC_DOCDES","TDC_TIPO"+GetWhere("=",cTipDoc))
   cTipDes:=DPSQLROW(2,"")


? "CREAR DOCUMENTO DESTINO",cTipPro,cTipDes

   IF !Empty(cTipDes)


    cWhere:="DOF_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "DOF_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
            "DOF_NUMERO"+GetWhere("=",cNumero)+" AND "+;
            "DOF_TIPTRA"+GetWhere("=",cTipTra)

    DEFAULT oDp:oTableDocFlow:=OpenTable("SELECT * FROM DPDOCCLIFLOW",.F.)


    oDp:oTableDocFlow:AppendBlank()
    oDp:oTableDocFlow:Replace("DOF_CODSUC",cCodSuc)
    oDp:oTableDocFlow:Replace("DOF_TIPDOC",cTipDoc)
    oDp:oTableDocFlow:Replace("DOF_NUMERO",cNumero)
    oDp:oTableDocFlow:Replace("DOF_TIPTRA","D"    )
    oDp:oTableDocFlow:Replace("DOF_TIPDES",cTipDes)
    oDp:oTableDocFlow:Commit()

/*    
20/03/2025
   EJECUTAR("CREATERECORD","DPDOCCLIFLOW",{"DOF_CODSUC","DOF_TIPDOC","DOF_NUMERO","DOF_TIPTRA","DOF_TIPDES"},;
                                          {cCodSuc     ,cTipDoc     ,cNumero     ,cTipTra     ,cTipDes     },;
            NIL,.T.,cWhere)


     EJECUTAR("DPDOCCLIFLOWCREA",cCodSuc,cTipDoc,cNumero)
*/

   ENDIF


   // 20/03/2025 Depende del plugIn Gestion de Sociedades
   IF !oDp:lFavtocompras
       RETURN .T.
   ENDIF

/*
   IF !ISRELEASE("21.10")
       RETURN .T.
   ENDIF
*/

   IF Empty(cTipPro)
      RETURN .F.
   ENDIF

   cRif   :=SQLGET("DPCLIENTES","CLI_RIF","CLI_CODIGO"+GetWhere("=",cCodigo))
   cRif   :=STRTRAN(cRif,"-","")
   cDb    :=SQLGET("DPEMPRESA","EMP_BD","EMP_RIF"+GetWhere("=",cRif))

   IF Empty(cDb)
     RETURN .F.
   ENDIF
  
   lMkDir(cDirTo)

   oDb:=OpenOdbc(cDb)

   oCli:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",cCodigo)+" LIMIT 1",.T.)
   oCli:CTODBF(cDirTo+"DPCLIENTES_"+cTipDoc+"_"+cNumero+".DBF")
   oCli:End()

   cWhere  :="DOC_CODSUC"+GetWhere("=",cCodSuc      )+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumero      )+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D"          )

   SQLUPDATE("DPDOCCLI","DOC_RIF",cRif,cWhere)

   oDoc:=OpenTable("SELECT * FROM DPDOCCLI WHERE "+cWhere,.T.)
   oDoc:CTODBF(cDirTo+"DPDOCCLI_"+cTipDoc+"_"+cNumero+".DBF")
   oDoc:End()

   cWhere:="MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
           "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO)+" AND MOV_INVACT=1 AND MOV_APLORG='V' "

   cSql:=" SELECT "+SELECTFROM("DPINV",.F.)+;
         " FROM DPMOVINV "+;
         " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
         " WHERE "+cWhere

   oInv:=OpenTable(cSql,.T.)
   oInv:CTODBF(cDirTo+"DPINV_"+cTipDoc+"_"+cNumero+".DBF")
   oInv:End()

   oMov:=OpenTable("SELECT * FROM DPMOVINV WHERE "+cWhere,.T.)

   oMov:Gotop()
   WHILE !oMov:Eof()
     oMov:Replace("MOV_CODCTA",cRif)
     oMov:DbSkip()
   ENDDO

   oMov:CTODBF(cDirTo+"DPMOVINV_"+cTipDoc+"_"+cNumero+".DBF")
   oMov:End()

   cWhere:="MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
           "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO)+" AND MOV_INVACT=1 AND MOV_APLORG='V' "

   cSql:=" SELECT "+SELECTFROM("DPGRU",.F.)+;
         " FROM DPMOVINV "+;
         " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
         " INNER JOIN DPGRU ON INV_GRUPO =GRU_CODIGO "+;
         " WHERE "+cWhere

   oInv:=OpenTable(cSql,.T.)
   oInv:CTODBF(cDirTo+"DPGRU_"+cTipDoc+"_"+cNumero+".DBF")
   oInv:End()

   EJECUTAR("GS_DOCCLITODOCPRO",cCodSuc,cTipDoc,cCodigo,cNumero,cDirTo)

RETURN .T.
// EOF
