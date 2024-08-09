// Programa   : DPDOCCLIEXPORTAUT  
// Fecha/Hora : 15/09/2010 00:36:09
// Propósito  : Generar Nuevo Documento de Ventas
// Creado Por : Juan Navas
// Llamado por: DPDOCCLIMNU
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNumDoc,cTipExp,oDocExp,cNumero,dFecha,cLetra,cNumFis)
   LOCAL oTable,cSql,oNew,oItems,aItems:={},I,oTipDoc,nCxC:=0,cUpdate:=""
   LOCAL nFisico:=0,nLogico:=0,nContab:=0,lResp:=.T.,cCodVen,cSerie
   LOCAL cItem

// ? cNumDoc,cTipExp,oDocExp,cNumero,"cNumDoc,cTipExp,oDocExp,cNumero"

   cSql:="SELECT * FROM DPDOCCLI WHERE DOC_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+;
                                "  AND DOC_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+;
                                "  AND DOC_NUMERO"+GetWhere("=",oDocExp:cNumero)+;
                                "  AND DOC_TIPTRA"+GetWhere("=","D")

// ? cLetra,"cLetra"


   EJECUTAR("DPCREATERCEROS")

   DEFAULT cNumero:=oDocExp:cNumDes,dFecha:=oDp:dFecha

   IF Empty(cNumero)
      EJECUTAR("DPDOCCLIGETNUM",oDocExp:cTipExp)
      cNumero:=oDp:cNumero
   ENDIF

//  ? "ESTE ES EL NUMERO DE LA FACTURA",cNumero,"FINAL",oDocExp:cNumDes,"<-oDocExp:cNumDes"
   
   oTable:=OpenTable(cSql,.T.)

   IF oTable:RecCount()=0
      MensajeErr("Documento "+oDocExp:cTipDoc+" "+oDocExp:cNumero+" no Existe ")
      oTable:End()
      RETURN NIL
   ENDIF

   // Actualiza todas las Cantidades como Exportadas

   oDocExp:cCodigo:=oTable:DOC_CODIGO

   DpSqlBegin(NIL,NIL,"DPDOCCLI")

   oTipDoc:=OpenTable("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=",oDocExp:cTipExp),.T.)

   IF Empty(cLetra)
      cSerie:=SQLGET("DPTIPDOCCLI","TDC_SERIEF","TDC_TIPO"+GetWhere("=",oTipDoc:TDC_DOCDES))
      cLetra:=SQLGET("DPSERIEFISCAL","SFI_LETRA","SFI_MODELO"+GetWhere("=",cSerie))
   ENDIF

   oNew:=OpenTable("SELECT * FROM DPDOCCLI",.F.)
   oNew:lAuditar:=.F.

   IF Empty(cNumero)
//    cNumero:=oDocExp:NUMDOC(oDocExp:cCodSuc,oDocExp:cTipExp)
//    EJECUTAR("DPDOCCLIGETNUM",oDocExp:cTipExp)
//    cNumero:=oDp:cNumero
   ENDIF

//   cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
//                                                   "DOC_TIPDOC"+GetWhere("=",oDocExp:cTipExp)+" AND "+;
//                                                   "DOC_TIPTRA"+GetWhere("=","D"))
//
//   cNumero:=MAX(cNumDoc,cNumero)

   oDocExp:cNumSug:=cNumero

// ? cNumero,"cNumero NUEVA FACTURA"

   nCxC:=IF(oTipDoc:TDC_CXC="N", 0,nCxC)
   nCxC:=IF(oTipDoc:TDC_CXC="D", 1,nCxC)
   nCxC:=IF(oTipDoc:TDC_CXC="C",-1,nCxC)

   oNew:AppendBlank()
   oNew:lAuditar:=.F.

   cCodVen:=oTable:DOC_CODVEN
   cCodVen:=IF(Empty(cCodVen),STRZERO(1,6),cCodVen)

   IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",cCodVen))
     EJECUTAR("DPVENDEDORCREA",cCodVen,"Recuperado en DPDOCCLIEXPORTAUT ")
     SQLUPDATE("DPCLIENTES","CLI_CODVEN","CLI_CODIGO"+GetWhere("=",oTable:DOC_CODIGO))
   ENDIF

   AEVAL(oTable:aFields,{|a,n| oNew:FieldPut(n,oTable:FieldGet(n)) })

   oNew:Replace("DOC_TIPDOC",oDocExp:cTipExp)
   oNew:Replace("DOC_NUMERO",cNumero        )
   oNew:Replace("DOC_CXC"   ,nCxC           )
   oNew:Replace("DOC_ASODOC",oDocExp:cNumero)
   oNew:Replace("DOC_TIPAFE",oDocExp:cTipDoc)
   oNew:Replace("DOC_FECHA" ,dFecha         )
   oNew:Replace("DOC_CODVEN",cCodVen        )
   oNew:Replace("DOC_TIPTRA","D"            )
   oNew:Replace("DOC_SERFIS",cLetra         )
   oNew:Replace("DOC_IMPRES",.F.            ) // requiere imprimir desde Impresora Fiscal

   IF !Empty(cNumFis)
      oNew:Replace("DOC_NUMFIS",cNumFis)
   ENDIF

   IF Empty(oNew:DOC_CODTER)
      oNew:Replace("DOC_CODTER",oDp:cCodter)
   ENDIF

   oNew:Commit("")

// ? "factura creada",cNumero,oDp:cSql

   oNew:End()
   oTable:End()

   nFisico:=IF(oTipDoc:TDC_INVFIS,1,0)*oTipDoc:TDC_INVACT
   nLogico:=IF(oTipDoc:TDC_INVLOG,1,0)*oTipDoc:TDC_INVACT
   nContab:=IF(oTipDoc:TDC_INVCON,1,0)*oTipDoc:TDC_INVACT

   aItems:=ASQL("SELECT * FROM DPMOVINV WHERE MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                                             "MOV_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
                                             "MOV_DOCUME"+GetWhere("=",oDocExp:cNumero)+" AND "+;
                                             "MOV_APLORG"+GetWhere("=","V"))

   cUpdate:="UPDATE DPMOVINV"+;
            " SET MOV_EXPORT=MOV_CANTID,"+;
            "     MOV_TIPASO"+GetWhere("=",oDocExp:cTipExp)+","+;
            "     MOV_DOCASO"+GetWhere("=",cNumero        )+;
            " WHERE MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
            " MOV_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
            " MOV_DOCUME"+GetWhere("=",oDocExp:cNumero)+" AND "+;
            " MOV_APLORG"+GetWhere("=","V")

   oTable:Execute(cUpdate)

/*
"UPDATE DPMOVINV SET MOV_EXPORT=MOV_CANTID,MOV_TIPASO"+ WHERE MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                                                                  "MOV_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
                                                                  "MOV_DOCUME"+GetWhere("=",oDocExp:cNumero)+" AND "+;
                                                                  "MOV_APLORG"+GetWhere("=","V"))
*/

   /*
   // 21/09/2022 En caso que existan movimientos en DPMOVINV con el mismo numero de documento, será INACTIVADO para evitar totales duplicados
   */

   SQLUPDATE("DPMOVINV","MOV_INVACT",0,"MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                                       "MOV_TIPDOC"+GetWhere("=",oDocExp:cTipExp)+" AND "+;
                                       "MOV_DOCUME"+GetWhere("=",cNumero        )+" AND "+;
                                       "MOV_APLORG"+GetWhere("=","V"            ))

   oTipDoc:=OpenTable("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=",oDocExp:cTipDoc),.T.)

   oItems:=OpenTable("SELECT * FROM DPMOVINV",.F.)
   oItems:lAuditar:=.F.

   FOR I=1 TO LEN(aItems)

      cWhere  :="MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                "MOV_TIPDOC"+GetWhere("=",oDocExp:cTipExp)+" AND "+;
                "MOV_DOCUME"+GetWhere("=",cNumero        )+" AND "+;
                "MOV_APLORG"+GetWhere("=","V"            )

      cItem   :=SQLINCREMENTAL("DPMOVINV","MOV_ITEM",cWhere,NIL,NIL,.T.,4)

      oItems:AppendBlank()

      AEVAL(aItems[I],{|a,n| oItems:FieldPut(n,a)})

      // Datos del Documento Origen
      oItems:Replace("MOV_ITEM"  ,cItem            )
      oItems:Replace("MOV_ASODOC",oDocExp:cNumero  )
      oItems:Replace("MOV_ASOTIP",oDocExp:cTipDoc  )
      oItems:Replace("MOV_ITEM_A",oItems:MOV_ITEM  )
      oItems:Replace("MOV_IMPORT",oItems:MOV_CANTID)
      oItems:Replace("MOV_FECHA" ,dFecha           )
      oItems:Replace("MOV_TIPDOC",oDocExp:cTipExp  )
      oItems:Replace("MOV_DOCUME",cNumero)

      //
      // Asignacion de Existecias Segun Modelaje

      IF nFisico=oItems:MOV_FISICO
         nFisico:=0
      ENDIF
      oItems:Replace("MOV_FISICO",nFisico)

      IF nLogico=oItems:MOV_LOGICO
         nLogico:=0
      ENDIF
      oItems:Replace("MOV_LOGICO",nLogico)

      IF nContab=oItems:MOV_CONTAB
         nContab:=0
      ENDIF
      oItems:Replace("MOV_CONTAB",nContab)
    
      oItems:Commit()

   NEXT I

   oItems:End()

   // Asigna Exportado al Documento
   SQLUPDATE("DPDOCCLI","DOC_ESTADO","EX",oTable:cWhere)

   IF !lResp

      DpSqlRollBack()

   ELSE

       DpSqlCommit()

   ENDIF

   SQLDELETE("dpdoccliflow","DOF_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                            "DOF_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
                            "DOF_NUMERO"+GetWhere("=",oDocExp:cNumero))

   // IF oDocExp:lLibVta
   // IF oTipDoc:TDC_LIBVTA
   IF SQLGET("DPTIPDOCCLI","TDC_LIBVTA","TDC_TIPO"+GetWhere("=",oDocExp:cTipExp))
     EJECUTAR("DPDOCNUMFIS",oDocExp:cCodSuc,oDocExp:cTipExp,oDocExp:cCodigo,cNumero)
   ENDIF

// Se incluyó en Proforma 
/*
   IF oDocExp:lLimite .AND. oDocExp:nPar_CXC<>0
      oDocExp:RECIBO()
      RETURN .T.
   ENDIF
*/

   // Realiza el Pago; luego de general el Documento
   IF oDocExp:lPagEle
      oDocExp:RECIBO()
   ENDIF

   IF oDocExp:lMenu
      EJECUTAR("DPDOCCLIMNU",oDocExp:cCodSuc,cNumero,oDocExp:cCodigo,NIL,oDocExp:cTipExp,NIL)
   ENDIF

   oDocExp:cNumSug:=cNumero // Numero creado
   oDocExp:Close()

RETURN NIL

FUNCTION NUMDOC(cCodSuc,cTipDoc)
  LOCAL cNumero

//  DPDOCCLIGETNUM      
/*
  LOCAL oData,cNumDoc:=STRZERO(1,10)

  oData:=DATASET("SUC_V"+cCodSuc,"ALL")
  cNumDoc:=oData:Get(cTipDoc+"Numero",cNumDoc)
  oData:End()


  cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                  "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                                  "DOC_TIPTRA"+GetWhere("=","D"))

*/

/*
  cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                             "DOC_TIPTRA"+GetWhere("=","D"))
  cNumero:=DPINCREMENTAL(cNumero)
*/

/*
  IF !Empty(cNumDoc)
    cNumero:=IF(cNumero>cNumDoc,cNumero,cNumDoc)
  ENDIF
*/
// ? cNumero,"Numero final"

RETURN cNumero

FUNCTION RECIBO()
   LOCAL oRecibo

   oDocExp:cCodVen:=SQLGET("DPDOCCLI","DOC_CODVEN","DOC_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                                                   "DOC_TIPDOC"+GetWhere("=",oDocExp:cTipExp)+" AND "+;
                                                   "DOC_NUMERO"+GetWhere("=",oDocExp:cNumSug)+" AND "+;
                                                   "DOC_TIPTRA"+GetWhere("=","D"))

   oRecibo:=EJECUTAR("DPDOCCLIPAG2",oDocExp:cCodSuc,;
                                    oDocExp:cTipExp,;
                                    oDocExp:cCodCli,;
                                    oDocExp:cNumSug,;
                                    oDocExp:cNomDoc,;
                                    oDocExp:cCodVen,;
                                    .F.,;
                                    oDocExp:lPagEle)

   oRecibo:=oDp:oCliRec

   IF oRecibo:lPagEle

     // cCodSuc,cTipDoc,cCodigo,cNumero,cWhere
     oRecibo:cRunGrabar:=[EJECUTAR("DPFACTURAV_PRINT",.F.,]+;
                         GetWhere("",oDocExp:cCodSuc)+","+;
                         GetWhere("",oDocExp:cTipExp)+","+;
                         GetWhere("",oDocExp:cCodCli)+","+;
                         GetWhere("",oDocExp:cNumSug)+","+;
                         ["]+oDocExp:cWhere+["]         +","+;
                         [NIL,NIL,]+IF(oDocExp:lDocGen,".T.",".F.")+[)]

     oRecibo:oWnd:SetText(oRecibo:cTitle+" [ Pagos con Instrumentos Electrónicos ]")

   ENDIF

RETURN 

// EOF

