// Programa   : DPCLIENTESMNUTRAN
// Fecha/Hora : 12/09/2005 17:22:34
// Propósito  : Consulta Ficha del Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación : Ventas y Cuentas por Cobrar
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
   LOCAL cNombre:="",aTipDoc:={},cSql,cRif:=""
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw
   LOCAL oBtn,nGroup,bAction,nDocCxC:=0,aTipDocSer:={},aTipDocInv:={},nNumMem:=0, nFilMai:=0,cCodRut
   LOCAL aTipCxC :={}
   LOCAL aTipOtr :={}
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL oData,lRun:=.F.
   LOCAL lCuotas   :=.F.,lCuotasPrg
   LOCAL nCuoxFac  :=0
   LOCAL aTipDocAct:=ASQL("SELECT TDC_TIPO,TDC_ACTIVO FROM DPTIPDOCCLI")
 
   DEFAULT lRun:=.T.

   EJECUTAR("DPSERIEFISCALLOAD") // datos de la impresora fiscal

   oData:=DATASET("DPCLIENTESMNUTRAN","ALL")

   //lRun:=oData:Set(oMdiOut:cTable ,lRun  )
   oData:End(.T.)

// lRun:=.T.
   
   DEFAULT cCodCli:=SQLGET("DPDOCCLI","DOC_CODIGO","DOC_CXC=1")

   lCuotasPrg:=COUNT("DPCLIENTEPROG","DPG_CODIGO"+GetWhere("=",cCodCli))>0
   lCuotas   :=.T. // COUNT("DPDOCCLI","DOC_CODIGO"+GetWhere("=",cCodCli)+" AND DOC_TIPDOC"+GetWhere("=","CUO"))>0

   IF lCuotas
      nCuoxFac:=COUNT("DPDOCCLI","DOC_CODIGO"+GetWhere("=",cCodCli)+" AND DOC_TIPDOC"+GetWhere("=","CUO")+" AND DOC_TIPAFE"+GetWhere("=",""))
// ? CLPCOPY(oDp:cSql)
   ENDIF

   DEFAULT cCodCli:=STRZERO(1,10)

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_NUMMEM,CLI_FILMAI,CLI_RIF,CLI_CODRUT","CLI_CODIGO"+GetWhere("=",cCodCli))

   nNumMem :=DPSQLROW(2,0)
   nFilMai :=DPSQLROW(3,0)
   cRif    :=DPSQLROW(4,"")
   cCodRut :=DPSQLROW(5,"")

   cSql:=" SELECT TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC,0 AS CUANTOS,TDC_INVFIS,TDC_INVACT,0 DOC_CXC "+;
         " FROM DPTIPDOCCLI "+;
         " GROUP BY TDC_TIPO,TDC_FILBMP,TDC_DESCRI,TDC_CXC "+;
         " ORDER BY TDC_DESCRI "


   aTipDoc :={}
   aTipCxC :={}
   aTipOtr :={}
   aTipDoc:=ACLONE(aTipCxC)

   AADD(aData,{"Uno","Dos","Ttres"})
   AADD(aData,{"4","5","6"})

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-12 BOLD
   DEFINE FONT oFontBrw NAME "Tamoha" SIZE 0,-10 BOLD

   DpMdi("Menú de Transacciones del "+GetFromVar("{oDp:xDPCLIENTES}"),"oMdiCliT","TEST.EDT")

   oMdiCliT:cCodCli   :=cCodCli
   oMdiCliT:cNombre   :=cNombre
   oMdiCliT:lSalir    :=.F.
   oMdiCliT:nHeightD  :=45
   oMdiCliT:lMsgBar   :=.F.
   oMdiCliT:oGrp      :=NIL
   oMdiCliT:nNumMem   :=nNumMem
   oMdiCliT:nFilMai   :=nFilMai
   oMdiCliT:cRif      :=cRif
   oMdiCliT:oFrm      :=oFrm
   oMdiCliT:cCodRut   :=cCodRut
   oMdiCliT:cCodigo   :=""
   oMdiCliT:lCuotas   :=lCuotas
   oMdiCliT:nCuoxFac  :=nCuoxFac
   oMdiCliT:lCuotasPrg:=lCuotasPrg
   oMdiCliT:lTIP_CTZ  :=.F.
   oMdiCliT:lTIP_NEN  :=.F.
   oMdiCliT:lTIP_PLA  :=.F.

   AEVAL(aTipDocAct,{|a,n| oMdiCliT:SET("lTIP_"+ALLTRIM(a[1]),a[2])})

// ? oMdiCliT:lTIP_CTZ,"oMdiCliT:lTIP_CTZ"

   SetScript("DPCLIENTESMNUTRAN")

   oMdiCliT:Windows(0,0,aCoors[3]-170,415)  


  @ 48, -1 OUTLOOK oMdiCliT:oOut ;
       SIZE 150+250, oMdiCliT:oWnd:nHeight()-95 ;
       PIXEL ;
       FONT oFont ;
       OF oMdiCliT:oWnd;
       COLOR CLR_BLACK,oDp:nGris2

   DEFINE GROUP OF OUTLOOK oMdiCliT:oOut PROMPT "&Transacciones por Formularios"

   IF oMdiCliT:lCuotas .OR. oMdiCliT:lCuotasPrg


     DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
            BITMAP "BITMAPS\PLANTILLAS.BMP" ;
            PROMPT "Generar Cuotas" ;
            ACTION (oMdiCliT:REGAUDITORIA("Generar Cuotas"),;
                    EJECUTAR("BRCSCLIRESCUO",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))

   ENDIF

   IF oMdiCliT:nCuoxFac>0

     DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
            BITMAP "BITMAPS\facturavta.BMP" ;
            PROMPT "Facturar Cuotas "+LSTR(oMdiCliT:nCuoxFac) ;
            ACTION (oMdiCliT:REGAUDITORIA("Facturar Cuotas"),;
                    EJECUTAR("BRCSCUOXFACT",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))


   ENDIF



   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\recibodivisa.BMP" ;
          PROMPT "Recibos de CxC en Divisas " ;
          ACTION (oMdiCliT:REGAUDITORIA("Recibos de CxC en Divisas"),;
                  EJECUTAR("DPRECIBODIV",oMdiCliT:cCodCli))

  DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\crucedocs.BMP" ;
          PROMPT "Cruce de Documentos" ;
          ACTION (oMdiCliT:REGAUDITORIA("Recibos de CxC en Divisas"),;
                  EJECUTAR("DPRECIBODIV",oMdiCliT:cCodCli,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\ANTICIPO.BMP" ;
          PROMPT "Crear Anticipo " ;
          ACTION (oMdiCliT:REGAUDITORIA("Crear Anticipo"),;
                  EJECUTAR("DPRECIBODIV",oMdiCliT:cCodCli,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\notacredito.BMP" ;
          PROMPT "Devoluciones de Venta ";
          ACTION (oMdiCliT:REGAUDITORIA("Devoluciones de Venta"),;
                    EJECUTAR("BRTICKETPOS","DOC_CODIGO"+GetWhere("=",oMdiCliT:cCodCli),NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\RECPAGO.BMP" ;
          PROMPT "Recibos" ;
          ACTION (oMdiCliT:REGAUDITORIA("Recibos"),;
                  EJECUTAR("DPRECIBOSCLIX",.T.,"P",NIL,oMdiCliT:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\otrospagos.BMP" ;
          PROMPT "Otros Ingresos " ;
          ACTION (oMdiCliT:REGAUDITORIA("Otros Ingresos"),;
                  EJECUTAR("DPRECIBODIV",oMdiCliT:cCodCli,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL,NIL,NIL,"OIN"))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\facturavta.BMP" ;
          PROMPT "Facturación" ;
          ACTION (oMdiCliT:REGAUDITORIA("Facturación"),;
                  EJECUTAR("DPFACTURAV","FAV",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))

IF oMdiCliT:lTIP_NEN

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\notaentrega.BMP" ;
          PROMPT "Nota de Entrega" ;
          ACTION (oMdiCliT:REGAUDITORIA("Nota de Entrega"),;
                  EJECUTAR("DPFACTURAV","NEN",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))
ENDIF

IF oMdiCliT:lTIP_CTZ

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\cotiza.BMP" ;
          PROMPT "Cotización" ;
          ACTION (oMdiCliT:REGAUDITORIA("Cotización"),;
                  EJECUTAR("DPFACTURAV","CTZ",NIL,NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))

ENDIF
  
   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\DEVVENTA.BMP" ;
          PROMPT "Crear Débitos/Créditos Según Motivos o Conceptos" ;
          ACTION (oMdiCliT:REGAUDITORIA("Devolución"),;
                  EJECUTAR("BRFAVTOCREDET","CLI_CODIGO"+GetWhere("=",oMdiCliT:cCodCli),NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))


   DEFINE GROUP OF OUTLOOK oMdiCliT:oOut PROMPT "&Transacciones por Plantillas"

   IF oMdiCliT:lTIP_PLA

      DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
             BITMAP "BITMAPS\PLANTILLAS.BMP" ;
             PROMPT "Documentos desde Plantillas" ;
             ACTION (oMdiCliT:REGAUDITORIA("Documentos desde Plantillas"),;
                     oMdiCliT:PLANTILLAS())

   ENDIF

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\facturavta.BMP" ;
          PROMPT "Facturación" ;
          ACTION (oMdiCliT:REGAUDITORIA("Facturación"),;
                  EJECUTAR("BRCREADOCCLIPLA",NIL,NIL,NIL,"FAV",oMdiCliT:cCodCli,NIL,NIL,NIL,.F.))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\notaentrega.BMP" ;
          PROMPT "Notas de Entrega" ;
          ACTION (oMdiCliT:REGAUDITORIA("Notas de Entrega"),;
                  EJECUTAR("BRCREADOCCLIPLA",NIL,NIL,NIL,"NEN",oMdiCliT:cCodCli,NIL,NIL,NIL,.F.))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\cotiza.BMP" ;
          PROMPT "Cotización" ;
          ACTION (oMdiCliT:REGAUDITORIA("Cotización"),;
                  EJECUTAR("BRCREADOCCLIPLA",NIL,NIL,NIL,"CTZ",oMdiCliT:cCodCli,NIL,NIL,NIL,.F.))


   DEFINE GROUP OF OUTLOOK oMdiCliT:oOut PROMPT "&Aplicar Retenciones"

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\RETISLR.bmp" ;
          PROMPT "Retenciones ISLR" ;
          ACTION (oMdiCliT:REGAUDITORIA("Retenciones ISLR"),;
                  EJECUTAR("BRCLISINISLR","DOC_CODIGO"+GetWhere("=",oMdiCliT:cCodCli),NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))

   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\RETIVA.BMP" ;
          PROMPT "Retenciones de IVA" ;
          ACTION (oMdiCliT:REGAUDITORIA("Retenciones de IVA"),;
                  EJECUTAR("BRCLISINRTI","DOC_CODIGO"+GetWhere("=",oMdiCliT:cCodCli),NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))
  
   oMdiCliT:Activate("oMdiCliT:FRMINIT()") //,,"oMdiCliT:oSpl:AdjRight()")

   EJECUTAR("DPSUBMENUCREAREG",oMdiCliT,NIL,"T","DPCLIENTES")

RETURN oMdiCliT


FUNCTION FRMINIT()
   LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

   DEFINE BUTTONBAR oBar SIZE 42,42 OF oMdiCliT:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

   IF oDp:nVersion>6 .OR. ISRELEASE("18.11")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
            ACTION EJECUTAR("OUTLOOKTOBRW",oMdiCliT:oOut,oMdiCliT:cCodCli,oMdiCliT:cNombre,"DPCLIENTES","Consulta"),oMdiCliT:End();
            WHEN oDp:nVersion>=6

 ENDIF


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oMdiCliT:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 1,nCol SAYREF oMdiCliT:oCodCli PROMPT oMdiCliT:cCodCli;
           SIZE 80,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  SayAction(oMdiCliT:oCodCli,{||EJECUTAR("DPCLIENTES",0,oMdiCliT:cCodCli)})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
 
  @ 21,nCol SAY oMdiCliT:cNombre;
            SIZE 300,19 BORDER  PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont


  oBar:Refresh(.T.)

  oMdiCliT:oWnd:bResized:={||oMdiCliT:oWnd:oClient := oMdiCliT:oOut,;
                          oMdiCliT:oWnd:bResized:=NIL}

                       

//  oMdiCliT:oWnd:oClient := oMdiCliT:oOut

RETURN .T.

// 


//   oMdiCliT:oBrw:SetColor(nil,14155775)
/*
   oMdiCliT:oWnd:bResized:={||oMdiCliT:oDlg:Move(0,0,oMdiCliT:oWnd:nWidth(),50,.T.),;
                             oMdiCliT:oGrp:Move(0,0,oMdiCliT:oWnd:nWidth()-15,oMdiCliT:nHeightD,.T.)}
*/

/*
   oMdiCliT:oWnd:bResized:={||oMdiCliT:oSpl:AdjRight(),;
                         oMdiCliT:oDlg:Move(0,oMdiCliT:oOut:nWidth(),;
                         oMdiCliT:oWnd:nWidth()-oMdiCliT:oOut:nWidth()-08,oMdiCliT:nHeightD,.T.),;
                         oMdiCliT:oGrp:Move(0,0,;
                         oMdiCliT:oWnd:nWidth()-oMdiCliT:oOut:nWidth()-08,oMdiCliT:nHeightD,.T.)}
*/

//	   EVal(oMdiCliT:oWnd:bResized)

/*
   oMdiCliT:oBrw:bLDblClick:={|oBrw|oBrw:=oMdiCliT:oBrw,;
                                   EJECUTAR("DPDOCCLIVIEW",;
                                   oMdiCliT:cCodCli,;
                                   oMdiCliT:aData[oBrw:nArrayAt,1],;
                                   oMdiCliT:aData[oBrw:nArrayAt,2],;
                                   oMdiCliT:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}
   oMdiCliT:oBrw:GoBottom()
*/

RETURN .T.

FUNCTION GETDATA(cWhere)
  LOCAL cSql,oTable,aData,nSaldo:=0,oCol,oFontB
  LOCAL cAno:="",nDebe:=0,nTDebe:=0,nHaber:=0,nTHaber:=0,nSaldo:=0,nTTran:=0,nTran:=0

  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0,-10 BOLD

  oMdiCliT:cPicture:="999,999,999,999.99"

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


  IF oMdiCliT:lActivated

     Aeval(oMdiCliT:oBrw:aCols,{|o,n|o:End() })

     oMdiCliT:oBrw:aCols:={}

//   oMdiCliT:oBrw:lCreated:=.F.
//   oMdiCliT:oBrw:Destroy()
     oMdiCliT:oBrw:aArrayData:=ACLONE(oTable:aDataFill)
     oMdiCliT:oBrw:nArrayAt  :=MIN(oMdiCliT:oBrw:nArrayAt,len(oMdiCliT:oBrw:aArrayData))

//   oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[5]
//   oMdiCliT:oCol:nWidth       :=NIL // 100
//   oMdiCliT:oCol:nDataStrAlign   := AL_LEFT
//   oMdiCliT:oCol:nDataStyle :=NIL
//   oMdiCliT:oCol:Adjust()
//   oMdiCliT:oBrw:Refresh(.T.)
//   RETURN .T.
  ENDIF

// aData:=ACLONE(oTable:aDataFill)
  oMdiCliT:aData:=ACLONE(oTable:aDataFill)

  // ViewArray(oMdiCliT:aData)

  oMdiCliT:oBrw:SetArray(oMdiCliT:aData)

  oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[2]
  oMdiCliT:oCol:cHeader:="Mes"   
  oMdiCliT:oCol:nWidth :=75

  oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[3]
  oMdiCliT:oCol:cHeader:="Cant."   
  oMdiCliT:oCol:nWidth :=38
  oMdiCliT:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nFootStrAlign:=AL_RIGHT

  oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[4]
  oMdiCliT:oCol:cHeader      :="Debe"   
  oMdiCliT:oCol:nWidth       :=155
  oMdiCliT:oCol:bStrData     :={|oBrw|oBrw:=oMdiCliT:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oMdiCliT:cPicture)}
  oMdiCliT:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCliT:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCliT:oBrw,{CLR_HBLUE, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[5]
  oMdiCliT:oCol:cHeader:="Haber"   
  oMdiCliT:oCol:nWidth :=155
  oMdiCliT:oCol:bStrData     :={|oBrw|oBrw:=oMdiCliT:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oMdiCliT:cPicture)}
  oMdiCliT:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCliT:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCliT:oBrw,{CLR_HRED, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  oMdiCliT:oCol:=oMdiCliT:oBrw:aCols[6]
  oMdiCliT:oCol:cHeader:="Saldo"   
  oMdiCliT:oCol:nWidth :=155
  oMdiCliT:oCol:bStrData     :={|oBrw|oBrw:=oMdiCliT:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oMdiCliT:cPicture)}
  oMdiCliT:oCol:nHeadStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nDataStrAlign:=AL_RIGHT
  oMdiCliT:oCol:nFootStrAlign:=AL_RIGHT
  oMdiCliT:oCol:bClrStd      := {|oBrw|oBrw:=oMdiCliT:oBrw,{IIF(oBrw:aArrayData[oBrw:nArrayAt,6]>0,CLR_HBLUE,CLR_HRED), iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

  AEVAL(oMdiCliT:oBrw:aCols,{|oCol|oCol:oHeaderFont  :=oFontB})

  IF oMdiCliT:lActivated

    AEVAL(oMdiCliT:oBrw:aCols,{|oCol|oCol:nDataStyle   :=NIL   ,;
                                    oCol:Adjust() })

  ENDIF

  oMdiCliT:oBrw:DelCol(1)

  oMdiCliT:oBrw:bClrStd := {|oBrw|oBrw:=oMdiCliT:oBrw,{0, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }
RETURN .T.

FUNCTION ENTREVISTA()
  LOCAL cTitle
  LOCAL cWhere,oLbx

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEENT}"))+;
                 " ["+oMdiCliT:cCodCli+" "+ALLTRIM(oMdiCliT:cNombre)+"]"

  cWhere:="ENT_CODIGO"+GetWhere("=",oMdiCliT:cCodCli)

  CursorWait()

  IF COUNT("DPCLIENTEENT",cWhere)=0 
     MensajeErr(GetFromVar("{oDp:xDPCLIENTEES}")+" ["+oMdiCliT:cCodCli+"] no posee Expedientes")
     RETURN .F.
  ENDIF

  oDp:aCargo:={"",oMdiCliT:cCodCli,"P","",""}
  oLbx:=DPLBX("DPCLIENTEENTCON.LBX",cTitle,cWhere)
  oLbx:aCargo:=oDp:aCargo

RETURN .T.


/*
// Facturación Periódica
*/
FUNCTION FACTURAPER()
   LOCAL cTitle
   LOCAL cWhere,oLbx


   IF MYCOUNT("DPCLIENTEPROG","DPG_CODIGO"+GetWhere("=",oMdiCliT:cCodCli))=0
      MensajeErr("No hay Registros en "+GetFromVar("{oDp:DPCLIENTEPROG}")+CRLF+;
                 "Vinculados con el "+GetFromVar("{oDp:xDPCLIENTES}")+" "+oMdiCliT:cCodCli)
      RETURN .F.
   ENDIF

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
           " ["+oMdiCliT:cCodCli+" "+ALLTRIM(oMdiCliT:cNombre)+" ]"

   cWhere:="DPG_CODIGO"+GetWhere("=",oMdiCliT:cCodCli)

   oDp:aRowSql:={} // Lista de Campos Seleccionados
   oDpLbx:=TDpLbx():New("DPCLIENTEPROGC.LBX",cTitle,cWhere)
   oDpLbx:uValue1:=oMdiCliT:cCodCli
   oDpLbx:Activate()

RETURN .T.

/*
// Visualizar Comparativos
*/
FUNCTION COMPARATIVOS()
   LOCAL cScope,cNombre
   LOCAL cTitle  :="Valores Comparativos"

   cScope:="REC_CODSUC "+GetWhere("=",oDp:cSucursal  )+" AND "+;
           "REC_CODIGO "+GetWhere("=",oMdiCliT:cCodCli)+" AND "+;
           "REC_ACT=1  "

  EJECUTAR("DPRUNCOMP","DPRECIBOSCLI",oMdiCliT:cCodCli,oMdiCliT:cNombre,cTitle,"Mensual",cScope, .T. , .T. )

RETURN .T.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPCLIENTES",oMdiCliT:cCodCli,NIL,NIL,NIL,NIL,cConsulta)

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oMdiCliT)


FUNCTION SETBTNGRPACTION(oMdiCliT,cAction)
   LOCAL nGroup:=LEN(oMdiCliT:oOut:aGroup)
   LOCAL oBtn  :=ATAIL(oMdiCliT:oOut:aGroup[ nGroup, 2 ])

   oBtn:bAction   :=BLOQUECOD(cAction)
   oBtn:bLButtonUp:=oBtn:bAction
   oBtn:CARGO     :=cAction

RETURN oBtn


/*
// Visualizar Comparativos
*/
FUNCTION MOBBCO()
  LOCAL cWhere:="REC_CODIGO"+GetWhere("=",oMdiCliT:cCodCli)
  LOCAL cCodSuc,nPeriodo,dDesde,dHasta,cTitle

  EJECUTAR("BRMOBXCLI",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,oMdiCliT:cCodCli)

RETURN .T.

/*
// Ejecutar Plantillas
*/

FUNCTION PLANTILLAS()
  LOCAL cSql:=[ SELECT DOC_NUMERO,DOC_TIPAFE,COUNT(*)-1 AS CUANTOS ]+;
              [ FROM DPDOCCLI  ]+;
              [ WHERE  DOC_TIPDOC='PLA' AND DOC_ACT=1 ]+;
              [ GROUP BY DOC_NUMERO ORDER BY DOC_NUMERO]

  LOCAL aData:=ASQL(cSql)

  IF LEN(aData)=1
     EJECUTAR("BRCREADOCCLIPLA",NIL,NIL,NIL,aData[1,2],oMdiCliT:cCodCli,NIL,NIL,NIL,.F.)
  ENDIF

RETURN .T.

// EOF
