// Programa   : DPCLIENTESRECHUM
// Fecha/Hora : 21/05/2019 07:48:26
// Propósito  : Incluir/Modificar DPCLIENTESREC
// Creado Por : DpXbase
// Llamado por: DPCLIENTESREC.LBX
// Aplicación : Facturación y Clientes                                      
// Tabla      : DPCLIENTESREC

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCLIENTESREC(nOption,cCodigo,cCodCli)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL oDpLbx
  LOCAL cTitle:="Recursos del Cliente",;
         aItems1:=GETOPTIONS("DPCLIENTESREC","CRC_SEXO",NIL,.T.),;
         aItems2:=GETOPTIONS("DPCLIENTESREC","CRC_PARENT",NIL,.T.)

  cExcluye:="CRC_CODIGO,;
             CRC_NOMBRE,;
             CRC_ACTIVO,;
             CRC_ID,;
             CRC_FECHA,;
             CRC_SEXO,;
             CRC_PARENT,;
             CRC_MEMO"

  IF !ISRELEASE("18.12",.T.)
     RETURN .F.
  ENDIF

  oDpLbx:=GetDpLbx(oDp:nNumLbx)

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)<>"A"
     oDpLbx:aCargo:=oDp:aCargo
  ENDIF

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)="A"

     cCodCli:=oDpLbx:aCargo[2] 
     cTitle :=" "+oDp:xDPCLIENTESREC  

  ENDIF

  DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPCLIENTESREC WHERE ]+BuildConcat("CRC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPCLIENTESREC}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPCLIENTESREC WHERE ]+BuildConcat("CRC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Recursos del Cliente                                                            "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPCLIENTESREC}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPCLIENTESREC]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="CRC_CODIGO          " // Clave de Validación de Registro

  oCLIENTESREC:=DPEDIT():New(cTitle,"DPCLIENTESRECHUM.edt","oCLIENTESRECHUM" , .F. )

  oCLIENTESRECHUM:nOption  :=nOption
  oCLIENTESRECHUM:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCLIENTESRECHUM
  oCLIENTESRECHUM:SetScript()        // Asigna Funciones DpXbase como Metodos de oCLIENTESRECHUM
  oCLIENTESRECHUM:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCLIENTESRECHUM:nClrPane:=oDp:nGris

  oCLIENTESRECHUM:cCodCli:=cCodCli

  IF oCLIENTESRECHUM:nOption=1 // Incluir en caso de ser Incremental
     // oCLIENTESRECHUM:RepeatGet(NIL,"CRC_CODIGO") // Repetir Valores
     
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oCLIENTESRECHUM:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : CRC_CODIGO          
  // Uso   : Código                                  
  //
  @ 3.0, 1.0 GET oCLIENTESRECHUM:oCRC_CODIGO  VAR oCLIENTESRECHUM:CRC_CODIGO           ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_CODIGO",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                    FONT oFontG;
                    SIZE 40,10

    oCLIENTESRECHUM:oCRC_CODIGO:cMsg    :="Código"
    oCLIENTESRECHUM:oCRC_CODIGO:cToolTip:="Código"

  @ oCLIENTESRECHUM:oCRC_CODIGO:nTop-08,oCLIENTESRECHUM:oCRC_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_NOMBRE          
  // Uso   : Nombre                                  
  //
  @ 4.8, 1.0 GET oCLIENTESRECHUM:oCRC_NOMBRE  VAR oCLIENTESRECHUM:CRC_NOMBRE           ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_NOMBRE",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                    FONT oFontG;
                    SIZE 800,10

    oCLIENTESRECHUM:oCRC_NOMBRE:cMsg    :="Nombre"
    oCLIENTESRECHUM:oCRC_NOMBRE:cToolTip:="Nombre"

  @ oCLIENTESRECHUM:oCRC_NOMBRE:nTop-08,oCLIENTESRECHUM:oCRC_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_ACTIVO          
  // Uso   : Activo                                  
  //
  @ 6.6, 1.0 CHECKBOX oCLIENTESRECHUM:oCRC_ACTIVO  VAR oCLIENTESRECHUM:CRC_ACTIVO            PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPCLIENTESREC","CRC_ACTIVO",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oCLIENTESRECHUM:oCRC_ACTIVO:cMsg    :="Activo"
    oCLIENTESRECHUM:oCRC_ACTIVO:cToolTip:="Activo"


  //
  // Campo : CRC_ID              
  // Uso   : Identificación                          
  //
  @ 8.4, 1.0 GET oCLIENTESRECHUM:oCRC_ID  VAR oCLIENTESRECHUM:CRC_ID               ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_ID",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                    FONT oFontG;
                    SIZE 48,10

    oCLIENTESRECHUM:oCRC_ID:cMsg    :="Identificación"
    oCLIENTESRECHUM:oCRC_ID:cToolTip:="Identificación"

  @ oCLIENTESRECHUM:oCRC_ID:nTop-08,oCLIENTESRECHUM:oCRC_ID:nLeft SAY "Identificación" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_FECHA           
  // Uso   : Fecha                                   
  //
  @ 10.2, 1.0 BMPGET oCLIENTESRECHUM:oCRC_FECHA  VAR oCLIENTESRECHUM:CRC_FECHA             PICTURE "99/99/9999";
          NAME "BITMAPS\\Calendar.bmp";
          ACTION LbxDate(oCLIENTESRECHUM:oCRC_FECHA,oCLIENTESRECHUM:CRC_FECHA);
                    WHEN (AccessField("DPCLIENTESREC","CRC_FECHA",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                    FONT oFontG;
                    SIZE 32,10

    oCLIENTESRECHUM:oCRC_FECHA:cMsg    :="Fecha"
    oCLIENTESRECHUM:oCRC_FECHA:cToolTip:="Fecha"

  @ oCLIENTESRECHUM:oCRC_FECHA:nTop-08,oCLIENTESRECHUM:oCRC_FECHA:nLeft SAY "Fecha" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_SEXO            
  // Uso   : Sexo                                    
  //

   IF Empty(aItems1)
     AADD(aItems1,"Indefinido")
   ENDIF 

  @ 11.5, 1.0 COMBOBOX oCLIENTESRECHUM:oCRC_SEXO VAR oCLIENTESRECHUM:CRC_SEXO             ITEMS aItems1;
                      WHEN (AccessField("DPCLIENTESREC","CRC_SEXO",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                      FONT oFontG;


 ComboIni(oCLIENTESRECHUM:oCRC_SEXO)


    oCLIENTESRECHUM:oCRC_SEXO:cMsg    :="Sexo"
    oCLIENTESRECHUM:oCRC_SEXO:cToolTip:="Sexo"

  @ oCLIENTESRECHUM:oCRC_SEXO:nTop-08,oCLIENTESRECHUM:oCRC_SEXO:nLeft SAY "Sexo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_PARENT          
  // Uso   : Parentesco                              
  //

   IF Empty(aItems2)
     AADD(aItems2,"Indefinido")
   ENDIF 

  @ 0.5,15.0 COMBOBOX oCLIENTESRECHUM:oCRC_PARENT VAR oCLIENTESRECHUM:CRC_PARENT           ITEMS aItems2;
                      WHEN (AccessField("DPCLIENTESREC","CRC_PARENT",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                      FONT oFontG;


 ComboIni(oCLIENTESRECHUM:oCRC_PARENT)


    oCLIENTESRECHUM:oCRC_PARENT:cMsg    :="Parentesco"
    oCLIENTESRECHUM:oCRC_PARENT:cToolTip:="Parentesco"

  @ oCLIENTESRECHUM:oCRC_PARENT:nTop-08,oCLIENTESRECHUM:oCRC_PARENT:nLeft SAY "Parentesco" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



          oCLIENTESRECHUM:CRC_MEMO:=ALLTRIM(oCLIENTESRECHUM:CRC_MEMO)  //
  // Campo : CRC_MEMO            
  // Uso   : Comentarios                             
  //
  @ 2.3,15.0 GET oCLIENTESRECHUM:oCRC_MEMO  VAR oCLIENTESRECHUM:CRC_MEMO            ;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("DPCLIENTESREC","CRC_MEMO",oCLIENTESRECHUM:nOption);
                    .AND. (oCLIENTESRECHUM:nOption=1 .OR. oCLIENTESRECHUM:nOption=3));
                    FONT oFontG;
                    SIZE 0,10

    oCLIENTESRECHUM:oCRC_MEMO:cMsg    :="Comentarios"
    oCLIENTESRECHUM:oCRC_MEMO:cToolTip:="Comentarios"

  @ oCLIENTESRECHUM:oCRC_MEMO:nTop-08,oCLIENTESRECHUM:oCRC_MEMO:nLeft SAY "Comentarios" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  oCLIENTESRECHUM:oScroll:=oCLIENTESRECHUM:SCROLLGET("DPCLIENTESREC","DPCLIENTESRECHUM.SCG",cExcluye)

  oCLIENTESRECHUM:oScroll:SetColSize(200,250+15,215)

  oCLIENTESRECHUM:oScroll:SetColorHead(CLR_WHITE , 16744448,oFont) 

  oCLIENTESRECHUM:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 
  oCLIENTESRECHUM:oScroll:SetColor(16773862 , CLR_BLACK , 2 , 16771538 , oFont ) 
  oCLIENTESRECHUM:oScroll:SetColor(16773862 , CLR_GRAY  , 3 , 16771538 , oFont ) 

  oCLIENTESRECHUM:Activate({||oCLIENTESRECHUM:ViewDatBar()})


  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCLIENTESRECHUM

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,nLin:=0
   LOCAL oDlg:=oCLIENTESRECHUM:oDlg


   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor


   IF ValType(oCLIENTESRECHUM:oScroll)="O"
      oCLIENTESRECHUM:oScroll:oBrw:SetColor(NIL , 16773862 )
   ENDIF

   IF oCLIENTESRECHUM:nOption=2 


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\\XSALIR.BMP";
            ACTION (oCLIENTESRECHUM:Close())

     oBtn:cToolTip:="Salir"

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\\XSAVE.BMP";
            ACTION (oCLIENTESRECHUM:Save())

     oBtn:cToolTip:="Grabar"

     DEFINE BUTTON oBtn;
            OF oBar;
            FONT oFont;
            NOBORDER;
            FILENAME "BITMAPS\\XCANCEL.BMP";
            ACTION (oCLIENTESRECHUM:Cancel()) CANCEL

     oBtn:cToolTip:="Cancelar"

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   // Controles se Inician luego del Ultimo Boton
   nLin:=32
   AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

   @ 2,nLin+2 SAY " "+oDp:xDPCLIENTES+" " OF oBar;
       BORDER SIZE 95,20 PIXEL FONT oFont COLOR CLR_WHITE,16752190 RIGHT

   @ 22,nLin+2 SAY " Nombre " OF oBar;
       BORDER SIZE 95,20 PIXEL FONT oFont COLOR CLR_WHITE,16752190 RIGHT

   @ 2,nLin+97 SAY " "+oCLIENTESRECHUM:cCodCli+" " OF oBar;
       BORDER SIZE 95,20 PIXEL FONT oFont COLOR CLR_WHITE,16761992 

   @ 22,nLin+97 SAY " "+SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCLIENTESRECHUM:cCodCli))+" " OF oBar;
       BORDER SIZE 295,20 PIXEL FONT oFont COLOR CLR_WHITE,16761992 

RETURN .T.


/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCLIENTESRECHUM:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
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

  oCLIENTESRECHUM:CRC_CODCLI:=oCLIENTESRECHUM:cCodCli
  oCLIENTESRECHUM:CRC_TIPO  :="Humano"

  // Condiciones para no Repetir el Registro

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

/*
<LISTA:CRC_CODIGO:N:GET:N:N:Y:Código,CRC_NOMBRE:N:GET:N:N:Y:Nombre,CRC_ACTIVO:N:CHECKBOX:N:N:Y:Activo,CRC_ID:N:GET:N:N:Y:Identificación
,CRC_FECHA:N:BMPGET:N:N:Y:Fecha,CRC_SEXO:N:COMBO:N:N:Y:Sexo,CRC_PARENT:N:COMBO:N:N:Y:Parentesco,CRC_MEMO:N:MGET:N:N:Y:Comentarios
,SCROLLGET:N:GET:N:N:N:Para Diversos Campos>
*/
