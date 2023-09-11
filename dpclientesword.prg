// Programa   : DPCLIENTESWORD
// Fecha/Hora : 09/12/2006 18:58:53
// Propósito  : Incluir/Modificar DPCLIENTESWORD
// Creado Por : DpXbase
// Llamado por: DPCLIENTESWORD.LBX
// Aplicación : Administración del Sistema              
// Tabla      : DPCLIENTESWORD

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCLIENTESWORD(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:="",aModelos:={},aDescri:={}
  LOCAL nClrText,nAt
  LOCAL cTitle:="Modelos de Cartas para Clientes"

  cExcluye:="DOC_DESCRI,;
             DOC_FILE,;
             DOC_MEMO"

  aModelos:={}
  aDescri :={}
  aModelos:=ASQL("SELECT CLC_CODIGO,CLC_DESCRI FROM DPCLICORRESPOND WHERE CLC_ACTIVO=1")
  AEVAL(aModelos,{|a,n| aModelos[n]:=a[1] ,;
                        AADD(aDescri,a[2]) })

  AADD(aModelos,"Ninguno")
  AADD(aDescri ,"Ninguno")

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

   nOption:=IIF(nOption=2,0,nOption) 

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPCLIENTESWORD WHERE ]+BuildConcat("DOC_DESCRI")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPCLIENTESWORD}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPCLIENTESWORD WHERE ]+BuildConcat("DOC_DESCRI")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Modelos de Cartas para Clientes         "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPCLIENTESWORD}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPCLIENTESWORD]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="DOC_DESCRI" // Clave de Validación de Registro
  nAt:=ASCAN(aModelos,ALLTRIM(oTable:DOC_CORRES))
  nAt:=IF(nAt=0,LEN(aModelos),nAt)
  
  oCLIENTESWORD:=DPEDIT():New(cTitle,"DPCLIENTESWORD.edt","oCLIENTESWORD" , .F. )

  oCLIENTESWORD:aDescri  :=ACLONE(aDescri)
  oCLIENTESWORD:aModelos :=ACLONE(aModelos)
  oCLIENTESWORD:nOption  :=nOption
  oCLIENTESWORD:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCLIENTESWORD
  oCLIENTESWORD:SetScript()        // Asigna Funciones DpXbase como Metodos de oCLIENTESWORD
  oCLIENTESWORD:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCLIENTESWORD:nClrPane:=oDp:nGris

  IF oCLIENTESWORD:nOption=1 // Incluir en caso de ser Incremental
     // oCLIENTESWORD:RepeatGet(NIL,"DOC_DESCRI") // Repetir Valores
     
     // AutoIncremental 
  ENDIF

  oCLIENTESWORD:DOC_CORRES:=aDescri[nAt]
  //Tablas Relacionadas con los Controles del Formulario

  oCLIENTESWORD:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : DOC_DESCRI
  // Uso   : Descripción                             
  //
  @ 1.0, 1.0 GET oCLIENTESWORD:oDOC_DESCRI  VAR oCLIENTESWORD:DOC_DESCRI  VALID oCLIENTESWORD:ValUnique(oCLIENTESWORD:DOC_DESCRI);
                   .AND. !VACIO(oCLIENTESWORD:DOC_DESCRI,NIL);
                    WHEN (AccessField("DPCLIENTESWORD","DOC_DESCRI",oCLIENTESWORD:nOption);
                    .AND. oCLIENTESWORD:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCLIENTESWORD:oDOC_DESCRI:cMsg    :="Descripción"
    oCLIENTESWORD:oDOC_DESCRI:cToolTip:="Descripción"

  @ oCLIENTESWORD:oDOC_DESCRI:nTop-08,oCLIENTESWORD:oDOC_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : DOC_FILE  
  // Uso   : Dirección del Archivo                   
  //
  @ 2.8, 1.0 BMPGET oCLIENTESWORD:oDOC_FILE    VAR oCLIENTESWORD:DOC_FILE   ;
          NAME "BITMAPS\FIND.BMP";
          ACTION  (cFile:=cGetFile32("Fichero(*.*) |*.*|Ficheros (*.*) |*.*",;
                    "Seleccionar Archivo (*.*)",1,cFilePath(oCLIENTESWORD:DOC_FILE),.f.,.t.),;
                    cFile:=STRTRAN(cFile,"/","/"),;
                    oCLIENTESWORD:DOC_FILE:=IIF(!EMPTY(cFile),cFile,oCLIENTESWORD:DOC_FILE),;
                    oCLIENTESWORD:oDOC_FILE:VarPut(oCLIENTESWORD:DOC_FILE,.T.),;
                    DPFOCUS(oCLIENTESWORD:oDOC_FILE));
                    WHEN (AccessField("DPCLIENTESWORD","DOC_FILE",oCLIENTESWORD:nOption);
                    .AND. oCLIENTESWORD:nOption!=0);
                    FONT oFontG;
                    SIZE 200,10

    oCLIENTESWORD:oDOC_FILE  :cMsg    :="Dirección del Archivo"
    oCLIENTESWORD:oDOC_FILE  :cToolTip:="Dirección del Archivo"

  @ oCLIENTESWORD:oDOC_FILE  :nTop-08,oCLIENTESWORD:oDOC_FILE  :nLeft SAY "Dirección del Archivo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



          oCLIENTESWORD:DOC_MEMO:=ALLTRIM(oCLIENTESWORD:DOC_MEMO)  //
  // Campo : DOC_MEMO  
  // Uso   : Instrucciones de Uso                    
  //
  @ 4.6, 1.0 GET oCLIENTESWORD:oDOC_MEMO    VAR oCLIENTESWORD:DOC_MEMO  ;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("DPCLIENTESWORD","DOC_MEMO",oCLIENTESWORD:nOption);
                    .AND. oCLIENTESWORD:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oCLIENTESWORD:oDOC_MEMO  :cMsg    :="Instrucciones de Uso"
    oCLIENTESWORD:oDOC_MEMO  :cToolTip:="Instrucciones de Uso"

  @ oCLIENTESWORD:oDOC_MEMO  :nTop-08,oCLIENTESWORD:oDOC_MEMO  :nLeft SAY "Instrucciones de Uso" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : DOC_LMAIL 
  // Enviar por Correo
  //

  @ 12.0, 100 CHECKBOX oCLIENTESWORD:oDOC_LMAIL     VAR oCLIENTESWORD:DOC_LMAIL     PROMPT ANSITOOEM("Para Enviar por Correo");
                    WHEN (AccessField("DPCLIENTESWORD","DOC_LMAIL",oCLIENTESWORD:nOption);
                    .AND. oCLIENTESWORD:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oCLIENTESWORD:oDOC_LMAIL   :cMsg    :="Para enviar por Correo"
    oCLIENTESWORD:oDOC_LMAIL   :cToolTip:="Para enviar poe Correo"


  //
  // Campo : DOC_CORRES   
  // Uso   : Correspondecia para Enviar la Carta
  //
  @ 12, 1.0 COMBOBOX oCLIENTESWORD:oDOC_CORRES    VAR oCLIENTESWORD:DOC_CORRES    ITEMS aDescri;
                      WHEN (AccessField("DPCLIENTESWORD","DOC_CORRES",oCLIENTESWORD:nOption);
                     .AND. oCLIENTESWORD:nOption!=0;
                     .AND. oCLIENTESWORD:DOC_LMAIL ;
                     .AND. LEN(oCLIENTESWORD:oDOC_CORRES:aItems)>1);
                      FONT oFontG


  ComboIni(oCLIENTESWORD:oDOC_CORRES   )

  oCLIENTESWORD:oDOC_CORRES   :cMsg    :="Documento de Correspondecia"
  oCLIENTESWORD:oDOC_CORRES   :cToolTip:="Documento de Correspondencia"

  @  oCLIENTESWORD:oDOC_CORRES:nTop-08, oCLIENTESWORD:oDOC_CORRES:nLeft SAY "Carta de Correspondencia" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCLIENTESWORD:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oCLIENTESWORD:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCLIENTESWORD:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF


  oCLIENTESWORD:Activate(NIL)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCLIENTESWORD

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCLIENTESWORD:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
     oCLIENTESWORD:DOC_MEMO:=""
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.
  LOCAL cExt :=cFileExt(oCLIENTESWORD:DOC_FILE)

  lResp:=oCLIENTESWORD:ValUnique(oCLIENTESWORD:DOC_DESCRI)

  IF !lResp
    MsgAlert("Registro "+CTOO(oCLIENTESWORD:DOC_DESCRI),"Ya Existe")
  ENDIF

  IF EMPTY(oCLIENTESWORD:DOC_DESCRI)
     MensajeErr("Descripción no Puede estar Vacia")
     RETURN .F.
  ENDIF

  IF LEN(cExt)>3 .AND. UPPE(RIGHT(cExt,1))="X"
     MensajeErr("Extensión "+cExt+" no Valida ")
     RETURN .F.
  ENDIF

  oCLIENTESWORD:DOC_CORRES:=oCLIENTESWORD:aModelos[oCLIENTESWORD:oDOC_CORRES:nAt]

  IF oCLIENTESWORD:oDOC_CORRES:nAt=LEN(oCLIENTESWORD:oDOC_CORRES:aItems) .OR. !oCLIENTESWORD:DOC_LMAIL
    oCLIENTESWORD:DOC_CORRES:=""
  ENDIF

  oCLIENTESWORD:DOC_CODSUC:=oDp:cSucursal

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
    LOCAL nNumFil:=0

    IF DPVERSION()>4

      MsgRun("Almacenando Archivo : "+ALLTRIM(oCLIENTESWORD:DOC_FILE),"Por favor Espere..",;
             {||nNumFil:=EJECUTAR("DPFILEEMPSAV",oCLIENTESWORD:DOC_FILE,"DPCLIENTESWORD",NIL,oCLIENTESWORD:DOC_DESCRI)})

      SQLUPDATE("DPCLIENTESWORD","DOC_FILNUM",nNumFil,"DOC_DESCRI"+GetWhere("=",oCLIENTESWORD:DOC_DESCRI))

    ENDIF

RETURN .T.

/*
<LISTA:DOC_DESCRI:Y:GET:N:N:N:Descripción,DOC_FILE:N:BMPGETF:N:N:Y:Dirección del Archivo,DOC_MEMO:N:MGET:N:N:Y:Instrucciones de Uso>
*/
