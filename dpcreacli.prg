// Programa   : DPCREACLI
// Fecha/Hora : 13/05/2011 01:28:31
// Propósito  : Creación Rápida del Cliente (Herramienta para Contadores)
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(_oGet,_cRif,_lAuto,cCodAct,cCodCla,cCodEdo)
  LOCAL oDlg,oFont,oFontB,oGroup,oBtn,oBtnSave,aSay:={},I,oSay,nLine,cRif
  LOCAL lOk:=.F.
  LOCAL nWidth   :=390+60+40, nHeight:=310
  LOCAL aPoint   :=IF(_oGet=NIL , NIL , AdjustWnd( _oGet, nWidth, nHeight ))

  LOCAL oGet:=_oGet,lAuto:=_lAuto
  LOCAL oDir1,oDir2,oDir3,oTel1,oEmail,oRepres,oCI
  LOCAL oBtn2,oBtn2
  LOCAL oCliente,cCodigo

  LOCAL lExiste:=.F.
  LOCAL lValRif:=.F

  LOCAL oNombreCli,oRetIva,oRif
  LOCAL cNombreCli:=SPACE(80)
  LOCAL cDir1  :=SPACE(40)
  LOCAL cDir2  :=SPACE(40)
  LOCAL cDir3  :=SPACE(40)
  LOCAL cTel1  :=SPACE(20)
  LOCAL cEmail :=SPACE(80)
  LOCAL cRepres:=SPACE(120)
  LOCAL cCI    :=SPACE(10)
  LOCAL nRetIva:=0
  LOCAL cRif_
  LOCAL oCodAct,oSayAct
  LOCAL oCodCla,oSayCla
  LOCAL oCodEdo,oSayEdo

  IF oDp:cForInv="Clínico"
    RETURN EJECUTAR("DPCREACLICLINICO",_oGet,_cRif,_lAuto,cCodAct,cCodCla,cCodEdo)
  ENDIF



  DEFAULT cCodAct:=SPACE(06),;
          cCodCla:=SPACE(06),;
          cCodEdo:=SPACE(20)

  IF Empty(_cRif)
     _cRif:=SPACE(12)
  ENDIF


  DEFAULT _cRif  :=SPACE(12),;
          _lAuto :=.F.      ,;
          cRif   :=_cRif

  IF Empty(cRif)

    cRif:=SPACE(12)

  ENDIF

  IF !Empty(_cRif)

    cRif    :=_cRif
    oCliente:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_RIF"+GetWhere("=",_cRif),.T.)

    IF oCliente:RecCount()>0  
      cCodigo:=oCliente:CLI_CODIGO
      cCodCla:=oCliente:CLI_CODCLA
      cCodAct:=oCliente:CLI_ACTIVI
      cCodEdo:=oCliente:CLI_ESTADO
      cCodVen:=oCliente:CLI_CODVEN
      cNombreCli:=oCliente:CLI_NOMBRE
      cDir1  :=oCliente:CLI_DIR1
      cDir2  :=oCliente:CLI_DIR2
      cDir3  :=oCliente:CLI_DIR3
      cTel1  :=oCliente:CLI_TEL1
      nRetIva:=oCliente:CLI_RETIVA
      cEmail :=oCliente:CLI_EMAIL
      cRif   :=oCliente:CLI_RIF
    ENDIF

    oCliente:End()

    IF !Empty(cCodigo)
 
      oCliente:=Opentable("SELECT * FROM DPCLIENTESPER WHERE PDC_CODIGO"+GetWhere("=",cCodigo),.T.,oDp:oDbLic)
      cRepres :=oCliente:PDC_PERSON
      cCI     :=oCliente:PDC_COMENT
      oCliente:End()

    ENDIF

  ENDIF

  AADD(aSay,{"R.I.F:"        ,NIL})
  AADD(aSay,{"Nombre:"       ,NIL})
  AADD(aSay,{"% Ret/ISLR:"   ,NIL})
  AADD(aSay,{"Dirección 1:"  ,NIL})
  AADD(aSay,{"          2:"  ,NIL})
  AADD(aSay,{"          3:"  ,NIL})
  AADD(aSay,{"Teléfono:"     ,NIL})
  AADD(aSay,{"Correo:"       ,NIL})
  AADD(aSay,{"Rep. Legal:"   ,NIL})
  AADD(aSay,{"Cédula:"       ,NIL})
  AADD(aSay,{"Clasificación:",NIL})
  AADD(aSay,{"Act.Económica:",NIL})
  AADD(aSay,{"Estado Ubicac:",NIL})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-10
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0,-11 BOLD

  IF aPoint=NIL

     DEFINE DIALOG oDlg;
            TITLE "Creación Rápida de "+oDp:xDPCLIENTES;
            FROM 0,0 TO 18+06+5,47+10+10;
            COLOR NIL,oDp:nGris
  ELSE

     DEFINE DIALOG oDlg;
            TITLE "Creación Rápida de "+oDp:xDPCLIENTES;
            PIXEL OF oGet:oWnd;
            STYLE nOr( DS_SYSMODAL, DS_MODALFRAME );
            COLOR NIL,oDp:nGris


  ENDIF

  oDlg:lHelpIcon:=.F.

  oDlg:bkeyDown:={|nKey| IF(nKey=120,EVAL(oBtnSave:bAction),NIL)}


  FOR I=1 TO LEN(aSay)

    nLine:=(I*.8)

    @ nLine,.5 SAY oSay PROMPT aSay[I,1] SIZE 45,10;
              COLOR NIL,oDp:nGris RIGHT FONT oFontB OF oDlg

    aSay[I,2]:=oSay:nTop

  NEXT I


  @ aSay[1,2],50 GET oRif VAR cRif PICTURE "@!";
                 SIZE 42,10;
                 VALID VALRIFCLI(cRif,oRif);
                 COLOR NIL,CLR_WHITE PIXEL FONT oFontB OF oDlg

//  oRif:bkeyDown:={|nKey| IIF( nKey=13 .AND. VALRIFCLI(cRif,oRif), IF(!lExiste,VALRIF(cRif,oRif),NIL) , NIL )}

  oRif:bkeyDown:={|nKey| IIF( nKey=13 .AND. VALRIFCLI(cRif,oRif), NIL)}



  @ aSay[1,2],91+1 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION VALRIF(cRif,oRif);
                 FONT oFontB;
                 WHEN !Empty(cRif) PIXEL FONT oFontB


  @ aSay[2,2],50 GET oNombreCli VAR cNombreCli;
                 VALID !Empty(cNombreCli) .AND. VALNOMBRE();
                 SIZE 120,10;
                 COLOR NIL,CLR_WHITE PIXEL FONT oFontB



  @ aSay[3,2],50 GET oRetIva VAR nRetIva;
                 COLOR NIL,CLR_WHITE;
                 PICTURE "999" RIGHT;
                 SIZE 20,10 PIXEL FONT oFontB

  @ aSay[4,2],50 GET oDir1 VAR cDir1;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[5,2],50 GET oDir2 VAR cDir2;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[6,2],50 GET oDir3 VAR cDir3;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[7,2],50 GET oTel1 VAR cTel1;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[8,2],50 GET oEmail VAR cEmail;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[9,2],50 GET oRepres VAR cRepres;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[10,2],50 GET oCI VAR cCI PICTURE "999999999";
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB


  @ aSay[11,2],50 GET oCodCla VAR cCodCla;
                  VALID VALCODCLA();
                  SIZE 35,10 PIXEL FONT oFontB;
                  WHEN COUNT("DPCLICLA","CLC_ACTIVO=1")>0

  @ aSay[11,2],100 SAY oSayCla PROMPT SQLGET("DPCLICLA","CLC_DESCRI","CLC_CODIGO"+GetWhere("=",cCodCla));
                   SIZE 150,10 PIXEL FONT oFontB COLOR CLR_WHITE,16753736

  @ aSay[11,2],86 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION LISTCLA();
                  FONT oFontB;
                  WHEN COUNT("DPCLICLA","CLC_ACTIVO=1")>0;
                  PIXEL 


  @ aSay[12,2],50 GET oCodAct VAR cCodAct;
                  VALID VALCODACT();
                  WHEN COUNT("DPACTIVIDAD_E","ACT_ACTIVO=1")>0;
                  SIZE 35,10 PIXEL FONT oFontB

  @ aSay[12,2],100 SAY oSayAct PROMPT SQLGET("DPACTIVIDAD_E","ACT_DESCRI","ACT_CODIGO"+GetWhere("=",cCodAct));
                   SIZE 150,10 PIXEL FONT oFontB COLOR CLR_WHITE,16753736

  @ aSay[12,2],86 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION LISTACT();
                  FONT oFontB;
                  WHEN COUNT("DPACTIVIDAD_E","ACT_ACTIVO=1")>0;
                  PIXEL 

  @ aSay[13,2],50 GET oCodEdo VAR cCodEdo;
                  VALID VALCODEDO();
                  SIZE 35,10 PIXEL FONT oFontB

  @ aSay[13,2],100 SAY oSayEdo PROMPT SQLGET("DPESTADOS","ESTADO","ESTADO"+GetWhere("=",cCodEdo));
                   SIZE 150,10 PIXEL FONT oFontB COLOR CLR_WHITE,16753736

  @ aSay[13,2],86 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION LISTEDO();
                  FONT oFontB;
                  WHEN 1=1 PIXEL FONT oFontB


  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0,-14 BOLD

  @ 6.5+2.5+.5,17+5+6 BUTTON oBtnSave PROMPT " Aceptar F9 ";
             SIZE 32+10,16;
             FONT oFontB;
             ACTION (lOk:=CLIGRABAR(cRif) ,;
                 IF(lOk,oDlg:End(),NIL))

  @ 6.5+2.5+.5,23+5+8 BUTTON " Salir   ";
             SIZE 32+10,16;
             FONT oFontB;
             ACTION (lOk:=.F.,oDlg:End()) CANCEL


  IF aPoint=NIL

    ACTIVATE DIALOG oDlg CENTERED

  ELSE

    ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(aPoint[1], aPoint[2],NIL,NIL,.T.),;
                                  oDlg:SetSize(nWidth+40,nHeight+70+16),;
                                  IIF(_lAuto,oRif:KeyBoard(13),NIL))


  ENDIF

  IF lOk .AND. ValType(_oGet)="O" .AND. !Empty(cRif) .AND. "GET"$_oGet:ClassName()
     _oGet:VarPut(cRif,.T.)
     _oGet:KeyBoard(13)
  ENDIF

RETURN .T.

FUNCTION CLIGRABAR(cRif)
   LOCAL cCodPro // ,cCodCla,cCodAct,
   LOCAL oTable,cCodVen,lNew:=.F.
   LOCAL cTipDoc:="REG"
   LOCAL cCodigo:=""

   CursorWait()

// Quitamos los guiones
   cRif   :=STRTRAN(cRif,"-","")

//? Empty(cRif),"cRif",cRif

   IF Empty(cRif)
      MsgMemo("Es necesario Indicar el RIF")
      RETURN .F.
   ENDIF

/*
   IF !lExiste .AND. !VALRIFCLI(cRif)
      DPFOCUS(oRif)
      RETURN .F.
   ENDIF
*/
   IF !EJECUTAR("EMAILVALID",cEmail)
     oEmail:MsgErr("Correo Incorrecto")
     RETURN .F.
   ENDIF

   IF Empty(cNombreCli)
      oNombreCli:MsgErr("Es necesario el Nombre")
      RETURN .F.
   ENDIF

   IF Empty(cCodCla)
     cCodCla:=SQLGET("DPCLICLA"     ,"CLC_CODIGO",NIL,NIL,oDp:oDbLic)
   ENDIF

   IF Empty(cCodAct)
     cCodAct:=SQLGET("DPACTIVIDAD_E","ACT_CODIGO",NIL,NIL,oDp:oDbLic)
   ENDIF

   cCodVen:=SQLGET("DPVENDEDOR"   ,"VEN_CODIGO",NIL,NIL,oDp:oDbLic)

   cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO","CLI_RIF"+GetWhere("=",cRif),NIL,oDp:oDbLic)

   IF Empty(cCodigo) .AND. !Empty(cRif)
      cCodigo:=cRif
   ENDIF

   // Agregamos Ceros 
   IF ISALLDIGIT(cCodigo)
      cCodigo:=REPLI("0",10-LEN(ALLTRIM(cCodigo)))+cCodigo
   ENDIF

   oTable:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",cCodigo),.T.,oDp:oDbLic)
   oTable:SetForeignkeyOff()

   IF oTable:RecCount()=0
      oTable:AppendBlank()
      oTable:cWhere:=""
      lNew  :=.T.
   ELSE
      cCodVen:=oTable:CLI_CODVEN
      // cCodCla:=oTable:CLI_CODCLA
      lNew  :=.F.
   ENDIF

   oTable:Replace("CLI_CODIGO" ,cCodigo       )
   oTable:Replace("CLI_CODCLA" ,cCodCla       )
   oTable:Replace("CLI_CUENTA" ,oDp:cCtaIndef )
   oTable:Replace("CLI_ACTIVI" ,cCodAct       )
   oTable:Replace("CLI_PAIS"   ,oDp:cPais     )
   oTable:Replace("CLI_ESTADO" ,cCodEdo       )
   oTable:Replace("CLI_MUNICI" ,oDp:cMunicipio)
   oTable:Replace("CLI_PARROQ" ,oDp:cParroquia)
   oTable:Replace("CLI_CODVEN",cCodVen      )
   oTable:Replace("CLI_RIF"    ,cRif          )
   oTable:Replace("CLI_NOMBRE" ,cNombreCli       )
   oTable:Replace("CLI_DIR1"   ,cDir1         )
   oTable:Replace("CLI_DIR2"   ,cDir2         )
   oTable:Replace("CLI_DIR3"   ,cDir3         )
   oTable:Replace("CLI_TEL1"   ,cTel1         )
   oTable:Replace("CLI_SITUAC" ,"A"           )
   oTable:Replace("CLI_TIPPER" ,"J"           )
   oTable:Replace("CLI_RESIDE" ,"S"           )
   oTable:Replace("CLI_ZONANL" ,"N"           )
   oTable:Replace("CLI_CONTRI" ,"S"           )
   oTable:Replace("CLI_CONESP" ,"N"           )
   oTable:Replace("CLI_ENOTRA" ,"S"           )
   oTable:Replace("CLI_CATEGO" ,"B"           )
   oTable:Replace("CLI_PRECIO" ,"N"           )
   oTable:Replace("CLI_LISTA"  ,oDp:cLista    )
   oTable:Replace("CLI_TERCER" ,"N"           )
   oTable:Replace("CLI_SITUAC" ,"Activo"      )
   oTable:Replace("CLI_RETIVA" ,nRetIva       )
   oTable:Replace("CLI_EMAIL"  ,cEmail        )
   oTable:Replace("CLI_CODMON" ,oDp:cMonedaExt)

   oTable:Commit(oTable:cWhere)
   oTable:End()

   // Aqui asigna el Cliente por Sucursal

   EJECUTAR("DPTABSETSUC",oTable:CLI_CODIGO,oDp:cSucursal,"DPCLIENTES")

   IF Empty(cTipDoc)
      RETURN .T.
   ENDIF

   //IF COUNT("dpdoccli","DOC_CODSUC"+GetWhere("=",oDpLic:cCodSuc)+" AND DOC_CODIGO"+GetWhere("=",cRif)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc),oDp:oDbLic)>0
   //   RETURN .T.
   // ENDIF

   /*
   // Solo se Puede AutoAsignar Clientes Nuevos
   */

   // Representante Legal

   IF !Empty(cRepres)

     oTable:=Opentable("SELECT * FROM DPCLIENTESPER WHERE PDC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                                         "PDC_COMENT"+GetWhere("=",cCI    ),.T.,oDp:oDbLic)

     oTable:SetForeignkeyOff()

     IF oTable:RecCount()=0
       oTable:AppendBlank()
       oTable:cWhere:=""
     ENDIF

     oTable:Replace("PDC_CODIGO" ,cCodigo              )
     oTable:Replace("PDC_CARGO"  ,"Representante Legal")
     oTable:Replace("PDC_PERSON" ,cRepres              )
     oTable:Replace("PDC_COMENT" ,cCI                  )
     oTable:Replace("PDC_TIPO"   ,"Representante"      )
     oTable:Commit(oTable:cWhere)
     oTable:End()

  ENDIF

RETURN .T.

FUNCTION VALRIFCLI(cRif)
  LOCAL oCliente
  LOCAL cRif2:=""
  
  IF Empty(cRif)
     RETURN .F.
  ENDIF

  cRif2:=SQLGET("DPCLIENTES","CLI_RIF,CLI_NOMBRE","CLI_RIF"+GetWhere(" LIKE ","%"+ALLTRIM(cRif)+"%"))

  IF !Empty(cRif2)

    oCliente:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_RIF"+GetWhere("=",cRif2),.T.)

//    IF oCliente:RecCount()>0  
      cCodigo:=oCliente:CLI_CODIGO
      cCodCla:=oCliente:CLI_CODCLA
      cCodAct:=oCliente:CLI_ACTIVI
      cCodEdo:=oCliente:CLI_ESTADO
      cCodVen:=oCliente:CLI_CODVEN
      cNombreCli:=oCliente:CLI_NOMBRE
      cDir1  :=oCliente:CLI_DIR1
      cDir2  :=oCliente:CLI_DIR2
      cDir3  :=oCliente:CLI_DIR3
      cTel1  :=oCliente:CLI_TEL1
      nRetIva:=oCliente:CLI_RETIVA
      cEmail :=oCliente:CLI_EMAIL
      cRif   :=oCliente:CLI_RIF
//    ENDIF

    oCliente:End()
/*
    cRif   :=cRif2

    oRif:MsgErr("Cliente "+cRif+CRLF+ALLTRIM(oDp:aRow[2])+" ya Existe","Validación")

    oNombreCli:VarPut(SPACE(80),.T.)
*/

    AEVAL(oDlg:aControls,{|o,n| o:Refresh(.T.) })
    DPFOCUS(oNombreCli)

  ELSE

    DPFOCUS(oNombreCli)

  ENDIF

  IF !EJECUTAR("VALRIFLEN",cRif,oRif,.F.) //,lZero,cNombreCli)
     oRif:MsgErr(oDp:cRifErr,"RIF Inválido")
     DPFOCUS(oRif)
     RETURN .F.
  ENDIF

  DPFOCUS(oNombreCli)

RETURN .T.

FUNCTION VALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.,cRif_:=cRif

  IF !VALRIFCLI(cRif)
      RETURN .F.
  ENDIF

  IF !EJECUTAR("VALRIFLEN",cRif,oRif,.F.) //,lZero,cNombreCli)
     RETURN .F.
  ENDIF

  IF ISDIGIT(cRif)
    // 02/01/2023, cuando el RIF ya existe, agrega 0 innecesario
    // cRif:=STRZERO(VAL(cRif),8)
    // oRif:VarPut(cRif,.T.)
    // ? "LLENAR DE CEROS"
  ENDIF

  // QUITAR ESPACIOS
  cRif:=PADR(STRTRAN(cRif," ",""),LEN(cRif))
  cRif:=UPPER(cRif)

  oRif:VarPut(cRif,.T.)

  oDp:cSeniatErr:=""

  MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
         {|| lOk:=EJECUTAR("VALRIFSENIAT",cRif,!ISDIGIT(cRif),ISDIGIT(cRif)) })

// ? ISDIGIT(cRif),lOk

  IF !lOk .AND. ISDIGIT(cRif)

    MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
            {||lOk:=EJECUTAR("RIFVAUTODET",cRif,oRif)})
   
  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF lOk

     lValRif:=.T.
 
     IF !Empty(oDp:aRif)

       cRif:=oDp:aRif[6]
       oRif:VARPUT(cRif,.T.)  
       oRif:Refresh(.T.)

       oNombreCli:VARPUT(oDp:aRif[1],.T.)
       oRetiva:VARPUT(oDp:aRif[2],.T.)

       DPFOCUS(oNombreCli)

     ENDIF

  ELSE

     lRifVal:=.F.

     cRif:=cRif_
     oRif:VarPut(cRif_,.T.)

     MensajeErr(oDp:cRifErr,"RIF no fué Validado")

  ENDIF

RETURN .T.

FUNCTION VALCODCLA()
   
   IF !ISSQLFIND("DPCLICLA","CLC_CODIGO"+GetWhere("=",cCodCla))
      LISTCLA()
   ENDIF

   oSayCla:Refresh(.T.)

   IF !ISSQLFIND("DPCLICLA","CLC_CODIGO"+GetWhere("=",cCodCla))
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION LISTCLA()
  LOCAL cCodigo,cWhere:="CLC_ACTIVO=1"

  cCodCla:=EJECUTAR("REPBDLIST","DPCLICLA","CLC_CODIGO,CLC_DESCRI",.F.,cWhere,NIL,"Código,Descripción",cCodCla,NIL,NIL,NIL,oCodCla)
  oSayCla:Refresh(.T.)

RETURN .T.


FUNCTION VALCODACT()
   
   IF !ISSQLFIND("DPACTIVIDAD_E","ACT_CODIGO"+GetWhere("=",cCodAct))
      LISTACT()
   ENDIF

   oSayAct:Refresh(.T.)

   IF !ISSQLFIND("DPACTIVIDAD_E","ACT_CODIGO"+GetWhere("=",cCodAct))
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION LISTACT()
  LOCAL cCodigo,cWhere:="ACT_ACTIVO=1"

  cCodAct:=EJECUTAR("REPBDLIST","DPACTIVIDAD_E","ACT_CODIGO,ACT_DESCRI",.F.,cWhere,NIL,"Código,Descripción",cCodAct,NIL,NIL,NIL,oCodAct)
  oSayAct:Refresh(.T.)

RETURN .T.


FUNCTION LISTEDO()
  LOCAL cCodigo,cWhere:="1=1"

  cCodEdo:=EJECUTAR("REPBDLIST","DPESTADOS","ESTADO",.F.,cWhere,NIL,"Estado",cCodEdo,NIL,NIL,NIL,oCodEdo)
  oSayEdo:Refresh(.T.)

RETURN .T.

FUNCTION VALCODEDO()
   
   IF !ISSQLFIND("DPESTADOS","ESTADO"+GetWhere("=",cCodEdo))
      LISTEDO()
   ENDIF

   oSayEdo:Refresh(.T.)

   IF !ISSQLFIND("DPESTADOS","ESTADO"+GetWhere("=",cCodEdo))
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION VALNOMBRE()
  LOCAL lMsg :=.T.
  LOCAL lResp:=EJECUTAR("VALNOMBRE",cNombreCli,oNombreCli,cRif,lMsg)

  DPFOCUS(oDir1)

RETURN .T.
// 



