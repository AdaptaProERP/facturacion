// Programa   : DPCLIENTESEDITRIF
// Fecha/Hora : 07/03/2025 19:56:33
// Propósito  : Facilita Corregir el RIF y/o Nombre del Cliente
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,oCodigo,cMemo,oCliNombre)
  LOCAL cRif,cNombreCli,aPoint:={},cCodCli_:=cCodCli,lCodCli:=.T.
  LOCAL cWhere:="",lResp:=.F.
  LOCAL lSave :=.T.
  LOCAL oBrush,oDlg,oRif,oNombreCli,oMemo,oFontC,oBtnSave
  LOCAL nCol   :=110
  LOCAL nWidth :=820  // Ancho Calculado seg£n Columnas 
  LOCAL nHeight:=69+30  // Alto
  LOCAL oFontB :=NIL
  LOCAL oBar
  LOCAL cTitle :="Editar RIF y Nombre del Cliente",lCodCli

  DEFAULT cCodCli:="0009460028",;
          cMemo  :=MEMOREAD("DP\VALIDARRIF.TXT")

  IF !Empty(oDp:cRifErr)
     cMemo:=cMemo+CRLF+"Incidencia detectada:"+CRLF+oDp:cRifErr
  ENDIF

  cCodCli_:=cCodCli
  cWhere  :="CLI_CODIGO"+GetWhere("=",cCodCli)

  cRif   :=SQLGET("DPCLIENTES","CLI_RIF,CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
  lCodCli:=ALLTRIM(cRif)==ALLTRIM(cCodCli)
  cNombreCli:=PADR(DPSQLROW(2),200)

  DEFINE FONT oFontB NAME "Tahoma"      SIZE 0, -12  BOLD
  DEFINE FONT oFontC NAME "Courier New" SIZE 0, -12  BOLD


  IF !Empty(cMemo)
    nHeight:=nHeight+200
  ENDIF

  IF oCodigo=NIL 

    DEFINE DIALOG oDlg TITLE cTitle FROM 1,30 TO nHeight,nWidth PIXEL 

  ELSE

    DEFINE DIALOG oDlg TITLE cTitle FROM 1,30 TO nHeight,nWidth PIXEL   STYLE nOr( DS_SYSMODAL, DS_MODALFRAME )

  ENDIF

  oDlg:bkeyDown:={|nKey| IF(nKey=120,EVAL(oBtnSave:bAction),NIL)}
  oDlg:lHelpIcon:=.F.

  IF !Empty(cMemo)
     @ 0,0 GET oMemo VAR cMemo OF oDlg MULTILINE FONT oFontC
  ENDIF


  ACTIVATE DIALOG oDlg CENTERED;
           ON INIT DLGBAR()

  IF lResp .AND. ValType(oCodigo)="O"

     cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO,CLI_CODVEN","CLI_RIF"+GetWhere("=",cRif))

     IF Empty(DPSQLROW(2)) .AND. !Empty(oDp:cCodVen)
        SQLUPDATE("DPCLIENTES",{"CLI_CODVEN","CLI_LISTA"},{oDp:cCodVen,oDp:cOJO},"CLI_RIF"+GetWhere("=",cRif))
     ENDIF

     oCodigo:VarPut(cCodCli,.T.)
     oCodigo:KeyBoard(13) 
     
     IF ValType(oCliNombre)="O"
        oCliNombre:Refresh(.T.)
     ENDIF
  ENDIF
            
RETURN lResp

/*
// Coloca la Barra de Botones
*/
FUNCTION DLGBAR()
   LOCAL oCursor,oBtn,oFontB,oFont,nCol:=20,aPoint:={},oGroup

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12  BOLD
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -13  BOLD

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 65+1,65+5 OF oDlg 3D CURSOR oCursor
  
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "F9 Grabar"; 
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION (lResp:=VALIDARIF(),IF(lResp,oDlg:End(),NIL))

   oBtnSave:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SENIAT.BMP";
          TOP PROMPT "Validar";
          ACTION REG_VALRIF() CANCEL

   oBtn:cToolTip:="Validar RIF en el Portal del SENIAT"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Regresar"; 
          FILENAME "BITMAPS\XCANCEL.BMP";
          ACTION (lResp:=.F.,oDlg:End()) CANCEL

  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth(), o:SetColor(0,oDp:nGris)})
  oBar:SetColor(0,oDp:nGris)

  @ 03,nCol SAY " RIF " OF oBar ;
            BORDER  PIXEL RIGHT;
            COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 62,20

  @ 24,nCol SAY " Nombre " OF oBar ;
            BORDER  PIXEL RIGHT;
            COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 62,20

  @ 03,nCol+63 GET oRif    VAR cRif    OF oBar SIZE 098,20 FONT oFontB PIXEL VALID  VALRIF()
  @ 24,nCol+63 GET oNombreCli VAR cNombreCli OF oBar SIZE 380,20 FONT oFontB PIXEL VALID  VALNOMBRE()

  IF ValType(oMemo)="O"
     oMemo:Move(oBar:nBottom(),0,oDlg:nWidth()-8,oDlg:nHeight()-(oBar:nBottom()+30),.T.)
  ENDIF

  IF ValType(oCodigo)="O"
     aPoint:=AdjustWnd( oCodigo, oDlg:nWidth(), oDlg:nHeight() )
     oDlg:Move(aPoint[1] + 0, aPoint[2])
  ENDIF

  DPFOCUS(oRif)

RETURN .F.

FUNCTION VALRIF()
  LOCAL lSayErr :=.F.
  LOCAL lResp   :=EJECUTAR("VALRIFLEN",cRif,oRif,lSayErr,.F.)
  LOCAL cNombre_:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_RIF"+GetWhere("=",cRif))

  IF !Empty(cNombre_)
     oNombreCli:VarPut(cNombre_,.T)
     cNombreCli:=cNombre_
     oNombreCli:Refresh(.T.)
  ENDIF

  IF !lResp
    cMemo:=MEMOREAD("DP\VALIDARRIF.TXT")
    oMemo:VarPut(cMemo+CRLF+REPLI("-",80)+CRLF+"Validación, RIF="+ALLTRIM(cRif)+" "+oDp:cRifErr,.T.)
  ENDIF

RETURN lResp

FUNCTION VALNOMBRE()
  LOCAL lMsg :=.T.
  LOCAL lResp:=EJECUTAR("VALNOMBRE",cNombreCli,oNombreCli,cRif,lMsg)

  IF lResp
    DPFOCUS(oBtnSave)
  ENDIF

RETURN lResp


FUNCTION VALIDARIF()
  LOCAL cWhere:=NIL
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL cSql  :=" SET FOREIGN_KEY_CHECKS = 0"

  // RIF=CODIGO
  IF lCodCli
    cCodCli:=cRif
  ENDIF

  IF !Empty(cCodCli_)

    cWhere:="CLI_CODIGO"+GetWhere("=",cCodCli_)

  ELSE
    
    cWhere  :="CLI_RIF"+GetWhere("=",cRif)
    cCodCli_:=SQLGET("DPCLIENTES","CLI_CODIGO","CLI_RIF"+GetWhere("=",cRif))

    IF Empty(cCodCli_)
       cCodCli_:=cRif
    ENDIF

  ENDIF

  oDb:Execute(cSql)

  EJECUTAR("CREATERECORD","DPCLIENTES",{"CLI_RIF","CLI_NOMBRE","CLI_CODIGO","CLI_SITUAC"},; 
                                       {cRif     ,cNombreCli  ,cCodCli     ,"Activo"    },;
                                        NIL,.T.,cWhere)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"

  oDb:Execute(cSql)

RETURN .T.

FUNCTION REG_VALRIF()
  LOCAL lOk:=.T.,nLen:=LEN(cRif)

  oDp:aRif:={}

  oDp:lValRif:=.F.

  IF Empty(cRif)
     oRif:MsgErr("Introduzca RIF","Validación")
     RETURN .F.
  ENDIF

  IF ISDIGIT(cRif)
    cRif:=STRZERO(VAL(cRif),8)
    oRif:VarPut(cRif,.T.)
  ENDIF

  cRif:=PADR(STRTRAN(cRif," ",""),nLen)

  oDp:cSeniatErr:=""
  oDp:cDataRif  :=""

  MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
         {|| lOk:=.T. })

  oDp:cDataRif:=""

  lOk:=EJECUTAR("VALRIFSENIAT",cRif,.F.,.F.,oRif)

  cRif:=IF(Empty(oDp:cDataRif),cRif,oDp:cDataRif)

  IF !lOk .AND. ISDIGIT(cRif)

    MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
            {||lOk:=EJECUTAR("RIFVAUTODET",cRif,oRif)})

  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF lOk

     cRifVAL:=.T.
     lValRif   :=.T. // Cuando se Modifica no es necesario Validarlo Nuevamente

     oDp:aRif[6]:=oDp:cDataRif

     IF !Empty(oDp:aRif) .AND. !Empty(oDp:aRif[1])

       oNombreCli:VARPUT( oDp:aRif[1] , .T. )

       cRif:=oDp:aRif[6]
       oRif:VARPUT(cRif,.T.)

       DPFOCUS(oRif)

     ENDIF

  ELSE

     cRifVAL:=.F.

     oRif:MsgErr("RIF "+ALLTRIM(cRif)+" no fué Validado",NIL)

  ENDIF

  oNombreCli:ForWhen()

RETURN .T.
// EOF
