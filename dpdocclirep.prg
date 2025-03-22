// Programa   : DPDOCCLIREP
// Fecha/Hora : 12/06/2005 12:29:55
// Propósito  : Emisión de Facturas
// Creado Por : Juan Navas
// Llamado por: REPORTE: DPFACTURA
// Aplicación : Ventas y Cuentas por Cobrar
// Tabla      : DPCLIDOC

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,cSql,cTipDoc,_cTipDoc)
   LOCAL oTable,oGrupo
   LOCAL cWhere,cAlias:=ALIAS(),cSqlCli:="",I,cField,cSqlMov,cSqlIva,oSerial,cMemo
   LOCAL aStruct  :={},nAt,aNumDoc:={},aCodCli:={},aFiles:={} // Número de Cotizaciones
   LOCAL aDpCliente:={}
   LOCAL aDpCliZero:={}
   LOCAL cFileDbf  :="",cSqlDir:="",cFileDir,cSerial
   LOCAL aRecibos  :={},nSaldo:=0,cWhereAso:="",nSeriales:=0,aSerWhere:={},aDesc:={}
   LOCAL cMovInrHor:=oDp:cPathCrp+"DPMOVINVHORA"
   LOCAL cTipDocCli:="DPTIPDOCCLI",cSqlTipDoc,cGirNum
   LOCAL lCliZero  :=.F.
   LOCAL cRdd      :="DBFCDX"
   LOCAL cSqlIni   :=cSql
   LOCAL nValCam   :=0
   LOCAL aMemo     :={}
   LOCAL cMemoTalla:="" // memo de las tallas
   LOCAL aTallas   :={},nField:=0

   IF ValType(cTipDoc)="C" .AND. cTipDoc="FAM" .AND. Empty(_cTipDoc)
      _cTipDoc:="FAV"
   ENDIF

   DEFAULT cTipDoc:="FAV",;
          _cTipDoc:=cTipDoc

//  oDp:lTracer:=.T.
// ? cTipDoc,_cTipDoc
//   EJECUTAR("CRYSTALDELDBF")
// ? cTipDoc,_cTipDoc

   cFileDbf:=oDp:cPathCrp+"DOCCLI"+_cTipDoc
   cFileDir:=oDp:cPathCrp+"DOCCLI"+_cTipDoc+"DIR"

   AADD(aFiles,cFileDbf)
   AADD(aFiles,cFileDir)
   AADD(aFiles,oDp:cPathCrp+"DOCCLI"+_cTipDoc+"SER")
   AADD(aFiles,oDp:cPathCrp+"DOCCLI"+_cTipDoc+"IVA")
   AADD(aFiles,oDp:cPathCrp+"DOCCLI"+_cTipDoc+"CLI")
  

   FOR I=1 TO LEN(aFiles)
      FERASE(aFiles[I]+".DBF")
      IF FILE(aFiles[I]+".DBF") 
         cMsg:=cMsg+IIF(Empty(cMsg),"",CRLF)+;
               "Fichero "+aFiles[I]+".DBF está en uso"
      ENDIF
   NEXT I

   IF !Empty(cMsg)
      MensajeErr(cMsg)
      RETURN .F.
   ENDIF


   IF oGenRep=NIL .OR. !(oGenRep:oRun:nOut=8 .OR. oGenRep:oRun:nOut=9)
      RETURN .F.
   ENDIF

//   oGenRep:oRun:lFileDbf:=.T.


   /*
   // Genera los Datos del Encabezado
   */

   // oGenRep:cSql,CHKSQL(oGenRep:cSql)

   CLOSE ALL

   cWhere:=" WHERE   DPDOCCLI.DOC_CODSUC"+GetWhere("=",oDp:cSucursal)  + ;
           "   AND   DPDOCCLI.DOC_TIPDOC"+GetWhere("=",cTipDoc      )  + ;
           "   AND   DPDOCCLI.DOC_TIPTRA='D'" + ;
           IF( Empty(oGenRep:cWhere) , "" , " AND " ) 

   // JN 18/06/2015

   nAt:=AT(" FROM ",oGenRep:cSql)

   IF nAt>0
     oGenRep:cSql:="SELECT * "+SUBS(oGenRep:cSql,nAt,LEN(oGenRep:cSql))
   ENDIF

   oGenRep:cSql:=STRTRAN(oGenRep:cSql," WHERE ", cWhere )

   IF !"GROUP BY"$oGenRep:cSql
      oGenRep:cSql:=oGenRep:cSql+" GROUP BY DOC_NUMERO"
   ENDIF

   cSql   :=oGenRep:cSql

//  ? oGenRep:cSql,"oGenRep:cSql"
  

   nAt    :=AT(" FROM ",cSql)

// 13/12/2013
//
//   cSql   :="SELECT DOC_NUMERO,DOC_CODIGO "+SUBS(cSql,nAt,LEN(cSql))

   cSql:="SELECT DOC_NUMERO,DOC_CODIGO  FROM DPDOCCLI "+oGenRep:cWhere+" AND DOC_TIPTRA"+GetWhere("=","D")+;
         " GROUP BY DOC_NUMERO "

// jn " GROUP BY DOC_NUMERO "
// ? CLPCOPY(cSql)


   aCodCli:=ASQL(cSql)

//  ? CLPCOPY(cSql)

   aNumDoc:={}

   FOR I=1 TO LEN(aCodCli)

      AADD(aNumDoc,aCodCli[I,1])
      aCodCli[I]:=aCodCli[I,2]

      IF !lCliZero
        lCliZero  :=aCodCli[I]=STRZERO(0,10)
      ENDIF

   NEXT I

   // Datos del Cliente
   oTable :=OpenTable("SELECT * FROM DPCLIENTESCERO",.F.)

   Aeval(oTable:aFields,{|a,n|AADD(aDpCliZero,a[1])})
   
   oTable:End()

   // ViewArray(aDpCliZero)
   // Datos del Cliente

   oTable :=OpenTable("SELECT * FROM DPCLIENTES",.F.)

   FOR I=1 TO oTable:FCOUNT()

       cField:=STRTRAN(oTable:FieldName(i),"CLI_","CCG_")
       nAt   :=ASCAN(aDpCliZero,{|a,n|ALLTRIM(a)=ALLTRIM(cField)})

//? nAt,cField,"nAt,cField"

       IF lCliZero .AND. nAt>0
         cField:="IF(DOC_CODIGO='0000000000',DPCLIENTESCERO."+aDpCliZero[nAt]+",DPCLIENTES."+oTable:FieldName(I)+") AS "+oTable:FieldName(I)
       ELSE
          cField:="DPCLIENTES."+oTable:FieldName(I)
       ENDIF

       cSqlCli:=cSqlCli+IIF(!Empty(cSqlCli),",","")+cField
       
   NEXT I

   oTable:End()

// RETURN .F.

   cSqlCli :=cSqlCli+","+SELECTFROM("DPTRANSP"     ,.F.)
   cSqlCli :=cSqlCli+","+SELECTFROM("DPCLIENTESSUC",.F.)

  IF Empty(aNumDoc)
     MsgMemo("No hay documentos "+cTipDoc+" "+oGenRep:cWhere)
     RETURN NIL
  ENDIF

  //  JN 13/12/2013

  cSqlCli :=" SELECT "+cSqlCli+;
            ",DPVENDEDOR.VEN_NOMBRE"+;
            ",DPVENDEDOR.VEN_EMAIL"+;
            ",DPDOCCLI.DOC_NETO "+;
            ",DPDOCCLI.DOC_BASNET "+;
  	       ",'' AS ENLETRASBSF "+;
            ",DPDOCCLI.DOC_MTOEXE "+;
            ",DPDOCCLI.DOC_MTODIV "+;
            ",DPDOCCLI.DOC_NETO-DPDOCCLI.DOC_MTOIVA AS DOC_MTOBRU "+;
            ",DPDOCCLI.DOC_CODIGO "+;
            ",DPDOCCLI.DOC_NUMERO "+;
            ",DPDOCCLI.DOC_FECHA  "+;
            ",DPDOCCLI.DOC_HORA   "+;           
            ",DPDOCCLI.DOC_RECNUM "+;
            ",DPDOCCLI.DOC_FACAFE "+;
            ",DPDOCCLI.DOC_SUCCLI "+;
            ",DPDOCCLI.DOC_VALCAM "+;
            ",DPDOCCLI.DOC_TIPAFE "+;
            ",DPDOCCLI.DOC_NUMMEM "+;
            ",DPDOCCLI.DOC_GIRNUM "+;
            ",DPDOCCLI.DOC_TIPDOC "+;
            ",DPTERCEROS.TDC_NOMBRE"+;
            ",MEM_MEMO,MEM_NUMERO,MEM_DESCRI,TDC_DESCRI "+;
            " FROM DPDOCCLI "+;
            " LEFT JOIN DPCLIENTES  ON DOC_CODIGO=CLI_CODIGO "+;
            " LEFT JOIN DPVENDEDOR  ON DOC_CODVEN=VEN_CODIGO "+;
            " LEFT JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO   "+;
            " LEFT JOIN DPTERCEROS  ON DOC_CODTER=TDC_CODIGO "+;
            IIF(lCliZero," LEFT  JOIN DPCLIENTESCERO ON DOC_CODSUC=CCG_CODSUC AND "+;
                         "                              DOC_TIPDOC=CCG_TIPDOC AND "+;
                         "                              DOC_NUMERO=CCG_NUMDOC ","") +;
            " LEFT  JOIN "+oDp:cDpMemo+" ON MEM_NUMERO = DPDOCCLI.DOC_NUMMEM AND DPMEMO.MEM_ID"+GetWhere("=",oDp:cIdMemo)+;
            " LEFT  JOIN DPTRANSP  ON DOC_CODTRA=TRA_CODIGO "+;
            " LEFT  JOIN DPCLIENTESSUC ON DOC_SUCCLI=SDC_CODCLI "+;
            " WHERE  DPDOCCLI.DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "        DPDOCCLI.DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            GetWhereOr("DOC_NUMERO",aNumDoc)+" AND "+;
            "         DPDOCCLI.DOC_TIPTRA='D' "+;
            " GROUP BY DOC_TIPDOC,DOC_NUMERO "

   cSqlCli:=STRTRAN(cSqlCli,"DPMEMO.",oDp:cDPMEMO+".")

   oDp:nMontoEx:=0

// ? CLPCOPY(cSqlCli)

  oTable:=OpenTable(cSqlCli,.T.)
// oTable:Browse(),CLPCOPY(oDp:cSql)
  cGirNum:=oTable:DOC_GIRNUM

//? oTable:DOC_GIRNUM,"oTable:DOC_GIRNUM",cGirNum
// oTable:Browse()

  nValCam:=oTable:DOC_VALCAM

  oGrupo:=OpenTable(" SELECT DOC_BASNET,DOC_NETO,DOC_FECHA,DOC_MTOIVA,DOC_NUMFIS "+;
                    " FROM DPDOCCLI WHERE DOC_CODSUC"+GetWhere("=",oDp:cSucursal    )+;
                    "                 AND DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPAFE)+;
                    "                 AND DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+;
                    "                 AND DOC_NUMERO"+GetWhere("=",oTable:DOC_FACAFE)+" GROUP BY DOC_NUMERO " ,.T.)

// Caso de Quibor, Utiliza este Campo en los Formatos como monto Bruto: oTable:REPLACE("DOC_MONAFE",oGrupo:DOC_BASNET ) // Monto Factura que Afecta
// 15/06/2023 Esto no puede Aplicar Fiscalmente; Base imponible será CERO
//   IF oGrupo:DOC_MTOIVA=0
//      oGrupo:Replace("DOC_BASNET",oGrupo:DOC_NETO)
//   ENDIF

//oGrupo:Browse()
//? CLPCOPY(oDp:cSql)
//VIEWARRAY(oGrupo)
//?? oTable:DOC_NETO,"oTable:DOC_NETO"
//?? oTable:DOC_BASNET,"oTable:DOC_BASNET"
//?? oGrupo:DOC_NETO, "oGrupo:DOC_NETO"
//?? oGrupo:DOC_BASNET, "oGrupo:DOC_BASNET"


   nAt   :=oTable:FieldPos("ENLETRAS")

   DEFAULT oGenRep:cTitle:=""


   IF "PREVISUALIZAR"$oGenRep:cTitle
     oTable:REPLACE("CLI_NOMBRE","[PREVIEW*"+ALLTRIM(oTable:CLI_NOMBRE)+"*PREVIEW]")
     oTable:REPLACE("CLI_RIF"   ,"[*"+ALLTRIM(oTable:CLI_RIF)+"*]")
   ENDIF

// ? oGenRep:cTitle,"oGenRep:cTitle"

   oTable:REPLACE("DOC_EXONER",0,19,2 )
   oTable:REPLACE("DOC_BASNET",0,19,2 )
   oTable:REPLACE("DOC_IMPOTR",0,19,2 ) // Otros Impuestos
   oTable:REPLACE("DOC_MTOIVA",0,19,2 ) // Otros Impuestos
   oTable:REPLACE("DOC_BRUTO" ,0,19,2 ) // Monto Bruto

   oTable:REPLACE("DOC_PAGDIV",0) // Monto Pagado en Dolares calculado en Bs
   oTable:REPLACE("DOC_PAGITF",0) // IGTF PAGADO EN RECIBOS DE INGRESO PARA FACTURAS CREADAS DEL FORMULARIO CLASICCO
   oTable:REPLACE("DOC_IGTF"  ,PORCEN(oTable:DOC_NETO,3))           // IGTF TEXTO FACTURA NO PAGADA
   oTable:REPLACE("DOC_EXONER",0)           // Exonerado
// oTable:REPLACE("DOC_MTODIV",0)           // Monto Neto en Divisas
   oTable:REPLACE("DOC_IVADIV",0)           // Monto del IVA en Divisas
   oTable:REPLACE("DOC_EXEDIV",0)           // Monto Exonerado en Divisa
   oTable:REPLACE("DOC_BASDIV",0)           // Monto Base Neta en Divisas
   oTable:REPLACE("DOC_BRUDIV",0)           // Monto Bruto en Divisas
   oTable:REPLACE("ENLETRASDIV",SPACE(250)) // Monto el Letras calculado en Divisas.


   oTable:REPLACE("DOC_IMPOTR",0) // Otros Impuestos
   oTable:REPLACE("DOC_MTOIVA",0) // Monto del IVA
   // IVA Básicas
   oTable:REPLACE("DOC_IMP_EX",0) // Exento
   oTable:REPLACE("DOC_IMP_GN",0) // General
   oTable:REPLACE("DOC_IMP_RD",0) // Reducido
   oTable:REPLACE("DOC_IMP_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_IMP_S2",0) // Suntuario 2
   // Tasas
   oTable:REPLACE("DOC_POR_EX",0) // Exento
   oTable:REPLACE("DOC_POR_GN",0) // General
   oTable:REPLACE("DOC_POR_RD",0) // Reducido
   oTable:REPLACE("DOC_POR_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_POR_S2",0) // Suntuario 2
   // Base
   oTable:REPLACE("DOC_BAS_EX",0) // Exento
   oTable:REPLACE("DOC_BAS_GN",0) // General
   oTable:REPLACE("DOC_BAS_RD",0) // Reducido
   oTable:REPLACE("DOC_BAS_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_BAS_S2",0) // Suntuario 2

   // Descuentos en Cascada %
                   
   oTable:REPLACE("DOC_DESC01",0) // % 1
   oTable:REPLACE("DOC_DESC02",0) // % 2
   oTable:REPLACE("DOC_DESC03",0) // % 3
   oTable:REPLACE("DOC_DESC04",0) // % 4
   oTable:REPLACE("DOC_DESC05",0) // % 5
   oTable:REPLACE("DOC_DESC06",0) // % 6
   oTable:REPLACE("DOC_DESC07",0) // % 7
   oTable:REPLACE("DOC_DESC08",0) // % 8    
   oTable:REPLACE("DOC_DESC09",0) // % 9     
   oTable:REPLACE("DOC_DESC10",0) // % 10

  // Descuento en Monto

   oTable:REPLACE("DOC_DESM01",0) //  1
   oTable:REPLACE("DOC_DESM02",0) //  2
   oTable:REPLACE("DOC_DESM03",0) //  3
   oTable:REPLACE("DOC_DESM04",0) //  4
   oTable:REPLACE("DOC_DESM05",0) //  5
   oTable:REPLACE("DOC_DESM06",0) //  6
   oTable:REPLACE("DOC_DESM07",0) //  7
   oTable:REPLACE("DOC_DESM08",0) //  8    
   oTable:REPLACE("DOC_DESM09",0) //  9     
   oTable:REPLACE("DOC_DESM10",0) //  10

   oTable:REPLACE("SALDOCXC",nSaldo  ) // Saldo de Cuentas por Cobrar

   oTable:Gotop()

   oDp:cWhereDoc:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal    )+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND "+;
                  "DOC_TIPTRA"+GetWhere("=","D")                          

   oTable:Gotop()


   WHILE !oTable:Eof()
     // Calcula Impuesto Factura por Factura

     IF oTable:DOC_NUMMEM>0 .AND. Empty(oTable:MEM_MEMO) 
        oDp:cMemoDoc:=SQLGET("DPMEMO","MEM_MEMO","MEM_NUMERO"+GetWhere("=",oTable:DOC_NUMMEM))
        oTable:Replace("MEM_MEMO",oDp:cMemoDoc)
     ENDIF

     oDp:nPagIGTF:=0
     // Monto pagado Segun Divisas, calculado en Bs, de este monto obtenemos el % del IGTF
     oTable:REPLACE("DOC_PAGDIV",EJECUTAR("DPDOCCLIPAGDIV",oDp:cSucursal,cTipDoc,oTable:DOC_NUMERO))
     oTable:REPLACE("DOC_PAGITF",oDp:nPagIGTF)

// ? oTable:DOC_PAGDIV,"AQUI ES IGTF",oDp:nPagIGTF,"oDp:nPagIGTF"

     nSaldo:=SQLGET("DPDOCCLI","SUM(DOC_NETO*DOC_CXC)","DOC_CODIGO"+GetWhere("=" ,oTable:DOC_CODIGO)+" AND "+;
                                                       "DOC_ACT=1 AND DOC_CXC<>0 AND "+;
                                                       "(DOC_FECHA"+GetWhere("<=",oTable:DOC_FECHA )+" OR "+;
                                                       "(DOC_FECHA"+GetWhere("=" ,oTable:DOC_FECHA )+" AND  DOC_HORA"+GetWhere("<=",oTable:DOC_HORA)+"))")

     oTable:REPLACE("SALDOCXC",nSaldo  ) // Saldo de Cuentas por Cobrar


     oTable:DOC_DESCCO:=SQLGET("DPDOCCLI","DOC_DESCCO","DOC_CODSUC"+GetWhere("=",oDp:cSucursal    )+" AND "+;
                                          "DOC_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
                                          "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND "+;
                                          "DOC_TIPTRA"+GetWhere("=","D"))

     aDesc:=_VECTOR(oTable:DOC_DESCCO,",")

     FOR I=1 TO LEN(aDesc)
        oTable:REPLACE("DOC_DESC"+STRZERO(I,2),aDesc[I]) 
     NEXT I

       
     oDp:aArrayIva:={}
     EJECUTAR("DPDOCCLIIMP",oTable:DOC_CODSUC,cTipDoc,oTable:DOC_CODIGO,oTable:DOC_NUMERO,;
                           .F.,oTable:DOC_DCTO,oTable:DOC_RECARG,oTable:DOC_OTROS,"V")

// ViewArray(oDp:aArrayIva)

     IF EMPTY(oDp:aArrayIva) .OR. oDp:nBruto=0 // Impuesto de Documentos

          EJECUTAR("DPDOCCLIIVA",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_CODIGO,oTable:DOC_NUMERO,.T.,;
                                  oTable:DOC_DCTO  ,oTable:DOC_RECARG,oTable:DOC_OTROS,0)


     ENDIF

//   ? oDp:IVA_GN,"IVA_GN",oDp:BAS_GN


// 14/06/2023 Base imponible es CERO si el IVA es CERO     oDp:nBaseNet:=IF(Empty(oDp:nBaseNet),oDp:nBruto,oDp:nBaseNet)

//? oDp:nBaseNet,"oDp:nBaseNet"

//   oTable:REPLACE("DOC_EXONER",oDp:nMontoEx,19,2 )
//   oTable:REPLACE("DOC_EXONER",oTable:DOC_MTOEXE,19,2 )
     oTable:REPLACE("DOC_EXONER",oDp:nMontoEx,19,2 )
     oTable:REPLACE("DOC_MTOEXE",oDp:nMontoEx,19,2 )

     oTable:REPLACE("DOC_BASNET",oDp:nBaseNet,19,2 )
     oTable:REPLACE("DOC_IMPOTR",oDp:nImpOtr ,19,2 )   // Otros Impuestos
     oTable:REPLACE("DOC_MTOIVA",oDp:nIva    ,19,2 ) // Otros Impuestos
     oTable:REPLACE("DOC_BRUTO" ,oDp:nBruto  ,19,2 ) // Monto Bruto

// ? oDp:nBruto,"oDp:nBruto", oTable:DOC_BRUTO,"oTable:DOC_BRUTO"

     oTable:REPLACE("DOC_NETAFE",oGrupo:DOC_NETO   ) // Monto Neto Factura que Afecta
     oTable:REPLACE("DOC_MONAFE",oGrupo:DOC_BASNET ) // Monto Base Factura que Afecta
     oTable:REPLACE("DOC_FCHAFE",oGrupo:DOC_FECHA  ) // Fecha Factura que Afecta
     oTable:REPLACE("DOC_IVAAFE",oGrupo:DOC_MTOIVA ) // Iva Factura que Afecta
     oTable:REPLACE("DOC_FISAFE",oGrupo:DOC_NUMFIS ) // Numero Fiscal Factura que Afecta

// y? oTable:DOC_VALCAM,oTable:DOC_MTODIV,"oTable:DOC_MTODIV"
     // Montos en DIVISA
     IF oTable:DOC_MTODIV=0 .OR. oTable:DOC_MTODIV=oTable:DOC_NETO
       oTable:REPLACE("DOC_MTODIV",ROUND(oTable:DOC_NETO  /oTable:DOC_VALCAM,2)) // Monto Neto en Divisas
     ENDIF

     oTable:REPLACE("DOC_IVADIV",ROUND(oTable:DOC_MTOIVA/oTable:DOC_VALCAM,2)) // Monto del IVA en Divisas
     oTable:REPLACE("DOC_EXEDIV",ROUND(oTable:DOC_MTOEXE/oTable:DOC_VALCAM,2)) // Monto del IVA en Divisas
     oTable:REPLACE("DOC_BASDIV",ROUND(oTable:DOC_BASNET/oTable:DOC_VALCAM,2)) // Monto Base Neta en Divisas

     oTable:REPLACE("DOC_BRUDIV",ROUND(oTable:DOC_BRUTO/oTable:DOC_VALCAM,2))  // Monto Bruto en Divisa

// ? oTable:DOC_BRUDIV,oTable:cTable,"oTable:DOC_BRUDIV,oTable:cTable"
// ? oTable:DOC_MTOEXE,"oTable:DOC_MTOEXE"
// oTable:

     // Base
     oTable:REPLACE("DOC_BAS_EX",oDp:BAS_EX) // Exento
     oTable:REPLACE("DOC_BAS_GN",oDp:BAS_GN) // General
     oTable:REPLACE("DOC_BAS_RD",oDp:BAS_RD) // Reducido
     oTable:REPLACE("DOC_BAS_S1",oDp:BAS_S1) // Suntuario 1
     oTable:REPLACE("DOC_BAS_S2",oDp:BAS_S2) // Suntuario 2

     // Monto de IVA
     oTable:REPLACE("DOC_IVA_EX",oDp:IVA_EX) // Exento
     oTable:REPLACE("DOC_IVA_GN",oDp:IVA_GN) // General
     oTable:REPLACE("DOC_IVA_RD",oDp:IVA_RD) // Reducido
     oTable:REPLACE("DOC_IVA_S1",oDp:IVA_S1) // Suntuario 1
     oTable:REPLACE("DOC_IVA_S2",oDp:IVA_S2) // Suntuario 2

     // Monto de IVA
     oTable:REPLACE("DOC_POR_EX",oDp:POR_EX) // Exento
     oTable:REPLACE("DOC_POR_GN",oDp:POR_GN) // General
     oTable:REPLACE("DOC_POR_RD",oDp:POR_RD) // Reducido
     oTable:REPLACE("DOC_POR_S1",oDp:POR_S1) // Suntuario 1
     oTable:REPLACE("DOC_POR_S2",oDp:POR_S2) // Suntuario 2

     oTable:REPLACE("ENLETRAS",PADR(ENLETRAS(oTable:DOC_NETO),300))
     oTable:REPLACE("ENLETRASBSF",PADR(ENLETRAS(oTable:DOC_NETO/1000),300))
     oTable:REPLACE("ENLETRASDIV",PADR(ENLETRAS(oTable:DOC_MTODIV),300))

// ? oTable:DOC_RECNUM,"DOC_RECNUM"

// DR20080326
// DR20080326     IF !Empty(aRecibos)
     IF !EMPTY(oTable:DOC_RECNUM)
        AADD(aRecibos, oTable:DOC_RECNUM)
     ENDIF
// DR20080326     ENDIF
     oTable:DbSkip()

   ENDDO

// ? LEN(aRecibos),"ARECIBOS"
// oTable:CTODBF(cFileDbf+"hCrp+"DPFACTURACLI.DBF" ,"DBFCDX")

   // Asigna 20 Caracteres para ser Compatible con DPMOVINV (Crystal Report)   
   IF oTable:FIELDPOS("DOC_NUMERO")>0
    //  oTable:aFields[oTable:FIELDPOS("DOC_NUMERO"),3]:=20
   ENDIF

// ViewArray(oTable:aFields())
   // jn 22/11/2019
//   oTable:CTODBF(cFileDbf ,"DBFCDX") // DOCCLIFAV.DBF  no debe ser generada por REPOUTPUT

   oTable:GOTOP()
//   oTable:aFields[oTable:FieldPos("DOC_NUMERO"),3]:=20

   // ViewArray(oTable:aFields)
   //  ? oTable:FieldPos("DOC_MUMERO")

// ? "PONER EL 20 A -> DOC_NUMERO ",cFileDbf+"CLI.DBF" 
// oTable:Browse()

   oTable:CTODBF(cFileDbf+"CLI.DBF" ,"DBFCDX")


// ? cFileDbf+"CLI.DBF"
// ? cFileDbf+"CLI.DBF","AQUI DEBE SER DOCCLINENCLI.DBF"

//? cFileDbf+"CLI.DBF","AQUI"
// oTable:Browse()
   oTable:End()
/*
CLOSE ALL
SELECT A
USE (cFileDbf+"CLI.DBF")

? A->DOC_BRUTO,"BRUTO"
BROWSE()
CLOSE ALL
*/

   DPWRITE("TEMP\"+cFileDbf+"CLI.SQL",oTable:cSql)

// ? cFileDbf+"CLI.DBF"

   // Resumen de Impuestos Impuestos
// FERASE(oDp:cPathCrp+"DPFACTURAIMP.DBF")
   FERASE(cFileDbf+"IMP.DBF")
//   DPWRITE("TEMP\"+cFileDbf+"IMP.SQL",oTable:cSql)

   // 05/06/2023
   // Tipo de documento del cliente, contiene campo MEMO

   cSqlTipDoc:=" SELECT * FROM DPTIPDOCCLI "+;
               " INNER JOIN DPMEMO   ON TDC_NUMMEM=MEM_NUMERO WHERE TDC_TIPO"+GetWhere("=",cTipDoc)+" GROUP BY TDC_TIPO"

// ? CLPCOPY(cSqlTipDoc)

   oTable:=OpenTable(cSqlTipDoc,.T.)

   oTable:CTODBF(oDp:cPathCrp+cTipDocCli+".DBF" ,"DBFCDX")
   FERASE(oDp:cPathCrp+"cTipDocCli.CDX")
   USE (oDp:cPathCrp+cTipDocCli+".DBF") VIA "DBFCDX" EXCLU NEW

   oDp:cLeyenda2:=FIELD->MEM_MEMO

// ? oDp:cLeyenda2,"oDp:cLeyenda2"

   INDEX ON TDC_TIPO TAG "DPTIPDOCCLI" TO (oDp:cPathCrp+cTipDocCli+".CDX")

// ? indexkey(1)

// BROWSE()
   CLOSE ALL

// 05/06/2023
   // Tipo de documento del cliente, contiene campo MEMO

   cSqlTipDoc:=" SELECT * FROM DPTIPDOCCLIMOT "+;
               " INNER JOIN DPMEMO   ON MDC_NUMMEM=MEM_NUMERO  "+;
               " WHERE MDC_CODIGO"+GetWhere("=",cGirNum)+" GROUP BY MDC_CODIGO "

   oTable:=OpenTable(cSqlTipDoc,.T.)

// ? CLPCOPY(oDp:cSql)
// ENLACE CON DPDOCCLI.DOC_GIRNUM=MDC_

   oTable:CTODBF(oDp:cPathCrp+"DPTIPDOCCLIMOT.DBF" ,"DBFCDX")
   FERASE(oDp:cPathCrp+"DPTIPDOCCLIMOT.CDX")
   USE (oDp:cPathCrp+"DPTIPDOCCLIMOT.DBF") VIA "DBFCDX" EXCLU NEW
// BROWSE()
   INDEX ON MDC_CODIGO TAG "DPTIPDOCCLIMOT" TO (oDp:cPathCrp+"DPTIPDOCCLIMOT.CDX")

// ? oTable:DOC_GIRNUM,"DOC_GIRNUM",cGirNum
//
// BROWSE()
   CLOSE ALL



   cSqlIVA:=" SELECT DOC_NUMERO,DOC_CODIGO,TIP_CODIGO , TIP_DESCRI , MOV_IVA , SUM(MOV_TOTAL) AS MOV_TOTAL,"+;
            " SUM(MOV_TOTAL*MOV_IVA/100) AS MOV_MTOIVA, "+;
            " 0 AS MOV_PORVAR,0 AS MOV_BASNET,0 AS MOV_IVANET,SUM(MOV_IMPOTR) AS MOV_IMPOTR "+;
            " FROM DPMOVINV "+;
            " INNER JOIN DPIVATIP ON MOV_TIPIVA=TIP_CODIGO  "+;
            " INNER JOIN DPDOCCLI ON MOV_CODSUC=DOC_CODSUC  "+;
            "                    AND MOV_CODCTA=DOC_CODIGO  "+;
            "                    AND MOV_DOCUME=DOC_NUMERO  "+;
            "                    AND MOV_TIPDOC=DOC_TIPDOC  "+;                         
            " "+cWhere+ GetWhereOr("DOC_NUMERO",aNumDoc)+;
            " GROUP BY DOC_NUMERO,DOC_CODIGO,TIP_CODIGO , TIP_DESCRI , MOV_IVA "

   oTable:=OpenTable(cSqlIva,.T.)

// CLPCOPY(cSqliva)
// oTable:Browse()
// oTable:CTODBF(oDp:cPathCrp+"DPFACTURAIVA.DBF" ,"DBFCDX")
// FERASE(oDp:cPathCrp+"DPFACTURAIVA.CDX")
// USE (oDp:cPathCrp+"DPFACTURAIVA.DBF") VIA "DBFCDX" EXCLU NEW
// INDEX ON DOC_NUMERO+DOC_CODIGO TAG "DPFACTURAIVA" TO (oDp:cPathCrp+"DPFACTURAIVA.CDX")

   oTable:CTODBF(cFileDbf+"IVA.DBF" ,"DBFCDX")
   FERASE(cFileDbf+"IVA.CDX")

   DPWRITE("TEMP\"+cFileDbf+"IVA.SQL",oTable:cSql)

   USE (cFileDbf+"IVA.DBF") VIA "DBFCDX" EXCLU NEW
   INDEX ON DOC_NUMERO+DOC_CODIGO TAG "DPFACTURAIVA" TO (cFileDbf+"IVA.CDX")
   oTable:End()

// FERASE(oDp:cPathCrp+"DPFACTURACLI.CDX")
// USE (oDp:cPathCrp+"DPFACTURACLI.DBF") VIA "DBFCDX" EXCLU NEW
// INDEX ON DOC_NUMERO+DOC_CODIGO TAG "DPFACTURACLI" TO (oDp:cPathCrp+"DPFACTURACLI.CDX")
// USE

   FERASE(cFileDbf+"CLI.CDX")
   USE (cFileDbf+"CLI.DBF") VIA "DBFCDX" EXCLU NEW


   DPWRITE("TEMP\"+cFileDbf+"CLI.SQL",oTable:cSql)

   INDEX ON DOC_NUMERO+DOC_CODIGO TAG "DPFACTURACLI" TO (cFileDbf+"CLI.CDX")
   USE

   // Datos del Cuerpo, COMPONENTES

   // Datos del Cuerpo
   cSqlMov:=" SELECT "+SELECTFROM("DPMOVINV",.F.)+;
            ",DPMEMO.MEM_MEMO AS MOV_MEMO,IF(MOV_NUMMEM>0 AND MEM_DESCRI"+GetWhere("<>","")+",MEM_DESCRI,DPINV.INV_DESCRI) AS MOV_DESCRI"+;
            ",MOV_MTODIV "+;
            ",ROUND(MOV_PRECIO/"+LSTR(nValCam)+",2)    AS MOV_PREDIV "+;
            ",MOV_PRECIO-(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_PREDES "+;
            ",ROUND(MOV_PRECIO/"+LSTR(nValCam)+",2)    AS MOV_PREDIV "+;
            ",(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_MTODES "+;
            ",ROUND((MOV_PRECIO*(MOV_DESCUE/100))/"+LSTR(nValCam)+",2) AS MOV_DESDIV "+;
            ","+SELECTFROM("DPINV"     ,.F.)+;
            ","+SELECTFROM("DPIVATIP"  ,.F.,"TIP_CODIGO")+;
            ","+SELECTFROM("DPUNDMED"  ,.F.)+;
            ","+SELECTFROM("DPINVMED"  ,.F.)+;
            ","+SELECTFROM("DPTALLAS"  ,.F.)+;
            ","+SELECTFROM("DPPERSONAL",.F.)+;
            ",DPGRU.GRU_DESCRI "+;
            ","+SELECTFROM("DPMARCAS"   ,.F.)+;
            " FROM DPMOVINV "+;
            " LEFT  JOIN DPINV      ON MOV_CODIGO           = INV_CODIGO       "+;
            " LEFT  JOIN DPGRU      ON DPINV.INV_GRUPO      = DPGRU.GRU_CODIGO "+;
            " LEFT  JOIN DPMARCAS   ON DPINV.INV_CODMAR     = DPMARCAS.MAR_CODIGO "+;
            " LEFT  JOIN DPIVATIP   ON MOV_TIPIVA           = TIP_CODIGO "+;
            " LEFT  JOIN DPTALLAS   ON INV_TALLAS           = TAL_CODIGO "+;
            " LEFT  JOIN DPPERSONAL ON MOV_CODPER           = PER_CODIGO "+;
            " LEFT  JOIN DPUNDMED   ON MOV_UNDMED           = UND_CODIGO "+;
            " LEFT  JOIN DPINVMED   ON MOV_CODIGO           = IME_CODIGO AND MOV_UNDMED=IME_UNDMED "+;
            " LEFT  JOIN "+oDp:cDpMemo+" ON MOV_NUMMEM           = MEM_NUMERO AND MEM_ID "+GetWhere("=",oDp:cIdMemo)+;
            " WHERE DPMOVINV.MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "       DPMOVINV.MOV_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            GetWhereOr("MOV_DOCUME",aNumDoc)+" AND "+;
            "       DPMOVINV.MOV_INVACT=1 AND "+;
            "       DPMOVINV.MOV_TIPO"+GetWhere("=","C")+;
            " "

// GROUP BY DPMOVINV.MOV_ITEM,DPMOVINV.MOV_CODIGO "
//" GROUP BY DPMOVINV.MOV_ITEM,DPMOVINV.MOV_CODIGO "
// ? CLPCOPY(cSqlMov)

   cSqlMov:=STRTRAN(cSqlMov,"DPMEMO.",oDp:cDPMEMO+".")

//  ? CLPCOPY(cSqlMov)

   oTable:=OpenTable(cSqlMov,.T.)

   WHILE !oTable:EOF()

      IF "PREVISUALIZAR"$oGenRep:cTitle
         oTable:REPLACE("INV_DESCRI","PREVIEW"+ALLTRIM(oTable:INV_DESCRI))
         oTable:REPLACE("MOV_DESCRI","PREVIEW"+ALLTRIM(oTable:MOV_DESCRI))
      ENDIF

      IF oTable:MOV_MTODIV=0 .AND. nValCam>0
        oTable:Replace("MOV_MTODIV",oTable:MOV_TOTAL/nValCam)
      ENDIF


      oTable:Replace("MOV_PVPSID",oTable:MOV_PRECIO*MOV_PESO)

      IF oTable:MOV_NUMMEM>0 .AND. Empty(oTable:MEM_MEMO) 
        oDp:cMemoDoc:=SQLGET("DPMEMO","MEM_MEMO","MEM_NUMERO"+GetWhere("=",oTable:MOV_NUMMEM))
        oTable:Replace("MEM_MEMO",oDp:cMemoDoc)
      ENDIF

      oTable:DbSkip()

   ENDDO

   oTable:CTODBF(cFileDbf+"DETCOMP.DBF" ,"DBFCDX")

   DPWRITE("TEMP\"+cFileDbf+"DETCOMP.SQL",oTable:cSql)

   oTable:End()

   FERASE(cFileDbf+"DETCOMP.CDX")
   USE (cFileDbf+"DETCOMP.DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON MOV_ITEM_C+MOV_CODCOM TAG "DPFACTURADET" TO (cFileDbf+"DETCOMP.CDX")


   // Datos del Cuerpo
   cSqlMov:=""
   cSqlMov:=" SELECT "+SELECTFROM("DPMOVINV",.F.)+;
            ",DPMEMO.MEM_MEMO AS MOV_MEMO,IF(MOV_NUMMEM>0 AND MEM_DESCRI"+GetWhere("<>","")+",MEM_DESCRI,DPINV.INV_DESCRI) AS MOV_DESCRI"+;
            ",ROUND(MOV_PRECIO/"+LSTR(nValCam)+",2)                         AS MOV_PREDIV "+;
            ",IF(MOV_MTODIV IS NULL,MOV_TOTAL/"+LSTR(nValCam)+",MOV_MTODIV) AS MOV_MTODIV "+;
            ",MOV_PRECIO-(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_PREDES "+;
            ",(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_MTODES "+;
            ",ROUND((MOV_PRECIO*(MOV_DESCUE/100))/"+LSTR(nValCam)+",2) AS MOV_DESDIV "+;
            ","+SELECTFROM("DPINV"     ,.F.)+;
            ","+SELECTFROM("DPIVATIP"  ,.F.,"TIP_CODIGO")+;
            ","+SELECTFROM("DPUNDMED"  ,.F.)+;
            ","+SELECTFROM("DPINVMED"  ,.F.)+;
            ","+SELECTFROM("DPTALLAS"  ,.F.)+;
            ","+SELECTFROM("DPPERSONAL",.F.)+;
            ",DPGRU.GRU_DESCRI "+;
            ","+SELECTFROM("DPMARCAS"   ,.F.)+;
            " FROM DPMOVINV "+;
            " LEFT  JOIN DPINV      ON MOV_CODIGO           = INV_CODIGO       "+;
            " LEFT  JOIN DPGRU      ON DPINV.INV_GRUPO      = DPGRU.GRU_CODIGO "+;
            " LEFT  JOIN DPMARCAS   ON DPINV.INV_CODMAR     = DPMARCAS.MAR_CODIGO "+;
            " LEFT  JOIN DPIVATIP   ON MOV_TIPIVA           = TIP_CODIGO "+;
            " LEFT  JOIN DPTALLAS   ON INV_TALLAS           = TAL_CODIGO "+;
            " LEFT  JOIN DPPERSONAL ON MOV_CODPER           = PER_CODIGO "+;
            " LEFT  JOIN DPUNDMED   ON MOV_UNDMED           = UND_CODIGO "+;
            " LEFT  JOIN DPINVMED   ON MOV_CODIGO           = IME_CODIGO AND MOV_UNDMED=IME_UNDMED "+;
            " LEFT  JOIN "+oDp:cDpMemo+" ON MOV_NUMMEM           = MEM_NUMERO AND MEM_ID "+GetWhere("=",oDp:cIdMemo)+;
            " WHERE DPMOVINV.MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "       DPMOVINV.MOV_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            GetWhereOr("MOV_DOCUME",aNumDoc)+" AND "+;
            "       DPMOVINV.MOV_INVACT=1 "+;
            " GROUP BY MOV_ITEM "
            
   cSqlMov:=STRTRAN(cSqlMov,"DPMEMO.",oDp:cDPMEMO+".")

// ? "AQUI DEBE EMITIR LOS PRODUCTOS",CLPCOPY(cSqlMov)
// ? ,"INDIVIDUALES",CLPCOPY(cSqlMov)
// " INNER JOIN DPDOCCLI  ON MOV_CODSUC           = DOC_CODSUC AND "+;
//          "                         MOV_TIPDOC           = DOC_TIPDOC AND "+;
//          "                         MOV_CODCTA           = DOC_CODIGO AND "+;
//          "                         MOV_DOCUME           = DOC_NUMERO AND DOC_TIPTRA='D'"+;
// ORDER BY MOV_ITEM "
// CHKSQL(cSqlMov,.T.),CLPCOPY(cSqlMov)
// ? CLPCOPY(cSqlMov)

   oTable:=OpenTable(cSqlMov,.T.)

   oTable:AddField("MOV_SERIAL","M",10,0)
//   oTable:AddField("MOV_RTF","M",10,0)
//   oTable:AddField("INV_RTF","M",10,0)

   oTable:Replace("MOV_SERIAL",""+CRLF)
   oTable:GoTop()

   WHILE !oTable:Eof()

      IF "PREVISUALIZAR"$oGenRep:cTitle
         oTable:REPLACE("INV_DESCRI","PREVIEW:"+ALLTRIM(oTable:INV_DESCRI))
         oTable:REPLACE("MOV_DESCRI","PREVIEW:"+ALLTRIM(oTable:MOV_DESCRI))
      ENDIF

     oTable:Replace("MOV_PVPSID",oTable:MOV_PRECIO*MOV_PESO)

     // tiene Campo Memo
     IF oTable:INV_NUMMEM>0 
//        cMemo:=SQLGET("DPMEMO","MEM_BLOB","MEM_NUMERO"+GetWhere("=",oTable:INV_NUMMEM)+" AND MEM_ID"+GetWhere("=",oDp:cIdMemo))
        // oTable:Replace("MOV_MEMO","cMemo")
//        AADD(aMemo,oTable:INV_NUMMEM)
// ? oTable:INV_NUMMEM,"oTable:INV_NUMMEM"
     ENDIF

     // tiene Campo Memo

     IF oTable:MOV_NUMMEM>0 
        // cMemo:=SQLGET("DPMEMO","MEM_BLOB","MEM_NUMERO"+GetWhere("=",oTable:MOV_NUMMEM)+" AND MEM_ID"+GetWhere("=",oDp:cIdMemo))
        AADD(aMemo,oTable:MOV_NUMMEM)
     ENDIF

     IF !oTable:INV_METCOS="S"
        oTable:DbSkip()
        LOOP
     ENDIF

     cWhere:= " MSR_CODSUC"+GetWhere("=",oTable:MOV_CODSUC)+" AND "+;
              " MSR_CODALM"+GetWhere("=",oTable:MOV_CODALM)+" AND "+;
              " MSR_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
              " MSR_CODCTA"+GetWhere("=",oTable:MOV_CODCTA)+" AND "+;
              " MSR_NUMDOC"+GetWhere("=",oTable:MOV_DOCUME)+" AND "+;
              " MSR_ITEM  "+GetWhere("=",oTable:MOV_ITEM  )

     AADD(aSerWhere,cWhere)

     cSqlMov:=" SELECT MSR_SERIAL "+;
              " FROM DPMOVSERIAL WHERE "+cWhere
/*
              " MSR_TIPDOC"+GetWhere("=",cTipDoc      )    +" AND "+;
              " MSR_CODSUC"+GetWhere("=",oDp:cSucursal)    +" AND "+;
              " MSR_NUMDOC"+GetWhere("=",oTable:MOV_DOCUME)+" AND "+;
              " MSR_CODCTA"+GetWhere("=",oTable:MOV_CODCTA)+" AND "+;
              " MSR_ITEM  "+GetWhere("=",oTable:MOV_ITEM  )
*/
     oSerial:=OpenTable(cSqlMov,.T.)
     cMemo:=""

     WHILE !oSerial:Eof()

       // oDp:cSerialLen :=10
       // oDp:cSerialCant:=4
       // oDp:cSerialSep :=","
       nSeriales++

       FOR I=1 TO oDp:cSerialCant

          cSerial:=ALLTRIM(oSerial:MSR_SERIAL)
          
          IF (cSerial==oSerial:MSR_SERIAL)

             cMemo:=cMemo + IIF( I=1 .OR. oSerial:Eof() , "" , oDp:cSerialSep )+;
                     RIGHT(oSerial:MSR_SERIAL,oDp:cSerialLen)

          ELSE

             cMemo:=cMemo + IIF( I=1 .OR. oSerial:Eof() , "" , oDp:cSerialSep )+;
                     LEFT(oSerial:MSR_SERIAL,oDp:cSerialLen)

          ENDIF

          oSerial:DbSkip()

       NEXT 

       cMemo:=cMemo+CRLF

     ENDDO

//   oSerial:Browse()
//   ? cMemo
     oSerial:End()
     oTable:REPLACE("MOV_SERIAL",cMemo)

     // Documento Asociado
     IF !Empty(oTable:MOV_ASOTIP) 

         cWhereAso:=cWhereAso + IIF( Empty(cWhereAso) , "", " OR ")+ ;
                   "( MOV_ASOTIP"+GetWhere("=",oTable:MOV_ASOTIP)+" AND MOV_ASODOC "+GetWhere("=",oTable:MOV_ASODOC)+")"

     ENDIF

     oTable:DbSkip()

   ENDDO

   oTable:GoTop()
  
   IF !Empty(cWhereAso)

     cWhereAso:="MOV_CODSUC"+GetWhere("=",oTable:MOV_CODSUC)+" AND MOV_TIPDOC"+GetWhere("=",oTable:MOV_TIPDOC)+" AND "+;
                 "("+cWhereAso+")"

   ELSE

      cWhereAso:="1=0"

   ENDIF


   IF !Empty(oGenRep:uValue1)
     EJECUTAR("DPPOLIZA",oGenRep:uValue1,oTable)
   ENDIF

   oTable:GoTop()

   nField:=oTable:FieldPos("MOV_DOCUME")

   IF nField>0
     oTable:aFields[nField,3]:=10
     AEVAL(oTable:aDataFill,{|a,n| oTable:aDataFill[n,nField]:=LEFT(a[nField],10)})
   ENDIF

   // ViewArray(oTable:aFields)

   oTable:CTODBF(cFileDbf+"DET.DBF" ,"DBFCDX")

   DPWRITE("TEMP\"+cFileDbf+"DET.SQL",oTable:cSql)

   oTable:End()

   FERASE(cFileDbf+"DET.CDX")
   USE (cFileDbf+"DET.DBF") VIA "DBFCDX" EXCLU NEW

// INDEX ON MOV_DOCUME+MOV_CODCTA+MOV_ITEM TAG "DPFACTURADET" TO (cFileDbf+"DET.CDX") // MOV_ITEM genera incidencia
   INDEX ON MOV_DOCUME+MOV_CODCTA TAG "DPFACTURADET" TO (cFileDbf+"DET.CDX")

// ? LEN(MOV_DOCUME) ,"LEN(MOV_DOCUME)"

   CLOSE ALL
   /*
   // Memos RTF
   */
   IF Empty(aMemo)
      AADD(aMemo,0)
   ENDIF

// JN 31/03/2023 esto no funciono con crystal report, tiempo perdido
// ViewArray(aMemo)

   FERASE("CRYSTAL\DPMEMORTF.DBF")
   FERASE("CRYSTAL\DPMEMORTF.CDX")
   FERASE("CRYSTAL\DPMEMORTF.FPT")

   oTable:=OpenTable("SELECT MEM_NUMERO AS RTF_NUMERO,MEM_RTF AS RTF_MEMO FROM DPMEMO WHERE "+GetWhereOr("MEM_NUMERO",aMemo),.T.)
   oTable:CTODBF("CRYSTAL\DPMEMORTF.DBF")
   oTable:End()
  

   USE ("CRYSTAL\DPMEMORTF.DBF") VIA "DBFCDX" EXCLU NEW

// ? "ALIAS",ALIAS()
// BROWSE()

   INDEX ON RTF_NUMERO TAG "DPMEMORTF" TO ("CRYSTAL\DPMEMORTF.CDX")


   /*
   // Gestion de Horarios
   */

   cWhere:= " MIH_CODSUC"+GetWhere("=",oTable:MOV_CODSUC)+" AND "+;
            " MIH_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
            " MIH_NUMERO"+GetWhere("=",oTable:MOV_DOCUME)+" AND "+;
            " MIH_TIPO  "+GetWhere("=","A"              )

   oTable:=OpenTable("SELECT * FROM DPMOVINVHORA WHERE "+cWhere,.T.)
   nField:=oTable:FieldPos("MIH_NUMERO")

   IF nField>0
     oTable:aFields[nField,3]:=10
   ENDIF

   oTable:CTODBF(cMovInrHor+".DBF" ,"DBFCDX")
   oTable:End()

   FERASE(cMovInrHor+".CDX")
   USE (cMovInrHor+".DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON MIH_ITEM TAG "DPMOVINVHORA" TO (cMovInrHor+".CDX")


/*
   // Seriales
   cSqlMov:=" SELECT "+SELECTFROM("DPMOVSERIAL",.F.)+;
            " FROM DPMOVSERIAL "+;
	      " WHERE  (MSR_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            "         MSR_CODSUC"+GetWhere("=",oDp:cSucursal)+") AND ( "+;
            " "
//  GetWhereOr("MSR_NUMDOC",aNumDoc)+;

   FOR I=1 TO LEN(aCodCli)
       cSqlMov:=cSqlMov+IIF(I>1," OR ", "") +" (MSR_NUMDOC"+GetWhere("=",aNumDoc[I])+" AND MSR_CODCTA"+GetWhere("=",aCodCli[I])+")"
   NEXT I

   cSqlMov:=cSqlMov+")"
*/
   cWhere:=""
   AEVAL(aSerWhere, { |cMemo| cWhere:=cWhere + IIF( Empty(cWhere), "" , " OR " )+;
                              "("+cMemo+")" })

   cWhere:=IIF( Empty(cWhere), "", " WHERE ") + cWhere


   cSqlMov:="SELECT * FROM DPMOVSERIAL "+cWhere 

   oTable:=OpenTable(cSqlMov,nSeriales>0)
   oTable:CTODBF(cFileDbf+"SER.DBF" ,"DBFCDX")
   oTable:End()

   FERASE(cFileDbf+"SER.CDX")
   USE (cFileDbf+"SER.DBF") VIA "DBFCDX" EXCLU NEW
// INDEX ON MSR_NUMDOC+MSR_CODCTA          TAG "DPFACTURASER" TO (cFileDbf+"SER.CDX")
   INDEX ON MSR_NUMDOC+MSR_CODCTA+MSR_ITEM TAG "DPFACTURASER" TO (cFileDbf+"SER.CDX")


// BROWSE()
// USE

   cSqlDir:="SELECT * FROM DPDOCCLIDIR "+;
            " WHERE  (DIR_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            "         DIR_CODSUC"+GetWhere("=",oDp:cSucursal)+") AND "+;
            GetWhereOr("DIR_NUMDOC",aNumDoc)

   oTable:=OpenTable(cSqlDir)
   oTable:CTODBF(cFileDir+".DBF" ,"DBFCDX")

   FERASE(cFileDir+".CDX")
   USE (cFileDir+".DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON DIR_NUMDOC+DIR_CODIGO TAG "DPFACTURADIR" TO (cFileDir+".CDX")

//   CLPCOPY(cSqlDir)

   CLOSE ALL

   // Crea los Datos del Pago
   // AEVAL(aRecibos,{|a,n|aRecibos[n]:=a[1]})

   // Asociación de Anticipos
//   cSql:=" SELECT DOC_TIPDOC,MOV_ASODOC,DOC_RECNUM,REC_MONTO,REC_FECHA,REC_HORA FROM DPMOVINV "+;
//         " INNER JOIN DPDOCCLI ON DOC_TIPDOC=MOV_ASOTIP AND DOC_NUMERO=MOV_ASODOC "+;
//         " INNER JOIN DPRECIBOSCLI ON REC_NUMERO=DOC_RECNUM "+;
//         " WHERE MOV_TIPDOC='FAV' AND MOV_ASOTIP='CTZ' 
//GROUP BY DOC_TIPDOC,MOV_ASODOC,DOC_RECNUM,REC_MONTO,REC_FECHA,REC_HORA

    cSql:=" SELECT DOC_TIPDOC,DOC_NUMERO,DOC_RECNUM,REC_MONTO,REC_FECHA,REC_HORA FROM DPMOVINV "+;
          " INNER JOIN DPDOCCLI ON DOC_TIPDOC=MOV_ASOTIP AND DOC_NUMERO=MOV_ASODOC "+;
          " INNER JOIN DPRECIBOSCLI ON REC_NUMERO=DOC_RECNUM "+;
          " WHERE "+cWhereAso+;
          " GROUP BY DOC_TIPDOC,DOC_NUMERO,DOC_RECNUM,REC_MONTO,REC_FECHA,REC_HORA "


   // Anticipos Asociados a los Documentos Importados
   oTable:=OpenTable(cSql,"1=0"<>cWhereAso)

   oTable:CTODBF(cFileDbf+"ANT.DBF" ,"DBFCDX")

   FERASE(cFileDbf+"ANT.CDX")
   USE (cFileDbf+"ANT.DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON DOC_TIPDOC+DOC_NUMERO TAG "DPFACTURAANT" TO (cFileDbf+"ANT.CDX")

   oTable:End()

   EJECUTAR("DPFACTURAPAGREP",aRecibos,cTipDoc,_cTipDoc)
   EJECUTAR("CRYSTALINDEXKEY") // rehacer los indices para los vinculos

   /*
   // Documento Progresivo
   */

   cFileDbf:=oDp:cPathCrp+"DPCLIENTEPROG.DBF"

   IF !Empty(oGenRep:uValue1)

       oTable:=OpenTable("SELECT * FROM DPCLIENTEPROG WHERE DPG_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                                           "DPG_TIPDOC"+GetWhere("=",cTipDoc)      +" AND "+;
                                                           "DPG_NUMERO"+GetWhere("=",oGenRep:uValue1),.T.)
   ELSE

       oTable:=OpenTable("SELECT * FROM DPCLIENTEPROG",.F.)

   ENDIF

   oTable:CTODBF(cFileDbf,cRdd)
   oTable:End()

   /*
   // Cuotas del Documento Progresivo
   */

   cFileDbf:=oDp:cPathCrp+"DPDOCCLIPROG.DBF"

   IF !Empty(oGenRep:uValue1)

       oTable:=OpenTable("SELECT * FROM DPDOCCLIPROG WHERE PLC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                                          "PLC_TIPDOC"+GetWhere("=",cTipDoc)      +" AND "+;
                                                          "PLC_NUMERO"+GetWhere("=",oGenRep:uValue1),.T.)
   ELSE

       oTable:=OpenTable("SELECT * FROM DPDOCCLIPROG",.F.)

   ENDIF

   oTable:CTODBF(cFileDbf,cRdd)
   oTable:End()


   /*
   // Movimiento para Proyectos
   */

//? oGenRep:aCargo,Valtype(oGenRep:aCargo)
// IF ValType(oGenRep:aCargo)="C" .AND. !Empty(oGenRep:aCargo) .AND. oDp:nVersion>=5

   IF .F. 
      // 12/12/2013 Solo para AdaptaPro proyectos

      cFileDbf:="CRYSTAL\DPMOVINVPRY.DBF"

      cSqlMov:=" SELECT * FROM DPMOVINV "+;
               " INNER JOIN VIEW_DPINVPRY   ON MOV_CODCOM=PRY_CODIGO "+;
               " INNER JOIN DPINV           ON MOV_CODIGO=INV_CODIGO "+;
               " LEFT  JOIN DPMEMO          ON INV_NUMMEM=MEM_NUMERO "+;
               " INNER JOIN DPCOMPONENTECLA ON MOV_LOTE  =CDC_CODIGO "+;
               " LEFT  JOIN VIEW_DPMEMOPRY  ON MOV_NUMMEM=MPR_NUMERO "+;
               " WHERE MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
               "       MOV_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
               "       MOV_INVACT=1 "+;
               "   AND "+GetWhereOr("MOV_DOCUME",aNumDoc)
               " ORDER BY PRY_CODIGO,MOV_LOTE,MOV_CODIGO "

       oTable:=OpenTable(cSqlMov,.t.)
       oTable:CTODBF(cFileDbf,cRdd)
       oTable:End()

       FERASE("CRYSTAL\DPMOVINVPRY.CDX")
       CLOSE ALL
       USE (cFileDbf) EXCLU
       INDEX ON MOV_TIPDOC+MOV_DOCUME TAG "DPMOVINVPRY" TO ("CRYSTAL\DPMOVINVPRY.CDX")

       // Memos del DPMOVIV
       cFileDbf:="CRYSTAL\DPMOVINVMEMPRY.DBF"

       cSqlMov:= " SELECT MOV_TIPDOC,MOV_DOCUME,MOV_ITEM,MEM_DESCRI AS MOV_DESCRI,MEM_MEMO AS MOV_MEMO FROM DPMOVINV "+;
                 " LEFT  JOIN DPMEMO ON MOV_NUMMEM=MEM_NUMERO "+;
                 " WHERE MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                 "       MOV_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
                 "       MOV_INVACT=1 "+;
                 "   AND "+GetWhereOr("MOV_DOCUME",aNumDoc)
                 " ORDER BY MOV_TIPDOC,MOV_DOCUME,MOV_ITEM "

        oTable:=OpenTable(cSqlMov,.t.)
        oTable:CTODBF(cFileDbf,cRdd)
        oTable:End()

        FERASE("CRYSTAL\DPMOVINVMEMPRY.CDX")
        CLOSE ALL
        USE (cFileDbf) EXCLU
        INDEX ON MOV_TIPDOC+MOV_DOCUME+MOV_ITEM TAG "DPMOVINVMEMPRY" TO ("CRYSTAL\DPMOVINVMEMPRY.CDX")

   ENDIF

//
// Genera las Condiciones del Proyecto Administrativo
//
/*
//  JN 22/05/2013
    cFileDbf:="CRYSTAL\MEMOPRODUCTOADMINISTRATIVO"+_cTipDoc+"_CND.DBF"
    cFileCdx:="CRYSTAL\MEMOPRODUCTOADMINISTRATIVO"+_cTipDoc+"_CND.CDX"

    cSqlMov:=" SELECT * FROM DPINV "+;
             " LEFT  JOIN DPMEMO          ON INV_NUMMEM=MEM_NUMERO "+;
             " WHERE INV_CODIGO"+GetWhere("=",cTipDoc+"-CONDICION1") 

    oTable:=OpenTable(cSqlMov,.T.)
    oTable:CTODBF(cFileDbf,cRdd)
    oTable:End()

//
// Genera las Condiciones del Proyecto Nómina
//

    cFileDbf:="CRYSTAL\MEMOPRODUCTONOMINA"+_cTipDoc+"_CND.DBF"
    cFileCdx:="CRYSTAL\MEMOPRODUCTONOMINA"+_cTipDoc+"_CND.CDX"

    cSqlMov:=" SELECT * FROM DPINV "+;
             " LEFT  JOIN DPMEMO          ON INV_NUMMEM=MEM_NUMERO "+;
             " WHERE INV_CODIGO"+GetWhere("=",cTipDoc+"-CONDICION2") 

    oTable:=OpenTable(cSqlMov,.T.)
    oTable:CTODBF(cFileDbf,cRdd)
    oTable:End()

*/

  // JN 26/09/2013

  IF oDp:nVersion>=6

   cSqlMov:=" SELECT * FROM DPCTABANCO "+;
            " INNER JOIN DPBANCOS ON DPBANCOS.BAN_CODIGO=DPCTABANCO.BCO_CODIGO  "+;
            " WHERE BCO_IMPDOC=1  AND BCO_ACTIVA=1  AND BCO_CODSUC"+GetWhere("=",oDp:cSucursal)

   cFileDbf:="CRYSTAL\DPCTABANCO.DBF"
   oTable:=OpenTable(cSqlMov,.T.)
   oTable:CTODBF(cFileDbf,cRDD)
   oTable:End()

  ENDIF

/*
  cFileDbf:=oDp:cPathCrp+"DOCCLI"+_cTipDoc+".DBF"

? FILE(cFileDbf),cFileDbf,cSqlIni,CLPCOPY(oGenRep:cSql)

  CLOSE ALL
  USE (cFileDbf)
  BROWSE()
*/
// ? "aqui es",cTipDoc

  EJECUTAR("DOCCLIREPFAVCOPY",cTipDoc) // Clona FAV hacia CRE

  IF cTipDoc<>"FAV"
    EJECUTAR("DOCCLIREPFAVCOPY",cTipDoc,"FAV") // Clona FAV hacia CRE
  ENDIF

  IF cTipDoc="CRE"
    EJECUTAR("DOCCLIREPFAVCOPY","DEV","CRE") // Nota de Credito por Devolución de Venta (Versiones Anteriores DEV, Fiscalmente debe ser CRE)
  ENDIF

 

  EJECUTAR("RPTHEAD",oGenRep:oRun)

  EJECUTAR("DOCCLIDBFCLONE",NIL,cTipDoc,"FAV")

  IF ISSQLFIND("DPTIPDOCCLI","TDC_TIPO"+GetWhere("=","FA2")) 
    EJECUTAR("DOCCLIDBFCLONE",NIL,cTipDoc,"FA2")
  ENDIF

  IF cTipDoc="CTZ"
    EJECUTAR("DOCCLIDBFCLONE",NIL,cTipDoc,"PRE")
  ENDIF

  IF cTipDoc="PRE" 
    EJECUTAR("DOCCLIDBFCLONE",NIL,cTipDoc,"CTZ")
  ENDIF

  EJECUTAR("DPDOCCLIREPRTF",oDp:cSucursal,cTipDoc,RGO_I1,RGO_F1)

RETURN .T.
// EOF
