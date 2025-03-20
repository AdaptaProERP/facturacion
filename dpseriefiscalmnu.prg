// Programa   : DPSERIEFISCALMNU
// Fecha/Hora : 24/09/2014 02:02:44
// Propósito  : Menú DPBANCOS
// Creado Por : DpXbase
// Llamado por: DPSERIEFISCAL.LBX
// Aplicación : SERIES FISCALES
// Tabla      : DPSERFISCAL


#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"

FUNCTION MAIN(cModelo)
  LOCAL cLetra,aBtn:={},I
  LOCAL oFont,oFontB,oBtn
  LOCAL cWhere,bAction,nGroup,cImpFis,cAction,cCodSuc,cCodPrg,cTipDoc:=""
  LOCAL nCant:=0

  DEFAULT cModelo:=SQLGET("DPSERIEFISCAL","SFI_MODELO")

  cLetra :=SQLGET("DPSERIEFISCAL","SFI_LETRA,SFI_IMPFIS,SFI_MODVAL,SFI_CODSUC,SFI_PRGRUN","SFI_MODELO"+GetWhere("=",cModelo))
  cImpFis:=DPSQLROW(2,"Ninguna")
  cCodSuc:=DPSQLROW(4,oDp:cSucursal)
  cCodPrg:=DPSQLROW(5,"")
  nCant  :=COUNT("DPTIPDOCCLINUM","TDN_SERFIS"+GetWhere("=",cLetra))
  cTipDoc:=SQLGET("DPTIPDOCCLINUM",[GROUP_CONCAT(TDN_TIPDOC)],[TDN_SERFIS]+GetWhere("=",cLetra)+[ AND TDN_CODSUC]+GetWhere("=",cCodSuc))
  cTipDoc:=IF(ValType(cTipDoc)="C",cTipDoc,"")

  oDp:lImpFisModVal:=DPSQLROW(3,.T.)

  DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
  DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

// ? cTipDoc,ValType(cTipDoc)

  DpMdi(GetFromVar("{oDp:DPSERIEFISCAL}"),"oSerieMnu","TEST.EDT")

  oSerieMnu:cModelo :=cModelo
  oSerieMnu:cCodigo :=cModelo
  oSerieMnu:cLetra  :=cLetra
  oSerieMnu:lSalir  :=.F.
  oSerieMnu:nHeightD:=45
  oSerieMnu:lMsgBar :=.F.
  oSerieMnu:oGrp    :=NIL
  oSerieMnu:cImpFis :=cImpFis
  oSerieMnu:cCodSuc :=cCodSuc
  oSerieMnu:cCodPrg :=cCodPrg
  oSerieMnu:cTipDoc :=cTipDoc
  oSerieMnu:aTipDoc :=_VECTOR(cTipDoc,",")





  SetScript("DPSERIEFISCALMNU")

//  AADD(aBtn,{"Consultar"    ,"VIEW.BMP"      ,"CONSULTAR" })
//  AADD(aBtn,{"Documentos"   ,"XBROWSE.BMP"   ,"DOCUMENTOS"})

 

  IF !Empty(oSerieMnu:cImpFis) .AND. !("NING"$UPPER(oSerieMnu:cImpFis) .OR. "DIGI"$UPPER(oSerieMnu:cImpFis))

//   AADD(aBtn,{"Tickes"            ,"XBROWSEAMARILLO.BMP"   ,"TICKES"})
	AADD(aBtn,{"Reporte X"         ,"REPORTEX.BMP"   ,"REPORTEX"})
//	AADD(aBtn,{"Reporte X"         ,"XPRINT.BMP"   ,"REPORTEX"})

     AADD(aBtn,{"Reporte Z"         ,"REPORTEZ.BMP"   ,"REPORTEZ"})

     IF "EPSON"$oSerieMnu:cImpFis
       AADD(aBtn,{"Cancelar Impresión"   ,"CANCEL2.BMP"    ,"REPCANCEL"})
       AADD(aBtn,{"Ultimo Número Factura","FACTURAVTA.BMP" ,"REPULTIMAF"})
     ENDIF

    IF "BEMA"$oSerieMnu:cImpFis
       AADD(aBtn,{"Cancelar Impresión"   ,"CANCEL2.BMP"    ,"REPCANCEL"})
       AADD(aBtn,{"Resetear Impresión"   ,"CANCEL.BMP"     ,"REPCANCEL"})
       AADD(aBtn,{"Ultimo Número Factura","FACTURAVTA.BMP" ,"REPULTIMAF"})
       AADD(aBtn,{"Ultima Devolución"    ,"FACTURAVTA.BMP" ,"REPULTIMAD"})
    ENDIF

  ENDIF

  AADD(aBtn,{"Asignar en tipos de Documentos ("+LSTR(nCant)+"# Relacionados)" ,"TipDocument.bmp"   ,"SELTIPDOCCLI"})

//  IF nCant>0
//    AADD(aBtn,{"Remover "+LSTR(nCant)+"# relacionados con tipos de Documentos" ,"xdelete.bmp"   ,"DELTIPDOCCLI"})
//  ENDIF

  AADD(aBtn,{"Registrar talonarios" ,"SERIALES.bmp"   ,"TALONARIOS"})

  AADD(aBtn,{"Exportar Transacciones de ventas " ,"upload.bmp"     ,"RDVEXPORT"})
  AADD(aBtn,{"Importar Transacciones de ventas " ,"download.bmp"   ,"RDVIMPORT"})
  
  IF "DIGI"$oSerieMnu:cImpFis
     AADD(aBtn,{"PC autorizados"        ,"pcactivo.BMP" ,"PCAUTORIZA"})
     AADD(aBtn,{"Programa JSON-Factura" ,"FACTURAVTA.BMP" ,"DIGPRG"})
  ENDIF

//AADD(aBtn,{"Exportar hacia Facturas de Contingencia"   ,"exportdocump.bmp"   ,"FAVTOFAM"})
  AADD(aBtn,{"Permisos"     ,"xunlock.BMP"   ,"PERMISOS"})

  AADD(aBtn,{"Salir"        ,"XSALIR.BMP"    ,"EXIT"      })

  // oSerieMnu:Windows(0,0,530+50,415)
  oSerieMnu:Windows(0,0,oDp:aCoors[3]-200,415) 

  @ 48, -1 OUTLOOK oSerieMnu:oOut ;
     SIZE 150+250, oSerieMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oSerieMnu:oWnd;
     COLOR CLR_BLACK,oDp:nGris2

   DEFINE GROUP OF OUTLOOK oSerieMnu:oOut PROMPT "&Opciones "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oSerieMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup :=LEN(oSerieMnu:oOut:aGroup)
      oBtn   :=ATAIL(oSerieMnu:oOut:aGroup[ nGroup, 2 ])
      cAction:="oSerieMnu:BTNACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])"

      bAction:=BloqueCod(cAction)

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oSerieMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   aBtn:={}

/*
   IF "DIGI"$oSerieMnu:cImpFis
      AADD(aBtn,{"Programa JSON-Factura"  ,"FACTURAVTA.BMP" ,"DIGPRG"})
//      AADD(aBtn,{"JSON-Devolución"      ,"notacredito.BMP","DIGDEVOLU"})
//      AADD(aBtn,{"JSON-Enviar Correo"   ,"EMAIL.BMP"      ,"DIGMAIL"})
      AADD(aBtn,{"Programa Fuente"      ,"PROGRAMA.BMP"   ,"DIGPRG" })
   ENDIF

   IF !Empty(aBtn)

     DEFINE GROUP OF OUTLOOK oSerieMnu:oOut PROMPT "&Definición Facturación Digital "

     FOR I=1 TO LEN(aBtn)

       DEFINE BITMAP OF OUTLOOK oSerieMnu:oOut ;
              BITMAP "BITMAPS\"+aBtn[I,2];
              PROMPT aBtn[I,1];
              ACTION 1=1

        nGroup :=LEN(oSerieMnu:oOut:aGroup)
        oBtn   :=ATAIL(oSerieMnu:oOut:aGroup[ nGroup, 2 ])
        cAction:="oSerieMnu:BTNACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])"

        bAction:=BloqueCod(cAction)

        oBtn:bAction:=bAction
 
        oBtn:=ATAIL(oSerieMnu:oOut:aGroup[ nGroup, 3 ])
        oBtn:bLButtonUp:=bAction

     NEXT I

   ENDIF
*/

   @ 0, 100 SPLITTER oSerieMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oSerieMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oSerieMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oSerieMnu:oDlg FROM 0,oSerieMnu:oOut:nWidth() TO oSerieMnu:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oSerieMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris FONT oFontB

   @ .1,.2 GROUP oSerieMnu:oGrp TO 10,10 PROMPT "["+oSerieMnu:cLetra+"-"+oSerieMnu:cModelo+" "+oSerieMnu:cTipDoc+" ] "

   @ .5,.5 SAY "Impresora Fiscal :"+oSerieMnu:cImpFis+"" SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oSerieMnu:oDlg NOWAIT VALID .F.

   oSerieMnu:Activate("oSerieMnu:FRMINIT()",,"oSerieMnu:oSpl:AdjRight()")
 
   EJECUTAR("DPSUBMENUCREAREG",oSerieMnu,NIL,"M","DPSERIEFICALMNU")

   IF "DIG"$cImpFis .AND. Empty(oSerieMnu:cCodPrg) 
      oSerieMnu:BTNACTION("DIGPRG")
   ENDIF

RETURN

FUNCTION FRMINIT()

   oSerieMnu:oWnd:bResized:={||oSerieMnu:oDlg:Move(0,0,oSerieMnu:oWnd:nWidth(),50,.T.),;
                             oSerieMnu:oGrp:Move(0,0,oSerieMnu:oWnd:nWidth()-15,oSerieMnu:nHeightD,.T.)}

   EVal(oSerieMnu:oWnd:bResized)

RETURN .T.

// Ejecutar
FUNCTION BTNACTION(cAction,cTitle)
  LOCAL cWhere,cWeb,oCursor,cNumero
  LOCAL cPrg,cMemo,bRun,cField,cFile

  IF cAction="EXIT"
     oSerieMnu:Close()
  ENDIF

  IF cAction="CONSULTAR"
    EJECUTAR("DPSERIEFISCAL",0,oSerieMnu:cModelo)
    RETURN .T.
  ENDIF

  IF cAction="DOCUMENTOS"
    cWhere:="DOC_CODSUC"+GetWhere("=",oSerieMnu:cCodSuc)+" AND DOC_SERFIS"+GetWhere("=",oSerieMnu:cLetra)
    EJECUTAR("BRSERFISCAL",cWhere)
    RETURN .T.
  ENDIF

  IF cAction="TALONARIOS"
    // cWhere:="DOC_CODSUC"+GetWhere("=",ooSerieMnu:cCodSuc)+" AND DOC_SERFIS"+GetWhere("=",oSerieMnu:cLetra)
    // EJECUTAR("BRSERFISCAL",cWhere)
    EJECUTAR("dpseriefiscal_numlbx",oSerieMnu:cCodSuc,oSerieMnu:cLetra)
    RETURN .T.
  ENDIF


  IF "TICKES"$cAction
     cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_SERFIS"+GetWhere("=",oSerieMnu:cLetra)
     EJECUTAR("BRTICKETPOS",cWhere)
     RETURN .T.
  ENDIF

  IF cAction="PERMISOS"
    oCursor:=OpenTable("SELECT * FROM DPSERIEFISCAL WHERE SFI_MODELO"+GetWhere("=",oSerieMnu:cModelo))
    EJECUTAR("DPTABXUSU",oCursor:SFI_MODELO,oCursor:SFI_LETRA,"DPSERIEFISCAL","Usuarios por "+GetFromVar("DPSERIEFISCAL"))
    oCursor:End()
    RETURN .T.
  ENDIF

  IF cAction="FAVTOFAM" 

     IF MsgNoYes("Desea Migrar las Facturas de Venta hacia Facturas de Contigencia","Necesario para Reiniciar la facturación desde Impresora Fiscal")
        MsgRun("Procesando","por favor espere",{||EJECUTAR("FAVTOFAM")})
     ENDIF
  ENDIF


  IF cAction="REPORTEZ" 
     EJECUTAR("DLL_IMPFISCAL_CMD","Z",cAction,NIL,oSerieMnu:cLetra,cTitle)
  ENDIF

  IF cAction="REPORTEX" 
     EJECUTAR("DLL_IMPFISCAL_CMD","X",cAction,NIL,oSerieMnu:cLetra,cTitle)
  ENDIF

  IF cAction="REPCANCEL" 
     EJECUTAR("DLL_IMPFISCAL_CMD","C",cAction,NIL,oSerieMnu:cLetra,cTitle)
  ENDIF

  IF cAction="REPULTIMAF" 
     cNumero:=EJECUTAR("DLL_IMPFISCAL_CMD","UF",cAction,NIL,oSerieMnu:cLetra,cTitle)
     cNumero:=CTOO(cNumero,"C")
     MsgMemo("Número Obtenido "+cNumero,"Ultimo Número Fiscal")
  ENDIF

  // Exportar RDV
  IF cAction="RDVEXPORT"
     // oSerieMnu:cCodSuc Asume la sucursal para todas las series fiscales
     EJECUTAR("BRRDVDIARIO",NIL,oSerieMnu:cCodSuc,oDp:nQuincenal,nil,nil,nil,oSerieMnu:cLetra)
  ENDIF

  IF cAction="RDVIMPORT"
     RETURN EJECUTAR("RDVIMPORT",NIL,oSerieMnu:cCodSuc,oSerieMnu:cLetra)
  ENDIF

  IF cAction="PCAUTORIZA"
     EJECUTAR("BRSERFISXPC","TXU_CODIGO"+GetWhere("=",oSerieMnu:cLetra))
     RETURN NIL
  ENDIF

  IF cAction="SELTIPDOCCLI"
     RETURN EJECUTAR("BRSELSERFISXTIP",NIL,NIL,NIL,NIL,NIL,NIL,oSerieMnu:cLetra)
  ENDIF

  IF cAction="DELTIPDOCCLI"
     RETURN EJECUTAR("BRSELSERFISXTIP","TDN_SERFIS"+GetWhere("=",oSerieMnu:cLetra),NIL,NIL,NIL,NIL,NIL,oSerieMnu:cLetra,.T.)
  ENDIF

  IF cAction="DIGPRG"

     cField:="SFI_PRGRUN"
     HrbLoad("DPXBASE.HRB") // Carga M?dulo DpXbase

     bRun  :={||NIL}
     cWhere:="SFI_LETRA"+GetWhere("=",oSerieMnu:cLetra)
     cMemo :=SQLGET("DPSERIEFISCAL",cField,cWhere)
     cMemo :=IF(Empty(cMemo),cPrg,ALLTRIM(cMemo))

     IF Empty(cMemo) .OR. LEN(cMemo)=0
        cFile:="DP\"+ALLTRIM(STRTRAN(oSerieMnu:cImpFis,"_EVAL",""))+".TXT"
        cMemo:=MemoRead(cFile)
        cMemo:=STRTRAN(cMemo,[<DIGITAL>],cFileNoPath(cFile))
     ENDIF

     IF Empty(cMemo)

        cMemo:=[/]+[/ Facturación Digital ]+oSerieMnu:cCodigo+CRLF+;
               [#INCLUDE DPXBASE.CH      ]+CRLF+;
               [FUNCTION MAIN(cCodSuc,cTipDoc,cNumero,nAction)]+CRLF+;
               [LOCAL cJson:=""       ]+CRLF+;
               []+CRLF+;
               [RETURN cJson ]+CRLF+;
               [/]+[/EOF]

     ENDIF

     // cFile :="DP\DPPRECIOTIP_"+cField+".TXT"

     oDp:cFavD_cPrg     :=""         // Programa DpXbase
     oDp:cFavD_oDpXbase :=NIL    

     DPXBASEEDIT(3,oSerieMnu:cCodigo,bRun,NIL,cMemo,"DPSERIEFISCAL",cField,cWhere)

  ENDIF

RETURN .T.

FUNCTION CLOSE()
RETURN .T.

