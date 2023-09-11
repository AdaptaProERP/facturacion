// Programa   : DPCLIENTESRECVEH
// Fecha/Hora : 21/05/2019 07:48:26
// Propósito  : Incluir/Modificar DPCLIENTESREC
// Creado Por : DpXbase
// Llamado por: DPCLIENTESREC.LBX
// Aplicación : Facturación y Clientes                                      
// Tabla      : Recurso del Cliente Vehiculo

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCLIENTESREC(nOption,cCodigo,cCodCli)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL oDpLbx
  LOCAL cTitle:="Recursos del Cliente ["+oDp:DPCLIENTESREC_VEHICULO+"]",;
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

  oCLIENTESREC:=DPEDIT():New(cTitle,"DPCLIENTESRECHUM.edt","oCLIENTESRECVEH" , .F. )

  oCLIENTESRECVEH:nOption  :=nOption
  oCLIENTESRECVEH:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCLIENTESRECVEH
  oCLIENTESRECVEH:SetScript()        // Asigna Funciones DpXbase como Metodos de oCLIENTESRECVEH
  oCLIENTESRECVEH:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCLIENTESRECVEH:nClrPane:=oDp:nGris

  oCLIENTESRECVEH:cCodCli:=cCodCli

  IF oCLIENTESRECVEH:nOption=1 // Incluir en caso de ser Incremental
     // oCLIENTESRECVEH:RepeatGet(NIL,"CRC_CODIGO") // Repetir Valores
     
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oCLIENTESRECVEH:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : CRC_CODIGO          
  // Uso   : Código                                  
  //
  @ 3.0, 1.0 GET oCLIENTESRECVEH:oCRC_CODIGO  VAR oCLIENTESRECVEH:CRC_CODIGO           ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_CODIGO",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                    FONT oFontG;
                    SIZE 40,10

    oCLIENTESRECVEH:oCRC_CODIGO:cMsg    :="Código"
    oCLIENTESRECVEH:oCRC_CODIGO:cToolTip:="Código"

  @ oCLIENTESRECVEH:oCRC_CODIGO:nTop-08,oCLIENTESRECVEH:oCRC_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_NOMBRE          
  // Uso   : Nombre                                  
  //
  @ 4.8, 1.0 GET oCLIENTESRECVEH:oCRC_NOMBRE  VAR oCLIENTESRECVEH:CRC_NOMBRE           ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_NOMBRE",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                    FONT oFontG;
                    SIZE 800,10

    oCLIENTESRECVEH:oCRC_NOMBRE:cMsg    :="Nombre"
    oCLIENTESRECVEH:oCRC_NOMBRE:cToolTip:="Nombre"

  @ oCLIENTESRECVEH:oCRC_NOMBRE:nTop-08,oCLIENTESRECVEH:oCRC_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_ACTIVO          
  // Uso   : Activo                                  
  //
  @ 6.6, 1.0 CHECKBOX oCLIENTESRECVEH:oCRC_ACTIVO  VAR oCLIENTESRECVEH:CRC_ACTIVO            PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPCLIENTESREC","CRC_ACTIVO",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oCLIENTESRECVEH:oCRC_ACTIVO:cMsg    :="Activo"
    oCLIENTESRECVEH:oCRC_ACTIVO:cToolTip:="Activo"


IF .F.

  //
  // Campo : CRC_ID              
  // Uso   : Identificación                          
  //
  @ 8.4, 1.0 GET oCLIENTESRECVEH:oCRC_ID  VAR oCLIENTESRECVEH:CRC_ID               ;
                    WHEN (AccessField("DPCLIENTESREC","CRC_ID",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                    FONT oFontG;
                    SIZE 48,10

    oCLIENTESRECVEH:oCRC_ID:cMsg    :="Identificación"
    oCLIENTESRECVEH:oCRC_ID:cToolTip:="Identificación"

  @ oCLIENTESRECVEH:oCRC_ID:nTop-08,oCLIENTESRECVEH:oCRC_ID:nLeft SAY "Identificación" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_FECHA           
  // Uso   : Fecha                                   
  //
  @ 10.2, 1.0 BMPGET oCLIENTESRECVEH:oCRC_FECHA  VAR oCLIENTESRECVEH:CRC_FECHA             PICTURE "99/99/9999";
          NAME "BITMAPS\\Calendar.bmp";
          ACTION LbxDate(oCLIENTESRECVEH:oCRC_FECHA,oCLIENTESRECVEH:CRC_FECHA);
                    WHEN (AccessField("DPCLIENTESREC","CRC_FECHA",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                    FONT oFontG;
                    SIZE 32,10

    oCLIENTESRECVEH:oCRC_FECHA:cMsg    :="Fecha"
    oCLIENTESRECVEH:oCRC_FECHA:cToolTip:="Fecha"

  @ oCLIENTESRECVEH:oCRC_FECHA:nTop-08,oCLIENTESRECVEH:oCRC_FECHA:nLeft SAY "Fecha" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_SEXO            
  // Uso   : Sexo                                    
  //

   IF Empty(aItems1)
     AADD(aItems1,"Indefinido")
   ENDIF 

  @ 11.5, 1.0 COMBOBOX oCLIENTESRECVEH:oCRC_SEXO VAR oCLIENTESRECVEH:CRC_SEXO             ITEMS aItems1;
                      WHEN (AccessField("DPCLIENTESREC","CRC_SEXO",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                      FONT oFontG;


 ComboIni(oCLIENTESRECVEH:oCRC_SEXO)


    oCLIENTESRECVEH:oCRC_SEXO:cMsg    :="Sexo"
    oCLIENTESRECVEH:oCRC_SEXO:cToolTip:="Sexo"

  @ oCLIENTESRECVEH:oCRC_SEXO:nTop-08,oCLIENTESRECVEH:oCRC_SEXO:nLeft SAY "Sexo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : CRC_PARENT          
  // Uso   : Parentesco                              
  //

   IF Empty(aItems2)
     AADD(aItems2,"Indefinido")
   ENDIF 

  @ 0.5,15.0 COMBOBOX oCLIENTESRECVEH:oCRC_PARENT VAR oCLIENTESRECVEH:CRC_PARENT           ITEMS aItems2;
                      WHEN (AccessField("DPCLIENTESREC","CRC_PARENT",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                      FONT oFontG;


 ComboIni(oCLIENTESRECVEH:oCRC_PARENT)


    oCLIENTESRECVEH:oCRC_PARENT:cMsg    :="Parentesco"
    oCLIENTESRECVEH:oCRC_PARENT:cToolTip:="Parentesco"

  @ oCLIENTESRECVEH:oCRC_PARENT:nTop-08,oCLIENTESRECVEH:oCRC_PARENT:nLeft SAY "Parentesco" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



ENDIF

  oCLIENTESRECVEH:CRC_MEMO:=ALLTRIM(oCLIENTESRECVEH:CRC_MEMO)  //
  // Campo : CRC_MEMO            
  // Uso   : Comentarios                             
  //
  @ 2.3,15.0 GET oCLIENTESRECVEH:oCRC_MEMO  VAR oCLIENTESRECVEH:CRC_MEMO            ;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("DPCLIENTESREC","CRC_MEMO",oCLIENTESRECVEH:nOption);
                    .AND. (oCLIENTESRECVEH:nOption=1 .OR. oCLIENTESRECVEH:nOption=3));
                    FONT oFontG;
                    SIZE 0,10

    oCLIENTESRECVEH:oCRC_MEMO:cMsg    :="Comentarios"
    oCLIENTESRECVEH:oCRC_MEMO:cToolTip:="Comentarios"

  @ oCLIENTESRECVEH:oCRC_MEMO:nTop-08,oCLIENTESRECVEH:oCRC_MEMO:nLeft SAY "Comentarios" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  oCLIENTESRECVEH:oScroll:=oCLIENTESRECVEH:SCROLLGET("DPCLIENTESREC","DPCLIENTESRECVEH.SCG",cExcluye)

  oCLIENTESRECVEH:oScroll:SetColSize(200,250+15,215)

  oCLIENTESRECVEH:oScroll:SetColorHead(CLR_WHITE , 16744448,oFont) 

  oCLIENTESRECVEH:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 
  oCLIENTESRECVEH:oScroll:SetColor(16773862 , CLR_BLACK , 2 , 16771538 , oFont ) 
  oCLIENTESRECVEH:oScroll:SetColor(16773862 , CLR_GRAY  , 3 , 16771538 , oFont ) 

  oCLIENTESRECVEH:Activate({||oCLIENTESRECVEH:ViewDatBar()})


  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCLIENTESRECVEH

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,nLin:=0
   LOCAL oDlg:=oCLIENTESRECVEH:oDlg


   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor


   IF ValType(oCLIENTESRECVEH:oScroll)="O"
      oCLIENTESRECVEH:oScroll:oBrw:SetColor(NIL , 16773862 )
   ENDIF

   IF oCLIENTESRECVEH:nOption=2 


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\\XSALIR.BMP";
            ACTION (oCLIENTESRECVEH:Close())

     oBtn:cToolTip:="Salir"

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\\XSAVE.BMP";
            ACTION (oCLIENTESRECVEH:Save())

     oBtn:cToolTip:="Grabar"


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\ADJUNTAR.BMP";
            ACTION oCLIENTESRECVEH:CRC_FILMAI:=EJECUTAR("DPFILEEMPMAIN",oCLIENTESRECVEH:CRC_FILMAI)

     oBtn:cToolTip:="Adjuntar Digitales"

     DEFINE BUTTON oBtn;
            OF oBar;
            FONT oFont;
            NOBORDER;
            FILENAME "BITMAPS\\XCANCEL.BMP";
            ACTION (oCLIENTESRECVEH:Cancel()) CANCEL

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

   @ 2,nLin+97 SAY " "+oCLIENTESRECVEH:cCodCli+" " OF oBar;
       BORDER SIZE 95,20 PIXEL FONT oFont COLOR CLR_WHITE,16761992 

   @ 22,nLin+97 SAY " "+SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCLIENTESRECVEH:cCodCli))+" " OF oBar;
       BORDER SIZE 295,20 PIXEL FONT oFont COLOR CLR_WHITE,16761992 

RETURN .T.


/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCLIENTESRECVEH:nOption=1 // Incluir en caso de ser Incremental
     
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

  oCLIENTESRECVEH:CRC_CODCLI:=oCLIENTESRECVEH:cCodCli
  oCLIENTESRECVEH:CRC_TIPO  :=oDp:DPCLIENTESREC_VEHICULO

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

