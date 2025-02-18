// Programa   : DPDOCCLIPREDEL
// Fecha/Hora : 08/10/2005 21:30:48
// Propósito  : Verificar la Anulación de un Documento
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm,lDelete,cText,lValEjer)
   LOCAL cEstado :="",lDelete:=.F.,aCxC:={-1,0,1},aData,oTable,lLibVta
   LOCAL nCxC    :=IIF(oForm:DOC_CXC=1,0,1),nInv:=0,I,nImport,cNumCbt,dFecha,cNumRet
   LOCAL lAnuFiscal:=.F.,cNumero:="",cCuota:="",cCxC:="",cWhereD
   LOCAL nPeriodo:=oDp:nDiario,dDesde:=NIL,dHasta:=NIL,cTitle:=NIL,cCodCli:=oForm:DOC_CODIGO,cCodMot:=NIL,cTipDoc:=oForm:DOC_TIPDOC
   LOCAL cWhere  :="DOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                   "DOC_TIPDOC"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                   "DOC_NUMERO"+GetWhere("=",oForm:DOC_NUMERO)+" AND "+;
                   "DOC_CODIGO"+GetWhere("=",oForm:DOC_CODIGO)+" AND DOC_TIPTRA='D' LIMIT 1"

   LOCAL dFecha,dFechaS // Fecha del Servidor

   oDp:lDelete:=.T.  

   DEFAULT lDelete :=.T.,;
           cText   :="Anular",;
           lValEjer:=.T.

   IF oForm:DOC_TIPDOC="FAV" .OR. oForm:DOC_TIPDOC="TIK"
      cWhere:=STRTRAN(cWhere,"LIMIT 1","")
      EJECUTAR("BRFAVTOCREDET",cWhere,oForm:DOC_CODSUC,nPeriodo,dDesde,dHasta,cTitle,cCodCli,cCodMot,cTipDoc)
      RETURN .T.
   ENDIF
   
   IF oForm:DOC_TIPDOC="FAV" .AND. lDelete
      DPLBX("DPTIPDOCCLIMOT.LBX")
      RETURN .F.
   ENDIF

   IF lValEjer .AND. !EJECUTAR("DPVALFECHA",oForm:DOC_FECHA,.T.,.T.) 
      oDp:lDelete:=.F. 
      RETURN .F.
   ENDIF

   cEstado :=IIF( ValType(oForm:oEstado) ="O" , oForm:oEstado:GetText() , "" )

   IF ValType(oForm)="O"
 
     // Determina si el Documento es para CXC 

     IF !SQLGET("DPDOCCLICTA","SUM(CCD_MONTO)","CCD_TIPDOC"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                                               "CCD_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                               "CCD_NUMERO"+GetWhere("=",oForm:DOC_NUMERO)+" AND "+;
                                               "CCD_ACT = 1 ")=0 .AND. .F.

        MensajeErr(oForm:cNomDoc+" ["+oForm:DOC_NUMERO+"]"+" Posee Cuentas Contables","Debe Utilizar la Opción Documentos")

        RETURN .F.

     ENDIF

     cEstado:=""

     oDp:lExcluye:=.F.
     cCxC    :=SQLGET("DPTIPDOCCLI","TDC_CXC,TDC_LIBVTA","TDC_TIPO"+GetWhere("=",oForm:DOC_TIPDOC))

     IF Empty(cCxC)
        MensajeErr("Tipo de Documento "+oForm:DOC_TIPDOC+" no Encontrado en Tabla Tipo de Documento del Cliente")
        RETURN .F.
     ENDIF

     nCxC    :=aCxC[AT(cCxC,"CND")]
     lLibVta :=DPSQLROW(2,.F.) //  oDp:aRow[2]

     IF !(oForm:DOC_ESTADO="AC" .OR. oForm:DOC_ESTADO="NU" .OR. oForm:DOC_ESTADO="PA")
       oForm:DOC_ESTADO:="AC" 
     ENDIF


     IF oForm:DOC_ESTADO="AC"

        IF !EJECUTAR("DPDOCCLIISDEL",oForm)
           RETURN .F.
        ENDIF

        cEstado:="NU"
        lDelete:=.F.
        nCxC   :=0 // Es Inactivado en CXC

        IF !MsgNoYes("Número: "+oForm:DOC_NUMERO,"Desea "+cText+" "+oForm:cNomDoc)
           RETURN .F.
        ENDIF

        IF "Anul"$cText .AND.lLibVta .AND. oForm:DOC_CXC<>0 .AND. MsgNoYes("Número: "+oForm:DOC_NUMERO,"Aplicar Anulación Fiscal "+oForm:cNomDoc)
          lAnuFiscal:=.T.
        ENDIF

     ENDIF

     IF oForm:DOC_ESTADO="PA"

        MensajeErr("Operación Negada:"+CRLF+"Documento: "+oForm:DOC_TIPDOC+" "+oForm:DOC_NUMERO+", Está Pagado.")

     ENDIF

     IF "Anul"$cText .AND. oForm:DOC_ESTADO="NU"

        cEstado:="AC"
        lDelete:=.T.
        IF !MsgNoYes("Número: "+oForm:DOC_NUMERO,"Desea Reactivar "+oForm:cNomDoc)
           RETURN .F.
        ENDIF

     ENDIF

     IF !Empty(cEstado)


        oForm:DOC_ESTADO:=cEstado
        nInv := IIF(cEstado="NU" , 0 , 1 )

        // Anula Documentos Asociados RTI y RET
        EJECUTAR("DPDOCCLIDELASO",oForm:DOC_CODSUC,oForm:DOC_TIPDOC,oForm:DOC_CODIGO,oForm:DOC_NUMERO,nInv)

        SQLUPDATE("DPDOCCLI","DOC_ESTADO" , cEstado    , cWhere)
        SQLUPDATE("DPDOCCLI","DOC_CXC"    , nCxC       , cWhere)
        SQLUPDATE("DPDOCCLI","DOC_ACT"    , nInv       , cWhere)
        SQLUPDATE("DPDOCCLI","DOC_ANUFIS" , lAnuFiscal , cWhere)

        AUDITAR( IIF(cEstado="NU","ANUL","REAC") , NIL ,"DPDOCCLI" ,"Tipo:"+oForm:DOC_TIPDOC+" Num:"+oForm:DOC_NUMERO )

        IIF( ValType(oForm:oEstado)="O", oForm:oEstado:Refresh(.T.) , NIL )

        cWhere  :="MOV_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                  "MOV_DOCUME"+GetWhere("=",oForm:DOC_NUMERO)+" AND "+;
                  "MOV_TIPDOC"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                  "MOV_CODCTA"+GetWhere("=",oForm:DOC_CODIGO)+" AND "+;
                  "MOV_APLORG='V'"

        SQLUPDATE("DPMOVINV","MOV_INVACT",nInv   ,cWhere)

        // Devuelve Cantidades Importadas
        aData:=ASQL("SELECT MOV_ASODOC,MOV_ASOTIP,MOV_ITEM_A,MOV_IMPORT,MOV_CODIGO FROM DPMOVINV WHERE "+cWhere+;
                    " AND MOV_ASODOC<>''")

        dFechaS:=EJECUTAR("DPFECHASRV")

        FOR I=1 TO LEN(aData)

            cWhere :="MOV_ASODOC"+GetWhere("=",aData[I,1])     +" AND "+;
                     "MOV_ASOTIP"+GetWhere("=",aData[I,2])     +" AND "+;
                     "MOV_ITEM_A"+GetWhere("=",aData[I,3])     +" AND "+;
                     "MOV_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                     "MOV_INVACT"+GetWhere("=",1)

            nImport:=SQLGET("DPMOVINV","SUM(MOV_IMPORT)",cWhere)

            cWhere :="MOV_DOCUME"+GetWhere("=",aData[I,1])     +" AND "+;
                     "MOV_TIPDOC"+GetWhere("=",aData[I,2])     +" AND "+;
                     "MOV_ITEM"  +GetWhere("=",aData[I,3])     +" AND "+;
                     "MOV_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)

            // Actualiza las Cantidades Exportadas
            SQLUPDATE("DPMOVINV",{"MOV_EXPORT","MOV_MTOCLA","MOV_CXUNDE"},{nImport,0,0},cWhere)
     
            IF ValType(dFecha)="D"
              SQLUPDATE("DPINV"   ,"INV_FCHACT",dFecha,"INV_CODIGO"+GetWhere("=",aData[I,5]))
            ENDIF

            // Devuelve el estado ACTIVO caso de documentos Neutros

            cWhereD:="DOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                     "DOC_TIPDOC"+GetWhere("=",aData[I,2]      )+" AND "+;
                     "DOC_NUMERO"+GetWhere("=",aData[I,1]      )+" AND "+;
                     "DOC_CXC=0"

            SQLUPDATE("DPDOCCLI","DOC_ESTADO","AC",cWhereD)

        NEXT I


        IF nInv=0 .AND. !Empty(oForm:DOC_CBTNUM)

           // MOC_CODSUC,MOC_ACTUAL,MOC_NUMCBT,MOC_FECHA,MOC_ITEM,MOC_CUENTA                  

           SQLDELETE("DPASIENTOS","MOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                  "MOC_ACTUAL"+GetWhere("=","N"            )+" AND "+;       
                                  "MOC_NUMCBT"+GetWhere("=",oForm:DOC_CBTNUM)+" AND "+;
                                  "MOC_FECHA "+GetWhere("=",oForm:DOC_FECHA )+" AND "+;
                                  "MOC_TIPO  "+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                                  "MOC_DOCUME"+GetWhere("=",oForm:DOC_NUMERO)+" AND "+;                               
                                  "MOC_TIPTRA"+GetWhere("=","D"            )+" AND "+;
                                  "MOC_ORIGEN"+GetWhere("=","VTA"          )+" LIMIT 1")

        ENDIF

        oForm:LOADDATA(0)

        // Aqui debe Buscar las retenciones Asociadas
        cNumRet:=MYSQLGET("DPDOCCLIISLR","RXC_DOCNUM","RXC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                                      "RXC_TIPDOC"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                                                      "RXC_NUMDOC"+GetWhere("=",oForm:DOC_NUMERO))


        IF !Empty(cNumRet) .AND. .NOT. (oForm:DOC_TIPDOC="RET" .OR. oForm:DOC_TIPDOC="RTI")


          cWhere:="DOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=","RET"          )+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",cNumRet        )+" AND DOC_TIPTRA='D'"

          SQLUPDATE("DPDOCCLI","DOC_ESTADO" , cEstado    , cWhere)
//        SQLUPDATE("DPDOCCLI","DOC_CXP"    , nCXP       , cWhere)
          SQLUPDATE("DPDOCCLI","DOC_ACT"    , nInv       , cWhere)

          cNumCbt:=SQLGET("DPDOCCLI","DOC_CBTNUM,DOC_FECHA",cWhere)

          IF (nInv=0 .AND. !Empty(cNumCbt))

             dFecha:=oDp:aRow[2]

             // INDICE MOC_CODSUC,MOC_ACTUAL,MOC_FECHA,MOC_NUMCBT                                      

             SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
                                    "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
                                    "MOC_TIPO  "+GetWhere("=","RET"  )+" AND "+;
                                    "MOC_DOCUME"+GetWhere("=",cNumRet)+" AND "+;
                                    "MOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                    "MOC_ACTUAL"+GetWhere("=","N"            )+" AND "+;       
                                    "MOC_TIPTRA"+GetWhere("=","D"            )+" AND "+;
                                    "MOC_ORIGEN"+GetWhere("=","VTA"          )+"LIMIT 1" )


          ENDIF


        ENDIF


        // Retenciones de ISLR

        cNumRet:=MYSQLGET("DPDOCCLIRTI","RTI_DOCNUM","RTI_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                                     "RTI_TIPDOC"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+;
                                                     "RTI_NUMERO"+GetWhere("=",oForm:DOC_NUMERO))

        IF !Empty(cNumRet) .AND. .NOT. (oForm:DOC_TIPDOC="RET" .OR. oForm:DOC_TIPDOC="RTI")

          cWhere:="DOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=","RTI"          )+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",cNumRet        )+" AND DOC_TIPTRA='D'"

          SQLUPDATE("DPDOCCLI","DOC_ESTADO" , cEstado    , cWhere)
//        SQLUPDATE("DPDOCCLI","DOC_CXP"    , nCXP       , cWhere)
          SQLUPDATE("DPDOCCLI","DOC_ACT"    , nInv       , cWhere)

          cNumCbt:=SQLGET("DPDOCCLI","DOC_CBTNUM,DOC_FECHA",cWhere)

          IF (nInv=0 .AND. !Empty(cNumCbt))

             dFecha:=oDp:aRow[2]

             SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
                                    "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
                                    "MOC_TIPO  "+GetWhere("=","RTI"  )+" AND "+;
                                    "MOC_DOCUME"+GetWhere("=",cNumRet)+" AND "+;
                                    "MOC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+;
                                    "MOC_ACTUAL"+GetWhere("=","N"            )+" AND "+;       
                                    "MOC_TIPTRA"+GetWhere("=","D"            )+" AND "+;
                                    "MOC_ORIGEN"+GetWhere("=","VTA"          )+ "LIMIT 1")


          ENDIF

        ENDIF

        /*
        // Libera la Cuota Facturada en Documento Periodico
        */

        IF !Empty(SQLGET("DPDOCCLIPROG","PLC_TIPDES,PLC_NUMERO,PLC_CUOTA",;
                  "PLC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+; 
                  "PLC_TIPDES"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+; 
                  "PLC_NUMDOC"+GetWhere("=",oForm:DOC_NUMERO))) .AND. cEstado="NU"


             cNumero:=oDp:aRow[2]
             cCuota :=oDp:aRow[3]

             SQLUPDATE("DPDOCCLIPROG",{"PLC_NUMDOC"},;
                                      {""          },;
                                      "PLC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+; 
                                      "PLC_TIPDES"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+; 
                                      "PLC_NUMDOC"+GetWhere("=",oForm:DOC_NUMERO))

             EJECUTAR("AUDITORIA","DELI",.F.,"DPDOCCLIPROG",cNumero+"+"+cCuota,NIL)

             MensajeErr("Cuota "+cCuota+" "+oDp:xDPCLIENTEPROG+" "+cNumero,"Cuota Liberada")

        ENDIF

        IF !Empty(SQLGET("DPDOCCLIPROG","PLC_TIPDES,PLC_NUMERO,PLC_CUOTA",;
                  "PLC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+; 
                  "PLC_TIPDES"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+; 
                  "PLC_NUMORG"+GetWhere("=",oForm:DOC_NUMERO))) .AND.!cEstado="NU"


               cNumero:=oDp:aRow[2]
               cCuota :=oDp:aRow[3]

               SQLUPDATE("DPDOCCLIPROG",{"PLC_NUMDOC"    },;
                                        {oForm:DOC_NUMERO},;
                                        "PLC_CODSUC"+GetWhere("=",oForm:DOC_CODSUC)+" AND "+; 
                                        "PLC_TIPDES"+GetWhere("=",oForm:DOC_TIPDOC)+" AND "+; 
                                        "PLC_NUMORG"+GetWhere("=",oForm:DOC_NUMERO))

               EJECUTAR("AUDITORIA","DREA",.F.,"DPDOCCLIPROG",cNumero+"+"+cCuota,NIL)
 
               MensajeErr("Cuota "+cCuota+" "+oDp:xDPCLIENTEPROG+" "+cNumero,"Cuota Reactivada")

 
        ENDIF


        MensajeErr(oForm:cNomDoc+" Número "+oForm:DOC_NUMERO+" "+;
                   IIF(cEstado="NU","Nulo","Reactivada"),;
                   "Proceso Concluido")
        
     ENDIF

  ENDIF
 
RETURN .F. // .T. Elimina registro
// EOF


