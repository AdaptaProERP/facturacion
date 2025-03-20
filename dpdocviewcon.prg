// Programa   : DPDOCVIEWCON
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Asiento Contables   
// Creado Por : Juan Navas
// Llamado por: DPDOCCONTAB
// Aplicación : Ventas
// Tabla      : DPASIENTOS

#INCLUDE "DPXBASE.CH"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cTipTra,lVenta,lView,cOrg,cTipo,dFecha,cNumCbt)
  LOCAL cTableTip:="DPTIPDOCCLI",oData,cSql,oTable,aData
  LOCAL cDpDocCli:="DPDOCCLI",cTabla:="DPCLIENTES"
  LOCAL nSaldo   :=0,nDebe:=0,nHaber:=0,cActual,cWhere,cDescri
  LOCAL oBrw,oCol,oFont,oFontG,oFontB,oSayRef,cTitle,cTextAdd:=""
  LOCAL cFchDec:=IIF(oDp:lConFchDec .AND. !lVenta,"DOC_FCHDEC","DOC_FECHA")
 	 
  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="FAV"        ,;
          cCodigo:=STRZERO(1,10),;
          cNumero:=STRZERO(1,10),;
          cTipTra:="D",;
          lVenta :=.T.,;
          lView  :=.T.

// 20/3/2055 inncesario aqui  EJECUTAR("DPCBTEFIX2")

// ? cCodSuc,cTipDoc,cCodigo,cNumero,cTipTra,lVenta,lView,cOrg,cTipo,dFecha,cNumCbte,"cCodSuc,cTipDoc,cCodigo,cNumero,cTipTra,lVenta,lView,cOrg,cTipo,dFecha,cNumCbte"

  // Necesito la Fecha del Documento
  IF cOrg=NIL
    cOrg     :=IIF(lVenta,"VTA"     ,"COM"     )
  ENDIF

  cDpDocCli:=IIF(lVenta,"DPDOCCLI","DPDOCPRO")

  oDp:cNumCbt:=""

  // Verificar nombre de cliente o proveedor
  cTabla   :=IIF(lVenta,"DPCLIENTES","DPPROVEEDOR")


  IF cTipTra="I"

    dFecha:=SQLGET("DPDOCMOV","DOC_FECHA,DOC_NUMCBT",;
                              "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                              "DOC_CODSUC"+GetWhere("=",cCodSuc))

    DEFAULT cOrg:="INV"

  ELSE

      // 28/10/2022, contabilizar por fecha declaracion
      IF !lVenta
        cFchDec:="DOC_FCHDEC"
      ENDIF

      DEFAULT dFecha:=SQLGET(cDpDocCli,cFchDec+",DOC_CBTNUM",;
                           "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                           "DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                           "DOC_TIPTRA"+GetWhere("=",cTipTra))


/*
    dFecha:=SQLGET(cDpDocCli,"DOC_FECHA,DOC_CBTNUM",;
                             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                             "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                             "DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                             "DOC_TIPTRA"+GetWhere("=",cTipTra))
*/



  ENDIF

  IF cTipTra="P"

    // Produccion

    DEFAULT cOrg:="PRD"

    dFecha:=SQLGET("DPEJECUCIONPROD","EOP_FECHA,EOP_CBTNUM",;
                                     "EOP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                     "EOP_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                     "EOP_TIPO"  +GetWhere("=",cTipo  ))


  ENDIF


  IF !Empty(oDp:aRow)

    DEFAULT cNumCbt:=oDp:aRow[2]

  ENDIF


  cWhere:="MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
          "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
          "MOC_TIPO  "+GetWhere("=",cTipDoc)+" AND "+;
          "MOC_DOCUME"+GetWhere("=",cNumero)+" AND "+;
          IIF( Empty(cCodigo) ,"" , "MOC_CODAUX"+GetWhere("=",cCodigo)+" AND ")+;
          "MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "MOC_TIPTRA"+GetWhere("=",cTipTra)+" AND "+;
          "MOC_ORIGEN"+GetWhere("=",cOrg)

// ? cCodigo,"codigo del proveedor"
/*
 cWhere:="MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
          "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
          "MOC_TIPO  "+GetWhere("=",cTipDoc)+" AND "+;
          "MOC_DOCUME"+GetWhere("=",cNumero)+" AND "+;
          "MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "MOC_TIPTRA"+GetWhere("=",cTipTra)+" AND "+;
          "MOC_ORIGEN"+GetWhere("=",cOrg)
*/
  cSql:="SELECT MOC_CODAUX,MOC_ACTUAL "+;
        " FROM DPASIENTOS "+;
        "WHERE "+cWhere+" LIMIT 1"
  
  oTable :=OpenTable(cSql,.T.)

// ? CLPCOPY(oDp:cSql)

  cCodigo:=oTable:MOC_CODAUX
  cActual:=oTable:MOC_ACTUAL

  oTable:End()
  IF !lView
     RETURN cActual
  ENDIF

  cSql:=" SELECT MOC_CUENTA,CTA_DESCRI,MOC_DESCRI,MOC_MONTO AS DEBE,0 AS HABER,0 AS SALDO,MOC_ACTUAL,"+;
        " MOC_TIPASI,MOC_TIPTRA,MOC_TIPO "+;
        " FROM DPASIENTOS "+;
        " INNER JOIN DPCTA ON MOC_CUENTA=CTA_CODIGO "+;
        " WHERE "+cWhere

  oTable:=OpenTable(cSql,.T.)

// ? CLPCOPY(oDp:cSql)

  nHaber:=0

  cWhere:="CBT_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "CBT_NUMERO"+GetWhere("=",cNumCbt)+" AND "+;
          "CBT_FECHA "+GetWhere("=",dFecha )+" AND "+;
          "CBT_ACTUAL"+GetWhere("=",cActual)

  cDescri:=SQLGET("DPCBTE","CBT_COMEN1",cWhere)

  oDp:cNumCbt:=cNumCbt
/*
  cActual:=oTable:MOC_ACTUAL

  IF !lView
     oTable:End()
     RETURN cActual
  ENDIF
*/

  WHILE !oTable:Eof()

    nSaldo:=nSaldo+oTable:DEBE
    nSaldo:=VAL(STR(nSaldo))

    IF oTable:DEBE<0
      
       oTable:Replace("HABER",oTable:DEBE*-1)
       oTable:Replace("DEBE" ,0)
       nHaber:=nHaber+oTable:HABER
    ELSE
       oTable:Replace("HABER",0)
    ENDIF

    nDebe :=nDebe +oTable:DEBE  
  
    oTable:Replace("SALDO",nSaldo)
    oTable:DbSkip()

  ENDDO

  aData:=oTable:aDataFill
  oTable:End()

  IF EMPTY(aData)
     cTextAdd:=IF(lVenta,"",CRLF+"Contabilizar por Campo: "+cFchDec)
     MsgMemo("Documento no Posee Asientos Contables "+cTextAdd)
     RETURN .F.
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  DPEDIT():New("Asientos Contables del Documento ["+cTipDoc+" "+cNumero+"]","DPDOCVIEWCON.EDT","oDocViewCon",.T.)

  cTitle:="Asientos Contables del Documento ["+cTipDoc+" "+cNumero+"]"
  DpMdi(cTitle,"oDocViewCon","DPDOCVIEWCON.EDT")
  oDocViewCon:Windows(0,0,MIN(400,oDp:aCoors[3]-160),MIN(1140,oDp:aCoors[4]-10),.T.) // Maximizado

  oDocViewCon:cCodSuc   :=cCodSuc
  oDocViewCon:cTipDoc   :=cTipDoc
  oDocViewCon:cNumero   :=cNumero
  oDocViewCon:cNumCbt   :=cNumCbt
  oDocViewCon:dFecha    :=dFecha 
  oDocViewCon:cPictureM :="999,999,999,999.99"
  oDocViewCon:CLI_CODIGO:=cCodigo
  oDocViewCon:cCodigo   :=cCodigo
  oDocViewCon:aData     :=ACLONE(aData)
  oDocViewCon:cActual   :=cActual	
  oDocViewCon:cOrg      :=cOrg
  oDocViewCon:cTipTra   :=cTipTra
  oDocViewCon:lVenta    :=lVenta
  oDocViewCon:cDescri   :=cDescri
  oDocViewCon:cNombre   :=SQLGET(cTabla,;
                          IIF(lVenta,"CLI_NOMBRE","PRO_NOMBRE"),;
                          IIF(lVenta,"CLI_CODIGO","PRO_CODIGO")+GetWhere("=",oDocViewCon:cCodigo))

  oDocViewCon:nClrPane1:=oDp:nClrPane1
  oDocViewCon:nClrPane2:=oDp:nClrPane2
  oDocViewCon:lBarDef  :=.T.
  oDocViewCon:lMsgBar  :=.F.

/*

  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Documento ";
           FONT oFontG

  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Cuenta Contable ";
           FONT oFontG

  @ 1,1 SAY "Comprobante" RIGHT
  @ 5,1 SAY "Fecha"       RIGHT
  @ 2,1 SAY "Documento"   RIGHT
  @ 3,1 SAY "Número"      RIGHT
  @ 4,1 SAY "Código"      RIGHT

  @ 1,1 SAYREF oSayRef PROMPT oDocViewCon:cNumCbt;
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  oSayRef:bAction:={||oDocViewCon:COBCBTE()}

  @ 1,1 SAYREF oSayRef PROMPT oDocViewCon:cCodigo;
        RIGHT;
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  IF lVenta
    oSayRef:bAction:={||EJECUTAR("DPCLIENTESCON",oDocViewCon,oDocViewCon:cCodigo)}
  ELSE
    oSayRef:bAction:={||EJECUTAR("DPPROVEEDORCON",oDocViewCon,oDocViewCon:cCodigo)}
  ENDIF

  IF cTipTra="I"
    oSayRef:bAction:={||EJECUTAR("DPINVCON",oDocViewCon,oDocViewCon:cCodigo)}
  ENDIF

  oDocViewCon:oCodAux:=oSayRef

  @ 01,1 SAY oDocViewCon:dFecha

  @ 04,1 SAY oDocViewCon:oNombre VAR oDocViewCon:cNombre
  @ 02,1 SAY oDocViewCon:cNumero

  @ 03,1 SAY oDocViewCon:cTipDoc+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDocViewCon:cTipDoc))

  @ 1,1 SAYREF oDocViewCon:oSayCta PROMPT oDocViewCon:aData[1,6];
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  oDocViewCon:oSayCta:bAction:={||EJECUTAR("DPCTACON",oDocViewCon:aData[oDocViewCon:oBrw:nArrayAt,1])}
*/

  oBrw:=TXBrowse():New( oDocViewCon:oDlg )

  // oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .T.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:aCols[1]:cHeader:="Código"+CRLF+"Cuenta"
  oBrw:aCols[1]:nWidth :=120

  oBrw:aCols[2]:cHeader:="Descripción"+CRLF+"de la Cuenta"
  oBrw:aCols[2]:nWidth :=220

  oBrw:aCols[3]:cHeader:="Descripción"+CRLF+"del Asiento"
  oBrw:aCols[3]:nWidth :=300

  oBrw:aCols[4]:cHeader:="Debe"
  oBrw:aCols[4]:nWidth :=120
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[4]:cFooter       := TRAN(nDebe,oDocViewCon:cPictureM)
  oBrw:aCols[4]:bStrData      := {  |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,4]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oDocViewCon :cPictureM))}
  oBrw:aCols[4]:bClrStd       :={|oBrw,nClrText|oBrw:=oDocViewCon:oBrw,;
                                  nClrText:=CLR_HBLUE,;
                                 {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1, oDocViewCon:nClrPane2 ) } }


  oBrw:aCols[5]:cHeader:="Haber"
  oBrw:aCols[5]:nWidth :=120
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:cFooter       := TRAN(nHaber,oDocViewCon:cPictureM)
  oBrw:aCols[5]:bStrData      := {  |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,5]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oDocViewCon :cPictureM))}

  oBrw:aCols[5]:bStrData      := {  |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,5]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oDocViewCon :cPictureM))}


  oBrw:aCols[5]:bClrStd       :={|oBrw,nClrText|oBrw:=oDocViewCon:oBrw,;
                                  nClrText:=CLR_HRED,;
                                 {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1, oDocViewCon:nClrPane2 ) } }

  oBrw:aCols[6]:cHeader:="Saldo"
  oBrw:aCols[6]:nWidth :=120
  oBrw:aCols[6]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[6]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[6]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[6]:cFooter       := TRAN(nSaldo,oDocViewCon:cPictureM)
  oBrw:aCols[6]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oDocViewCon:cPictureM)}

  oBrw:aCols[7]:cHeader:="Act"
  oBrw:aCols[7]:nWidth :=30

  oBrw:aCols[8]:cHeader:="Tipo"+CRLF+"Asiento"
  oBrw:aCols[8]:nWidth :=40

  oBrw:aCols[9]:cHeader:="Tipo"+CRLF+"Trans."
  oBrw:aCols[9]:nWidth :=40

  oBrw:aCols[10]:cHeader:="Tipo"+CRLF+"Doc."
  oBrw:aCols[10]:nWidth :=40

//  oBrw:DelCol(6)


  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,nMto,nClrText|oBrw:=oDocViewCon:oBrw,nMonto:=oBrw:aArrayData[oBrw:nArrayAt,3],;
                               nClrText:=0,;
                              {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1, oDocViewCon:nClrPane2 ) } }

  oBrw:bLDblClick:={||oDocViewCon:VERCUENTA()}

/*
  oBrw:bChange:={||oDocViewCon:oSayCta:SetText(oDocViewCon:aData[oDocViewCon:oBrw:nArrayAt,6]),;
                   oDocViewCon:oCodAux:SetText(oDocViewCon:aData[oDocViewCon:oBrw:nArrayAt,8+1])}
*/
  oBrw:SetFont(oFont)

  oBrw:CreateFromCode()
    oDocViewCon:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDocViewCon)}
    oDocViewCon:BRWRESTOREPAR()

  oDocViewCon:oBrw:=oBrw

  oDocViewCon:oWnd:oClient := oDocViewCon:oBrw

  oDocViewCon:Activate({||oDocViewCon:LeyBar(oDocViewCon)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN cActual

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oDocViewCon)
   LOCAL oCursor,oBar,oBtn,oFont,oFontG,oCol,nDif,oSayRef
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDocViewCon:oDlg
   LOCAL nAdd:=10
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15+25,180 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   oDocViewCon:oFontBtn   :=oFont       // MDI:GOTFOCUS()
   oDocViewCon:nClrPaneBar:=oDp:nGris   // MDI:GOTFOCUS()
   oDocViewCon:oBrw:oLbx  :=oDocViewCon // MDI:GOTFOCUS()


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbteactualizado.BMP";
          TOP PROMPT "Cbte.";   
          ACTION oDocViewCon:COBCBTE()

   oBtn:cToolTip:="Visualizar Comprobante Contable"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XEDIT.BMP",NIL,"BITMAPS\XEDITG.BMP";
          TOP PROMPT "Editar";   
          WHEN ISTABMOD("DPCBTE");
          ACTION oDocViewCon:EDITCBTE()

   oBtn:cToolTip:="Editar Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BUG.BMP";
          TOP PROMPT "Resolver";   
          ACTION oDocViewCon:SETINTEGRACION()

   oBtn:cToolTip:="Asignar Integración Contable en Cuentas Indefinidas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir";   
          ACTION oDocViewCon:oRep:=REPORTE("ASIENTODIF"),;
                 oDocViewCon:oRep:SetRango(1,oDocViewCon:cNumCbt,oDocViewCon:cNumCbt),;
                 oDocViewCon:oRep:SetRango(2,oDocViewCon:dFecha,oDocViewCon:dFecha),;
                 oDocViewCon:oRep:SetCriterio(5,oDp:cSucursal)

   oBtn:cToolTip:="Imprimir Recibo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar"; 
          ACTION EJECUTAR("BRWSETFILTER",oDocViewCon:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          TOP PROMPT "Excel"; 
          ACTION (EJECUTAR("BRWTOEXCEL",oDocViewCon:oBrw,oDocViewCon:cTitle,oDocViewCon:cNombre+;
                  " Comprobante:"+oDocViewCon:cNumCbt+" del "+DTOC(oDocViewCon:dFecha)))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION (EJECUTAR("BRWTOHTML",oDocViewCon:oBrw))

   oBtn:cToolTip:="Generar Archivo html"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION (oDocViewCon:oBrw:GoTop(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Siguiente"; 
          ACTION (oDocViewCon:oBrw:PageDown(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Anterior"; 
          ACTION (oDocViewCon:oBrw:PageUp(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Ultimo"; 
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDocViewCon:oBrw:GoBottom(),oDocViewCon:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION oDocViewCon:Close()

  oDocViewCon:oBrw:SetColor(0,oDocViewCon:nClrPane1)


//  @ 0.1,60 SAY oDocViewCon:cTrabajad OF oBar BORDER SIZE 345,18

 
  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDocViewCon:SETBTNBAR(40+20,40+15,oBar)

  @ 3+nAdd,10 SAY "Comprobante " RIGHT OF oBar BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 4+nAdd,10 SAY "Fecha "       RIGHT OF oBar BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 5+nAdd,10 SAY "Documento "   RIGHT OF oBar BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 6+nAdd,10 SAY "Número "      RIGHT OF oBar BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 7+nAdd,10 SAY "Código "      RIGHT OF oBar BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 4+nAdd,21 SAYREF oSayRef PROMPT oDocViewCon:cNumCbt;
              SIZE 42,12;
              FONT oFontB;
              COLORS CLR_HBLUE,oDp:nGris OF oBar

  oSayRef:bAction:={||oDocViewCon:COBCBTE()}

  @ 5+nAdd,21 SAYREF oSayRef PROMPT oDocViewCon:cCodigo;
              RIGHT;
              SIZE 42,12;
              FONT oFontB;
              COLORS CLR_HBLUE,oDp:nGris OF oBar

  IF oDocViewCon:lVenta
    oSayRef:bAction:={||EJECUTAR("DPCLIENTESCON",oDocViewCon,oDocViewCon:cCodigo)}
  ELSE
    oSayRef:bAction:={||EJECUTAR("DPPROVEEDORCON",oDocViewCon,oDocViewCon:cCodigo)}
  ENDIF

  IF oDocViewCon:cTipTra="I"
    oSayRef:bAction:={||EJECUTAR("DPINVCON",oDocViewCon,oDocViewCon:cCodigo)}
  ENDIF

  oDocViewCon:oCodAux:=oSayRef

  @ 03+nAdd,15 SAY oDocViewCon:dFecha OF oBar COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG BORDER

  @ 04+nAdd,15 SAY oDocViewCon:oNombre VAR oDocViewCon:cNombre OF oBar COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG BORDER
  @ 05+nAdd,15 SAY oDocViewCon:cNumero OF oBar COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG BORDER

  @ 03+nAdd,15 SAY oDocViewCon:cTipDoc+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDocViewCon:cTipDoc)) OF oBar;
          COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG BORDER

  @ 02+nAdd,15 SAYREF oDocViewCon:oSayCta PROMPT oDocViewCon:aData[1,6];
          SIZE 42,12;
          FONT oFontB;
          COLORS CLR_HBLUE,oDp:nGris OF oBar

  @ 04+nAdd,15 SAY oDocViewCon:cDescri;
          OF oBar COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG BORDER

 // oBar:SetSize(0,160,.t.)

RETURN .T.

FUNCTION RECIMPRIME(oDocViewCon)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oDocViewCon:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  ? "AQUI DEBE IMPRIMIR EL COMPROBANTE"

  RETURN .T.

  aVar:={oDp:cTipoNom  ,;
         oDp:cOtraNom  ,;
         oDp:cCodTraIni,;
         oDp:cCodTraFin,;
         oDp:cCodGru   ,;
         oDp:dDesde    ,;
         oDp:dHasta    ,;
         oDp:cRecIni   ,;
         oDp:cRecFin    }

  oDP:cTipoNom  :=""
  oDp:cOtraNom  :=""
  oDp:cCodTraIni:=""
  oDp:cCodTraFin:=""
  oDp:cCodGru   :=""
  oDp:dDesde    :=CTOD("")
  oDp:dHasta    :=CTOD("")
  oDp:cRecIni   :=cNumRec
  oDp:cRecFin   :=cNumRec

  REPORTE("RECIBOS")

  oDp:cTipoNom  :=aVar[1]
  oDp:cOtraNom  :=aVar[2]
  oDp:cCodTraIni:=aVar[3]
  oDp:cCodTraFin:=aVar[4]
  oDp:cCodGru   :=aVar[5]
  oDp:dDesde    :=aVar[6]
  oDp:dHasta    :=aVar[7]
  oDp:cRecIni   :=aVar[8]
  oDp:cRecFin   :=aVar[9]

RETURN .T.

FUNCTION COBCBTE()

  EJECUTAR("DPCBTE",oDocViewCon:cActual,oDocViewCon:cNumCbt,oDocViewCon:dFecha,.T.)

RETURN .T.

FUNCTION VERCUENTA()
   LOCAL aLine:=oDocViewCon:oBrw:aArrayData[oDocViewCon:oBrw:nArrayAt]
   LOCAL cCodCta:=aLine[1]
RETURN EJECUTAR("DPCTACON",NIL,cCodCta)

/*
// Asignar Codigos de Integración
*/
FUNCTION SETINTEGRACION()
  LOCAL cWhere:="MOC_ORIGEN"+GetWhere("=",IF(oDocViewCon:lVenta,"VTA","COM"))
RETURN EJECUTAR("BRASIENTOSTIP",cWhere,NIL,10)
//   RETURN EJECUTAR("BRASIENTOSINDEF",NIL,NIL,10)
//RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oDocViewCon)

FUNCTION EDITCBTE()
  LOCAL cWhere,cCodSuc:=oDocViewCon:cCodSuc,nPeriodo:=NIL,dDesde:=NIL,dHasta:=NIL,cTitle:=NIL,
  LOCAL cCbtNum:=oDocViewCon:cNumCbt,dCbtFch:=oDocViewCon:dFecha,cActual:=oDocViewCon:cActual

EJECUTAR("BRCBTFIJOEDIT",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCbtNum,dCbtFch,cActual)

// EOF
