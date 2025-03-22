// Programa   : DPDOCCLIMNU
// Fecha/Hora : 07/06/2005 15:43:33
// Propósito  : Menú Finalización Documentos de Clientes
// Creado Por : Juan Navas
// Llamado por: DPDOCCLI
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cNumero,cCodigo,cNomDoc,cTipDoc,oForm,cAction,cDocOrg)
   LOCAL oBtn,oFontB,nAlto:=24-4,nAncho:=120,aBtn:={},I,nLin:=0,nHeight,nOption:=0,lContab:=.F.
   LOCAL cEstado:="A",cCodVen:=STRZERO(1,6), cActual :="N",lFortxt:=.F.
   LOCAL nInvCon:=1,cTipExp:="",cWhere:="1=0"
   LOCAL lDocPrg:=.F.,lGenPro:=.F.,cNombre,bAction,nGroup,cNumCbt,oTable
   LOCAL lPagEle:=.F.
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL lMoneta:=.T.,lCargaP,cCargaP
   LOCAL lAproba:=.F. // Requiere Aprobación para Exportar
   LOCAL lCrossD:=.F.
   LOCAL lIVA   :=.F.
   LOCAL lImpTot:=.F.
   LOCAL cTipCxC:=""
   LOCAL lPagos :=.F.
   LOCAL cFileBmp:=""
  
   DEFAULT cCodSuc:=oDp:cSucursal,;
           cNumero:=STRZERO(1,10),;
           cCodigo:=STRZERO(1,10),;
           cTipDoc:="FAV",;
           cNomDoc:=SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)),;
           cAction:="",;
           cDocOrg:="V"

// ? cCodSuc,cNumero,cCodigo,cNomDoc,cTipDoc,oForm,cAction,"cCodSuc,cNumero,cCodigo,cNomDoc,cTipDoc,oForm,cAction"

   SysRefresh(.T.)

   IF ValType(oForm)="O"

     nInvCon:=oForm:nPar_InvCon // Inventario Afectado Contable
     cCodVen:=oForm:DOC_CODVEN
     cNumCbt:=oForm:DOC_CBTNUM
     nOption:=oForm:nOption
     lContab:=oForm:lPar_ConAut
     lFortxt:=oForm:lPar_ForTxt
     lDocPrg:=oForm:lPar_DocPrg

     DEFAULT oForm:lPagEle:=.F.

     lPagEle:=oForm:lPagEle

     cEstado:=LEFT(ALLTRIM(oForm:oEstado:GetText()),1)
     cWhere:=oForm:cWhere

     /*
     // Ejecuta Scanner segun definicion en Tipo de Documento de Cliente
     */

     IF oForm:nOption=1 .OR. oForm:nOption=3
       EJECUTAR("DPDOCCLIDIG",cCodSuc,cTipDoc,cCodigo,cNumero,.T.)
     ENDIF

     SysRefresh(.T.)

   ELSE

/*
     oTable:=OpenTable("SELECT * FROM DPDOCCLI WHERE DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                    "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                                    "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;                 
                                                    "DOC_TIPTRA"+GetWhere("=","D"    ),.T.)

     cNumCbt:=oTable:DOC_CBTNUM
     oTable:End()
*/

     cNumCbt:=SQLGET("DPDOCCLI","DOC_CBTNUM","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;                 
                                             "DOC_TIPTRA"+GetWhere("=","D"    ))

// inncesario, es lento al finalizar la factura
//     cActual:=EJECUTAR("DPDOCVIEWCON",oForm:DOC_CODSUC,oForm:DOC_TIPDOC,oForm:DOC_CODIGO,oForm:DOC_NUMERO,"D",.T.,.F.)

   ENDIF

   // 20/03/2025
   IF !Empty(cNumCbt)
     cActual:=SQLGET("DPCBTE","CBT_ACTUAL","CBT_CODSUC"+GetWhere("=",cCodSuc)+" AND CBT_FECHA"+GetWhere("=",dFecha)+" AND DOC_NUMERO"+GetWhere("=",cNumCbt))
//     ? cActual,oDp:cSql
   ENDIF

   IF cEstado="A"
     AADD(aBtn,{"Totalizar"  ,"MATH.BMP"       ,"TOTAL" })
   ENDIF

   AADD(aBtn,{"Consultar"    ,"VIEW.BMP"       ,"VIEW" })

   IF ValType(oForm)="O" .AND. oDoc:lPar_Pagos .AND. LEFT(cEstado,1)="A" .AND. oForm:nPar_CXC=0
     AADD(aBtn,{"Recibir Anticipo"  ,"RECPAGO.BMP"       ,"ANTICIPO" })
   ENDIF

   IF ValType(oForm)="O" .AND. oDoc:lPar_Pagos .AND. cEstado="A" .AND. oForm:nPar_CXC<>0
     AADD(aBtn,{"Recibo de Ingreso"  ,"RECPAGO.BMP"       ,"RECIBO" })
   ENDIF

//   IF ValType(oForm)="O" .AND. cTipdoc="NEN" .AND. cEstado="A"
//     AADD(aBtn,{"# Control Forma Fiscal"  ,"btnformafiscal.BMP"       ,"FISCAL" })
//   ENDIF

   IF ValType(oForm)="O" .AND. oForm:lPar_LibVta .AND. cEstado="A"
     AADD(aBtn,{"# Control de la Forma Fiscal"  ,"btnformafiscal.BMP"       ,"FISCAL" })
   ENDIF

   // Revisar si está actualizado, para no mostrar boton de contabilizar.
/*
   IF !oForm=NIL
     cActual:=EJECUTAR("DPDOCVIEWCON",oForm:DOC_CODSUC,oForm:DOC_TIPDOC,oForm:DOC_CODIGO,oForm:DOC_NUMERO,"D",.T.,.F.)
   ELSE
     cActual:="N"
   ENDIF
*/
   IF ValType(oForm)="O" .AND. oDoc:lPar_Contab .AND. nInvCon<>0 .AND. cEstado<>"N" .AND. cActual <> "S" .AND. oDp:cIdApl<>"1"
     AADD(aBtn,{"Contabilizar "+IF(!Empty(cNumCbt),"("+cNumCbt+")",""),"CONTABILIZAR.BMP"       ,"CONTAB" })
   ENDIF


/*
   // 26-01-2009 Marlon Ramos  
      //01-09-2008 Marlon Ramos IF cTipDoc="DEV" .AND. "EPSON TMU220AF"$UPPE(oDp:cImpFiscal)
      IF cTipDoc="DEV" .AND. ASCAN(oDp:aImprFiscEps,{|c,n| IIF( ValType(c)="C", (oDp:cImpFiscal $ c) , .F.) }) > 0
         //EJECUTAR("VALDDEVFIS",cNumero,cTipDoc)
         EJECUTAR("TICKETEPSONDEV",cNumero,cTipDoc)
      ENDIF
   // Fin 26-01-2009 Marlon Ramos 
*/


   cTipExp:=SQLGET("DPTIPDOCCLI","TDC_DOCDES,TDC_DESCRI,TDC_GENPRO,TDC_MONETA,TDC_CARGAP,TDC_REQAPR,TDC_CROSSD,TDC_IVA,TDC_IMPTOT,TDC_CXC,TDC_PAGOS","TDC_TIPO"+GetWhere("=",cTipDoc))

   cCargaP:=ALLTRIM(DPSQLROW(2,""))
   lGenPro:=DPSQLROW(3,lGenPro)
   lMoneta:=DPSQLROW(4,.T.    )
   lCargaP:=DPSQLROW(5,.T.    )
   lAproba:=DPSQLROW(6,.F.    )
   lCrossD:=DPSQLROW(7,.F.    ) // Cross-Docking
   lIVA   :=DPSQLROW(8,.F.    ) // Cross-Docking
   lImpTot:=DPSQLROW(9,.F.    ) // Expotar Total
   cTipCxC:=DPSQLROW(10,"N"   ) // Tipo de CxC
   lPagos :=DPSQLROW(11,.F.   ) // Pagos

// ? cTipCxC,"cTipo",lPagos
// ? cTipExp,"cTipExp",lMoneta,"lMoneta",lImpTot,"lImpTot",CLPCOPY(oDp:cSql)

   IF !Empty(cTipExp) .AND. cTipExp<>cTipDoc

      // .AND. lMoneta

      lGenPro:=oDp:aRow[3]

      SQLGET("DPTIPDOCCLI","TDC_DOCDES,TDC_DESCRI,TDC_FILBMP","TDC_TIPO"+GetWhere("=",cTipExp))
      cFileBmp:=cFileNoPath(ALLTRIM(oDp:aRow[3]))
      cFileBmp:=IF(Empty(cFileBmp),"exportdocum.bmp",cFileBmp)


      IF (cTipDoc="TIK" .AND. cTipExp="DEV") .OR. (cTipDoc="FAV" .AND. cTipExp="CRE")

        AADD(aBtn,{ALLTRIM(oDp:aRow[2])+IF(lImpTot," [Total] "," [Parcial] ") ,cFileBmp    ,"EXPORTAR" })

      ELSE

        AADD(aBtn,{"Exportar "+IF(lImpTot,"Total","Parcial")+" -> "+ALLTRIM(oDp:aRow[2]) ,"exportdocum.bmp"      ,"EXPORTAR" })

      ENDIF

   ENDIF

   IF lMoneta

     AADD(aBtn,{"Otros Datos"    ,"XEDIT.BMP"       ,"OTROS" })

     // Exportar hacia otra empresa
     AADD(aBtn,{"Exportar Documento"    ,"EXPORTS.BMP"       ,"EXPORTARDOC" })


     IF cTipDoc="NEN" .OR. (lPagos .AND. cTipCxC="N")
	       AADD(aBtn,{"Transferir hacia Cuentas por Cobrar","CXC.BMP"      ,"TOCXC" })
     ENDIF

   ENDIF

   IF cTipDoc="FAV"
     AADD(aBtn,{"Crear Débitos/Créditos Según Motivos o Conceptos","DEVVENTA.BMP","XMOTIVOS" })
   ENDIF

   AADD(aBtn,{"Imprimir"          ,"XPRINT.BMP"        ,"PRINT"  })
   AADD(aBtn,{"Imprimir en Texto" ,"IMPRESORATXT.BMP"  ,"IMPFOR" })

   IF oDp:nVersion>=5
      AADD(aBtn,{"Digitalización" ,"ADJUNTAR.BMP"     ,"DIGITALIZAR" })
   ENDIF
 
   IF oDp:nVersion>=5 .AND. lGenPro .AND. "93"$oDp:cIdApl
      AADD(aBtn,{oDp:xDPCENCOS ,"Proyectos.bmp"      ,"CENCOS" })
   ENDIF

   IF cTipDoc="SIN" .OR. .T.
     AADD(aBtn,{"Imprimir Etiquetas" ,"barcode.bmp"     ,"IMPBARCODE" })
   ENDIF

   IF lAproba .AND. oDp:nVersion>=6.0
     AADD(aBtn,{"Probación" ,"APROBAR.bmp"     ,"APROBAR" })
   ENDIF

   IF lCargaP .AND. oDp:nVersion>=6.0
     AADD(aBtn,{"Guia de Carga con Pesaje","pesaje.bmp"     ,"PESAJE" })
   ENDIF

   IF lCrossD
     AADD(aBtn,{"Crear Cross-Docking","crossdockingcli.bmp"     ,"CROSSDOCKING" })
   ENDIF

   IF "93"$oDp:cIdApl
     AADD(aBtn,{"Expediente"      ,"XEXPEDIENTE.BMP","EXP"   })
   ENDIF

//   IF "93"$oDp:cIdApl
//     AADD(aBtn,{"Aprobación de PedidoExpediente"      ,"XEXPEDIENTE.BMP","EXP"   })
//   ENDIF


   IF lDocPrg .AND. (ISTABINC("DPCLIENTEPROG") .OR. ISTABMOD("DPCLIENTEPROG"))
      AADD(aBtn,{oDp:xDPCLIENTEPROG,"FACTURAPER.BMP" ,"FACPROG" })
   ENDIF

   // Tareas Internas, Requiere PlugIn
   // AADD(aBtn,{"Etiquetas","BARCODE.bmp"     ,"ETQ" })


   AADD(aBtn,{"Tareas","TAREASS.BMP" ,"TARINT" })

   AADD(aBtn,{"Salir"      ,"XSALIR.BMP"     ,"EXIT"  })

   cNombre:=ALLTRIM(SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodigo)))

   // ? oDp:cSql
   // IF !lMoneta
   IF cTipDoc="PLA"
      cNombre:=""
   ENDIF

   DEFINE FONT oFontB  NAME "Tahoma" SIZE 0, -12 BOLD

//cNomDoc:="TITULO"
  
   cNomDoc:=STRTRAN(cNomDoc,cCargaP,"")

   IF Empty(cNomDoc)
      cNomDoc:=cCargaP+" "+cNumero
   ENDIF


   DpMdi(cCargaP,"oDpCliMnu","TEST.EDT")

   oDpCliMnu:cCodigo   :=cCodigo
   oDpCliMnu:cNombre   :=cNombre
   oDpCliMnu:lSalir    :=.F.
   oDpCliMnu:nHeightD  :=45
   oDpCliMnu:lMsgBar   :=.F.
   oDpCliMnu:oGrp      :=NIL
   oDpCliMnu:cCodSuc   :=cCodSuc
   oDpCliMnu:cTipDoc   :=cTipDoc
   oDpCliMnu:cNumero   :=cNumero
   oDpCliMnu:cCodVen   :=cCodVen
   oDpCliMnu:oForm     :=oForm
   oDpCliMnu:cNomDoc   :=cNomDoc
   oDpCliMnu:nOption   :=nOption
   oDpCliMnu:lMsgBar   :=.F.
   oDpCliMnu:aBtn      :=ACLONE(aBtn)
   oDpCliMnu:nCrlPane  :=15990760 // 16772810
   oDpCliMnu:lContab   :=lContab
   oDpCliMnu:cNomDoc   :=cNomDoc
   oDpCliMnu:cTipExp   :=cTipExp
   oDpCliMnu:cWhere    :=cWhere
   oDpCliMnu:lPagEle   :=lPagEle
   oDpCliMnu:lCargaP   :=lCargaP
   oDpCliMnu:cRef      :=oDpCliMnu:cTipDoc+"-"+oDpCliMnu:cNumero
   oDpCliMnu:lBarDef   :=.T.
   oDpCliMnu:lAproba   :=lAproba
   oDpCliMnu:lMonetaExp:=lMoneta // Monetario Documento Exportacion
   oDpCliMnu:lImpTot   :=lImpTot
   oDpCliMnu:cTipCxC   :=cTipCxC
   oDpCliMnu:lPagos    :=lPagos
   oDpCliMnu:cDocOrg   :=cDocOrg


   oDpCliMnu:Windows(0,0,aCoors[3]-150-00,415)  

/*
  @ 48, -1 OUTLOOK oDpCliMnu:oOut ;
     SIZE 150+250, oDpCliMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFontB ;
     OF oDpCliMnu:oWnd;
     COLOR CLR_BLACK,oDpCliMnu:nCrlPane 
*/

  @ 48, -1 OUTLOOK oDpCliMnu:oOut ;
     SIZE 150+250, oDpCliMnu:oWnd:nHeight()-85 ;
     PIXEL ;
     FONT oFontB ;
     OF oDpCliMnu:oWnd;
     COLOR CLR_BLACK,oDp:nGris


   DEFINE GROUP OF OUTLOOK oDpCliMnu:oOut PROMPT "&Opciones"

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oDpCliMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oDpCliMnu:oOut:aGroup)
      oBtn:=ATAIL(oDpCliMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oDpCliMnu:DOCCLIRUN(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oDpCliMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I



/*
   DEFINE GROUP OF OUTLOOK oDpCliMnu:oOut PROMPT "&Opciones"

   aBtn:={}
*/

/*
   @ 0, 100 SPLITTER oDpCliMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oDpCliMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oDpCliMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oDpCliMnu:oDlg FROM 0,oDpCliMnu:oOut:nWidth() TO oDpCliMnu:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oDpCliMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oDpCliMnu:oGrp TO 10,10 PROMPT "#"+oDpCliMnu:cTipDoc+"-"+oDpCliMnu:cNumero FONT oFontB

   @ .5,.5 SAY oDpCliMnu:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB OF oDpCliMnu:oDlg

   ACTIVATE DIALOG oDpCliMnu:oDlg NOWAIT VALID .F.
*/

/*
   DEFINE DIALOG oDpCliMnu:oDlg FROM 0,oDpCliMnu:oOut:nWidth() TO oDpCliMnu:nHeightD,700;
          TITLE cNombre STYLE WS_CHILD OF oDpCliMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oDpCliMnu:oGrp TO 10,10 PROMPT "Número ["+oDpCliMnu:cNumero+"]"

   @ .5,.5 SAY "oDpCliMnu:cNombre" SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oDpCliMnu:oDlg NOWAIT VALID .F.

*/

   oDpCliMnu:oWnd:oClient := oDpCliMnu:oOut

   oDpCliMnu:Activate("oDpCliMnu:FRMINIT()",,"oDpCliMnu:oSpl:AdjRight()")
 
   IF lGenPro
     EJECUTAR("DPDOCCLIASGPRO",oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cCodigo,oDpCliMnu:cNumero)
   ENDIF

   IF !Empty(cAction)
       oDpCliMnu:DOCCLIRUN(cAction)
   ENDIF

//? oDpCliMnu:oWnd

RETURN .T.

FUNCTION FRMINIT()

   LOCAL oCursor,oBar,oBtn,oFont,nCol:=21

   DEFINE BUTTONBAR oBar SIZE 42,42+28 OF oDpCliMnu:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

/*
   IF oDp:nVersion>=6.0 

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
            ACTION EJECUTAR("OUTLOOKTOBRW",oDpCliMnu:oOut,oDpCliMnu:cCodigo,oDpCliMnu:cNombre,"DPDOCCLI","Menú"),oDpCliMnu:End();
            WHEN oDp:nVersion>=6

 ENDIF
*/

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDpCliMnu:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  oDpCliMnu:SETBTNBAR(45,45,oBar)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 2,nCol SAY oDpCliMnu:oNomDoc PROMPT " "+oDpCliMnu:cNomDoc;
           SIZE 338,21 PIXEL COLOR CLR_BLACK,65535 OF oBar FONT oFontB BORDER

  @ 1+24,nCol SAYREF oDpCliMnu:oCodigo PROMPT oDpCliMnu:cCodigo;
           SIZE 120,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  SayAction(oDpCliMnu:oCodigo,{||EJECUTAR("DPCLIENTES",0,oDpCliMnu:cCodigo)})

  @ 1+24,nCol+180 SAYREF oDpCliMnu:oRef PROMPT oDpCliMnu:cRef;
              SIZE 120,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont


  SayAction(oDpCliMnu:oRef,{||EJECUTAR("DPFACTURAV",oDpCliMnu:cTipDoc,oDpCliMnu:cNumero,NIL,NIL,NIL,NIL,NIL,NIL,oDpCliMnu:cDocOrg)})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
 
  @ 21+24,nCol SAY oDpCliMnu:cNombre;
            SIZE 300,19 BORDER  PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  oBar:Refresh(.T.)

  oDpCliMnu:oWnd:bResized:={||oDpCliMnu:oWnd:oClient := oDpCliMnu:oOut,;
                          oDpCliMnu:oWnd:bResized:=NIL}

RETURN .T.
/*
FUNCTION FRMINITX()

   oDpCliMnu:oWnd:bResized:={||oDpCliMnu:oDlg:Move(0,0,oDpCliMnu:oWnd:nWidth(),50,.T.),;
                               oDpCliMnu:oGrp:Move(0,0,oDpCliMnu:oWnd:nWidth()-15,oDpCliMnu:nHeightD,.T.)}

   EVal(oDpCliMnu:oWnd:bResized)


RETURN .T.
*/

// Iniciación
FUNCTION DOCPROMNUINI()

  oBtn:=oDpCliMnu:oDlg:aControls[1]
  oDpCliMnu:oWnd:Move(0,0)
  DPFOCUS(oBtn)
  SysRefresh(.T.)

RETURN .T.

// Ejecutar
FUNCTION DOCCLIRUN(cAction)
  LOCAL oForm:=oDpCliMnu:oForm,lEdit:=.T.,cSerie,cWhere,lImpTotal
  LOCAL oCliRec,cTipExp,bBlq,nNumMain:=0,cTitle:="",cNumDoc
  LOCAL cCodSuc,nPeriodo:=11,dDesde:=CTOD(""),dHasta:=CTOD(""),cTitle:=""
  LOCAL lPesaje:=.F.

  IF cAction="PRINT"
    cSerie  :=MYSQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF","TDC_TIPO"+GetWhere("=",oDpCliMnu:cTipDoc))

    // 10-10-2008 Marlon Ramos (Agregar la Samsung) IF ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie)
    // 27-01-2009 Marlon Ramos (Agregar la Aclas y Okidata)   IF ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie) .OR. "SAMSUNG"$UPPER(cSerie)
    //IF ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie) .OR. "SAMSUNG"$UPPER(cSerie) .OR. "ACLAS"$UPPER(cSerie) .OR. "OKIDATA"$UPPER(cSerie)
    IF ALLTRIM(UPPER(cSerie))="BMC" .OR. "EPSON"=LEFT(UPPER(cSerie),5) .OR. "BEMATECH"=ALLTRIM(UPPER(cSerie)) .OR. "SAMSUNG"$UPPER(cSerie) .OR. "ACLAS"$UPPER(cSerie) .OR. "OKIDATA"$UPPER(cSerie) .OR. "STAR"$UPPER(cSerie)
      cAction:="FISCAL"
    ENDIF
  ENDIF

  IF cAction="FISCAL"
    RETURN EJECUTAR("DPDOCNUMFIS",oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cCodigo,oDpCliMnu:cNumero,.T.)
  ENDIF

 IF cAction="PESAJE"
    oDpCliMnu:PACKING()
    RETURN .T.
  ENDIF

  IF cAction="IMPBARCODE"

     EJECUTAR('DPDOCPROETQ',oDpCliMnu:cCodSuc,;
                            oDpCliMnu:cTipDoc,;
                            oDpCliMnu:cCodigo,;
                            oDpCliMnu:cNumero,;
                            oDpCliMnu:cNomDoc , "D" ,NIL,.T. )


//    EJECUTAR("ZEBRA",oDpCliMnu:cTipDoc,oDpCliMnu:cCodigo,oDpCliMnu:cNumero,.T.)
  ENDIF

  IF cAction="EXPORTAR"

   cTipExp:=SQLGET("DPTIPDOCCLI","TDC_DOCDES,TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDpCliMnu:cTipDoc))

   IF !Empty(cTipExp)

      CursorWait()

      // lImpTotal:=SQLGET("DPTIPDOCCLI","TDC_IMPTOT","TDC_TIPO"+GetWhere("=",cTipExp))

      IF oDpCliMnu:lImpTot

        EJECUTAR("DPDOCCLIEXPMNU",oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cNumero,cTipExp)

      ELSE

        cWhere:="MOV_CODSUC"+GetWhere("=",oDpCliMnu:cCodSuc)+" AND "+;
                "MOV_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc)+" AND "+;
                "MOV_CODCTA"+GetWhere("=",oDpCliMnu:cCodigo)+" AND "+;
                "MOV_DOCUME"+GetWhere("=",oDpCliMnu:cNumero)+" AND "+;
                "MOV_INVACT"+GetWhere("=",1)

        lPesaje:=SQLGET("DPMOVINV","SUM(MOV_PESO)",cWhere)>0

        IF lPesaje

           EJECUTAR("BRAVINOTENTDET",cWhere,oDpCliMnu:cCodSuc,NIL,NIL,NIL,NIL,oDpCliMnu:cNumero,oDpCliMnu:cTipDoc,cTipExp,NIL,NIL)

        ELSE
  
           cWhere:=NIL

           EJECUTAR("BRCREADOCCLIPLA",cWhere,oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,cTipExp,oDpCliMnu:cCodigo,oDpCliMnu:cNumero,cNumDoc)

        ENDIF


      ENDIF

   ELSE

      MensajeErr("Tipo de Documento ["+oDpCliMnu:cTipDoc+"]"+" Requiere Documento Destino")

   ENDIF

   RETURN

  ENDIF

  IF cAction="EXIT"
    oDpCliMnu:Close()
    IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
      DpFocus(oForm:oDlg)
    ENDIF

    RETURN .T.
  ENDIF

  IF cAction="PAGAR"

    RETURN EJECUTAR("DPDOCCLIPAG",oDpCliMnu:cCodSuc,;
                                  oDpCliMnu:cTipDoc,;
                                  oDpCliMnu:cCodigo,;
                                  oDpCliMnu:cNumero,;
                                  oDpCliMnu:cNomDoc)

  ENDIF

  IF cAction="RECIBO" .OR. cAction="ANTICIPO"

    oCliRec:=EJECUTAR("DPDOCCLIPAG2",oDpCliMnu:cCodSuc,;
                                     oDpCliMnu:cTipDoc,;
                                     oDpCliMnu:cCodigo,;
                                     oDpCliMnu:cNumero,;
                                     oDpCliMnu:cNomDoc,;
                                     oDpCliMnu:cCodVen,;
                                     (cAction="ANTICIPO"),;
                                     oDpCliMnu:lPagEle)
    oCliRec:=oDp:oCliRec


// ? oCliRec:ClassName()

    IF ValType(oCliRec)="O"
       oCliRec:oFrmDoc:=oDpCliMnu:oForm
       oCliRec:REC_TIPORG:=oDpCliMnu:cTipDoc
       oCliRec:REC_NUMORG:=oDpCliMnu:cNumero
// ? oCliRec:REC_TIPORG,oCliRec:REC_NUMORG

    ENDIF

    RETURN 
  ENDIF

  IF cAction="TOTAL"
    lEdit:=IIF( ValType(oForm)="O" .AND. oDpCliMnu:nOption=0 , .F. , lEdit)

    EJECUTAR("DOCTOTAL", IIF( ValType(oForm)="O" .AND. oDpCliMnu:nOption=3 , oForm ,  {oDpCliMnu:cTipDoc,;
                             oDpCliMnu:cCodSuc,;
                             oDpCliMnu:cNumero,;
                             oDpCliMnu:cCodigo,;
                             oDpCliMnu:cNomDoc} ) , .T. , NIL , NIL , .T. , lEdit )

    // Verifica que la factura Anterior es la Misma
    IF (ValType(oDpCliMnu:oForm)="O" .AND. oDpCliMnu:oForm:oWnd:hWnd>0 .AND. ;
        oDpCliMnu:oForm:nOption<>1 .AND.;
        oDpCliMnu:cNumero=oDpCliMnu:oForm:DOC_NUMERO)

      oDpCliMnu:oForm:DOC_NETO:=oDp:nNeto
      oDpCliMnu:oForm:DOC_DCTO:=oDp:nDesc  
      oDpCliMnu:oForm:oNeto:Refresh(.T.)
      oDpCliMnu:oForm:oDOC_DCTO:Refresh(.T.)
    ENDIF

    // Debe Re-Contabilizar
    IF oDpCliMnu:lContab .AND. oDpCliMnu:nOption<>0
      MsgRun("Contabilizando Documento "+oDpCliMnu:cNumero ,"Por favor Espere",{||;
                EJECUTAR("DPDOCCONTAB", NIL,oDpCliMnu:cCodSuc,;
                                            oDpCliMnu:cTipDoc,;
                                            oDpCliMnu:cCodigo,;
                                            oDpCliMnu:cNumero,.T.,.F.) })

    ENDIF
    RETURN .T.
  ENDIF

  IF cAction="PRINT"

    cSerie  :=MYSQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF","TDC_TIPO"+GetWhere("=",oDpCliMnu:cTipDoc))
    cWhere:="DOC_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc)
    oDp:cDocNumIni:=oDpCliMnu:cNumero
    oDp:cDocNumFin:=oDpCliMnu:cNumero
    REPORTE("DOCCLI"+oDpCliMnu:cTipDoc,cWhere)

    oDp:oGenRep:aCargo:=oDpCliMnu:cTipDoc

    bBlq:=[SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,"]+oDpCliMnu:cWhere+[")]

    oDp:oGenRep:bPostRun:=BLOQUECOD(bBlq) 

  ENDIF

  IF cAction="IMPFOR"

    cWhere:="DOC_CODSUC"+GetWhere("=",oDpCliMnu:cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",oDpCliMnu:cNumero)+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","D")
              
    EJECUTAR("FMTRUN","DPDOCCLI","DPDOCCLI"+oDpCliMnu:cTipDoc,oDpCliMnu:cNomDoc,cWhere)

  ENDIF

  IF cAction="DIGITALIZAR"
     EJECUTAR("DPDOCCLIDIG",oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cCodigo,oDpCliMnu:cNumero)
  ENDIF

  /*
  // Asignación de Proyecto
  */
  IF cAction="CENCOS"
     EJECUTAR("DPDOCCLIASGPRO",oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cCodigo,oDpCliMnu:cNumero)
  ENDIF

  IF cAction="APROBAR"

    cWhere:="DOC_CODSUC"+GetWhere("=",oDpCliMnu:cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",oDpCliMnu:cNumero)

    RETURN EJECUTAR("BRAVIPEDAPROB",cWhere,oDp:cSucursal,11,CTOD(""),CTOD(""),cTitle,.T.)

  ENDIF

  IF cAction="EXP"

    RETURN EJECUTAR("DPDOCCLIEXP",NIL,oDpCliMnu:cCodSuc,;
                                      oDpCliMnu:cTipDoc,;
                                      oDpCliMnu:cCodigo,;
                                      oDpCliMnu:cNumero,;
                                      oDpCliMnu:cNomDoc)

  ENDIF

  IF cAction="OTROS"

    RETURN EJECUTAR("DPDOCCLIOTR",{oDpCliMnu:cTipDoc,;
                                   oDpCliMnu:cCodSuc,;
                                   oDpCliMnu:cNumero,;
                                   oDpCliMnu:cCodigo,;
                                   oDpCliMnu:cNomDoc},.T.,)
  ENDIF


  IF cAction="CROSSDOCKING"

    RETURN EJECUTAR("BRCROSSDCLI",NIL,oDpCliMnu:cCodSuc,;
                                      oDpCliMnu:cTipDoc,;
                                      oDpCliMnu:cNumero)

  ENDIF

  IF cAction="CONTAB"
    // Verifica si está el comprobante actualizado... 
    // IF !EJECUTAR("DPDOCCLIISDEL",oForm)
    //   RETURN .F.
    // ENDIF

    EJECUTAR("DPDOCCONTAB", NIL,oDpCliMnu:cCodSuc,;
                                oDpCliMnu:cTipDoc,;
                                oDpCliMnu:cCodigo,;
                                oDpCliMnu:cNumero,.T.,.T.)
  ENDIF

/*
  IF cAction="EXPORTARDOC"
     ? "EXPORTARDOC"
     RETURN .T.
  ENDIF
*/
  IF cAction="FACPROG" 

    EJECUTAR("DPDOCPROG", oDpCliMnu:cCodSuc,;
                          oDpCliMnu:cTipDoc,;
                          oDpCliMnu:cCodigo,;
                          oDpCliMnu:cNumero)


  ENDIF

  IF cAction="VIEW" 

    EJECUTAR("DPDOCCLIFAVCON",NIL,oDpCliMnu:cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cNumero,oDpCliMnu:cCodigo)

  ENDIF

  IF cAction="TOCXC"

    cWhere:="DOC_CODSUC"+GetWhere("=",oDpCliMnu:cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",oDpCliMnu:cNumero)

    EJECUTAR("BRNENTOCXC",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,oDpCliMnu:cTipDoc,oDpCliMnu:cNumero)

  ENDIF

  IF cAction="TARINT"
     EJECUTAR("DPDOCCLI_TARINT",cCodSuc,oDpCliMnu:cTipDoc,oDpCliMnu:cNumero)
  ENDIF

  IF cAction="XMOTIVO"
     EJECUTAR("BRFAVTOCREDET","CLI_CODIGO"+GetWhere("=",oDpCliMnu:cCodigo)+" AND DOC_NUMERO"+GetWhere("=",oDpCliMnu:cNumero),NIL,NIL,NIL,NIL,NIL,oDpCliMnu:cCodigo)
  ENDIF


RETURN .T.

FUNCTION MNUCERRAR()
  LOCAL oForm:=oDpCliMnu:oForm

  oDpCliMnu:Close()

  IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
    DpFocus(oForm:oDlg)
  ENDIF

RETURN .T.

/*
// Si es un Pedido, Genera la Nota de Entrega
// Si es nota de entrega, edita la edicion
*/
FUNCTION PACKING(cTipDes,cNumEnt)
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=NIL,dDesde:=NIL,dHasta:=NIL,cTitle
  LOCAL cTipDoc:=oDpCliMnu:cTipDoc
  LOCAL cNumero:=oDpCliMnu:cNumero
  LOCAL nOption:=1
  LOCAL cCodigo:=SPACE(20) // Código del Producto
  LOCAL lFisico:=SQLGET("DPTIPDOCCLI","TDC_INVFIS","TDC_TIPO"+GetWhere("=",oDpCliMnu:cTipDoc))
  LOCAL cNumEnt:=""

//? lFisico,"lFisico"

  IF oDpCliMnu:cTipDoc="NEN"

/*
    cWhere:="MOV_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
            "MOV_TIPDOC"+GetWhere("=",cTipDoc )+" AND "+;
            "MOV_DOCUME"+GetWhere("=",cNumero )

    cNumEnt:=oDpCliMnu:cNumero

    EJECUTAR("BRAVIPEDCARGA",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDoc,cNumero,cNumEnt,nOption,cCodigo,cTipDes,oDpCliMnu:cCodigo)
*/

    cNumEnt:=oDpCliMnu:cNumero

    EJECUTAR("NENEDITPESAJE",oDpCliMnu:cTipDoc,oDpCliMnu:cNumero)


  ELSE

    /*
    // Pedido puede tener Varias Notas de Entrega
    */

    cWhere:="MOV_CODSUC"+GetWhere("=",oDpCliMnu:cCodSuc )+" AND "+;
            "MOV_TIPDOC"+GetWhere("=",oDpCliMnu:cTipDoc )+" AND "+;
            "MOV_DOCUME"+GetWhere("=",oDpCliMnu:cNumero )

    RETURN EJECUTAR("BRAVIPEDNENDET",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,oDpCliMnu:cTipDoc,oDpCliMnu:cNumero)

  ENDIF


/*
  cWhere:="MOV_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
          "MOV_TIPDOC"+GetWhere("=",cTipDoc )+" AND "+;
          "MOV_DOCUME"+GetWhere("=",cNumero )

 
  cNumEnt:=oDpCliMnu:cNumero

  EJECUTAR("BRAVIPEDCARGA",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDoc,cNumero,cNumEnt,nOption,cCodigo,cTipDes,oDpCliMnu:cCodigo)
*/

RETURN .T.

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oDpCliMnu)

/*
   DEFINE BITMAP OF OUTLOOK oMdiCliT:oOut ;
          BITMAP "BITMAPS\DEVVENTA.BMP" ;
          PROMPT "Crear Débitos/Créditos Según Motivos o Conceptos" ;
          ACTION (oMdiCliT:REGAUDITORIA("Devolución"),;
                  EJECUTAR("BRFAVTOCREDET","CLI_CODIGO"+GetWhere("=",oMdiCliT:cCodCli),NIL,NIL,NIL,NIL,NIL,oMdiCliT:cCodCli))
*/

// EOF
