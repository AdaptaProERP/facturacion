// Programa   : DPCLIENTESCON
// Fecha/Hora : 12/09/2005 17:22:34
// Propósito  : Consulta Ficha del Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación : Ventas y Cuentas por Cobrar
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"
//#include "outlook.ch"
//#include "splitter.Ch"

PROCE MAIN(oFrm,cCodCli)
   LOCAL cNombre:="",aTipDoc:={},cSql,cRif:=""
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw
   LOCAL oBtn,nGroup,bAction,nDocCxC:=0,aTipDocSer:={},aTipDocInv:={},nNumMem:=0, nFilMai:=0,cCodRut
   LOCAL aTipCxC :={}
   LOCAL aTipOtr :={}
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL oData,lRun:=.F.

   // DEFAULT lRun:=.T.
   // oData:=DATASET("OUTLOOKTOBRW","ALL")
   // lRun:=oData:Set(":cTable ,lRun  )
   // oData:End(.T.)
   // lRun:=.T.
   
   DEFAULT cCodCli:=SQLGET("DPDOCCLI","DOC_CODIGO","DOC_CXC=1")

   IF ValType(oFrm)="O"

     IF cCodCli=NIL
        cCodCli:=oFrm:CLI_CODIGO
     ENDIF

    // cNombre:=oFrm:oCLINOMBRE:GetText()

   ENDIF

   DEFAULT cCodCli:=STRZERO(1,10)

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_NUMMEM,CLI_FILMAI,CLI_RIF,CLI_CODRUT","CLI_CODIGO"+GetWhere("=",cCodCli))

   nNumMem :=IF( Empty( oDp:aRow), 0 , oDp:aRow[2])
   nFilMai :=IF( Empty( oDp:aRow), 0 , oDp:aRow[3])
   cRif    :=IF( Empty( oDp:aRow), "", oDp:aRow[4])
   cCodRut :=IF( Empty( oDp:aRow), "", oDp:aRow[5])

/*
   cSql:=" SELECT TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC,COUNT(*) AS CUANTOS "+;
         " ,TDC_INVFIS,TDC_INVACT FROM DPTIPDOCCLI "+;
         " INNER JOIN DPDOCCLI ON TDC_TIPO=DOC_TIPDOC  "+;
         " WHERE DOC_TIPTRA='D' AND "+;
         "       DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
         "       DOC_CODIGO"+GetWhere("=",cCodCli      )+"  "+;
         " GROUP BY TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC "+;
         " ORDER BY TDC_DESCRI "
*/

   cSql:=" SELECT TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC,COUNT(*) AS CUANTOS,TDC_INVFIS,TDC_INVACT,SUM(DOC_CXC) AS DOC_CXC "+;
         " FROM DPTIPDOCCLI "+;
         " INNER JOIN DPDOCCLI ON DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND  TDC_TIPO=DOC_TIPDOC  AND DOC_CODIGO"+GetWhere("=",cCodCli)+" AND DOC_TIPTRA"+GetWhere("=","D")+;
         " GROUP BY TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC "+;
         " ORDER BY TDC_DESCRI "


   aTipDoc :=ASQL(cSql)
   aTipCxC :={}
   aTipOtr :={}

//ViewArray(aTipDoc)

   FOR I=1 TO LEN(aTipDoc)

     aTipDoc[I,5]:=CTOO(aTipDoc[I,5],"N")

     aTipDoc[I,2]:=IF(Empty(aTipDoc[I,2]),"BITMAPS\XBROWSE.BMP",aTipDoc[I,2])

     IF aTipDoc[I,6]
       AADD(aTipDocSer,aTipDoc[I])
     ENDIF

     IF aTipDoc[I,7]<>0
       AADD(aTipDocInv,aTipDoc[I])
     ENDIF

   NEXT I

// ViewArray(aTipDoc)
//   ASORT(aTipDoc,,, { |x, y| DTOS(x[5])<DTOS(y[5])})

   FOR I=1 TO LEN(aTipDoc)

     IF aTipDoc[I,4]="N"

       AADD(aTipOtr,aTipDoc[I])

       // Notas de Entrega hacia CxP
       IF aTipDoc[I,8]>0
         AADD(aTipCxC,aTipDoc[I])
         nDocCxC:=nDocCxC+aTipDoc[I,5]
       ENDIF

     ELSE

       AADD(aTipCxC,aTipDoc[I])
       nDocCxC:=nDocCxC+aTipDoc[I,5]

     ENDIF

   NEXT I

   aTipDoc:=ACLONE(aTipCxC)

   AADD(aData,{"Uno","Dos","Ttres"})
   AADD(aData,{"4","5","6"})

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-12 BOLD
   DEFINE FONT oFontBrw NAME "Tamoha" SIZE 0,-10 BOLD

   DpMdi("Consultar "+GetFromVar("{oDp:xDPCLIENTES}"),"oMdiCli","TEST.EDT")

   oMdiCli:cCodCli   :=cCodCli
   oMdiCli:cNombre   :=cNombre
   oMdiCli:lSalir  :=.F.
   oMdiCli:nHeightD:=45
   oMdiCli:lMsgBar :=.F.
   oMdiCli:oGrp    :=NIL
   oMdiCli:nNumMem :=nNumMem
   oMdiCli:nFilMai :=nFilMai
   oMdiCli:cRif    :=cRif
   oMdiCli:oFrm    :=oFrm
   oMdiCli:cCodRut :=cCodRut

   SetScript("DPCLIENTESCON")

   oMdiCli:Windows(0,0,aCoors[3]-180,415)  

  @ 48, -1 OUTLOOK oMdiCli:oOut ;
       SIZE 150+250, oMdiCli:oWnd:nHeight()-95 ;
       PIXEL ;
       FONT oFont ;
       OF oMdiCli:oWnd;
       COLOR CLR_BLACK,15400703   


//   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Browse de Opciones" 
//       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
//       BITMAP "BITMAPS\XBROWSE.BMP";
//       PROMPT "Browse de Opciones";
//       ACTION EJECUTAR("OUTLOOKTOBRW",oMdiCli:oOut)


 IF LEN(aTipDoc)>0

       DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Cuentas por Cobrar" 


       IF ISRELEASE("20.01")

          DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
                 BITMAP "BITMAPS\FACTURAVTA.BMP";
                 PROMPT "Estado de Cuenta por Factura";
                 ACTION (oMdiCli:REGAUDITORIA("Estado de Cuenta por Factura"),;
                         EJECUTAR("BRFAVPAGDEBCRE",NIL,NIL,11,NIL,NIL,NIL,NIL,oMdiCli:cCodCli))

//                                                 cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumFav,cCodigo,cTipo,cTipDoc
          DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
                 BITMAP "BITMAPS\TipDocument.bmp";
                 PROMPT "CxC resumida por Tipo de Documento";
                 ACTION (oMdiCli:REGAUDITORIA("CxC resumida por Tipo de Documento"),;
                         EJECUTAR("BRCXCTIPDOCCLI",NIL,NIL,11,NIL,NIL,NIL,NIL,oMdiCli:cCodCli))


       ENDIF

//  IF DPVERSION()>4.0

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\CXC.BMP";
              PROMPT "Análisis";
              ACTION (oMdiCli:REGAUDITORIA("Análisis de CxC"),;
                      EJECUTAR("DPCLIANALISIS",oMdiCli:cCodCli))


       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\Divisas.BMP";
              PROMPT "CxC Valorizada en Divisas";
              ACTION (oMdiCli:REGAUDITORIA("Actualizada en Divisas"),;
                      EJECUTAR("BRCXCENDIV","CXD_CODIGO"+GetWhere("=",oMdiCli:cCodCli)))

     DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
               BITMAP "BITMAPS\edocuenta.BMP";
               PROMPT "Estado de Cuenta";
               ACTION (oMdiCli:REGAUDITORIA("Estado de Cuenta"),;
                      EJECUTAR("DPDOCCLIVIEW",oMdiCli:cCodCli))



       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\DELIVERY.BMP";
              PROMPT "Planificar Cobranza";
              ACTION (oMdiCli:REGAUDITORIA("Planificar Cobranza"),;
                      EJECUTAR("BRCXCENDIV","CLI_CODIGO"+GetWhere("=",oMdiCli:cCodCli)))

//  ENDIF

/*
JN 04/09/2014 (Este programa no esta concluido)
       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\ANTIGUEDAD.BMP";
              PROMPT "Transferencia de Cobranza";
              ACTION (oMdiCli:REGAUDITORIA("Transferencia de Cobranza"),;
                      EJECUTAR("DPDOCTRACOBRO",oMdiCli:cCodCli))
*/

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\CXC.BMP";
              PROMPT "Saldo";
              ACTION (oMdiCli:REGAUDITORIA("Resumen Anual de Saldos"),;
                      EJECUTAR("DPCLIENTESSLD",oMdiCli:cCodCli,"Resumen Anual de Saldos"))


       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\SUCURSAL.BMP";
              PROMPT "CXC de Sucursales";
              ACTION (oMdiCli:REGAUDITORIA("CXC de Sucursales"),;
                      EJECUTAR("BRCXCSUCCLI",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCli:cCodCli))

     

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\VENCIMIENTOS.BMP" ;
              PROMPT "Vencimientos";
              ACTION (oMdiCli:REGAUDITORIA("Vencimientos"),;
                      EJECUTAR("CLIVIEWVEN",oMdiCli:cCodCli))

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\documentocxc.BMP" ;
              PROMPT "Documentos Pendientes";
              ACTION (oMdiCli:REGAUDITORIA("Documentos Pendientes"),;
                      EJECUTAR("DPDOCCLIPENDTE",oMdiCli:cCodCli))

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\DOCCXC.BMP" ;
              PROMPT "Documentos ("+LSTR(nDocCxC)+")";
              ACTION (oMdiCli:REGAUDITORIA("Documentos CXC"),;
                      EJECUTAR("DPCLIENTESDOC",oMdiCli:cCodCli))



    ENDIF

    FOR I=1 TO LEN(aTipDoc)

      DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
             BITMAP aTipDoc[i,2];
             PROMPT ALLTRIM(aTipDoc[i,3])+" ("+LSTR(aTipDoc[I,5])+") ";
             ACTION msginfo("Your code ...", "LISTO" )

      bAction:=[EJECUTAR("DPCLIDOCVIEW","]+oMdiCli:cCodCli+[","]+aTipDoc[I,1]+[","]+aTipDoc[i,3]+[")]

/*
      nGroup:=LEN(oMdiCli:oOut:aGroup)
      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

      bAction:=[EJECUTAR("DPCLIDOCVIEW","]+oMdiCli:cCodCli+[","]+aTipDoc[I,1]+[","]+aTipDoc[i,3]+[")]

      bAction:=BLOQUECOD(bAction)

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction
*/


      SETBTNGRPACTION(oMdiCli,bAction)


   NEXT 
      
 IF LEN(aTipDoc)>0

    DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Listar Documentos de Cuentas x Cobrar" 

    FOR I=1 TO LEN(aTipDoc)

      DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
             BITMAP aTipDoc[i,2];
             PROMPT ALLTRIM(aTipDoc[i,3])+" ("+LSTR(aTipDoc[I,5])+") ";
             ACTION msginfo("Your code ...", "LISTO" )

      bAction:=[EJECUTAR("DPCLIVERDOC","]+oMdiCli:cCodCli+[","]+aTipDoc[I,1]+[","]+aTipDoc[i,3]+[")]
      SETBTNGRPACTION(oMdiCli,bAction)

/*
     nGroup:=LEN(oMdiCli:oOut:aGroup)
      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

      bAction:=[EJECUTAR("DPCLIVERDOC","]+oMdiCli:cCodCli+[","]+aTipDoc[I,1]+[","]+aTipDoc[i,3]+[")]
      bAction:=BLOQUECOD(bAction)
      oBtn:bAction:=bAction

      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction
*/


   NEXT 

ENDIF

   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Ingresos"

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\RECPAGO.BMP" ;
          PROMPT "Recibos" ;
          ACTION (oMdiCli:REGAUDITORIA("Recibos"),;
                  EJECUTAR("DPRECCLIVIEW",oMdiCli:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\COMPARATIVO.BMP" ;
          PROMPT "Comparativo de Recibos" ;
          ACTION oMdiCli:COMPARATIVOS()


   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\BANCOS.BMP" ;
          PROMPT "Movimientos Bancarios" ;
          ACTION oMdiCli:MOBBCO()


    IF LEN(aTipOtr)>0

       DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Otros Documentos" 


    ENDIF

    FOR I=1 TO LEN(aTipOtr)

      DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
             BITMAP aTipOtr[i,2];
             PROMPT ALLTRIM(aTipOtr[i,3])+" ("+LSTR(aTipOtr[I,5])+") ";
             ACTION msginfo("Your code ...", "LISTO" )
 
      nGroup:=LEN(oMdiCli:oOut:aGroup)
      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

      bAction:=[EJECUTAR("DPCLIVERDOC","]+oMdiCli:cCodCli+[","]+aTipOtr[I,1]+[","]+aTipOtr[i,3]+[")]
      bAction:=BLOQUECOD(bAction)
      oBtn:bAction:=bAction

      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT 

   // Listar Documentos

   IF LEN(aTipDocInv)>0  
    DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Resumen de Productos por Documento"
   ENDIF

   FOR I=1 TO LEN(aTipDocInv)

      DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
             BITMAP aTipDocInv[i,2];
             PROMPT ALLTRIM(aTipDocInv[i,3]);
             ACTION msginfo("Your code ...", "LISTO" )
 
      nGroup:=LEN(oMdiCli:oOut:aGroup)
      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

      bAction:=[EJECUTAR("DPCLIINVVIEW","]+oMdiCli:cCodCli+[","]+aTipDocInv[I,1]+[","]+aTipDocInv[i,3]+[")]
      bAction:=BLOQUECOD(bAction)

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT 
      
   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Seriales"

   IF "DATAPRO"$UPPE(oDp:cEmpresa) .OR. "ADAPTAPRO"$UPPE(oDp:cEmpresa) 

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\LOGODP2.BMP" ;
              PROMPT "Licencias Asignadas" ;
              ACTION (oMdiCli:REGAUDITORIA("Licencias Asignadas"),;
                      EJECUTAR("DPLICXCLI",oMdiCli:cCodCli))

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\LOGODP2.BMP" ;
              PROMPT "Licencias Conformadas" ;
              ACTION (oMdiCli:REGAUDITORIA("Licencias Conformadas"),;
                      EJECUTAR("DPLICCONF",oMdiCli:cCodCli))


       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\CLIENTE.BMP" ;
              PROMPT "Licencias Conformadas por Clientes " ;
              ACTION (oMdiCli:REGAUDITORIA("Licencias Conformadas por Clientes"),;
                      EJECUTAR("DPLICCONFXINT",NIL,oMdiCli:cCodCli))



   ENDIF


    FOR I=1 TO LEN(aTipDocSer)

      DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
             BITMAP aTipDocSer[i,2];
             PROMPT ALLTRIM(aTipDocSer[i,3])+" ("+LSTR(aTipDocSer[I,5])+") ";
             ACTION msginfo("Your code ...", "LISTO" )
 
      nGroup:=LEN(oMdiCli:oOut:aGroup)
      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

      bAction:=[EJECUTAR("DPCLIDOCSER","]+oMdiCli:cCodCli+[","]+aTipDocSer[I,1]+[","]+aTipDocSer[i,3]+[")]
      bAction:=BLOQUECOD(bAction)

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT 

   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Retenciones"

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\RETISLR.bmp" ;
          PROMPT "Retenciones ISLR" ;
          ACTION (oMdiCli:REGAUDITORIA("Retenciones ISLR"),;
                  EJECUTAR("DPCLIRETISLR",oMdiCli:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\RETIVA.BMP" ;
          PROMPT "Retenciones de IVA" ;
          ACTION (oMdiCli:REGAUDITORIA("Retenciones de IVA"),;
                  EJECUTAR("DPCLIRETRTI",oMdiCli:cCodCli))


   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\ARC.BMP" ;
          PROMPT "ARC de Retenciones" ;
          ACTION EJECUTAR("DPCLIHACERARC",oMdiCli:cCodCli,YEAR(oDp:dFecha));
          WHEN .T.
             
   oBtn:cToolTip:="Crear ARC del "+oDp:xDPCLIENTES

   
   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Otros"


   IF .T.
//oDp:nVersion>=5

     DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
            BITMAP "BITMAPS\movimientoinv.bmp" ;
            PROMPT "Todos los Movimientos de "+oDp:DPINV  ;
            ACTION (oMdiCli:REGAUDITORIA("Todos los Movimientos de Inventario"),;
                    EJECUTAR("DPCLIENTESMOVIN",oMdiCli:cCodCli))

//     SETBTNGRPACTION(oMdiCli,[EJECUTAR("DPCLIENTESMOVIN",oMdiCli:cCodCli)])
//     nGroup:=LEN(oMdiCli:oOut:aGroup)
//     oBtn:=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])


     DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
            BITMAP "BITMAPS\CLIENTE.bmp" ;
            PROMPT "Antiguedad de Movimienros"  ;
            ACTION (oMdiCli:REGAUDITORIA("Antiguedad de Movimientos"),;
                    EJECUTAR("DPCLIENTEANTG",NIL,oMdiCli:cCodCli))

     IF !Empty(oMdiCli:nNumMem)

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\XMEMO.bmp" ;
              PROMPT "Ver Campo Memo "  ;
              ACTION (oMdiCli:REGAUDITORIA("Ver Campo Memo"),;
                      EJECUTAR("DPVERMEMO",oMdiCli:nNumMem,oDp:xDPCLIENTES+"="+oMdiCli:cCodCli+" "+oMdiCli:cNombre))

     ENDIF

     IF !Empty(oMdiCli:nFilMai)

       DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
              BITMAP "BITMAPS\ADJUNTAR.bmp" ;
              PROMPT "Ver Archivos Adjuntos "  ;
              ACTION (oMdiCli:REGAUDITORIA("Ver Archivos Adjuntos"),;
                      EJECUTAR("DPFILEEMPMAIN",oMdiCli:nFilMai,oDp:xDPCLIENTES+"="+oMdiCli:cCodCli+" "+oMdiCli:cNombre,NIL,NIL,.T.))

     ENDIF


   ENDIF


   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\XFIND.BMP" ;
          PROMPT "Busca Clientes" ;
          ACTION (oMdiCli:REGAUDITORIA("busca Clientes"),;
                  EJECUTAR("DPCLIBUSCAR",oMdiCli:cNombre ))


   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\PRECIOS.BMP" ;
          PROMPT "Ultimo Precio" ;
          ACTION (oMdiCli:REGAUDITORIA("Ultimo Precio"),;
                  EJECUTAR("DPCLIULTVTA",oMdiCli:cCodCli))


   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\CLIENTE.BMP" ;
          PROMPT "Ficha del Cliente" ;
          ACTION (oMdiCli:REGAUDITORIA("Ficha del Cliente"),;
                  EJECUTAR("DPFICHACLI",oMdiCli:cCodCli ))

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\EXPEDIENTES.BMP" ;
          PROMPT oDp:DPEXPEDIENTE+" en Seguimiento";
          ACTION (oMdiCli:REGAUDITORIA("Seguimientos de Expedientes"),;
                  EJECUTAR("DPRESEXPXCLI",oMdiCli:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\XENTREVISTA.BMP" ;
          PROMPT "Entrevistas" ;
          ACTION oMdiCli:ENTREVISTA()

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\PAISES.BMP" ;
          PROMPT "Personas Asistentes a Eventos" ;
          ACTION (oMdiCli:REGAUDITORIA("Personas Asistentes al Curso"),;
                  EJECUTAR("BRW_CLIPECUR",oMdiCli:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\PRODUCTO.BMP" ;
          PROMPT "Productos de Interés" ;
          ACTION (oMdiCli:REGAUDITORIA("Producto de Interés"),;
                  EJECUTAR("DPCLIENTESINVCO",oMdiCli:cCodCli))

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\FACTURAPER.BMP" ;
          PROMPT "Facturación Periódica" ;
          ACTION oMdiCli:FACTURAPER()


    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\GOOGLE.BMP" ;
          PROMPT "Buscar en Google" ;
          ACTION (oMdiCli:REGAUDITORIA("Buscar en Google"),;
                  EJECUTAR("GOOGLEE",oMdiCli:cNombre))

    IF ISRELEASE("17.01")

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
           BITMAP "BITMAPS\RNC.BMP" ;
           PROMPT "Buscar en RNC" ;
           ACTION (oMdiCli:REGAUDITORIA("Buscar en RCN"),;
                   EJECUTAR("BUSCARRNC",oMdiCli:cRif))

    ENDIF

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\CHEQUE.BMP" ;
          PROMPT "Buscar Cheques" ;
          ACTION (oMdiCli:REGAUDITORIA("Buscar Cheque"),;
                  EJECUTAR("CLICHKDEV",oMdiCli:cCodCli))

IF .T. 
// RELEASE("18.10")

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
          BITMAP "BITMAPS\guiadespacho.BMP" ;
          PROMPT "Guias de Transporte" ;
          ACTION (oMdiCli:REGAUDITORIA("Guia de Transporte"),;
                  EJECUTAR("BRGTRAXDOC","MOV_CODCTA"+GetWhere("=",oMdiCli:cCodCli)))

ENDIF

    DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Pistas de Auditoría"


    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
           BITMAP "BITMAPS\AUDITORIA.BMP" ;
           PROMPT "Auditoria del Registro" ;
           ACTION  EJECUTAR("VIEWAUDITOR","DPCLIENTES",oMdiCli:cCodCli,oMdiCli:cNombre,NIL ,NIL,NIL,NIL,NIL,"CLI_CODIGO"+GetWhere("=",oMdiCli:cCodCli))

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;
           BITMAP "BITMAPS\AUDITORIAXCAMPO.BMP" ;
           PROMPT "Auditoria por Campo" ;
           ACTION  EJECUTAR("DPAUDITAEMC",oMdiCli:oFrm,"DPCLIENTES","DPCLIENTES.SCG",oMdiCli:cCodCli,oMdiCli:cNombre)

   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Contabilidad"


    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\CONTABILIDAD.BMP" ;
           PROMPT "Cuentas Contables" ;
           ACTION (oMdiCli:REGAUDITORIA("Cuentas Contables"),;
                  EJECUTAR("DPCLIENTECTA",oMdiCli:cCodCli , .F. ))


    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\cbtediferido.bmp" ;
           PROMPT "Asientos Contables" ;
           ACTION (oMdiCli:REGAUDITORIA("Asientos Contables"),;
                  EJECUTAR("BRASIENTOSVTA","MOC_CODAUX"+GetWhere("=",oMdiCli:cCodCli)))

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\math.BMP" ;
           PROMPT "Conciliación Contables" ;
           ACTION (oMdiCli:REGAUDITORIA("Conciliación Contables"),;
                  EJECUTAR("BRCONCTADOCCLI","MOC_CODAUX"+GetWhere("=",oMdiCli:cCodCli),NIL,12,oDp:dFchInicio,oDp:dFchCierre))

    DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Ruta de Entrega y Pedidos"


    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\ruta.BMP" ;
           PROMPT "Ruta" ;
           ACTION (oMdiCli:REGAUDITORIA("Rutas"),;
                  DPLBX("DPRUTAS.LBX",oDp:DPRUTAS+" ["+ALLTRIM(oMdiCli:cNombre)+"]","REN_CODIGO"+GetWhere("=",oMdiCli:cCodRut)))

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\XBROWSE.bmp" ;
           PROMPT "Diario de Ruta de Entrega y Pedidos" ;
           ACTION (oMdiCli:REGAUDITORIA("Diario de Ruta de Entrega y Pedidos"),;
                   EJECUTAR("BRRUTAXDIA","DRT_CODRUT"+GetWhere("=",oMdiCli:cCodRut),NIL,NIL,NIL,NIL," ["+oDp:XDPCLIENTES+" "+oMdiCli:cCodCli+"]"))

   DEFINE GROUP OF OUTLOOK oMdiCli:oOut PROMPT "&Ventas"

    DEFINE BITMAP OF OUTLOOK oMdiCli:oOut ;   
           BITMAP "BITMAPS\sucursal.BMP" ;
           PROMPT "Venta x Sucursales" ;
           ACTION (oMdiCli:REGAUDITORIA("Venta Sucursales"),;
                   EJECUTAR("BRSEMSUCCLIPES",nil,nil,nil,nil,nil,nil,oMdiCli:cCodCli))

   oMdiCli:Activate("oMdiCli:FRMINIT()") //,,"oMdiCli:oSpl:AdjRight()")

   EJECUTAR("DPSUBMENUCREAREG",oMdiCli,NIL,"C","DPCLIENTES")

RETURN oMdiCli


FUNCTION FRMINIT()
   LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

   DEFINE BUTTONBAR oBar SIZE 42,42 OF oMdiCli:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

   IF oDp:nVersion>6 .OR. ISRELEASE("18.11")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
            ACTION EJECUTAR("OUTLOOKTOBRW",oMdiCli:oOut,oMdiCli:cCodCli,oMdiCli:cNombre,"DPCLIENTES","Consulta"),oMdiCli:End();
            WHEN oDp:nVersion>=6

 ENDIF


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oMdiCli:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 1,nCol SAYREF oMdiCli:oCodCli PROMPT oMdiCli:cCodCli;
           SIZE 80,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  SayAction(oMdiCli:oCodCli,{||EJECUTAR("DPCLIENTES",0,oMdiCli:cCodCli)})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
 
  @ 21,nCol SAY oMdiCli:cNombre;
            SIZE 300,19 BORDER  PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont


  oBar:Refresh(.T.)

  oMdiCli:oWnd:bResized:={||oMdiCli:oWnd:oClient := oMdiCli:oOut,;
                          oMdiCli:oWnd:bResized:=NIL}

                       

//  oMdiCli:oWnd:oClient := oMdiCli:oOut

RETURN .T.

// 


//   oMdiCli:oBrw:SetColor(nil,14155775)
/*
   oMdiCli:oWnd:bResized:={||oMdiCli:oDlg:Move(0,0,oMdiCli:oWnd:nWidth(),50,.T.),;
                             oMdiCli:oGrp:Move(0,0,oMdiCli:oWnd:nWidth()-15,oMdiCli:nHeightD,.T.)}
*/

/*
   oMdiCli:oWnd:bResized:={||oMdiCli:oSpl:AdjRight(),;
                         oMdiCli:oDlg:Move(0,oMdiCli:oOut:nWidth(),;
                         oMdiCli:oWnd:nWidth()-oMdiCli:oOut:nWidth()-08,oMdiCli:nHeightD,.T.),;
                         oMdiCli:oGrp:Move(0,0,;
                         oMdiCli:oWnd:nWidth()-oMdiCli:oOut:nWidth()-08,oMdiCli:nHeightD,.T.)}
*/

//	   EVal(oMdiCli:oWnd:bResized)

/*
   oMdiCli:oBrw:bLDblClick:={|oBrw|oBrw:=oMdiCli:oBrw,;
                                   EJECUTAR("DPDOCCLIVIEW",;
                                   oMdiCli:cCodCli,;
                                   oMdiCli:aData[oBrw:nArrayAt,1],;
                                   oMdiCli:aData[oBrw:nArrayAt,2],;
                                   oMdiCli:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}
   oMdiCli:oBrw:GoBottom()
*/

RETURN .T.

FUNCTION GETDATA(cWhere)
  LOCAL cSql,oTable,aData,nSaldo:=0,oCol,oFontB
  LOCAL cAno:="",nDebe:=0,nTDebe:=0,nHaber:=0,nTHaber:=0,nSaldo:=0,nTTran:=0,nTran:=0

  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0,-10 BOLD

  oMdiCli:cPicture:="999,999,999,999.99"

  cSql:=" SELECT YEAR(DOC_FECHA) AS ANO, MONTH(DOC_FECHA) AS MES,COUNT(*) AS CUANTOS, "+;
        " SUM(IF(DOC_CXC=1,DOC_NETO,0)) AS DEBE,SUM(IF(DOC_CXC=-1,DOC_NETO,0)) AS HABER "+;
        "  FROM DPDOCCLI "+;
        " WHERE DOC_ACT=1 AND  "+cWhere+;
        " GROUP BY YEAR(DOC_FECHA),MONTH(DOC_FECHA) "+;
        " ORDER BY DOC_FECHA "

  oDp:lMySqlNativo:=.T.

  oTable:=OpenTable(cSql,.T.)

  oDp:lMySqlNativo:=.F.

  oTable:CTONUM("MES")
  oTable:CTONUM("ANO")
  oTable:CTONUM("CUANTOS")

//  CLPCOPY(cSql)
  
  oTable:Replace("SALDO",nSaldo)
  oTable:GoTop()
//  oTable:Browse()
  cAno:=oTable:ANO

//  ? cAno,oTable:ANO


  WHILE !oTable:EOF()
     // Cambio de Ano

     IF !cAno=oTable:ANO 
        AADD(oTable:aDataFill,NIL) // oTable:RecNo())
        AINS(oTable:aDataFill,oTable:Recno()) 
        oTable:aDataFill[oTable:Recno()]:={cAno   ,cAno   ,STR(nTran,5),nDebe,nHaber,nSaldo}
        cAno:=oTable:ANO
        oTable:DbSkip()
        nTran :=0
        nDebe :=0
        nHaber:=0
        LOOP
     ENDIF

     nTran :=nTran +oTable:CUANTOS
     nTTran:=nTtran+oTable:CUANTOS

     nDebe :=nDebe +oTable:DEBE
     nHaber:=nHaber+oTable:HABER

     nTDebe :=nTDebe +oTable:DEBE
     nTHaber:=nTHaber+oTable:HABER

     oTable:Replace("CUANTOS",STR(oTable:CUANTOS,5))
     oTable:Replace("MES",CMES(oTable:MES))
     nSaldo:=nSaldo+oTable:DEBE-oTable:HABER
     oTable:Replace("SALDO",nSaldo)
     oTable:DbSkip()

  ENDDO

  IF !Empty(cAno)
     AADD(oTable:aDataFill,{cAno   ,cAno   ,STR(nTran ,5),nDebe ,nHaber ,nSaldo})
  ENDIF
  AADD(oTable:aDataFill,{"TOTAL","TOTAL",STR(nTTran,5),nTDebe,nThaber,nSaldo})
//oTable:Browse()

  oTable:End()


  IF oMdiCli:lActivated

     Aeval(oMdiCli:oBrw:aCols,{|o,n|o:End() })

     oMdiCli:oBrw:aCols:={}

//   oMdiCli:oBrw:lCreated:=.F.
//   oMdiCli:oBrw:Destroy()
     oMdiCli:oBrw:aArrayData:=ACLONE(oTable:aDataFill)
     oMdiCli:oBrw:nArrayAt  :=MIN(oMdiCli:oBrw:nArrayAt,len(oMdiCli:oBrw:aArrayData))

//   oMdiCli:oCol:=oMdiCli:oBrw:aCols[5]
//   oMdiCli:oCol:nWidth       :=NIL // 100
//   oMdiCli:oCol:nDataStrAlign   := AL_LEFT
//   oMdiCli:oCol:nDataStyle :=NIL
//   OMdiCli:oCol:Adjust()
//   oMdiCli:oBrw:Refresh(.T.)
//   RETURN .T.
  ENDIF

// aData:=ACLONE(oTable:aDataFill)
  oMdiCli:aData:=ACLONE(oTable:aDataFill)

  // ViewArray(oMdiCli:aData)

  oMdiCli:oBrw:SetArray(oMdiCli:aData)

  oMdiCli:oCol:=oMdiCli:oBrw:aCols[2]
  oMdiCli:oCol:cHeader:="Mes"   
  oMdiCli:oCol:nWidth :=75

  oMdiCli:oCol:=oMdiCli:oBrw:aCols[3]
  oMdiCli:oCol:cHeader:="Cant."   
  oMdiCli:oCol:nWidth :=38
  oMdiCli:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCli:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCli:oCol:nFootStrAlign:=AL_RIGHT

  oMdiCli:oCol:=oMdiCli:oBrw:aCols[4]
  oMdiCli:oCol:cHeader      :="Debe"   
  oMdiCli:oCol:nWidth       :=155
  oMdiCli:oCol:bStrData     :={|oBrw|oBrw:=oMdiCli:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oMdiCli:cPicture)}
  oMdiCli:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCli:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCli:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCli:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCli:oBrw,{CLR_HBLUE, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  oMdiCli:oCol:=oMdiCli:oBrw:aCols[5]
  oMdiCli:oCol:cHeader:="Haber"   
  oMdiCli:oCol:nWidth :=155
  oMdiCli:oCol:bStrData     :={|oBrw|oBrw:=oMdiCli:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oMdiCli:cPicture)}
  oMdiCli:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCli:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCli:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCli:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCli:oBrw,{CLR_HRED, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  oMdiCli:oCol:=oMdiCli:oBrw:aCols[6]
  oMdiCli:oCol:cHeader:="Saldo"   
  oMdiCli:oCol:nWidth :=155
  oMdiCli:oCol:bStrData     :={|oBrw|oBrw:=oMdiCli:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oMdiCli:cPicture)}
  oMdiCli:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCli:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCli:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCli:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCli:oBrw,{IIF(oBrw:aArrayData[oBrw:nArrayAt,6]>0,CLR_HBLUE,CLR_HRED), iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  AEVAL(oMdiCli:oBrw:aCols,{|oCol|oCol:oHeaderFont  :=oFontB})

  IF oMdiCli:lActivated

    AEVAL(oMdiCli:oBrw:aCols,{|oCol|oCol:nDataStyle   :=NIL   ,;
                                    oCol:Adjust() })

  ENDIF

  oMdiCli:oBrw:DelCol(1)

  oMdiCli:oBrw:bClrStd := {|oBrw|oBrw:=oMdiCli:oBrw,{0, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }
RETURN .T.

FUNCTION ENTREVISTA()
  LOCAL cTitle
  LOCAL cWhere,oLbx

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEENT}"))+;
                 " ["+oMdiCli:cCodCli+" "+ALLTRIM(oMdiCli:cNombre)+"]"

  cWhere:="ENT_CODIGO"+GetWhere("=",oMdiCli:cCodCli)

  CursorWait()

  IF COUNT("DPCLIENTEENT",cWhere)=0 
     MensajeErr(GetFromVar("{oDp:xDPCLIENTEES}")+" ["+oMdiCli:cCodCli+"] no posee Expedientes")
     RETURN .F.
  ENDIF

  oDp:aCargo:={"",oMdiCli:cCodCli,"P","",""}
  oLbx:=DPLBX("DPCLIENTEENTCON.LBX",cTitle,cWhere)
  oLbx:aCargo:=oDp:aCargo

RETURN .T.


/*
// Facturación Periódica
*/
FUNCTION FACTURAPER()
   LOCAL cTitle
   LOCAL cWhere,oLbx


   IF MYCOUNT("DPCLIENTEPROG","DPG_CODIGO"+GetWhere("=",oMdiCli:cCodCli))=0
      MensajeErr("No hay Registros en "+GetFromVar("{oDp:DPCLIENTEPROG}")+CRLF+;
                 "Vinculados con el "+GetFromVar("{oDp:xDPCLIENTES}")+" "+oMdiCli:cCodCli)
      RETURN .F.
   ENDIF

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
           " ["+oMdiCli:cCodCli+" "+ALLTRIM(oMdiCli:cNombre)+" ]"

   cWhere:="DPG_CODIGO"+GetWhere("=",oMdiCli:cCodCli)

   oDp:aRowSql:={} // Lista de Campos Seleccionados
   oDpLbx:=TDpLbx():New("DPCLIENTEPROGC.LBX",cTitle,cWhere)
   oDpLbx:uValue1:=oMdiCli:cCodCli
   oDpLbx:Activate()

RETURN .T.

/*
// Visualizar Comparativos
*/
FUNCTION COMPARATIVOS()
   LOCAL cScope,cNombre
   LOCAL cTitle  :="Valores Comparativos"

   cScope:="REC_CODSUC "+GetWhere("=",oDp:cSucursal  )+" AND "+;
           "REC_CODIGO "+GetWhere("=",oMdiCli:cCodCli)+" AND "+;
           "REC_ACT=1  "

  EJECUTAR("DPRUNCOMP","DPRECIBOSCLI",oMdiCli:cCodCli,oMdiCli:cNombre,cTitle,"Mensual",cScope, .T. , .T. )

RETURN .T.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPCLIENTES",oMdiCli:cCodCli,NIL,NIL,NIL,NIL,cConsulta)

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oMdiCli)


FUNCTION SETBTNGRPACTION(oMdiCli,cAction)
   LOCAL nGroup:=LEN(oMdiCli:oOut:aGroup)
   LOCAL oBtn  :=ATAIL(oMdiCli:oOut:aGroup[ nGroup, 2 ])

   oBtn:bAction   :=BLOQUECOD(cAction)
   oBtn:bLButtonUp:=oBtn:bAction
   oBtn:CARGO     :=cAction

RETURN oBtn


/*
// Visualizar Comparativos
*/
FUNCTION MOBBCO()
  LOCAL cWhere:="REC_CODIGO"+GetWhere("=",oMdiCli:cCodCli)
  LOCAL cCodSuc,nPeriodo,dDesde,dHasta,cTitle

  EJECUTAR("BRMOBXCLI",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,oMdiCli:cCodCli)

RETURN .T.
// EOF
