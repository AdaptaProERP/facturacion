// Programa   : DPCREACLICLINICO
// Fecha/Hora : 13/05/2011 01:28:31
// Propósito  : Creación Rápida del Cliente (Herramienta para Contadores)
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(_oGet,_cRif,_lAuto,cCodAct,cCodCla,cCodEdo)
  LOCAL oDlg,oFont,oFontB,oGroup,oBtn,aSay:={},I,oSay,nLine,cRif
  LOCAL lOk:=.F.
  LOCAL nWidth   :=390+60+40, nHeight:=310
  LOCAL aPoint   :=IF(_oGet=NIL , NIL , AdjustWnd( _oGet, nWidth, nHeight ))

  LOCAL oGet:=_oGet,lAuto:=_lAuto
  LOCAL oDir1,oDir2,oDir3,oTel1,oEmail,oRepres,oCI
  LOCAL oBtn2,oBtn2
  LOCAL oCliente,cCodigo,oFocus

  LOCAL lExiste:=.F.
  LOCAL lValRif:=.F

  LOCAL oRif,oNombre,oRetIva
  LOCAL cNombre  :=SPACE(80)
  LOCAL cDir1    :=SPACE(40)
  LOCAL cDir2    :=SPACE(40)
  LOCAL cDir3    :=SPACE(40)
  LOCAL cTel1    :=SPACE(20)
  LOCAL cEmail   :=SPACE(80)
  LOCAL cPaciente:=SPACE(120)
  LOCAL cCI      :=SPACE(10)
  LOCAL dFchNac  :=CTOD(""),oFchNac
  LOCAL cSexo    :="Femenino",oSexo

  LOCAL nRetIva:=0
  LOCAL cRif_
  LOCAL oCodAct,oSayAct
  LOCAL oCodCla,oSayCla
  LOCAL oCodEdo,oSayEdo


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
    _lAuto  :=.T.
    oCliente:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_RIF"+GetWhere("=",_cRif),.T.)

    IF oCliente:RecCount()>0  
      cCodigo:=oCliente:CLI_CODIGO
      cCodCla:=oCliente:CLI_CODCLA
      cCodAct:=oCliente:CLI_ACTIVI
      cCodEdo:=oCliente:CLI_ESTADO
      cCodVen:=oCliente:CLI_CODVEN
      cNombre:=oCliente:CLI_NOMBRE
      cDir1  :=oCliente:CLI_DIR1
      cDir2  :=oCliente:CLI_DIR2
      cDir3  :=oCliente:CLI_DIR3
      cTel1  :=oCliente:CLI_TEL1
      nRetIva:=oCliente:CLI_RETIVA
      cEmail :=oCliente:CLI_EMAIL
      cRif   :=oCliente:CLI_RIF
      dFchNac:=oCliente:CLI_FCHINI
      cSexo  :=oCliente:CLI_SEXO

    ENDIF

    oCliente:End()

    IF !Empty(cCodigo)
 
      oCliente:=Opentable("SELECT * FROM DPCLIENTESREC WHERE CRC_CODCLI"+GetWhere("=",cCodigo),.T.,oDp:oDbLic)
      cPaciente :=oCliente:CRC_NOMBRE
      cCI     :=oCliente:CRC_CODIGO
      oCliente:End()

    ENDIF

  ENDIF

  AADD(aSay,{"RIF :"        ,NIL})
  AADD(aSay,{"Nombre :"       ,NIL})
  AADD(aSay,{"Dirección :"  ,NIL})
//  AADD(aSay,{"          2:"  ,NIL})
//  AADD(aSay,{"          3:"  ,NIL})
  AADD(aSay,{"Teléfono:"     ,NIL})
  AADD(aSay,{"Correo :"     ,NIL})
  AADD(aSay,{"Paciente:"     ,NIL})
  AADD(aSay,{"Cédula :"     ,NIL})
  AADD(aSay,{"Fecha Nac :"    ,NIL})
  AADD(aSay,{"Sexo :"     ,NIL})

//AADD(aSay,{"Clasificación:",NIL})
//AADD(aSay,{"Act.Económica:",NIL})
//AADD(aSay,{"Estado Ubicac:",NIL})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-10
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0,-12 BOLD

  IF aPoint=NIL

     DEFINE DIALOG oDlg;
            TITLE "Creación Rápida de "+oDp:xDPCLIENTES;
            FROM 0,0 TO 18+06-5,47+5;
            COLOR NIL,oDp:nGris
  ELSE

     DEFINE DIALOG oDlg;
            TITLE "Creación Rápida de "+oDp:xDPCLIENTES;
            PIXEL OF oGet:oWnd;
            STYLE nOr( DS_SYSMODAL, DS_MODALFRAME );
            COLOR NIL,oDp:nGris


  ENDIF

  oDlg:lHelpIcon:=.F.

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

  oFocus:=oRif


//  oRif:bkeyDown:={|nKey| IIF( nKey=13 .AND. VALRIFCLI(cRif,oRif), IF(!lExiste,VALRIF(cRif,oRif),NIL) , NIL )}

  oRif:bkeyDown:={|nKey| IIF( nKey=13 .AND. VALRIFCLI(cRif,oRif), NIL)}

/*

  @ aSay[1,2],91+1 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION VALRIF(cRif,oRif);
                 FONT oFontB;
                 WHEN !Empty(cRif) PIXEL FONT oFontB

*/
  @ aSay[2,2],50 GET oNombre VAR cNombre;
                 VALID !Empty(cNombre);
                 SIZE 120,10;
                 COLOR NIL,CLR_WHITE PIXEL FONT oFontB

  IF !Empty(cRif)
    oFocus:=oNombre
  ENDIF



  @ aSay[3,2],50 GET oDir1 VAR cDir1;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB
/*
  @ aSay[4,2],50 GET oDir2 VAR cDir2;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[5,2],50 GET oDir3 VAR cDir3;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB
*/

  @ aSay[4,2],50 GET oTel1 VAR cTel1;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[5,2],50 GET oEmail VAR cEmail;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[6,2],50 GET oRepres VAR cPaciente;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[7,2],50 GET oCI VAR cCI;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[8,2],50 GET oFchNac VAR dFchNac PICTURE "99/99/9999";
                 COLOR NIL,CLR_WHITE;
                 SIZE 45,10 PIXEL FONT oFontB

  @ aSay[9,2],50 COMBOBOX oSexo  VAR cSexo ITEMS {"Femenino","Masculino"};
                 COLOR NIL,CLR_WHITE;
                 SIZE 45,10 PIXEL FONT oFontB

/*	
  @ aSay[13,2],86 BUTTON oBtn PROMPT ">" SIZE 10,10 ACTION LISTEDO();
                  FONT oFontB;
                  WHEN 1=1 PIXEL FONT oFontB

*/
  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0,-16 BOLD

  @ 6.5+2.5+.5-3,17+2 BUTTON " Aceptar ";
             SIZE 37,14;
             FONT oFontB;
             ACTION (lOk:=CLIGRABAR(cRif) ,;
                 IF(lOk,oDlg:End(),NIL))

  @ 6.5+2.5+.5-3,23+3 BUTTON " Salir   ";
             SIZE 37,14;
             FONT oFontB;
             ACTION (lOk:=.F.,oDlg:End()) CANCEL

  IF aPoint=NIL

    ACTIVATE DIALOG oDlg CENTERED

  ELSE

    DPFOCUS(oFocus)

    ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(aPoint[1], aPoint[2],NIL,NIL,.T.),;
                                  oDlg:SetSize(nWidth+25,nHeight+30),;
                                  IF(_lAuto,oRif:KeyBoard(13),NIL),;
                                  DPFOCUS(oFocus))

//                              IIF(_lAuto,oRif:KeyBoard(13),NIL))


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

   IF Empty(cNombre)
      oNombre:MsgErr("Es necesario el Nombre")
      RETURN .F.
   ENDIF

   IF Empty(cCodCla)
     cCodCla:=SQLGET("DPCLICLA"     ,"CLC_CODIGO",NIL,NIL,oDp:oDbLic)
   ENDIF

   IF Empty(cCodAct)
     cCodAct:=SQLGET("DPACTIVIDAD_E","ACT_CODIGO",NIL,NIL,oDp:oDbLic)
   ENDIF

   // Vendedor Indefinido
   cCodVen:=STRZERO(0,6) // SQLGET("DPVENDEDOR"   ,"VEN_CODIGO",NIL,NIL,oDp:oDbLic)

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
   oTable:Replace("CLI_NOMBRE" ,cNombre       )
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
   oTable:Replace("CLI_FCHINI" ,dFchNac)
   oTable:Replace("CLI_SEXO"   ,cSexo  )

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

   IF !Empty(cPaciente)

     oTable:=Opentable("SELECT * FROM DPCLIENTESREC WHERE CRC_CODCLI"+GetWhere("=",cCodigo)+" AND "+;
                                                         "CRC_CODIGO"+GetWhere("=",cCI    ),.T.,oDp:oDbLic)

     oTable:SetForeignkeyOff()

     IF oTable:RecCount()=0
       oTable:AppendBlank()
       oTable:cWhere:=""
     ENDIF

     oTable:Replace("CRC_CODCLI" ,cCodigo   )
     oTable:Replace("CRC_TIPO"   ,"Paciente")
     oTable:Replace("CRC_NOMBRE" ,cPaciente   )
     oTable:Replace("CRC_CODIGO" ,cCI       )
     oTable:Replace("CRC_SEXO"   ,cSexo     )
     oTable:Replace("CRC_FCHINI" ,dFchNac   )
     oTable:Commit(oTable:cWhere)
     oTable:End()

  ENDIF

RETURN .T.

/*
// Function Innecesaria
*/
FUNCTION XVALRIF(cRif,oRif)
  //LOCAL oDp:aRif:={},lOk:=.T.,cRif_:=cRif,lView:=.F.
  LOCAL lOK,lView:=.F.

  IF !VALRIFCLI(cRif)
      RETURN .F.
  ENDIF

  IF ISDIGIT(cRif)
    // 02/01/2023
    // cRif:=STRZERO(VAL(cRif),8)
    // oRif:VarPut(cRif,.T.)
  ENDIF

  // QUITAR ESPACIOS
  cRif:=PADR(STRTRAN(cRif," ",""),LEN(cRif))
  cRif:=UPPER(cRif)

  oRif:VarPut(cRif,.T.)

  oDp:cSeniatErr:=""

/////////////////////////

  MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
         {|| lOk:=RUNLIC("VALRIFSENIAT",cRif,NIL,!ISDIGIT(cRif),lView)})


  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF !lOk .AND. ISDIGIT(cRif)

    MsgRun("Autodectando RIF "+cRif+" no Encontrado","Por favor espere..",;
           {||lOk:=RUNLIC("RIFVAUTODET",cRif,oRif) })

  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF lOk

     lValRif:=.T.

     IF !Empty(oDp:aRif)

       cRif:=oDp:aRif[6]
       oRif:VARPUT(cRif,.T.)
       oRif:Refresh(.T.)

       oNombre:VARPUT(oDp:aRif[1],.T.)
       oRetiva:VARPUT(oDp:aRif[2],.T.)

       DPFOCUS(oDir1)

     ENDIF

  ELSE

     //lRifVal:=.F.

     cRif:=cRif_
     //oRif:VarPut(cRif_,.T.)

     MensajeErr(oDp:cRifErr,"RIF no fué Validado")

  ENDIF

RETURN .T.

FUNCTION VALRIFCLI(cRif)

  LOCAL cRif2:=""
  
  IF Empty(cRif)
     RETURN .F.
  ENDIF
/*
  IF !ISSQLFIND("DPPROVEEDOR","PRO_RIF"+GetWhere("=",cRif))

     oRif:VarPut(SPACE(10),.T.)
     oNombre:VarPut(PADR("Proveedor no Encontrado",80),.T.)

     DPFOCUS(oRif)

     RETURN .F.

  ENDIF
*/
  cRif2:=SQLGET("DPPROVEEDOR","PRO_RIF,PRO_NOMBRE","PRO_RIF"+GetWhere(" LIKE ","%"+ALLTRIM(cRif)+"%"))

  IF !Empty(cRif2)

    cRif   :=cRif2

    oRif:MsgErr("Cliente "+cRif+CRLF+ALLTRIM(oDp:aRow[2])+" ya Existe","Validación")

//    cRif:=SPACE(10)
//    oRif:VarPut(cRif        ,.T.)
//    oRif:VarPut(cRif        ,.T.)
    oNombre:VarPut(SPACE(80),.T.)

    DPFOCUS(oRif)

  ELSE

    DPFOCUS(oNombre)

  ENDIF

RETURN .T.

FUNCTION VALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.,cRif_:=cRif

  IF !VALRIFCLI(cRif)
      RETURN .F.
  ENDIF

/*
// 14/09/2022
  IF !oDp:lAutRif
     RETURN .T.
  ENDIF
*/

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

// ? lOk,"Encontrado"

  IF lOk

     lValRif:=.T.
 
     IF !Empty(oDp:aRif)

       cRif:=oDp:aRif[6]
       oRif:VARPUT(cRif,.T.)  
       oRif:Refresh(.T.)

       oNombre:VARPUT(oDp:aRif[1],.T.)
       oRetiva:VARPUT(oDp:aRif[2],.T.)


       // cPersona:=oDp:aRif[3]
       // oProvee:cMemoRif:=oDp:aRif[4]

       // Código es RIF
//       IF oDp:lRifPro
//         oProvee:oPRO_CODIGO:VarPut(oProvee:cRif,.T.)
//       ENDIF

       // Contribuyente
//       IF !oProvee:ValUnique(oProvee:cRif,"cRif")
//         DPFOCUS(oProvee:oPRO_RIF)
//         RETURN .F.
//       ENDIF

         DPFOCUS(oNombre)

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



// 

