// Programa   : DPCLIENTESPER
// Fecha/Hora : 26/01/2005 23:10:42
// Propósito  : Personal del Cliente
// Creado Por : Juan Navas
// Llamado por: Clientes
// Aplicación : Ventas
// Tabla      : DPCLIENTESPER

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,cDescri)
  LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,,oFont,oFontB,cTitle:=""
  LOCAL aTipos:=GETOPTIONS("DPCLIENTESPER","PDC_TIPO")
  LOCAL cWhere,oDpLbx

  DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

  oDpLbx:=GetDpLbx(oDp:nNumLbx)

// oDp:lTracer:=.T.

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)<>"A"
     oDpLbx:aCargo:=oDp:aCargo
  ENDIF

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)="A" .AND. Empty(cCodCli)
     cCodCli:=oDpLbx:aCargo[1] // Código
  ENDIF

  // Font Para el Browse
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12

  IF Empty(aTipos) 
     aTipos:={"Trabajador","Representante","Socio","Externo"}
  ENDIF

  cTitle:=GetFromVar("{oDp:DPCLIENTESPER}")

  oDpCliPer:=DOCENC(cTitle,"oDpCliPer","DPCLIENTESPER.EDT")
  oDpCliPer:cCodCli :=cCodCli
  oDpCliPer:nBtnStyle:=1

  oDpCliPer:lBar:=.F.
  oDpCliPer:lAutoEdit:=.T.
  oDpCliPer:SetTable("DPCLIENTES","CLI_CODIGO"," WHERE CLI_CODIGO"+GetWhere("=",cCodCli))


  oDpCliPer:Windows(0,0,410,755+110+190) // 27.5-2,95.5)
/*
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT oDp:DPCLIENTES+" [ "+ALLTRIM(oDpCliPer:CLI_CODIGO)+" ]"
  @ 2,5 SAY oCLI_DESCRI PROMPT oDpCliPer:CLI_NOMBRE
*/
  cSql  :=" SELECT * FROM DPCLIENTESPER"
  cWhere:=""

  oGrid:=oDpCliPer:GridEdit( "DPCLIENTESPER" , oDpCliPer:cPrimary , "PDC_CODIGO" , cSql , cWhere , "PDC_CARGO" ) 

  oGrid:cScript  :="DPCLIENTESPER"
// oGrid:aSize    :={110-26+20,0,765+90+190,160+80}
  oGrid:GRIDGETSIZE(110-26+20-56,0,765+90+190,160+80)

  oGrid:oFont    :=oFont
  oGrid:oFontH   :=oFontB
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.T.
  oGrid:nClrPane1:=oDp:nClrPane1
  oGrid:nClrPane2:=oDp:nClrPane2
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH

  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
  oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:cPrint   :="GRIDPRINT"
  oGrid:lPrint   :=.T.
  oGrid:SetMemo("PDC_MEMO","Descripción Amplia",1,1,100,200)

  oGrid:AddBtn("word.bmp","Emitir Carta","oGrid:nOption=0",;
                [EJECUTAR("DPCLIWORD",oDpCliPer:cCodCli, oGrid:PDC_PERSON)])

  oGrid:AddBtn("EMAIL.BMP","Correspondencia","oGrid:nOption=0",;
                [EJECUTAR("BLAT",oDpCliPer:cCodCli)])

//  AADD(aBtn,{"Cartas","WORD.BMP"	,"CLIWORD"    })

  oCol:=oGrid:AddCol("PDC_PERSON")
  oCol:cTitle   :="Apellidos y Nombre"
  oCol:bValid   :={||!Empty(oGrid:PDC_PERSON)}
  oCol:cMsgValid:="Persona no puede estar Vacio"
  oCol:nWidth   :=180
  oCol:lPrimary :=.T. // No puede Repetirse
  oCol:lRepeat  :=.F.

  // Cargo
  oCol:=oGrid:AddCol("PDC_CARGO")
  oCol:cTitle   :="Cargo"
  oCol:bValid   :={||oGrid:VPDC_CARGO(oGrid:PDC_CARGO)}
  oCol:cMsgValid:="Cargo no Existe"
  oCol:nWidth   :=170
  oCol:cListBox :="DPCARGOS.LBX"
  oCol:lPrimary :=.F. // No puede Repetirse
  oCol:lRepeat  :=.T.
  //oCol:cListBox :={|oCol,uValue|EJECUTAR("DPCARGOS",uValue,oCol)}
  oCol:nEditType:=EDIT_GET_BUTTON

  oCol:=oGrid:AddCol("PDC_TIPO")
  oCol:cTitle   :="Relación"
  oCol:nWidth   :=80
  oCol:bValid   :={||.T.}
  oCol:lRepeat  :=.T.
  oCol:aItems    :=ACLONE(aTipos)
  oCol:aItemsData:=ACLONE(aTipos)

  oCol:=oGrid:AddCol("PDC_EXTENS")
  oCol:cTitle   :="Ext."
  oCol:nWidth   :=040

  oCol:=oGrid:AddCol("PDC_TELEFO")
  oCol:cTitle   :="Celular"
  oCol:nWidth   :=085

/*
  oCol:=oGrid:AddCol("PDC_PIN")
  oCol:cTitle   :="PIN"
  oCol:nWidth   :=065
*/

  oCol:=oGrid:AddCol("PDC_EMAIL")
  oCol:cTitle   :="E-mail"
  oCol:nWidth   :=180
  oCol:bValid   :={||oGrid:VALEMAAIL(oGrid:PDC_EMAIL)}

  oCol:=oGrid:AddCol("PDC_COMENT")
  oCol:cTitle   :="Comentario"
//FIELDLABEL("DPCLIENTESPER","PDC_COMENT")
  oCol:nWidth   :=180

//  IF EJECUTAR("ISFIELDMYSQL",NIL,"DPCLIENTESPER","PDC_COMEN2",.T.)
//    oCol:=oGrid:AddCol("PDC_COMEN2")
//    oCol:cTitle   :=FIELDLABEL("DPCLIENTESPER","PDC_COMEN2")
//    oCol:nWidth   :=180
//  ENDIF


//  oCol:bValid   :={||oGrid:VALEMAAIL(oGrid:PDC_EMAIL)}

// oCol:cMsgValid:="Correo Inválido"

  oDpCliPer:oFocus:=oGrid:oBrw
  oDpCliPer:SetOpenSize() 
  oDpCliPer:Activate()

RETURN

/*
// Carga los Datos
*/
FUNCTION LOAD()
  LOCAL oFontB

  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oDpCliPer:oBar:SetSize(NIL,50,.T.)

  @ 0.0,40 SAY " "+ALLTRIM(oDpCliPer:CLI_CODIGO)+" " OF oDpCliPer:oBar;
           FONT oFontB BORDER;
           SIZE 100,20  COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ 1.4,40 SAY oCLI_DESCRI PROMPT " "+oDpCliPer:CLI_NOMBRE OF oDpCliPer:oBar;
           FONT oFontB BORDER;
           SIZE 400,20  COLOR oDp:nClrYellowText,oDp:nClrYellow
 
RETURN .T.

/*
// Carga de data del Grid
*/
FUNCTION GRIDLOAD()
   LOCAL cCargo:=""

   IF oGrid:nOption=1

     IF oGrid:RecCount()=1 // Primero
       cCargo:=SqlGetMin("DPCARGOS","CAR_CODIGO")
     ELSE
       cCargo:=oGrid:oBrw:aArrayData[Len(oGrid:oBrw:aArrayData)-1,1]
       cCargo:=SqlGetMin("DPCARGOS","CAR_CODIGO","CAR_CODIGO"+GetWhere(">",cCargo))
     ENDIF

     oGrid:Replace("PDC_CARGO",cCargo,.T.)
     oGrid:PDC_ACTIVO:=.T.

   ENDIF

   oGrid:Set("PDC_FECHA",oDp:dFecha)

RETURN .T.

/*
// Pregrabar del Grid
*/
FUNCTION GRIDPRESAVE()

  oGrid:PDC_CODIGO:=oDpCliPer:cCodCli
  oGrid:Set("PDC_FECHA",oDp:dFecha)

RETURN .T.

/*
// Ejecuta la Impresión del Documento
*/
FUNCTION GRIDPRINT()
   LOCAL oRep

   oRep:=REPORTE("DPCLIPERSO")
   oRep:SetRango(1,oDpCliPer:cCodCli,oDpCliPer:cCodCli)

RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION PREDELETE()
RETURN .T.

/*
// Después de Borrar
*/
FUNCTION POSTDELETE()
RETURN .T.

/*
// Valida el Código
*/
FUNCTION VPDC_CARGO(cCargo)
  LOCAL lRet

  lRet:=(cCargo==SQLGET("DPCARGOS","CAR_CODIGO","CAR_CODIGO"+GetWhere("=",cCargo)))

RETURN lRet

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()

  SQLUPDATE("DPCLIENTESPER","PDC_FECHA",oDp:dFecha,"PDC_CODIGO"+GetWhere("=",oDpCliPer:cCodCli)+" AND PDC_PERSON"+GetWhere("=",oGrid:PDC_PERSON))

RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
RETURN .T.

FUNCTION GRIDSETSCOPE()
   LOCAL cWhere
RETURN .T.

FUNCTION VALEMAAIL(cMail)
  LOCAL lResp:=.t.

  EJECUTAR("EMAILVALID",cMail)

  IF !EMpty(oDp:cMail)
     oGrid:MensajeErr(oDp:cMail)
     lResp:=.f.
  ENDIF

RETURN lResp

// EOF






