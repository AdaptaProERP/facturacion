// Programa   : DPDOCCLIEXPMNU
// Fecha/Hora : 15/09/2010 00:36:09
// Propósito  : Generar Nuevo Documento de Ventas
// Creado Por : Juan Navas
// Llamado por: DPDOCCLIMNU
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cNumero,cTipExp,lPagEle,lDocGen,lRunDoc,dFecha,lDirecto)
   LOCAL cNumSug:="",cCodCli,cNumExp:="",cWhere,lMenu,lAuto,cNomDoc
   LOCAL cWhere,lLibVta:=.F.,oRep,oDoc,lAutoImp,lAutoExp,cImpFiscal,cLetra
   LOCAL cNomDoc,cNumDes:=""

   DEFAULT cCodSuc :=oDp:cSucursal,;
           cTipDoc :="NEN"        ,;
           cNumero :=STRZERO(1,10),;
           cTipExp :="FAV"        ,;
           lPagEle :=.F.          ,;
           lRunDoc :=.T.          ,;
           dFecha  :=oDp:dFecha   ,;
           lDirecto:=.F.

   lAuto     :=SQLGET("DPTIPDOCCLI","TDC_AUTIMP,TDC_DESCRI,TDC_LIBVTA,TDC_IMPTOT,TDC_SERIEF,SFI_IMPFIS,SFI_LETRA"," LEFT JOIN DPSERIEFISCAL ON TDC_SERIEF=SFI_MODELO WHERE TDC_TIPO"+GetWhere("=",cTipDoc))
   lLibVta   :=DPSQLROW(3,.F.)
   lAuto     :=CTOO(lAuto,"L")
   lAutoExp  :=DPSQLROW(4,.T.)
   lAutoExp  :=CTOO(lAutoExp,"L")

   // Documento Destino
   cLetra    :=SQLGET("DPTIPDOCCLI","SFI_LETRA,TDC_SERIEF,SFI_IMPFIS"," LEFT JOIN DPSERIEFISCAL ON TDC_SERIEF=SFI_MODELO WHERE TDC_TIPO"+GetWhere("=",cTipExp))
   cSerie    :=DPSQLROW(2,oDp:cImpFiscal)
   cImpFiscal:=DPSQLROW(3,oDp:cImpFiscal)
// cLetra  :=DPSQLROW(7,"") // 8/8/2024
// ? cLetra,oDp:cSql,cSerie,cImpFiscal,cTipExp 
//   ? lAutoExp,lDirecto,"lAutoExp,lDirecto"
//   IF ValType(lDirecto)="L"
//      lAutoExp:=lDirecto
//   ENDIF

   oDp:cNumExp:=""

//  ? cSerie,"cSerie",cImpFiscal,"cImpFiscal"

   cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
            "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","D")

   cCodCli:=SQLGET("DPDOCCLI","DOC_CODIGO",cWhere)

   cNumExp:=SQLGET("DPMOVINV","MOV_DOCUME,MOV_TIPDOC,MOV_CODCTA","MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                                 "MOV_ASOTIP"+GetWhere("=",cTipDoc)+" AND "+;
                                                                 "MOV_ASODOC"+GetWhere("=",cNumero))
   cCodCli:=IIF( Empty(oDp:aRow), cCodCli, oDp:aRow[3])

   IF !Empty(cNumExp)
      oDp:cNumExp:=cNumExp 
      MensajeErr("Ya Fue exportado hacia "+oDp:aRow[2]+" "+cNumExp)
      RETURN .F.
   ENDIF

// 06/01/2023 ? lAutoExp,lAuto

   IF lAutoExp .OR. lDirecto

// 06/01/2023  .OR. lAuto 

      IF (cTipExp="DEV" .OR. cTipExp="CRE" .OR. cTipExp="FAV" .OR. cTipExp="TIK")

         // Serie fiscal de la devolución

         EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",cLetra)) 

         oDp:cTkSerie:=SQLGET("DPTIPDOCCLI","SFI_LETRA,TDC_DESCRI"," LEFT JOIN DPSERIEFISCAL ON TDC_SERIEF=SFI_MODELO WHERE TDC_TIPO"+GetWhere("=",cTipExp))

         //? oDp:cTkSerie,oDp:cSql
         
         cNomDoc:=ALLTRIM(DPSQLROW(2,"")) // SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipExp)))
         cNumDes:=EJECUTAR("DPDOCCLIGETNUM",cTipExp)

         IF !MsgNoYes("Desea Crear "+cNomDoc+" #"+cNumDes+" Desde "+cTipDoc+"#"+cNumero)
            RETURN .T.
         ENDIF

         IF !EJECUTAR("ISDOCCLIIMPFISCALIMP",cCodSuc,cTipExp,cNumDes)
            RETURN .F.
         ENDIF

      ENDIF

      PUBLICO("oDocExp")
      oDocExp:=TPublic():New( .T. )

      oDocExp:cCodSuc:=cCodSuc
      oDocExp:cTipDoc:=cTipDoc
      oDocExp:cNumero:=cNumero
      oDocExp:cTipExp:=cTipExp
      oDocExp:cNumSug:=cNumSug
      oDocExp:cCodCli:=cCodCli
      oDocExp:lMenu  :=.F.
      oDocExp:lPagEle:=lPagEle
      oDocExp:lDocGen:=lDocGen
      oDocExp:cNomDoc:=cNomDoc
      oDocExp:cWhere :=cWhere
      oDocExp:lLibVta:=lLibVta
      oDocExp:dFecha :=dFecha
      oDocExp:cNumFis:="" // Número Fiscal

      cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
               "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
               "DOC_TIPTRA"+GetWhere("=","D")

      // EJECUTAR("DPDOCCLIGETNUM",oDocExp:cTipExp,cWhere)
      // oDp:cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO",cWhere)
      //oDocExp:cNumDes:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO",cWhere)

      // 8/8/2024 Impresora fiscal, aqui desde TIK hasta DEV
      IF !Empty(cImpFiscal)
         oDp:cImpFiscal:=cImpFiscal
         oDp:cImpLetra :=cLetra
         EJECUTAR("DPSERIEFISCALLOAD","SFI_IMPFIS"+GetWhere("=",cImpFiscal))
      ENDIF

      IF Empty(cNumDes)
         oDocExp:cNumDes:=cNumDes // EJECUTAR("DPDOCCLIGETNUM",oDocExp:cTipExp)
         oDocExp:cNumFis:=cNumDes
      ENDID

      // impresora fiscal TIK->DEV
      IF !Empty(cImpFiscal) 
          oDocExp:cNumFis:=EJECUTAR("DPDOCCLIGETNUMFIS",oDocExp:cTipExp)
         // oDocExp:cNumDes:=oDocExp:cNumFis
      ENDIF


      // ? "AQUI SI ESTA CORRECTA LA DEVOLUCION"
      // ? oDocExp:cNumDes,"numero correlativo",oDocExp:cTipExp,oDocExp:cNumFis,"<-oDocExp:cNumFis",oDocExp:cNumFis,"oDocExp:cNumFis"
      // oDp:cNumero

      EJECUTAR("DPDOCCLIEXPORTAUT",NIL,NIL,oDocExp,oDocExp:cNumDes,dFecha,cLetra,oDocExp:cNumFis)

      oDp:cNumero:=oDocExp:cNumSug

      IF !lRunDoc
         oDp:cNumero:=oDocExp:cNumSug
         RETURN oDp:cNumero
      ENDIF

      cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPDOC"+GetWhere("=",cTipExp)

//    oDoc    :=EJECUTAR("DPFACTURAV",cTipExp,oDocExp:cNumSug)
      lAutoImp:=SQLGET("DPTIPDOCCLI","TDC_AUTIMP","TDC_TIPO"+GetWhere("=",cTipExp))

      // 29/06/2023 no Requiere ver el documento, solo imprimirlo
      // oDoc    :=EJECUTAR("DPFACTURAV",oDocExp:cTipExp,oDocExp:cNumSug)
    
      cWhere  :="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPDOC"+GetWhere("=",cTipExp)

      IF lAutoImp 

        // impresora fiscal 8/8/2024
        IF !Empty(cImpFiscal)

            SQLUPDATE("DPDOCCLI",{"DOC_FACAFE","DOC_IMPRES"},;
                                 {cNumero     ,.F.},;
                                 "DOC_CODSUC"+GetWhere("=",cCodSuc        )+" AND "+;
                                 "DOC_TIPDOC"+GetWhere("=",oDocExp:cTipExp)+" AND "+;
                                 "DOC_NUMERO"+GetWhere("=",oDp:cNumero    )+" AND "+;
                                 "DOC_TIPTRA"+GetWhere("=","D"            ))

            IF oDocExp:cTipExp="DEV" .OR. oDocExp:cTipExp="CRE"

              SQLUPDATE("DPDOCCLI","DOC_ESTADO","DE","DOC_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
                                                     "DOC_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
                                                     "DOC_NUMERO"+GetWhere("=",oDocExp:cNumero)+" AND "+;
                                                     "DOC_TIPTRA"+GetWhere("=","D"            ))
            ENDIF


            EJECUTAR("DPDOCCLI_PRINT",cCodSuc,oDocExp:cTipExp,oDp:cNumero,cLetra)

        ELSE

          oDp:cDocNumIni:=oDocExp:cNumSug // oDocExp:cNumero
          oDp:cDocNumFin:=oDocExp:cNumSug // oDpCliMnu:cNumero

          oRep:=REPORTE("DOCCLI"+cTipExp,cWhere)

          oRep:SetRango(1,oDocExp:cNumSug,oDocExp:cNumSug)
          oRep:aCargo:=cTipExp

        ENDIF

      ENDIF

//    oDoc:PRINTER() 
//    oDp:cDocNumIni:=oDocExp:cNumDes // oDocExp:cNumero
//    oDp:cDocNumFin:=oDocExp:cNumDes // oDpCliMnu:cNumero
//    oRep:=REPORTE("DOCCLI"+cTipExp,cWhere)
//    oRep:SetRango(1,oDocExp:cNumDes,oDocExp:cNumDes)
//    oDp:oGenRep:aCargo:=cTipExp
//    oRep:aCargo:=cTipExp

      oDp:cNumero:=oDocExp:cNumSug

      RETURN oDp:cNumero

   ENDIF

//   cNumSug:=NUMDOC(cCodSuc,cTipExp)

   EJECUTAR("DPDOCCLIGETNUM",oDocExp:cTipExp)
   cNumSug:=oDp:cNumero



//   cNumSug:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
//                                                   "DOC_TIPDOC"+GetWhere("=",cTipExp)+" AND "+;
//                                                   "DOC_TIPTRA"+GetWhere("=","D"))

   

  oDocExp:=DPEDIT():New("Exportar Documento","DPDOCCLIEXPMNU.EDT","oDocExp",.T.)
  oDocExp:lMsgBar:=.F.

  oDocExp:cCodSuc:=cCodSuc
  oDocExp:cTipDoc:=cTipDoc
  oDocExp:cNumero:=cNumero
  oDocExp:cTipExp:=cTipExp
  oDocExp:cNumSug:=cNumSug
  oDocExp:cCodCli:=cCodCli
  oDocExp:lMenu  :=.T.
  oDocExp:lPagEle:=lPagEle
  oDocExp:lDocGen:=lDocGen
  oDocExp:cNomDoc:=cNomDoc
  oDocExp:cWhere :=cWhere
  oDocExp:lLibVta:=lLibVta
  oDocExp:cNumDes:=""


  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT " Origen "

  @ 5,1 GROUP oGrp TO 6, 21.5 PROMPT " Destino "

  @ 2,1 SAY "Tipo "             RIGHT
  @ 4,1 SAY "Número "           RIGHT
  @ 3,1 SAY oDp:xDPCLIENTES+" " RIGHT

  @ 6,1 SAY "Tipo"      RIGHT
  @ 8,1 SAY "Sugerido " RIGHT

  @ 2,10 SAY " "+oDocExp:cTipDoc+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDocExp:cTipDoc))
  @ 3,10 SAY " "+oDocExp:cNumero
  @ 4,10 SAY " "+SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oDocExp:cCodCli))


  @ 6,10 SAY " "+oDocExp:cTipExp+" "+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDocExp:cTipExp))
  @ 8,10 SAY " "+oDocExp:cNumSug


  oDocExp:cTipExp:=cTipExp
  oDocExp:cNumSug:=cNumSug

  oDocExp:Activate({||oDocExp:SETBOTONBAR()})


RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION SETBOTONBAR()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oDocExp:oDlg
   
   DEFINE CURSOR oCursor HAND

//   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Total"; 
          ACTION oDocExp:ExportDoc(NIL,NIL,oDocExp)

   oBtn:cToolTip:="Iniciar Proceso de Exportacion"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PLANTILLAS.BMP";
          TOP PROMPT "Parcial"; 
          ACTION oDocExp:EXPPARCIAL()

   oBtn:cToolTip:="Exportación Parcial"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Cerrar"; 
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDocExp:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Exportar Documento
*/
FUNCTION EXPORTDOC(cNumDoc,cTipExp,oDocExp,cNumero)
  LOCAL oDoc,cWhere,oRep
  LOCAL lAutoImp

  DEFAULT cTipExp:=oDocExp:cTipExp 

  lAutoImp:=SQLGET("DPTIPDOCCLI","TDC_AUTIMP","TDC_TIPO"+GetWhere("=",cTipExp))

  EJECUTAR("DPDOCCLIEXPORTAUT",oDocExp:cNumero,oDocExp:cTipExp,oDocExp,oDocExp:cNumSug)
  oDoc:=EJECUTAR("DPFACTURAV",oDocExp:cTipExp,oDocExp:cNumSug)

  cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPDOC"+GetWhere("=",cTipExp)

  IF lAutoImp 

    oDp:cDocNumIni:=oDocExp:cNumSug // oDocExp:cNumero
    oDp:cDocNumFin:=oDocExp:cNumSug // oDpCliMnu:cNumero

    oRep:=REPORTE("DOCCLI"+cTipExp,cWhere)

    oRep:SetRango(1,oDocExp:cNumSug,oDocExp:cNumSug)
    oRep:aCargo:=cTipExp

  ENDIF


RETURN NIL


// Se incluyó en Proforma 
/*
   IF oDocExp:lLimite .AND. oDocExp:nPar_CXC<>0
      oDocExp:RECIBO()
      RETURN .T.
   ENDIF
*/
/*
   // Realiza el Pago; luego de general el Documento
   IF oDocExp:lPagEle
      oDocExp:RECIBO()
   ENDIF

   IF oDocExp:lMenu
      EJECUTAR("DPDOCCLIMNU",oDocExp:cCodSuc,cNumero,oDocExp:cCodigo,NIL,oDocExp:cTipExp,NIL)
   ENDIF
*/

   oDocExp:cNumSug:=cNumero // Numero creado
   oDocExp:Close()

RETURN NIL

FUNCTION NUMDOC(cCodSuc,cTipDoc)
  LOCAL cNumero

//  DPDOCCLIGETNUM      
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

FUNCTION EXPPARCIAL()
  LOCAL cWhere:=""
  LOCAL lPesaje
  oDocExp:Close()

  cWhere:="MOV_CODSUC"+GetWhere("=",oDocExp:cCodSuc)+" AND "+;
          "MOV_TIPDOC"+GetWhere("=",oDocExp:cTipDoc)+" AND "+;
          "MOV_CODCTA"+GetWhere("=",oDocExp:cCodCli)+" AND "+;
          "MOV_DOCUME"+GetWhere("=",oDocExp:cNumero)+" AND "+;
          "MOV_INVACT"+GetWhere("=",1)

  lPesaje:=SQLGET("DPMOVINV","SUM(MOV_PESO)",cWhere)>0

  IF lPesaje

     EJECUTAR("BRAVINOTENTDET",cWhere,oDocExp:cCodSuc,NIL,NIL,NIL,NIL,oDocExp:cNumero,oDocExp:cTipDoc,oDocExp:cTipExp,NIL,NIL)

  ELSE

    cWhere:=""
    EJECUTAR("BRCREADOCCLIPLA",cWhere,oDocExp:cCodSuc,oDocExp:cTipDoc,oDocExp:cTipExp,oDocExp:cCodCli,oDocExp:cNumero,oDocExp:cNumSug)

  ENDIF

RETURN .T.

// EOF
