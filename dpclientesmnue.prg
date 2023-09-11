// Programa   : DPCLIENTESMNUE
// Fecha/Hora : 07/06/2005 15:43:33
// Prop¢sito  : Menú del Cliente
// Creado Por : JN
// Llamado por: DPDOCCLI
// Aplicaci¢n : Compras
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
   LOCAL oBtn,oFontB,nAlto:=24-5,nAncho:=120,aBtn:={},I,nLin:=0,nHeight,cNomDoc

   DEFAULT cCodCli:=STRZERO(1,10)

   cNomDoc:=GetFromVar("{oDp:xDPCLIENTES}")

   SysRefresh(.T.)

// AADD(aBtn,{"Expedientes"          ,"XEXPEDIENTE.BMP"  ,"EXP"       })
   AADD(aBtn,{"Entrevista Inicial"   ,"XENTREVISTA.BMP"  ,"ENTI"      })
   AADD(aBtn,{"Entrevista Pre-Venta" ,"XENTREVISTA.BMP"  ,"ENTS"      })
   AADD(aBtn,{"Entrevista Post-Venta","XENTREVISTA.BMP"  ,"ENTP"      })

   AADD(aBtn,{"Salir"            ,"XSALIR.BMP"       ,"EXIT"  })

   DEFINE FONT oFontB  NAME "MS Sans Serif" SIZE 0, -10 BOLD

   oDpCliMnu:=DPEDIT():New(cNomDoc,NIL,"oDpCliMnuE",.F.)
   oDpCliMnuE:cCodCli:=cCodCli
   oDpCliMnuE:lMsgBar:=.F.
   oDpCliMnuE:aBtn   :=ACLONE(aBtn)
   oDpCliMnuE:nCrlPane:=13041606 // 16772810
   oDpCliMnuE:cNombre :=MYSQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))

   nHeight:=370
   nHeight:=35+((Len(aBtn)+1)*(nAlto*2))
   oDpCliMnuE:CreateWindow(nil,70,1,nHeight,(nAncho*2)+12)
   oDpCliMnuE:oDlg:SetColor(NIL,oDpCliMnuE:nCrlPane)

   nLin   :=nAlto

   FOR I=1 TO LEN(aBtn)
 
     @nLin, 01 SBUTTON oBtn OF oDpCliMnuE:oDlg;
               SIZE nAncho,nAlto-1.5;
               FONT oFontB;	
               FILE "BITMAPS\"+aBtn[I,2] ;
               PROMPT PADR(aBtn[I,1],20);
               NOBORDER;
               ACTION 1=1;
               PIXEL;
               COLORS CLR_BLUE, {CLR_WHITE, oDpCliMnuE:nCrlPane, 1 }

      oBtn:bAction:=BloqueCod("oDpCliMnuE:DOCPRORUN(["+aBtn[I,3]+"])")

      nLin:=nLin+nAlto

   NEXT I

   @ .0,1 GROUP oDpCliMnuE:oGrupo1 TO nAlto-2, nAncho PROMPT "" PIXEL;
          COLOR NIL,oDpCliMnuE:nCrlPane

   @ .4,1 SAY "Código:" SIZE 50,10;
          COLOR CLR_BLUE,oDpCliMnuE:nCrlPane

   @ .4,6 SAY oDpCliMnuE:cCodCli SIZE 60,10;
          COLOR CLR_HRED,oDpCliMnuE:nCrlPane
  
   oDpCliMnuE:Activate({||DOCPROMNUINI()})

RETURN .T.

/*
// Iniciaci¢n
*/
FUNCTION DOCPROMNUINI()

    oBtn:=oDpCliMnuE:oDlg:aControls[1]
    oDpCliMnuE:oWnd:Move(0,0)
    DPFOCUS(oBtn)

    SysRefresh(.T.)

RETURN .T.

/*
// Ejecutar
*/
FUNCTION DOCPRORUN(cAction)
  LOCAL oRep

  IF cAction="EXIT"

     oDpCliMnuE:Close()

     IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
        DpFocus(oForm:oDlg)
     ENDIF

     RETURN .T.

  ENDIF

  IF cAction="EXP"

     oDpCliMnuE:EXPEDIENTES()

  ENDIF


  IF cAction="ENTS"

     oDpCliMnuE:ENTREVISTA("S")

  ENDIF

  IF cAction="ENTI"

     oDpCliMnuE:ENTREVISTA("I")

  ENDIF

  IF cAction="ENTP"

     oDpCliMnuE:ENTREVISTA("P")

  ENDIF

RETURN .T.

FUNCTION MNUCERRAR()
   LOCAL oForm:=oDpCliMnuE:oForm

   oDpCliMnuE:Close()

   IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
      DpFocus(oForm:oDlg)
   ENDIF

RETURN .T.

FUNCTION TOTALIZAR()
RETURN .T.


/*
// Expedientes
*/
FUNCTION ENTREVISTA(cTipo)
  LOCAL cTitle:="",cNumero
  LOCAL cWhere,oLbx

  DEFAULT cTipo:="P"

  cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEENT}"))+;
          SayOptions("DPCLIENTEENT","ENT_TIPO",cTipo)+" "+;
          " ["+oDpCliMnuE:cCodCli+" "+ALLTRIM(oDpCliMnuE:cNombre)+"]"

  cWhere:="ENT_CODIGO"+GetWhere("=",oDpCliMnuE:cCodCli)+" AND "+;
          "ENT_TIPO  "+GetWhere("=",cTipo)

  IF cTipo="I"

     cNumero:=SQLGET("DPCLIENTEENT","ENT_NUMERO",cWhere)

     EJECUTAR("DPCLIENTEENT" , IF(Empty(cNumero),1,3) , cNumero , "I" , oDpCliMnuE:cCodCli )

     RETURN .T.

  ENDIF

  oDp:aCargo:={"",oDpCliMnuE:cCodCli,cTipo,"",""}
  oLbx:=DPLBX("DPCLIENTEENT.LBX",cTitle,cWhere)

  oLbx:aCargo:=oDp:aCargo

RETURN .T.

/*
// Facturación Periódica
*/
FUNCTION FACTURAPER()
   LOCAL cTitle
   LOCAL cWhere,oLbx

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
           " ["+oDpCliMnuE:cCodCli+" "+ALLTRIM(oDpCliMnuE:cNombre)+" ]"

   cWhere:="DPG_CODIGO"+GetWhere("=",oDpCliMnuE:cCodCli)

   oDp:aRowSql:={} // Lista de Campos Seleccionados
   oDpLbx:=TDpLbx():New("DPCLIENTEPROG.LBX",cTitle,cWhere)
   oDpLbx:uValue1:=oDpCliMnuE:cCodCli
   oDpLbx:Activate()

RETURN .T.


// EOF







