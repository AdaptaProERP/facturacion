// Programa   : DPCLIENTESBUSCAR
// Fecha/Hora : 02/12/2015 16:08:03
// Propósito  : Buscar Clientes por Nombre, Correo o telefono
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(lMdi)
   LOCAL aData:={},cTitle:="Buscar Clientes Según Persona"
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB
   LOCAL cMail  :=SPACE(100)
   LOCAL oData  :=DATASET("DPCLIENTESBUSCAR","USER")
   LOCAL lExacto:=oData:Get("lExacto",.F.)
 
   oData:=DATASET("REGION","ALL")
   oData:End(.F.)

   DEFAULT lMdi:=.F.

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"DPCLIENTESBUSCAR.EDT","oCliFind",.T.,!lMdi)

   oCliFind:lMsgBar  :=.F.
   oCliFind:cNombre  :=SPACE(60)
   oCliFind:cTel     :=SPACE(15)
   oCliFind:cEmail   :=cMail
   oCliFind:lMdi     :=lMdi
   oCliFind:oBtnRun  :=NIL
   oCliFind:cCodigo  :=""
   oCliFind:lExacto  :=lExacto
 
   @ 5,1 SAY "Nombre"          RIGHT
   @ 6,1 SAY "Telefono:"       RIGHT
   @ 7,1 SAY "Correo o eMail:" RIGHT

   @ 3,1 GET oCliFind:oNombre VAR oCliFind:cNombre

   oCliFind:oNombre:bKeyDown:= {|nKey| oCliFind:oBtnRun:ForWhen(.T.),;
                                       IIF(nKey=13 .AND. !Empty(oCliFind:cNombre),;
                                       oCliFind:RunClientes(oCliFind:oBrw), NIL )}

   @ 4,1 GET oCliFind:oTel    VAR oCliFind:cTel

   oCliFind:oTel:bKeyDown:= {|nKey|IIF(nKey=13 .AND. !Empty(oCliFind:cTel),;
                                   oCliFind:RunClientes(oCliFind:oBrw), NIL )}

   @ 5,1 GET oCliFind:oEmail  VAR oCliFind:cEmail 

   @ 6,1 CHECKBOX oCliFind:lExacto  PROMPT ANSITOOEM("Búsqueda exacta")


   oCliFind:Activate({||oCliFind:ViewDatBar()})

RETURN oCliFind:cCodigo

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn
   LOCAL oDlg:=oCliFind:oDlg

   oDlg:Move(100,0)
 
   DEFINE CURSOR oCursor HAND

   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFontB  NAME "Arial"   SIZE 0, -14 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION oCliFind:RunClientes();
          WHEN !Empty(oCliFind:cNombre+oCliFind:cTel+oCliFind:cEmail)

   oBtn:cToolTip:="Ejecutar Consulta"

   oCliFind:oBtnRun:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliFind:Close()

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  oCliFind:oBar:=oBar

RETURN .T.

/*
// Ejecutar Clientes
*/
FUNCTION RUNCLIENTES(oBrw)
   LOCAL cWhere:="",aData:={},aDataCli:={},I,aNombre:={},cWhereN:="",cSql:="",cWhereP:=""
   LOCAL oData  :=DATASET("DPCLIENTESBUSCAR","USER")

   oData:Set("lExacto",oCliFind:lExacto)
   oData:End(.T.)


   IF !Empty(oCliFind:cNombre)

     aNombre:=_VECTOR(STRTRAN(ALLTRIM(oCliFind:cNombre)," ",","))

     cWhereP :="PDC_PERSON"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cNombre)+"%")

     IF LEN(aNombre)>1
       AEVAL(aNombre,{|a,n|aNombre[n]:="%"+a+"%" })
       cWhereP:=cWhereP+" OR "+STRTRAN(GetWhereOr("PDC_PERSON",aNombre," LIKE ")," OR "," AND ")
     ENDIF

     IF oDp:nVersion>=5 .AND. !oCliFind:lExacto
        cWhereN:=EJECUTAR("FINDSOUND",oCliFind:cNombre,"PDC_PERSON")
     ENDIF

     IF !Empty(cWhereN)
        cWhereP:=cWhereP+" OR ("+cWhereN+")"
     ENDIF

   ENDIF

   IF !Empty(oCliFind:cTel)

     cWhere:=cWhere + IIF( Empty(cWhere)," ", " OR ")+;
              "PDC_TELEFO"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cTel)+"%")+;
              " OR PDC_CELULA"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cTel)+"%")

   ENDIF


   IF !Empty(oCliFind:cEmail)
     cWhereP:=IIF( !Empty(cWhereP)," OR ", "")+ "PDC_EMAIL"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cEmail)+"%")
   ENDIF

//   IF !Empty(oCliFind:aCorreos) .AND. Empty(cWhereP)
//      cWhereP:=GetWhereOr("PDC_EMAIL",aCorreos)
//   ENDIF

   cWhere:=""

   cWhereN:=""

   IF !Empty(oCliFind:cNombre)

     cWhere:="CLI_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cNombre)+"%")

     aNombre:=_VECTOR(STRTRAN(ALLTRIM(oCliFind:cNombre)," ",","))
     // cWhereP:=""

     IF LEN(aNombre)>1

       AEVAL(aNombre,{|a,n|aNombre[n]:="%"+a+"%" })

       cWhereP:=STRTRAN(GetWhereOr("CLI_NOMBRE",aNombre," LIKE ")," OR "," AND ")
       cWhere :=cWhere +" OR "+cWhereP

     ENDIF

     IF !oCliFind:lExacto
        cWhereN:=EJECUTAR("FINDSOUND",oCliFind:cNombre,"CLI_NOMBRE","LIKE")
        cWhere :=cWhere+" OR "+cWhereN
     ENDIF

     cWhereN:=""

   ENDIF

   IF !Empty(oCliFind:cTel)

       FOR I=1 TO 6

           cWhere:=cWhere + IIF( !Empty(cWhere)," OR ", "")+ "CLI_TEL"+LSTR(I)+;
                   GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cTel)+"%")

       NEXT I

       FOR I=1 TO 2

           cWhere:=cWhere + " OR "+  "CLI_CELUL"+LSTR(I)+;
                   GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cTel)+"%")

       NEXT I

    ENDIF

    IF !Empty(oCliFind:cEmail)
       cWhere:=IIF( !Empty(cWhere)," OR ", "")+ "CLI_EMAIL"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cEmail)+"%")

       cWhere:=cWhere + IIF( !Empty(cWhere)," OR ", "")+ "CLI_WEB"+GetWhere(" LIKE ","%"+ALLTRIM(oCliFind:cEmail)+"%")

    ENDIF

    cWhere:=" LEFT JOIN DPCLIENTESPER ON CLI_CODIGO=PDC_CODIGO  "+;
            " WHERE "+cWhere+;
            IF(!Empty(cWhereP)," OR ","")+cWhereP

    IF COUNT("DPCLIENTES",cWhere)=0
       oCliFind:oNombre:MsgErr("No hay Registros")
       RETURN .F.
    ENDIF

// ? CLPCOPY(oDp:cSql)

    oCliFind:cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","CLI_CODIGO,CLI_NOMBRE,CLI_TEL1,CLI_TEL2,CLI_EMAIL,PDC_PERSON",.T.,cWhere,"Buscar Clientes",NIL,NIL,NIL,NIL,NIL,oCliFind:oBar,NIL)

    IF !Empty(oCliFind:cCodigo)
       oCliFind:Close()
    ENDIF
 
RETURN NIL

// EOF



