// Programa   : DOCCLICONFIRMA
// Fecha/Hora : 07/03/2025 19:56:33
// Propósito  : CONFIRMAR LA FACTURA
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,cCodCli,cLetra,cNomDoc,cImpFis,cSerie,lEditar)
   LOCAL cWhere:="",I,aData:={},lResp:=.F.,aTotal:={},lPreview:=.F.
   LOCAL lSave :=.T.,nDesc:=0,nRecarg:=0,nDocOtros:=0,cOrigen:="V",nIvaReb:=0,cDocOrg:="V",nAct:=0,cPicture:="999,999,999.99"
   LOCAL oBrush,oDlg,oCol,oBrw,cTitle:="Confirmar Factura" 
   LOCAL cDescri:="",nCol:=110
   LOCAL nWidth :=820+50  // Ancho Calculado seg£n Columnas 
   LOCAL nHeight:=180+20 // Alto
   LOCAL oFontB :=NIL
   LOCAL oBar,oRep,bBlq,cKey,cCodRep
   LOCAL cNumFis:=SPACE(10),cNum8,oGet8, oEstado,oNumFis
  
   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAV",;
           cNumero:=SQLGETMAX("DPDOCCLI"  ,"DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)),;
           cLetra :=SQLGET("DPDOCCLI"     ,"DOC_SERFIS","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND DOC_NUMERO"+GetWhere("=",cNumero)),;
           cImpFis:=SQLGET("DPSERIEFISCAL","SFI_IMPFIS","SFI_LETRA" +GetWhere("=",cLetra )),;
           cSerie :=SQLGET("DPSERIEFISCAL","SFI_MODELO","SFI_LETRA" +GetWhere("=",cLetra )),;
           lEditar:=SQLGET("DPSERIEFISCAL","SFI_EDITAB","SFI_LETRA" +GetWhere("=",cLetra )),;
           cNomDoc:=SQLGET("DPTIPDOCCLI"  ,"TDC_DESCRI","TDC_TIPO"  +GetWhere("=",cTipDoc))

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D"    )

   // Obtiene los valores impositivos

   EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodCli,cNumero,lSave,nDesc,nRecarg,nDocOtros,cOrigen,nIvaReb,cDocOrg,nAct)

   aData:={}

   FOR I=1 TO LEN(oDp:aArrayIva)

     AADD(aData,{oDp:aArrayIva[I,1],;
                 oDp:aArrayIva[I,2],;
                 ROUND(oDp:aArrayIva[I,6],2),;
                 oDp:aArrayIva[I,4],;
                 oDp:aArrayIva[I,7],;
                 oDp:aArrayIva[I,3],;
                 oDp:aArrayIva[I,5],0,oDp:aArrayIva[I,9]})
  NEXT I

  AEVAL(aData,{|a,n| aData[n,8]:=a[4]+a[7]})

  aTotal :=ATOTALES(aData)

  cNumFis:=EJECUTAR("DPDOCCLIGETNUMFIS",cCodSuc,cLetra,cTipDoc,cNumero)

  // cNum8  :=RIGHT(cNumFis,8)
  cDescri:="Confirmar : "+ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))

  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12  BOLD

  DEFINE DIALOG oDlg TITLE cDescri FROM 1,30 TO nHeight,nWidth PIXEL 

// STYLE nOr(WS_POPUP,WS_VISIBLE) BRUSH oBrush

  oDlg:lHelpIcon:=.F.

  oBrw:=TXBrowse():New( oDlg )
  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:nHeaderLines        := 2
  oBrw:SetArray( aData , .F. )
  oBrw:oFont:=oFontB
  oBrw:lFooter     := .T.

  // Renglon Tipo
  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "IVA"
  oCol:nWidth    :=35
 
  // Renglon Descripcion
  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Descripción"
  oCol:nWidth    :=110

  // Renglon % Var
  oCol:=oBrw:aCols[3]
  oCol:cHeader      := "%Var."
  oCol:nWidth       := 40
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"999.99")}
  oCol:nFootStrAlign:= AL_RIGHT
 
  // Renglon Base Bruta
  oCol:=oBrw:aCols[4]
  oCol:cHeader      := "Monto"+CRLF+"Bruto"
  oCol:nWidth       := nCol
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],cPicture)}
  oCol:cFooter      := TRAN(oDp:nBruto,cPicture)
  oCol:nFootStrAlign:= AL_RIGHT

  // Renglon Base Imponible
  oCol:=oBrw:aCols[5]
  oCol:cHeader      := "Base"+CRLF+"Imponible"
  oCol:nWidth       := nCol
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:cFooter      := TRAN(oDp:nBaseNet,cPicture)
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],cPicture)}
  oCol:nFootStrAlign:= AL_RIGHT

  // Renglon % IVA
  oCol:=oBrw:aCols[6]
  oCol:cHeader      := "%"+CRLF+"IVA"
  oCol:nWidth       := 40
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"999.99")}
  oCol:nFootStrAlign:= AL_RIGHT

  // Renglon Monto IVA
  oCol:=oBrw:aCols[7]
  oCol:cHeader      := "Monto"+CRLF+"I.V.A."
  oCol:nWidth       := nCol
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],cPicture)}
  oCol:cFooter      := TRAN(oDp:nIva,cPicture)
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrw:aCols[8]
  oCol:cHeader      := "Monto"+CRLF+"Neto"
  oCol:nWidth       := nCol
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],cPicture)}
  oCol:cFooter      := TRAN(aTotal[8],cPicture)
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrw:aCols[9]
  oCol:cHeader      := "Otros"+CRLF+"Impuestos"
  oCol:nWidth       := nCol
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,9],cPicture)}
  oCol:cFooter      := TRAN(aTotal[9],cPicture)
  oCol:nFootStrAlign:= AL_RIGHT

  oBrw:nRecSelColor := oDp:nLbxClrHeaderPane // 9302500

  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrStd   := {|| {0,IIF(oBrw:nArrayAt%2=0,oDp:nClrPane1,oDp:nClrPane2	)}}

  oBrw:CreateFromCode()

  ACTIVATE DIALOG oDlg CENTERED;
           ON INIT (DLGBAR(),oBrw:Move(oBar:nHeight()-2,0,oDlg:nWidth()-10,oDlg:nHeight()-oBar:nHeight()-11,.T.))

  IF lPreview
     
      cCodRep:="DOCCLI"+cTipDoc
      cDescri:=ALLTRIM(SQLGET("DPREPORTES","REP_DESCRI","REP_CODIGO"+GetWhere("=",cCodRep)))

      oDp:cDocNumIni:=cNumero
      oDp:cDocNumFin:=cNumero

      oRep:=REPORTE(cCodRep,cWhere,NIL,NIL,"PREVISUALIZAR [ "+cDescri+" ] "+cTipDoc+": "+cNumero+" "+ALLTRIM(cNomDoc))
      oRep:SetRango(1,cNumero,cNumero)

      oDp:oGenRep:aCargo:=cTipDoc
      oDp:oGenRep:lOnlyPreview:=.T. // SOLO PREVIEW

      // bBlq:=[SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,"]+cWhere+[")] 25/02/2025

      cKey:=cCodSuc+","+cTipDoc+","+cNumero+","+cTipTra

      bBlq:=[IMPRIMIRDOCCLI("]+cWhere+[","]+cKey+[","PREV")] // previsualización

      oDp:oGenRep:bPostRun:=BLOQUECOD(bBlq) 

      RETURN .F.

  ENDIF
        
RETURN lResp

/*
// Coloca la Barra de Botones
*/
FUNCTION DLGBAR()
   LOCAL oCursor,oBtn,oFontB,oFont,nCol:=20

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12  BOLD
   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -14  BOLD

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 65+1,65+5 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Aceptar"; 
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION (lResp:=VALIDARFISCAL(),IF(lResp,oDlg:End(),NIL))

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Preview"; 
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (lPreview:=.T.,lResp:=.F.,oDlg:End())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Regresar"; 
          FILENAME "BITMAPS\XCANCEL.BMP";
          ACTION (lResp:=.F.,oDlg:End())

  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth(), o:SetColor(0,oDp:nGris)})
  oBar:SetColor(0,oDp:nGris)

  @ 02,nCol SAY " Serie " OF oBar ;
            BORDER  PIXEL RIGHT;
            COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 62,20

  @ 23,nCol SAY " Medio " OF oBar ;
            BORDER  PIXEL RIGHT;
            COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 62,20
 
  @ 44,nCol SAY " Número " OF oBar ;
            BORDER  PIXEL RIGHT;
            COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 62,20

  @ 02,nCol+63 SAY " "+cSerie OF oBar;
               BORDER  PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20

  @ 23,nCol+63 SAY " "+cLetra+"-"+cImpFis;
               BORDER  PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20

  @ 44,nCol+63 SAY oNumFis VAR " "+cNumFis+" " OF oBar ;
               PIXEL ;
               BORDER;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 110,20

  @ 44,nCol+175 SAY oEstado VAR " "+oDp:cDocFisEstado+" " OF oBar ;
               PIXEL ;
               BORDER;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 087,20

RETURN .T.

/*
// Buscamos en el talonario digital, si el formato esta disponible
// Si es forma libre, no necesita validar el tipo de documento
// tampoco puede dejar espacios vacios
*/
FUNCTION VALIDARFISCAL()

  cNumFis:=EJECUTAR("DPDOCCLIGETNUMFIS",cCodSuc,cLetra,cTipDoc,cNumero)
  oEstado:Refresh(.T.)
  oNumFis:Refresh(.T.)

  SQLUPDATE("dpdocclinum",{"DCN_TIPDOC","DCN_NUMDOC","DCN_ESTADO"},{cTipDoc,cNumero,"U"},oDp:cWhereDocCliNum)

RETURN .T.
// EOF
