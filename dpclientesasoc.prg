// Programa   : DPCLIENTESASOC
// Fecha/Hora : 08/01/2006 13:14
// Prop¢sito  : Asociar Cliente con Otro Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESMNU
// Aplicaci¢n : Ventas
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
  LOCAL oBtn,oFont,cCodAso:=SPACE(10),cComent:=SPACE(80)

  DEFAULT cCodCli:=STRZERO(1,10)

  cCodAso:=SQLGET("DPCLIASOC","CCA_CODCLI,CCA_COMENT","CCA_CODIGO"+GetWhere("=",cCodCli))

  IF !Empty(oDp:aRow)
     cComent:=oDp:aRow[2]
  ENDIF

  DPEDIT():New("Asociar "+oDp:xDPCLIENTES+" "+cCodCli,"forms\dpcliasocia.edt","oCliAso",.T.)

  oCliAso:cCodCli:=cCodCli
  oCliAso:cCodAso:=cCodAso
  oCliAso:cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCliAso:cCodCli))
  oCliAso:cComent:=cComent
  oCliAso:lMsgBar:=.F.

  @ 6.4, 1.0 GROUP oCliAso:oGroup TO 11.4,6 PROMPT "Asociar con "

  @ 3,2 SAY "Nombre:" RIGHT
  @ 3,2 SAY "Código:" RIGHT

  // CLIENTE

  @ .1,06 BMPGET oCliAso:oCodAso VAR oCliAso:cCodAso;
                 VALID CERO(oCliAso:cCodAso,NIL,.T.) .AND.;
                            oCliAso:FindCodCli();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPCLIENTES",NIL,NIL),;
                         oDpLbx:GetValue("CLI_CODIGO",oCliAso:oCodAso)); 
                 SIZE 48,10

  @ 3,2 SAY oCliAso:oNombre PROMPT SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCliAso:cCodAso));
            UPDATE

  @ 3,2 SAY oCliAso:cNombre 

  @ 3,2 SAY "Comentarios"

  @ 3,2 GET oCliAso:oComent VAR oCliAso:cComent 

/*
  @09, 33  SBUTTON oBtn ;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\XSAVE.BMP" ;
           LEFT PROMPT "Grabar";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (CursorWait(),;
                   oCliAso:GRABARCLI())

  @10, 20  SBUTTON oBtn ;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\XSALIR.BMP" ;
           LEFT PROMPT "Cerrar";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (CursorWait(),;
                   oCliAso:Close())
*/

  oCliAso:Activate({||oCliAso:INICIO()})

RETURN .t.

FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oCliAso:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          ACTION oCliAso:GRABARCLI()

   oBtn:cToolTip:="Guardar"

   oCliAso:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCANCEL.BMP";
          ACTION (oCliAso:Cancel()) CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

RETURN .T.


FUNCTION GRABARCLI()
  LOCAL oTable,cWhere

  IF !oCliAso:FindCodCli()
     RETURN .F.
  ENDIF

  cWhere:="CCA_CODIGO"+GetWhere("=",oCliAso:cCodCli)
  oTable:=OpenTable("SELECT * FROM DPCLIASOC WHERE "+cWhere ,.T.)

  IF oTable:RecCount()=0
     oTable:AppendBlank()
     cWhere:=NIL
     oTable:Replace("CCA_FECHA" ,oDp:dFecha     )
  ENDIF

  oTable:Replace("CCA_CODIGO",oCliAso:cCodCli)
  oTable:Replace("CCA_CODCLI",oCliAso:cCodAso)
  oTable:Replace("CCA_COMENT",oCliAso:cComent)

  oTable:Commit(cWhere)
  oTable:End()

  oCliAso:Close()

RETURN .T.

FUNCTION FindCodCli()

   oCliAso:oNombre:Refresh(.T.)

   IF oCliAso:cCodCli=oCliAso:cCodAso
      MensajeErr("No puede Asociarse el Mismo "+oDp:xDPCLIENTES)
      oCliAso:oCodAso:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   IF !ISMYSQLGET("DPCLIENTES","CLI_CODIGO",oCliAso:cCodAso)
      oCliAso:oCodAso:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

RETURN .T.
