// Programa   : DPCLIENTES
// Fecha/Hora : 05/03/2005 11:41:49
// Propósito  : Edición del Formulario de DPCLIENTES
// Creado Por : DpXbase
// Llamado por: DPCLIENTES.LBX
// Aplicación : Ventas y Cuentas Por Cobrar             
// Tabla      : DPCLIENTES
// Modificacion: Se agrego validacion del RIF con mascara !-99999999-9, la cual
// "!" son letras y solo acepta J,V,G,E o P. Realizado Leonardo Palleschi Revisado (TJ)

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION MAIN(nOption,cCodigo,oDb,nModoFrm,cCatego)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL oBrw,cSqlCuerpo,oCuerpo,oCol,oCursorC,bInit
  LOCAL cTitle :="Clientes",nAt
  LOCAL cFilScg:="FORMS\DPCLIENTES_DATGET.SCG"

  cExcluye:="CLI_CODIGO, CLI_NOMBRE, CLI_RIF"

  DEFAULT cCodigo     :="",;
          nOption     :=0,;
          oDp:DPCLICLA:=COUNT("DPCLICLA"),;
          cCatego     :=""

  DEFAULT oDb:=GETDBSERVER()

  DEFAULT nModoFrm:=0

  IF EMPTY(oDp:DPCLICLA)
     EJECUTAR("DPDATACREA")
  ENDIF

  EJECUTAR("DPRUTAINDEF")

//  oDp:lOpenTableChk:=.F. // Quitar
//  oDp:cFileToScr:="C:\X\VALRIF.TXT"
//  ferase(oDp:cFileToScr)

  DEFAULT oDp:lRifCli:=.F.

  IF EMPTY(oDp:cModeVideo)
    DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -12 BOLD
    DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD 
    DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -12
  ELSE
    DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -14 BOLD
    DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -14 BOLD 
    DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -14
  ENDIF

  nClrText:=10485760 // Color del texto

  cTitle   :=" {oDp:DPCLIENTES}" 

  IF !Empty(cCatego)
     cTitle:=cCatego
  ENDIF

  cSql  :="SELECT * FROM DPCLIENTES WHERE "+IIF(Empty(cCodigo)," 1=0 ",;
          "CLI_CODIGO"+GetWhere("=",cCodigo))

  oTable:=OpenTable(cSql,!Empty(cCodigo),oDb) 


//  cTitle   :=cTitle+ oTable:CLI_CODIGO


//oTable:Browse()

  oTable:cPrimary:="CLI_CODIGO"                        // Clave de Validación de Registro

  oCLIENTES:=DPEDIT():New(cTitle,"DPCLIENTES"+oDp:cModeVideo+".edt","oCLIENTES" , .F. )

  oCLIENTES:lDlg     :=.T.                              // Formulario Sin Dialog
  oCLIENTES:nMode    :=1                                // Formulario Tipo de Documento
  oCLIENTES:nOption  :=nOption
  oCLIENTES:nOpcIni  :=nOption   
  oCLIENTES:cPersona :=""
  oCLIENTES:cMemoRif :=""
  oCLIENTES:nRetIva  := 0                               // % Retención de IVA
  oClientes:lValRif  :=.T.
  oCLIENTES:oScroll  :=NIL
  oClientes:lValRifOn:=.F.
  oCLIENTES:nModoFrm :=nModoFrm
  oCLIENTES:cCatego  :=cCatego


  IF (nOption=3 .OR. nOption=1) .AND. !Empty(cCodigo) 
    oCLIENTES:cScope:="CLI_CODIGO"+GetWhere("=",cCodigo)
  ENDIF

  oCLIENTES:SetTable( oTable , .F. )                  // Asocia la tabla <cTabla> con el formulario oCLIENTES
  oCLIENTES:SetScript()                               // Asigna Funciones DpXbase como Metodos de oCLIENTES
  oCLIENTES:SetDefault()                              // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCLIENTES:SetMemo("CLI_NUMMEM")                     // Campo para el Valor Memo

  IF DPVERSION()>4
    oCLIENTES:SetAdjuntos("CLI_FILMAI")                 // Vinculo con DPFILEEMP
  ENDIF

  oCLIENTES:nBtnWidth:=40
  oCLIENTES:cBtnList :="xbrowse2.bmp"
  oCLIENTES:BtnSetMnu("BROWSE","Buscar Nombre por Palabras"    ,"BRWCLIENTES","xbrowse2.bmp")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Buscar por Campos"             ,"BRWCLIENTES")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Opciones por Campos"           ,"BRWCLIENTES","MENUOPCCAMPO")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Por Nombre, Teléfono y correo" ,"BRWCLIENTES")
  oCLIENTES:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPVENDEDOR   ,"BRWCLIENTES")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPACTIVIDAD_E,"BRWCLIENTES")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPCLICLA     ,"BRWCLIENTES")  // Agregar Menú en Barra de Botones
  oCLIENTES:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPCTA        ,"BRWCLIENTES")  // Cuentas Contables

// ,[oCLIENTES:BUSCARXNOMBRE()],[oCLIENTES:nOption=0 .OR. oCLIENTES:nOption=4])


  oCLIENTES:CLI_RIF:=STRTRAN(oCLIENTES:CLI_RIF,"-","")
  oCLIENTES:SetBmp("CLI_FILBMP" )                     // Asignación de Imagen
//  oCLIENTES:OpcButtons("Buscar Cliente por Nombre, Teléfono y correo","XFINDPRG.BMP"   ,[oCLIENTES:BUSCARXNOMBRE()],[oCLIENTES:nOption=0 .OR. oCLIENTES:nOption=4])
  oCLIENTES:OpcButtons("Personal del Cliente","XPERSONAL.BMP"   ,[EJECUTAR("DPCLIENTESPER",oCLIENTES:CLI_CODIGO)])

  IF oDp:cIdApl$"93"
   oCLIENTES:OpcButtons("Expedientes"         ,"XEXPEDIENTE.BMP" ,[oCLIENTES:EXPEDIENTES()])
   oCLIENTES:OpcButtons("Entrevistas"         ,"XENTREVISTA.BMP" ,[oCLIENTES:ENTREVISTA()])
   oCLIENTES:OpcButtons("Asociados  "         ,"LINK.BMP"  ,[EJECUTAR("DPCLIASOC"   ,oCLIENTES:CLI_CODIGO)])
   oCLIENTES:OpcButtons("Definir Facturación Periódica","FACTURAPER.BMP",[oCLIENTES:FACTURAPER()])
  ENDIF

  IF !oDp:cIdApl$"1"
    oCLIENTES:OpcButtons("Cuentas Contables"   ,"CONTABILIDAD.BMP",[EJECUTAR("DPCLIENTECTA",oCLIENTES:CLI_CODIGO)])
  ENDIF

  oCLIENTES:OpcButtons("Menú de Opciones"         ,"MENU.BMP"          ,[EJECUTAR("DPCLIENTESMNU",oCLIENTES:CLI_CODIGO)])
  oCLIENTES:OpcButtons("Registrar Cheque Devuelto","chequedevuelto.bmp",[EJECUTAR("DPCHQDEVCLI"  ,oCLIENTES:CLI_CODIGO)])

  IF oDp:cIdApl$"93" .AND. oDp:nVersion>5.0
    oCLIENTES:OpcButtons("Correspondencia en HTML","HTML.bmp",[EJECUTAR("BRCLIEMAIL",NIL,oCLIENTES:CLI_CODIGO)])
  ENDIF

  oCLIENTES:OpcButtons("Menú de Transacciones","MENUTRANSACCIONES.BMP",[EJECUTAR("DPCLIENTESMNUTRAN",oCLIENTES:CLI_CODIGO)],[oCLIENTES:nOption=0 ])

//  oCLIENTES:OpcButtons("Consultar en Seniat" ,"RETIVA.BMP"     ,;
//  [SHELLEXECUTE(oDp:oFrameDp:hWND,"open","http://www.seniat.gov.ve/BuscaRif/BuscaRif.jsp?p_rif="+ALLTRIM(STRTRAN(oCLIENTES:CLI_RIF,"-","")))])

  IF oDp:lVen

//    oCLIENTES:OpcButtons("Consultar RIF en www.Seniat.gob.ve"   ,"RETIVA.BMP"     ,;
//              [EJECUTAR("VIEWRIFSENIAT",oCLIENTES:CLI_RIF,"DPCLIENTES",oCLIENTES:CLI_FILMAI)])

    oCLIENTES:OpcButtons("Actualizar Datos Tributarios desde www.Seniat.gob.ve"   ,"RETIVA.BMP"     ,;
                [oCLIENTES:VALRIF()])

  ENDIF

  oCLIENTES:cList:="DPCLIENTES.BRW"                  // Visualizar Clientes
  oCLIENTES:cView:="DPCLIENTESCON()"                   // Programa Consulta
  oClientes:cScopeOrg:=oClientes:cScope
  oCLIENTES:cCodCli:=oCLIENTES:CLI_CODIGO


  oClientes:CLI_CUENTA:=EJECUTAR("DPGETCTAMOD","DPCLIENTES_CTA",oClientes:CLI_CODIGO,"","CUENTA")

  //Tablas Relacionadas con los Controles del Formulario

  oCLIENTES:CreateWindow() 


  oCLIENTES:ViewTable("DPCTA"     ,"CTA_DESCRI","CTA_CODIGO","CLI_CUENTA")



  // Presenta la Ventana
  // Opciones del Formulario

  // Campo : CLI_CODIGO
  // Uso   : Código                                  
  @ 3.0, 1.0 GET oCLIENTES:oCLI_CODIGO  VAR oCLIENTES:CLI_CODIGO PICTURE "@!";
                  VALID CERO(oCLIENTES:CLI_CODIGO) ;
                  .AND. oCLIENTES:ValUnique(oCLIENTES:CLI_CODIGO);
                  .AND. !VACIO(oCLIENTES:CLI_CODIGO,NIL);
                  .AND. oCLIENTES:ValCodigo(oCLIENTES:CLI_CODIGO);
             WHEN (AccessField("DPCLIENTES","CLI_CODIGO",oCLIENTES:nOption);
                  .AND. oCLIENTES:nOption!=0 .AND. (!oDp:lRifCli .OR. oCLIENTES:CLI_RESIDE="N"));
             FONT oFontG

  oCLIENTES:oCLI_CODIGO:cMsg    :="Código"
  oCLIENTES:oCLI_CODIGO:cToolTip:="Código"

  @ 0,0 SAY "Código" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  // Campo : CLI_RIF   
  // Uso   : Número de Rif.                          
  //         PICTURE "!-99999999-9";
  //
  @ 6.6, 1.0 GET oCLIENTES:oCLI_RIF VAR oCLIENTES:CLI_RIF PICTURE "@!";
             VALID !Empty(oCLIENTES:CLI_RIF)  .AND. oCLIENTES:ValUnique(oCLIENTES:CLI_RIF,"CLI_RIF");
                   .AND. oCLIENTES:VAL_RIF();
             WHEN (AccessField("DPCLIENTES","CLI_RIF",oCLIENTES:nOption) .AND. oCLIENTES:nOption!=0);
                   .AND. !oCLIENTES:CLI_CODIGO=STRZERO(0,10) .AND. !oCLIENTES:CLI_RESIDE="N"

    oCLIENTES:oCLI_RIF   :cMsg    :="Número de "+oDp:cNit
    oCLIENTES:oCLI_RIF   :cToolTip:="Número de "+oDp:cNit

  @ oCLIENTES:oCLI_RIF:nTop-08,oCLIENTES:oCLI_RIF   :nLeft SAY oDp:cNit PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

//  oCLIENTES:oCLI_RIF:bkeyDown:={|nkey| IIF(nkey=13, oCLIENTES:CLIFINDCED(),NIL )}



  // Campo : CLI_NOMBRE
  // Uso   : Nombre         // se quito  .AND. oCLIENTES:VAL_NOMBRE()                         
  @ 4.8, 1.0 GET oCLIENTES:oCLI_NOMBRE  VAR oCLIENTES:CLI_NOMBRE ;
             VALID  !VACIO(oCLIENTES:CLI_NOMBRE,NIL);
             WHEN (AccessField("DPCLIENTES","CLI_NOMBRE",oCLIENTES:nOption) .AND. oCLIENTES:nOption!=0);
             FONT oFontG PICTURE "@!"

    oCLIENTES:oCLI_NOMBRE:cMsg    :="Nombre"
    oCLIENTES:oCLI_NOMBRE:cToolTip:="Nombre"

  @ oCLIENTES:oCLI_NOMBRE:nTop-08,oCLIENTES:oCLI_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  @ 30,1  BUTTON oCLIENTES:oBtnRif PROMPT " > " PIXEL;
                                   ACTION (oClientes:lValRifOn:=.T.,;
                                           oCLIENTES:VALRIF()) CANCEL;
                                   WHEN !Empty(oCLIENTES:CLI_RIF) .AND. DPVERSION()>=4;
                                   .AND. !(oCLIENTES:CLI_CODIGO=STRZERO(0,10))

  oCLIENTES:oBtnRif:cMsg    :="Validar "+oDp:cNit
  oCLIENTES:oBtnRif:cToolTip:="Validar "+oDp:cNit


  @ 10, 0 FOLDER oCLIENTES:oFolder ITEMS "Datos General","Jurídicos y Tributarios","Comerciales","Contable";
          OF oCLIENTES:oDlg SIZE 952,248

  SETFOLDER( 1)

  IF nModoFrm=1 .OR. nModoFrm=2
    oCLIENTES:oFolder:aEnable[2]:=.F.
    oCLIENTES:oFolder:aEnable[3]:=.F.
    oCLIENTES:oFolder:aEnable[4]:=.F.
    cFilScg  :="FORMS\DPCLIENTES_DATBAS.SCG"
  ENDIF

  IF "INQUI"$cCatego
     cFilScg:="FORMS\CNDCONDOMINIOS_DATGET.SCG"
  ENDIF

  oCLIENTES:oScroll:=oCLIENTES:SCROLLGET("DPCLIENTES",cFilScg,cExcluye,,,,0)

IF !oCLIENTES:oScroll=NIL

  // Remover Seniat
  IF !oDp:lVen
     AEVAL(oCLIENTES:oScroll:aView,{|a,n| oCLIENTES:oScroll:aView[n,1]:=STRTRAN(a[1],"SENIAT","")})
  ENDIF

  IF oCLIENTES:IsDef("oScroll")
    oCLIENTES:oScroll:SetEdit(oCLIENTES:nOption>0)
  ENDIF

 // oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
 // oGrid:nClrTextH   :=0 


  oClientes:oScroll:SetColSize(250,290+75+95,240)
  oClientes:oScroll:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFont) 

  oClientes:oScroll:SetColor(oDp:nClrPane1,oDp:nClrDPCLIENTES,1,oDp:nClrPane2,oFontB) 
  oClientes:oScroll:SetColor(oDp:nClrPane1,0,2,oDp:nClrPane2,oFont ) 
  oClientes:oScroll:SetColor(oDp:nClrPane1,0,3,oDp:nClrPane2,oFontB) 

ENDIF

  SETFOLDER(2)
  oCLIENTES:oScroll2:=oCLIENTES:SCROLLGET("DPCLIENTES","DPCLIENTES_DATJUD.SCG",cExcluye,,,,0)

IF !oCLIENTES:oScroll2=NIL

  oClientes:oScroll2:SetColSize(250+30,290+75+95-30,240)
  oClientes:oScroll2:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFont) 

  oClientes:oScroll2:SetColor(oDp:nClrPane1,oDp:nClrDPCLIENTES,1,oDp:nClrPane2,oFontB) 
  oClientes:oScroll2:SetColor(oDp:nClrPane1,0,2,oDp:nClrPane2,oFont ) 
  oClientes:oScroll2:SetColor(oDp:nClrPane1,0,3,oDp:nClrPane2,oFontB)

  IF oCLIENTES:IsDef("oScroll2")
    oCLIENTES:oScroll2:SetEdit(oCLIENTES:nOption>0)
  ENDIF

ENDIF

  SETFOLDER(3)
  oCLIENTES:oScroll3:=oCLIENTES:SCROLLGET("DPCLIENTES","DPCLIENTES_DATCOM.SCG",cExcluye,,,,0)

IF !oCLIENTES:oScroll3=NIL 

  oClientes:oScroll3:SetColSize(250+30,290+75+95-30,240)
  //oClientes:oScroll3:SetColSize(250,100,240)

  oClientes:oScroll3:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFont) 
  oClientes:oScroll3:SetColor(oDp:nClrPane1,oDp:nClrDPCLIENTES,1,oDp:nClrPane2,oFontB) 
  oClientes:oScroll3:SetColor(oDp:nClrPane1,0,2,oDp:nClrPane2,oFont ) 
  oClientes:oScroll3:SetColor(oDp:nClrPane1,0,3,oDp:nClrPane2,oFontB) 

  IF oCLIENTES:IsDef("oScroll3")
    oCLIENTES:oScroll3:SetEdit(oCLIENTES:nOption>0)
  ENDIF

 
ENDIF

  // oCLIENTES:SetEdit(!oCLIENTES:nOption=0)

  SETFOLDER(4)

  //
  // Campo : CLI_CUENTA
  // Uso   : Cuenta Contable                         
  //
  @ 6.0, 0.0 BMPGET oClientes:oCLI_CUENTA  VAR oClientes:CLI_CUENTA;
             VALID oClientes:oDPCTA:SeekTable("CTA_CODIGO",oClientes:oCLI_CUENTA,NIL,oClientes:oCTA_DESCRI);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPCTA",NIL,NIL,NIL,"CTA_CODIGO",NIL,NIL,oClientes:lDialog,oClientes:oDb,oClientes:oCLI_CUENTA),;
                     oDpLbx:GetValue("CTA_CODIGO",oClientes:oCLI_CUENTA)); 
             WHEN (AccessField("DPCLIENTES","CLI_CUENTA",oClientes:nOption);
                  .AND. oClientes:nOption!=0);
             FONT oFontG;
             SIZE 80,10

  oClientes:oCLI_CUENTA:cMsg    :="Cuenta Contable"
  oClientes:oCLI_CUENTA:cToolTip:="Cuenta Contable"

  @ 0,0 SAY GETFROMVAR("{oDp:xDPCTA}") RIGHT

  @ 0,0 SAY oClientes:oCTA_DESCRI;
        PROMPT oClientes:oDPCTA:CTA_DESCRI PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680 
 
  SETFOLDER( 0)

  @ 2,50 CHECKBOX oDp:lClienteMnu PROMPT ANSITOOEM("Menú al Finalizar");
         ON CHANGE EJECUTAR("SETMENUFICHA","lClienteMnu",oDp:lClienteMnu)

  bInit:=IF(oCLIENTES:nOption<>0,{||oCLIENTES:INICIO(),oCLIENTES:LOAD(oCLIENTES:nOption)},{||oCLIENTES:INICIO()})


  oCLIENTES:oFocus:=IIF(!oDp:lRifCli,oCLIENTES:oCLI_RIF,oCLIENTES:oCLI_CODIGO)
  oCLIENTES:Activate() 
//bInit)

  IF .T.

    oDp:nDif:=(oDp:aCoors[3]-160-oCLIENTES:oWnd:nHeight())

    oCLIENTES:oFolder:SetSize(NIL,oDp:aCoors[3]-(oCLIENTES:oFolder:nTop+210),.T.)

    oCLIENTES:oWnd:SetSize(NIL,oDp:aCoors[3]-160,.T.)

    oCLIENTES:oScroll:oBrw:SetSize(NIL,oCLIENTES:oFolder:nHeight()-25,.T.)
    oCLIENTES:oScroll2:oBrw:SetSize(NIL,oCLIENTES:oFolder:nHeight()-25,.T.)
    oCLIENTES:oScroll3:oBrw:SetSize(NIL,oCLIENTES:oFolder:nHeight()-25,.T.)

  ENDIF

RETURN oCLIENTES

FUNCTION INICIO()

  oCLIENTES:oDlg:oBar:SetColor(CLR_WHITE,oDp:nGris)

  AEVAL(oCLIENTES:oDlg:oBar:aControls,{|oBtn|oBtn:SetColor(CLR_WHITE,oDp:nGris)})

  oCLIENTES:oScroll:oBrw:SetColor(CLR_GREEN,oDp:nClrPane1)
  oCLIENTES:oScroll2:oBrw:SetColor(CLR_GREEN,oDp:nClrPane1)
  oCLIENTES:oScroll3:oBrw:SetColor(CLR_GREEN,oDp:nClrPane1)


RETURN .T.

// Expedientes
FUNCTION EXPEDIENTES()
  LOCAL cTitle:=ALLTRIM(GetFromVar("{oDp:DPEXPEDIENTE}"))+" del "+;
                GetFromVar("{oDp:XDPCLIENTES}")+" ["+oCLIENTES:CLI_CODIGO+" "+ALLTRIM(oCLIENTES:CLI_NOMBRE)+"]"
  LOCAL cWhere,oLbx
 
  // Cambio, requerido por el nuevo indice, TABLA+MAESTRO

  cWhere:="EXP_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "EXP_TABLA" +GetWhere("=","DPCLIENTES" )+" AND "+;
          "EXP_CODMAE"+GetWhere("=",oCLIENTES:CLI_CODIGO)+" AND EXP_ACT=1"

         
  oDp:aCargo:={oDp:cSucursal,oCLIENTES:CLI_CODIGO,"DPCLIENTES","",""}

  oLbx:=DPLBX("DPEXPEDIENTES.LBX",cTitle,cWhere)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5NúmeroDoc
  oLbx:aCargo:=oDp:aCargo


RETURN .T.

// Carga de los Datos
FUNCTION LOAD()

  IF oCLIENTES:nOption=0 // Incluir en caso de ser Incremental

    oCLIENTES:oScroll:SetValues(.F.,.T.)
    oCLIENTES:oScroll2:SetValues(.F.,.T.)
    oCLIENTES:oScroll3:SetValues(.F.,.T.)
    oCLIENTES:SetEdit(.F.) // Inactiva la Edicion

  ELSE

    oCLIENTES:SetEdit(.T.) // Activa la Edicion

    oCLIENTES:oScroll:SetEdit(.T.)
    oCLIENTES:oScroll2:SetEdit(.T.)
    oCLIENTES:oScroll3:SetEdit(.T.)

  ENDIF

  IF oCLIENTES:nOption=1 // Incluir en caso de ser Incremental

     oCLIENTES:CLI_FECHA:=oDp:dFecha
     oCLIENTES:CLI_LISTA:=oDp:cPrecio   

    IF !oDp:lRifCli
       oCLIENTES:CLI_CODIGO:=oCLIENTES:Incremental("CLI_CODIGO",.T.)
       oCLIENTES:oFocus    :=oCLIENTES:oCLI_CODIGO
    ELSE
       oCLIENTES:oCLI_CODIGO:VARPUT(CTOEMPTY(oCLIENTES:CLI_CODIGO),.T.)
       oCLIENTES:oFocus     :=oCLIENTES:oCLI_RIF
    ENDIF

    oCLIENTES:aScrollGets[1]:PUT("CLI_SITUAC","A"           ,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_PAIS"  ,oDp:cPais     ,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_ESTADO",oDp:cEstado   ,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_MUNICI",oDp:cMunicipio,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_PARROQ",oDp:cParroquia,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_TERCER","N"           ,2)
    oCLIENTES:aScrollGets[1]:PUT("CLI_LISTA",oDp:cPrecio    ,2)

    IF Empty(oCLIENTES:CLI_CODRUT)
      oCLIENTES:aScrollGets[3]:PUT("CLI_CODRUT",oDp:cCodRuta,2)
      oCLIENTES:oCLI_CODRUT:SET(oDp:cCodRuta,.T.)
    ENDIF

    DPFOCUS(oCLIENTES:oFocus)

  ENDIF

  oClientes:oCLI_CUENTA:ForWhen(.T.)
  oClientes:oCTA_DESCRI:Refresh(.T.)

  oCLIENTES:CLI_RIF:=STRTRAN(oCLIENTES:CLI_RIF,"-","")

  IF oCLIENTES:IsDef("oScroll")
    oCLIENTES:oScroll:SetEdit(oCLIENTES:nOption=1.OR.oCLIENTES:nOption=3)
  ENDIF

  oCLIENTES:cCodCli:=oCLIENTES:CLI_CODIGO

  IF oCLIENTES:nOption=3
    oCLIENTES:oCLI_RIF:KeyBoard(13)
  ENDIF

RETURN .T.

// Ejecuta Cancelar
FUNCTION CANCEL()
RETURN .T.

// Ejecución PreGrabar
FUNCTION PRESAVE()
  LOCAL lResp:=.T.,cMemo:="",I,uValue,cDir:="",cTel:="",cRIF:="",cIni:="",cFile:=""
  LOCAL aCampos:={"CLI_NOMBRE","CLI_RIF"}
  LOCAL aNombre:={"Nombre"    ,oDp:cNit}

  lResp:=oCLIENTES:ValUnique(oCLIENTES:CLI_CODIGO)

  
  IF !lResp
    oCLIENTES:oCLI_CODIGO:MsgErr("Registro Código "+CTOO(oCLIENTES:CLI_CODIGO),"Ya Existe")
    RETURN .F.
  ENDIF

  lResp:=oCLIENTES:ValUnique(oCLIENTES:CLI_RIF,"CLI_RIF","Registro RIF "+CTOO(oCLIENTES:CLI_RIF)+" ya Existe")

  IF !lResp
    // oCLIENTES:oCLI_RIF:MsgErr("Registro RIF "+CTOO(oCLIENTES:CLI_RIF),"Ya Existe")
    RETURN .F.
  ENDIF

  oClientes:CLI_SITUAC:=oCLIENTES:oScroll:GetValue("CLI_SITUAC")

  IF !ALLTRIM(oClientes:CLI_CODMON)=ALLTRIM(oDp:cMoneda)
     oClientes:CLI_ENOTRA:="S"
  ENDIF

  IF Empty(oCLIENTES:CLI_CODRUT)
    oCLIENTES:CLI_CODRUT:=oDp:cCodRuta
  ENDIF

  IF Empty(oCLIENTES:CLI_LISTA)
    oCLIENTES:CLI_LISTA:=oDp:cPrecio
  ENDIF

  IF oCLIENTES:nOption=1 .AND. !(oCLIENTES:CLI_CODIGO=STRZERO(0,10)) .AND. SQLGET("DPCLIENTES","CLI_RIF","CLI_RIF"+GetWhere("=",oCLIENTES:CLI_RIF))== oCLIENTES:CLI_RIF
    oCLIENTES:oCLI_CODIGO:MsgErr("Registro: "+oCLIENTES:CLI_RIF," Ya Existe")
    RETURN .F.
  ENDIF

  IF Empty(oCLIENTES:CLI_CODVEN) .AND. COUNT("DPVENDEDOR")>=1
    oCLIENTES:CLI_CODVEN:=SQLGET("DPVENDEDOR","VEN_CODIGO","VEN_CODIGO"+GetWhere("<>",""))
  ENDIF

  oCLIENTES:CLI_RIF:=UPPER(oCLIENTES:CLI_RIF)

  cRif:=oCLIENTES:CLI_RIF
  cRif:=STRTRAN(cRif,"-","")                      // Quita los guiones

  // Es Cedula
// Si no cumple la condición no lo valid
IF EVAL(oCLIENTES:oCLI_RIF:bWhen)

  IF ISDIGIT(cRif)
  
     cRif:=STRZERO(VAL(cRif),8)
     
  ELSE

    IF LEN(ALLTRIM(cRif)) < 9 .AND. !(oCLIENTES:CLI_CODIGO=STRZERO(0,10)) 
      oCLIENTES:oCLI_RIF:MsgErr("RIF Incorrecto -> Longitud mayor a 9 ")
      RETURN .F.
    ENDIF

    IF !LEFT(cRif,1)$"JVGEPC" .AND. !(oCLIENTES:CLI_CODIGO=STRZERO(0,10)) 
      oCLIENTES:oCLI_RIF:MsgErr("RIF Incorrecto -> Primera letra debe ser J, V , G , E , P o C")
      RETURN .F.
    ENDIF

  ENDIF

ENDIF
  
  IF !Empty(cMemo) .AND. oCLIENTES:CLI_CODIGO<>STRZERO(0,10)
    MensajeErr(cMemo,"Campos no Pueden Quedar Vacios ") 
    RETURN .F.
  ENDIF

  // Asume Codigo como RIF luego que el RIF sea valido
  IF oCLIENTES:nOption=1 .AND. SQLGET("DPCLIENTES","CLI_CODIGO","CLI_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO))== oCLIENTES:CLI_CODIGO

    oCLIENTES:oCLI_CODIGO:MsgErr("Código: "+oCLIENTES:CLI_CODIGO,"No puede Estar Vacio")

    IF Empty(oCLIENTES:CLI_RIF)
       oCLIENTES:CLI_CODIGO:=SQLINCREMENTAL("DPCLIENTES","CLI_CODIGO")
       oCLIENTES:oCLI_CODIGO:VarPut(oCLIENTES:CLI_CODIGO,.T.)
    ELSE
       oCLIENTES:oCLI_CODIGO:VarPut(PADR(STRTRAN(oCLIENTES:CLI_RIF,"-",""),10),.T.)
    ENDIF

    RETURN .F.

  ENDIF

  IF EMPTY(oCLIENTES:CLI_CODIGO) 
    oCLIENTES:oCLI_CODIGO:MsgErr("Código no puede estar Vacio")
    RETURN .F.
  ENDIF

  // Regiones por Defecto
  oCLIENTES:CLI_PAIS  :=IF(Empty(oCLIENTES:CLI_PAIS  ),oDp:cPais  ,oCLIENTES:CLI_PAIS  )
  oCLIENTES:CLI_ESTADO:=IF(Empty(oCLIENTES:CLI_ESTADO),oDp:cEstado,oCLIENTES:CLI_ESTADO)
  oCLIENTES:CLI_MUNICI:=IF(Empty(oCLIENTES:CLI_MUNICI),oDp:cEstado,oCLIENTES:CLI_MUNICI)
  oCLIENTES:CLI_PARROQ:=IF(Empty(oCLIENTES:CLI_PARROQ),oDp:cEstado,oCLIENTES:CLI_PARROQ)

  oCLIENTES:CLI_FECHA :=IF(EMPTY(oCLIENTES:CLI_FECHA),oDp:dFecha,oCLIENTES:CLI_FECHA)
  oCLIENTES:CLI_FCHUPD:=oDp:dFecha
  oClientes:CLI_ACTIVI:=IF(EMPTY(oClientes:CLI_ACTIVI),STRZERO(1,6),oClientes:CLI_ACTIVI)
  oClientes:CLI_CODCLA:=IF(EMPTY(oClientes:CLI_CODCLA),STRZERO(1,6),oClientes:CLI_CODCLA)
  oClientes:CLI_USUARI:=oDp:cUsuario
  oClientes:CLI_ZONANL:=IF(Empty(oClientes:CLI_ZONANL),"N",oClientes:CLI_ZONANL)

  // 22/05/2023 caso de Colegios, Condominios, 
  IF !Empty(oCLIENTES:cCatego ) .AND. !Empty(oCLIENTES:CLI_CATEGO)
     oCLIENTES:CLI_CATEGO:=oCLIENTES:cCatego 
  ENDIF

  IF !ISSQLGET("DPACTIVIDAD_E","ACT_CODIGO",oClientes:CLI_ACTIVI) 
     MensajeErr("Actividad "+oClientes:CLI_ACTIVI+" no Existe")
     lResp:=.F.
  ENDIF

  IF Empty(oCLIENTES:CLI_CUENTA)
      oCLIENTES:CLI_CUENTA:=oDp:cCtaIndef
  ENDIF

  IF !ISSQLGET("DPCLICLA","CLC_CODIGO",oClientes:CLI_CODCLA) 
    MensajeErr("Clasificación "+oClientes:CLI_CODCLA+" no Existe")
    lResp:=.F.
  ENDIF

  // Validaciones Lógicas

  IF !Empty(oClientes:CLI_RIF)

/*
     cIni:=LEFT(oClientes:CLI_RIF,1)
     oClientes:CLI_TIPPER:="N"
     oClientes:CLI_TIPPER:=IIF(cIni="J","J",oClientes:CLI_TIPPER)
     oClientes:CLI_TIPPER:=IIF(cIni="G","G",oClientes:CLI_TIPPER)
//   oClientes:SET("CLI_TIPPER",cIni)

? cIni,"cIni", oClientes:CLI_TIPPER,[ oClientes:SET("CLI_TIPPER"]
     oClientes:CLI_RESIDE:="S"
*/   
     IF cIni="G"

        oClientes:CLI_CONESP:="S"

     ELSE

       IF oClientes:lValRif .AND. LEFT(oClientes:cPersona,1)="E"
        oClientes:CLI_CONESP:="S"
       ENDIF

     ENDIF

     IF oClientes:CLI_TIPPER="N"
        oClientes:CLI_CONESP:="N"
     ENDIF

 ENDIF

 IF !Empty(oCLIENTES:nRetIva)

    oCLIENTES:CLI_RETIVA :=oCLIENTES:nRetIva
    //oCLIENTES:CLI_CONFIS :=oCLIENTES:cConFis // Condición Fiscal
   
/*
   cFile:="TEMP\"+STRTRAN(cRif,"-","")+".html"

    IF !Empty(oCLIENTES:cMemoRif) .AND. ValType(oCLIENTES:cMemoRif)="C"
       DpWrite(cFile,oCLIENTES:cMemoRif)
    ENDIF
*/
    cFile:="TEMP\RIF_"+ALLTRIM(cRif)+".HTML"
    IF FILE(cFile)
       oCLIENTES:CLI_FILMAI:=EJECUTAR("DPFILEEMPADJUNT",{cFile},"RIF "+cRif,"DPPROVEEDOR",oCLIENTES:CLI_FILMAI,oCLIENTES:CLI_CODIGO,"CLI_CODIGO")
    ENDIF

  ENDIF

  // Cuando se Incluye Cliente se Asigna a la Sucursal que lo creo
  IF oDp:lCliXSuc .AND. oCLIENTES:nOption=1
    EJECUTAR("DPTABSETSUC",oCLIENTES:CLI_CODIGO,oDp:cSucursal)
  ENDIF

  IF lResp
     lResp:=EJECUTAR("SCROLLGETVALID",oClientes:oScroll,oClientes:oCLI_CODIGO)
  ENDIF
 
// ? oCLIENTES:CLI_SITUAC,"oCLIENTES:CLI_SITUAC"

RETURN lResp

// Ejecución despues de Grabar
FUNCTION POSTSAVE()
  LOCAL oTarea,aMovInv:={"L","A"},oAct

  IF oCLIENTES:nOption!=1 .AND. oCLIENTES:cCodCli!=oCLIENTES:CLI_CODIGO

    // Cambia el Código del Cliente
    SQLUPDATE("DPMOVINV","MOV_CODCTA",oCLIENTES:CLI_CODIGO,"MOV_CODCTA"+GetWhere("=",oCLIENTES:cCodCli)+" AND "+"  MOV_APLORG='V'")

    SQLUPDATE("DPMOVINV","MOV_DOCUME",oCLIENTES:CLI_CODIGO,"MOV_DOCUME"+GetWhere("=",oCLIENTES:cCodCli)+" AND "+GetWhereOr("MOV_APLORG",aMovInv))

    SQLUPDATE("DPEXPEDIENTE","EXP_CODMAE",oCLIENTES:CLI_CODIGO,"EXP_CODMAE"+GetWhere("=",oCLIENTES:cCodCli)+;
              " AND (EXP_TABLA='DPDOCCLI' OR EXP_TABLA='DPCLIENTES')")

    SQLUPDATE("DPASIENTOS","MOC_CODAUX",oCLIENTES:CLI_CODIGO,"MOC_CODAUX"+GetWhere("=",oCLIENTES:cCodCli)+" AND MOC_ORIGEN='VTA'")


    // Cambios en el Codigo del Documento
    SQLUPDATE("DPDOCCLI","DOC_CODIGO",oCLIENTES:CLI_CODIGO,"DOC_CODIGO"+GetWhere("=",oCLIENTES:cCodCli))

    EJECUTAR("DPTABLEUPLNK","DPCLIENTES","CLI_CODIGO",oCLIENTES:CLI_CODIGO,oCLIENTES:cCodCli)


  ENDIF

//  EJECUTAR("DPCLILOGYPASS",oCLIENTES:CLI_CODIGO)

  EJECUTAR("DPCLIENTESTORIF",oClientes:CLI_CODIGO)
  EJECUTAR("SETCTAINTMOD","DPCLIENTES_CTA",oClientes:CLI_CODIGO,"","CUENTA",oClientes:CLI_CUENTA,.T.)

  IF oDp:lClienteMnu
    EJECUTAR("DPCLIENTESMNU",oCLIENTES:CLI_CODIGO)
  ENDIF

  IF oCLIENTES:nOpcIni=1 // Incluye desde el ListBox, debe cerrar luego de Incluir
    oCLIENTES:CLOSE()
  ENDIF

  IF oCLIENTES:nModoFrm=2
    oCLIENTES:CLOSE()
    RETURN .F.
  ENDIF

  EJECUTAR("DPPROCESOSRUN","DPCLIENTESPOSTGRABAR",oCLIENTES)

  IF Empty(oCLIENTES:CLI_LOGIN) .OR. Empty(oCLIENTES:CLI_CLAVE)
    EJECUTAR("DPCLILOGYPASS",oCLIENTES:CLI_CODIGO)
  ENDIF

  oTarea:=EJECUTAR("DPTARAUTRUN","DPCLIENTES",oCLIENTES:nOption,oCLIENTES:CLI_CODIGO,"CLI_CODIGO","CLI_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO))

  IF ValType(oTarea)="O"
     EJECUTAR("DPTARAUTSAVE",oTarea)
  ENDIF

  IF oCLIENTES:nOption=3
     oCLIENTES:oTable:GotoSkip(1,NIL,oCLIENTES:cScope)
     oCLIENTES:nOption:=0
     AEVAL(oCLIENTES:aScrollGets,{|o|o:UpdateFromForm(), IIF( oCLIENTES:nOption=1 .OR. oCLIENTES:nOption=3 ,o:SetEdit(.T.,oCLIENTES:nOption) , o:SetEdit(.F.,oCLIENTES:nOption))})
     oCLIENTES:nOption:=3
   ENDIF

   IF oCLIENTES:nModoFrm=1
      oCLIENTES:Close()
   ENDIF


RETURN .T.

// Ejecución para el Borrado 
FUNCTION DELETE()
  LOCAL nDocCli:=0,cMsg:=""

  nDocCli:=COUNT("DPDOCCLI","DOC_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO))

  IF nDocCli>0
    cMsg:="Registro en Documentos: "+LSTR(nDocCli)
  ENDIF

  IF !Empty(cMsg)
    cMsg:=GetFromVar("{oDp:xDPCLIENTES}")+": "+oCLIENTES:CLI_CODIGO+CRLF+cMsg
    MensajeErr(cMsg,"No es Posible Eliminar ")
    RETURN .F.
  ENDIF

  IF MsgNoYes("Código: "+oCLIENTES:CLI_CODIGO+CRLF+ALLTRIM(oCLIENTES:CLI_NOMBRE),;
                        "Eliminar: "+GetFromVar("{oDp:xDPCLIENTES}"))

    oCLIENTES:DelRecord(NIL,.T.)
  ENDIF
RETURN .T.

FUNCTION PRINT()
 EJECUTAR("DPFICHACLI",oCLIENTES:CLI_CODIGO )
RETURN .T.

FUNCTION ENTREVISTA(cTipo)
  LOCAL cTitle
  LOCAL cWhere,oLbx

// GetFromVar("{oDp:XDPCLIENTES}")+" ["+oCLIENTES:CLI_CODIGO+" "+ALLTRIM(oCLIENTES:CLI_NOMBRE)+"]"

  DEFAULT cTipo:="P"

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEENT}"))+;
                 SayOptions("DPCLIENTEENT","ENT_TIPO",cTipo,.T.)+;
                 " ["+oCLIENTES:CLI_CODIGO+" "+ALLTRIM(oCLIENTES:CLI_NOMBRE)+"]"

  cWhere:="ENT_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO)+" AND "+;
          "ENT_TIPO  "+GetWhere("=",cTipo)

  oDp:aCargo:={"",oCLIENTES:CLI_CODIGO,cTipo,"",""}
  oLbx:=DPLBX("DPCLIENTEENT.LBX",cTitle,cWhere)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5NúmeroDoc
  oLbx:aCargo:=oDp:aCargo
RETURN .T.

// Facturación Periódica
FUNCTION FACTURAPER()
  LOCAL cTitle
  LOCAL cWhere,oLbx

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
          " ["+oCLIENTES:CLI_CODIGO+" "+ALLTRIM(oCLIENTES:CLI_NOMBRE)+" ]"

  cWhere:="DPG_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO)

  oDp:aRowSql:={} // Lista de Campos Seleccionados
  oDpLbx:=TDpLbx():New("DPCLIENTEPROG.LBX",cTitle,cWhere)
  oDpLbx:uValue1:=oCLIENTES:CLI_CODIGO
  oDpLbx:Activate()

RETURN .T.

/*
// Validar Datos del RIF
*/
FUNCTION VAL_RIF()
  LOCAL lOk,nLen:=LEN(oCLIENTES:CLI_RIF)

  IF oDp:lEsp

     oCLIENTES:CLI_RIF:=ALLTRIM(STRTRAN(oCLIENTES:CLI_RIF,"-",""))
     oCLIENTES:CLI_RIF:=PADR(oCLIENTES:CLI_RIF,nLen)
     oCLIENTES:oCLI_RIF:VarPut(oCLIENTES:CLI_RIF,.T.)
    
     lOk:=EJECUTAR("ESVALNIF",oCLIENTES:CLI_RIF)

     IF !lOk
       oCLIENTES:oCLI_RIF:MsgErr(oCLIENTES:CLI_RIF+" no es Válido","Validación de "+oDp:cNit)
     ENDIF

     RETURN lOk

  ENDIF

  WHILE !oDp:lIsSeniat

    IF MsgYesNo("Página Web "+oDp:cUrlSeniat+" no ha sido Detectada","Desea Revisar Nuevamente?")
      EJECUTAR("ISSENIAT")
    ELSE

      // Código es RIF
      IF oDp:lRifCli
        oCLIENTES:oCLI_CODIGO:VarPut(oCLIENTES:CLI_RIF,.T.)
        DPFOCUS(oCLIENTES:oCLI_NOMBRE)
      ENDIF
    
      RETURN .T.

    ENDIF

  ENDDO

//? oDp:lAutRif,"oDp:lAutRif"

  IF oDp:lAutRif
     oCLIENTES:VALRIF()
  ENDIF

RETURN .T.

/*
// Buscar RIF segun Cedula
*/

FUNCTION CLIFINDCED()
  LOCAL cRif2:=""

  // Buscar por Cédula, para evitar Buscar en el Seniat
  oCLIENTES:ASIGNA_TIPPER()
  cRif2:=EJECUTAR("FINDCLIXCED",oCLIENTES:CLI_RIF)
  
  IF !Empty(cRif2)
     oCLIENTES:oCLI_RIF:VarPut(cRif2,.T.)
     oCLIENTES:CLI_RIF:=cRif2
  ENDIF

RETURN .T.

/*
// Según Primer Digito es tipo de persona
*/
FUNCTION ASIGNA_TIPPER()
  LOCAL cRif   :=ALLTRIM(oCLIENTES:CLI_RIF)
  LOCAL cIni   :=LEFT(cRif,1)
  LOCAL cTipPer:="Natural"

  cTipPer:=IF(cIni="J","Jurídica"     ,cTipPer)
  cTipPer:=IF(cIni="G","Gubernamental",cTipPer)

  oClientes:SET("CLI_TIPPER",cTipPer,.T.)

  IF cTipPer="G"
    oClientes:SET("CLI_CONESP","Si",.T.)
  ENDIF

  IF cIni="V"
    oClientes:SET("CLI_CONESP","No",.T.)
  ENDIF

RETURN .T.

/*
// Validación de RIF
*/
FUNCTION VALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.
  LOCAL cRif:=ALLTRIM(oCLIENTES:CLI_RIF)
  LOCAL cRif2:=""

  IF EMPTY(oCLIENTES:CLI_CODIGO) .AND. !Empty(cRif)
    oCLIENTES:oCLI_CODIGO:VarPut(cRif,.T.)
  ENDIF
 
  // Buscar por Cédula, para evitar Buscar en el Seniat
  cRif2:=EJECUTAR("FINDCLIXCED",cRif)
  
  IF !Empty(cRif2)
      oCLIENTES:oCLI_RIF:VarPut(cRif2,.T.)
      oCLIENTES:CLI_RIF:=cRif2
      cRif     :=cRif2
  ENDIF

  oDp:cSeniatErr:=""

  IF ISDIGIT(oCLIENTES:CLI_RIF) .AND. oDp:lVen
    oCLIENTES:CLI_RIF:=STRZERO(VAL(oCLIENTES:CLI_RIF),8)
    oCLIENTES:oCLI_RIF:VarPut(oCLIENTES:CLI_RIF,.T.)
  ENDIF

  IF !oCLIENTES:ValUnique(oCLIENTES:CLI_RIF,"CLI_RIF") .AND. oCLIENTES:nOption<>0
     RETURN .F.
  ENDIF

 // Solo Valida el RIF si el Boton Acction lo ejecuta
  IF !oClientes:lValRifOn .AND. oCLIENTES:nOption<>0
     RETURN .T.
  ENDIF

//  MsgRun("Verificando "+oDp:cNit+oCLIENTES:CLI_RIF,"Por Favor, Espere",;
//         {|| lOk:=EJECUTAR("VALRIFSENIAT",oCLIENTES:CLI_RIF,NIL,!ISDIGIT(cRif)) })

  MsgRun("Verificando "+oDp:cNit+oCLIENTES:CLI_RIF,"Por Favor, Espere")
  
  lOk:=EJECUTAR("VALRIFSENIAT",oCLIENTES:CLI_RIF,NIL,!ISDIGIT(cRif),oCLIENTES:oCLI_RIF)

  oClientes:lValRifOn:=.F. // Apaga solo valida si lo solicita

  IF !lOk .AND. oDp:lEsp
     oCLIENTES:oCLI_RIF:MsgErr(oDp:cNit+" Inválido")
     RETURN .F.
  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF !lOk .AND. ISDIGIT(oCLIENTES:CLI_RIF)

    MsgRun("Autodectando RIF "+oCLIENTES:CLI_RIF+" no Encontrado","Por favor espere..",;
           {||lOk:=EJECUTAR("RIFVAUTODET",oCLIENTES:CLI_RIF,oCLIENTES:oCLI_RIF) })
   
  ENDIF


  IF lOk

      oCLIENTES:CLI_RIFVAL:=.T.

      IF !Empty(oDp:aRif) .AND. !Empty(oDp:aRif[1])

        oCLIENTES:oCLI_NOMBRE:VARPUT( oDp:aRif[1] , .T. )
 
        oCLIENTES:nRetIva :=oDp:aRif[2]
        oCLIENTES:cPersona:=oDp:aRif[3]
        oCLIENTES:cMemoRif:=oDp:aRif[4]
        // Actividad Económica según RIF
        oCLIENTES:CLI_ACTECO:=oDp:aRif[5]

        IF "ORDI"$UPPER(oCLIENTES:cPersona)
           oCLIENTES:SET("CLI_CONESP","No") // no es contribuyente especial
        ENDIF

        IF "ESPE"$UPPER(oCLIENTES:cPersona)
           oCLIENTES:SET("CLI_CONESP","Si") // no es contribuyente especial
        ENDIF

//  ? oCLIENTES:cPersona,"oCLIENTES:cPersona",oCLIENTES:CLI_CONESP,"CONESP"

        // Código es RIF
        IF oDp:lRifCli
          oCLIENTES:oCLI_CODIGO:VarPut(oCLIENTES:CLI_RIF,.T.)
        ENDIF

        // Contribuyente
        IF !oCLIENTES:ValUnique(oCLIENTES:CLI_RIF,"CLI_RIF")
          DPFOCUS(oCLIENTES:oCLI_RIF)
          RETURN .F.
        ENDIF

        // ViewArray(oDp:aRif)

      ENDIF

  ELSE

     oCLIENTES:CLI_RIFVAL:=.F.

     MensajeErr(oDp:cRifErr,"RIF no fué Validado")

// :={cEmpresa,nPorRet,cCond}

  ENDIF

 IF oCLIENTES:nOption=0 .AND. !Empty(oDp:aRif) .AND. !Empty(oDp:aRif[1]) .AND. MsgYesNo("Desea Asignar %"+ALLTRIM(oDp:aRif[2])+" Retención IVA ")

     oDp:cConEspRif:=IF("Ordin"$oDp:aRif[3],"N","S")

     SQLUPDATE("DPCLIENTES",{"CLI_RETIVA"         ,"CLI_ACTECO","CLI_NOMBRE","CLI_CONESP" },;
                             {CTOO(oDp:aRif[2],"N"),oDp:aRif[5] ,oDp:aRif[1] ,oDp:cConEspRif},;
                             "CLI_CODIGO"+GetWhere("=",oCLIENTES:CLI_CODIGO))

     oCLIENTES:Set("CLI_RETIVA",CTOO(oDp:aRif[2],"N"),.T.)
     oCLIENTES:Set("CLI_ACTECO",oDp:aRif[5]   ,.T.)
     oCLIENTES:Set("CLI_CONESP",oDp:cConEspRif,.T.)

  ENDIF


RETURN .T.

FUNCTION VALCODIGO(cCodigo)
    LOCAL cC1:=UPPE(LEFT(cCodigo,1))
    LOCAL cC2:=SUBS(cCodigo,02,8)
    LOCAL cC3:=SUBS(cCodigo,10,1)
    LOCAL cNombre:=ALLTRIM(oCLIENTES:CLI_RIF)
    
    IF !ISDIGIT(cC1).AND. LEN(ALLTRIM(cCodigo))=10
        oCLIENTES:oCLI_RIF:VarPut(cC1+cC2+cC3,.T.)
        oCLIENTES:VALRIF()
        // Si Cambio
        IF !(cNombre==ALLTRIM(oCLIENTES:CLI_RIF))
          DPFOCUS( oCLIENTES:aScrollGets[1]:oBrw)
        ENDIF

    ENDIF
    
RETURN .T.


FUNCTION DPCLIENTESCON()
   //oClientes:nOption:=0
   EJECUTAR("DPCLIENTESCON",NIL,oCLIENTES:CLI_CODIGO)
RETURN NIL


FUNCTION BUSCARXNOMBRE()
   LOCAL cCodigo:=EJECUTAR("DPCLIENTESBUSCAR")
   LOCAL cWhere

   IF Empty(cCodigo)
      RETURN .F.
   ENDIF

   oCLIENTES:CLI_CODIGO:=cCodigo

   oCLIENTES:oTable:cSql:="SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",cCodigo)+;
                          IIF(Empty(oClientes:cScope),""," AND "+oClientes:cScope)

   oCLIENTES:oTable:Reload()
   oCLIENTES:Load(0)

RETURN .T.

FUNCTION BRWCLIENTES(nOption,cOption)
  LOCAL cWhere,cCodigo,cTitle:=oClientes:cListTitle
  LOCAL nAt:=ASCAN(oClientes:aButtons,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oClientes:aButtons[nAt,1],NIL)

  IF nOption=1 

     cWhere:=EJECUTAR("DPCLIBUSCAR",oClientes:CLI_NOMBRE,.T.,oBtnBrw)

     IF !Empty(cWhere)

        oClientes:List(cWhere)

        oClientes:cScope:=oClientes:cScopeOrg+IF(Empty(oClientes:cScopeOrg),""," AND ")+cWhere
        oClientes:RECCOUNT(.T.)
        oClientes:RECCOUNT(.F.)

     ENDIF

     RETURN .T.

  ENDIF

  IF nOption=2
     cWhere:=EJECUTAR("TABLECOUNTXFIELD","DPCLIENTES","CLI_CODIGO","CLI_DESCRI",oClientes)
     RETURN  NIL
  ENDIF

// ? nOption,"nOption"

  IF nOption=3


     oDp:cFieldName:=""
     cWhere:=EJECUTAR("DPEXPCLIENTE",.T.,oBtnBrw)
     
     IF !Empty(cWhere)

        DEFAULT oClientes:cListTitle:=oDp:DPCLIENTES

        oClientes:cListTitle:=oClientes:cListTitle+" ["+ALLTRIM(oDp:cFieldName)+"] "+cWhere

        oClientes:cScope:=oClientes:cScopeOrg+IF(Empty(oClientes:cScopeOrg),""," AND ")+cWhere
        oClientes:RECCOUNT(.T.)

        oClientes:List(cWhere)

     ENDIF

     RETURN .T.

  ENDIF


  IF nOption=4

     cCodigo:=EJECUTAR("DPCLIFINDXPER","",{},.T.,oBtnBrw)

     oClientes:oTable:cSql:="SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",cCodigo)+;
                            " LIMIT 1"

     oClientes:oTable:Reload()
     oClientes:Load(0)

  ENDIF

  IF nOption=5

     oClientes:BRWXVEN() 
     RETURN .T.

  ENDIF

  IF nOption=6

     oClientes:BRWXACT() 
     RETURN .T.

  ENDIF

  IF nOption=7 

     oClientes:BRWXCLA() 
     RETURN .T.

  ENDIF

  IF nOption=8 

     oClientes:BRWXCTA()
     RETURN .T.

  ENDIF



RETURN .T.

/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXVEN()
  LOCAL cWhere:="",cCodigo:=""
  LOCAL cTitle:="Seleccionar "+oDp:XDPVENDEDOR,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
 
  cWhere    := " INNER JOIN DPVENDEDOR ON CLI_CODVEN=VEN_CODIGO "+IF(Empty(oClientes:cScope)," WHERE 1=1 "," WHERE ")+oClientes:cScope

  cOrderBy:=" GROUP BY CLI_CODVEN ORDER BY CLI_CODVEN "
  aTitle  :={"Código","Nombre","Desde","Hasta","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"9999"}
  oDp:aSize      :={60,300,60,60,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","CLI_CODVEN,VEN_NOMBRE,MIN(CLI_FECHA) AS DESDE ,MAX(CLI_FECHA) AS HASTA,COUNT(*)",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="CLI_CODVEN"+GetWhere("=",cCodigo)+;
             IIF(!Empty(oClientes:cScopeOrg)," AND "+oClientes:cScopeOrg,"")

     cTitle:=oDp:XDPVENDEDOR+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",cCodigo)))+"]"

     oClientes:cListTitle:=cTitle

     oClientes:List(cWhere)
  
  ENDIF

RETURN .T.

/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXACT()
  LOCAL cWhere:="",cCodigo:=""
  LOCAL cTitle:="Seleccionar "+oDp:XDPACTIVIDAD_E,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
 
  cWhere    := " INNER JOIN DPACTIVIDAD_E ON ACT_CODIGO=CLI_ACTIVI "+IF(Empty(oClientes:cScope)," WHERE 1=1 "," WHERE ")+oClientes:cScope

  cOrderBy:=" GROUP BY CLI_ACTIVI ORDER BY CLI_ACTIVI "
  aTitle  :={"Código","Nombre","Desde","Hasta","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"9999"}
  oDp:aSize      :={60,300,60,60,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","ACT_CODIGO,ACT_DESCRI,MIN(CLI_FECHA) AS DESDE ,MAX(CLI_FECHA) AS HASTA,COUNT(*)",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="CLI_CODVEN"+GetWhere("=",cCodigo)+;
             IIF(!Empty(oClientes:cScopeOrg)," AND "+oClientes:cScopeOrg,"")

     cTitle:=oDp:XDPACTIVIDAD_E+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPACTIVIDAD_E","ACT_DESCRI","ACT_CODIGO"+GetWhere("=",cCodigo)))+"]"

     oClientes:cListTitle:=cTitle

     oClientes:List(cWhere)
  
  ENDIF

RETURN .T.



/*
// Browse por Clasificación 
*/
FUNCTION BRWXCLA()
  LOCAL cWhere:="",cCodigo:=""
  LOCAL cTitle:="Seleccionar "+oDp:XDPCLICLA,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
 
  cWhere    := " INNER JOIN DPCLICLA ON CLC_CODIGO=CLI_CODCLA "+IF(Empty(oClientes:cScope)," WHERE 1=1 "," WHERE ")+oClientes:cScope

  cOrderBy:=" GROUP BY CLI_ACTIVI ORDER BY CLI_ACTIVI "
  aTitle  :={"Código","Nombre","Desde","Hasta","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"9999"}
  oDp:aSize      :={60,300,60,60,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","CLI_CODCLA,CLC_DESCRI,MIN(CLI_FECHA) AS DESDE ,MAX(CLI_FECHA) AS HASTA,COUNT(*)",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="CLI_CODCLA"+GetWhere("=",cCodigo)+;
             IIF(!Empty(oClientes:cScopeOrg)," AND "+oClientes:cScopeOrg,"")

     cTitle:=oDp:XDPCLICLA+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPCLICLA","CLC_DESCRI","CLC_CODIGO"+GetWhere("=",cCodigo)))+"]"

     oClientes:cListTitle:=cTitle

     oClientes:List(cWhere)
  
  ENDIF

RETURN .T.

FUNCTION FINDXFIELD(cWhere,cTitle)

    IF !Empty(cWhere)

      oClientes:cListTitle:=ALLTRIM(oClientes:cTitle)+" ["+cTitle+"]"
      oClientes:List(cWhere)

    ENDIF

RETURN .T.

FUNCTION SELCAMPOSOP(cValue,cField,cWhere,cTitle)
  LOCAL nAt

  DEFAULT cWhere:=cField+[=LEFT("]+UPPER(cValue)+[",LENGTH(]+cField+[))],;
          cTitle:=""

  nAt   :=AT("(",cTitle)
  cTitle:=IF(nAt>0,LEFT(cTitle,nAt-1),cTitle)

  IF COUNT(oClientes:cTable,cWhere)=0
     MensajeErr("No hay Registros encontrados según "+CRLF+"Campo : "+cTitle+" "+CRLF+"Criterio: "+cValue+"",;
     "Tabla "+GETFROMVAR("{oDp:"+oClientes:cTable+"}"))
     RETURN .F.
  ENDIF

  oClientes:cListTitle:=ALLTRIM(oClientes:cTitle)+" ["+cTitle+"]"
  oClientes:List(cWhere)

RETURN .T.

FUNCTION BRWXCTA()
  LOCAL cWhere:="",cCodigo
  LOCAL cTitle:=" Clientes Agrupados por Cuenta Contable ",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt:=ASCAN(oClientes:aButtons,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oClientes:aButtons[nAt,1],NIL)


  cWhere :=" INNER JOIN DPCTA ON CLI_CTAMOD=CTA_CODMOD AND  CLI_CUENTA=CTA_CODIGO "+;
           " WHERE CLI_CTAMOD"+GetWhere("=",oDp:cCtaMod)


  cOrderBy:=" GROUP BY CTA_CODIGO ORDER BY CTA_CODIGO "
  aTitle  :={"Código;Cuenta","Descripción","Cant.;Reg"}


  oDp:aPicture   :={NIL,NIL,"9999"}
  oDp:aSize      :={120,300,40}
  oDp:lFullHeight:=.T.

  oDp:aLine:={}
  cCodigo:=EJECUTAR("REPBDLIST","VIEW_DPCLIENTESCTA","CTA_CODIGO,CTA_DESCRI,COUNT(*) AS CUANTOS",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(oDp:aLine)

     cWhere:="CTA_CODIGO"+GetWhere("=",cCodigo)
     oClientes:List(cWhere,oClientes:cList)

  ENDIF

RETURN .T.

/*
<LISTA:CLI_CODIGO:Y:GET:Y:N:N:Código,CLI_NOMBRE:N:GET:N:N:N:Nombre,CLI_RIF:N:GET:N:N:Y:R.I.F.,SCROLLGET:N:GET:N:N:N:Para Diversos Campos>
*/

// EOF
