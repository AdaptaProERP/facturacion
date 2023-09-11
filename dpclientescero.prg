// Programa   : DPCLIENTESCERO
// Fecha/Hora : 10/06/2005 06:17:48
// Propósito  : Editar Clientes con Código Zero
// Creado Por : Juan Navas
// Llamado por: DPDOCCLI
// Aplicación : Ventas y CXC
// Tabla      : DPCLIENTESCERO
// Modificion : (JU19022009)Se Agrego "DESC" a DOC_FECHA del ORDER BY de la FUNCTION VALRIF() 
//              para validar ultima fecha.

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrm,oGet,cCodSuc,cTipDoc,cCodCli,cNumDoc)

   LOCAL oDlg,nHeight:=356,nWidth:=335,nTop:=170,nLeft:=35-35,oWnd,oGrp,aPoint,oNombre
   LOCAL oFont,oFontB,oBtn,oBtnAceptar,bKeyF10,oBrush
   LOCAL nColor:=oDp:nGris,lAceptar:=.F.,lSalir:=.F.,cWhere:="",oTable,oNombre,cText:=""
   LOCAL nLin:=0,nCol:=0,bKey,oBtn,oRif,oTel1,oNombre,oRetiva,oDir1,oDir2,oDir3

   LOCAL cRif   :=SPACE(10),cNit :=SPACE(10)
   LOCAL cNombre:=SPACE(40),cDir1:=SPACE(40),cDir2:=SPACE(40),cDir3:=SPACE(40),cDir4:=SPACE(40)
   LOCAL cArea  :=SPACE(04),ctel1:=SPACE(12),cTel2:=SPACE(12),cTel3:=SPACE(12),cCelular:=SPACE(12)
   LOCAL cEmail :=SPACE(40)

   IF ValType(cCodSuc)="C"

     cWhere:="CCG_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "CCG_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "CCG_NUMDOC"+GetWhere("=",cNumDoc)

      oTable  :=OpenTable("SELECT * FROM DPCLIENTESCERO WHERE "+cWhere,.T.)
      cRif    :=oTable:CCG_RIF 
      cNombre :=oTable:CCG_NOMBRE
      cDir1   :=oTable:CCG_DIR1  
      cDir2   :=oTable:CCG_DIR2 
      cDir3   :=oTable:CCG_DIR3
      cDir4   :=oTable:CCG_DIR4
      cArea   :=oTable:CCG_AREA
      cTel1   :=oTable:CCG_TEL1 
      cTel2   :=oTable:CCG_TEL2  
      cTel3   :=oTable:CCG_TEL3  
      cCelular:=oTable:CCG_CELUL1
      cEmail  :=oTable:CCG_EMAIL
      oTable:End()

   ENDIF

   oWnd:=IIF(ValType(oFrm)="O",oFrm:oWnd,oDp:oFrameDp)

   IF ValType(oFrm)="O" .AND. ValType(oWnd)="O" .AND. oWnd:hWnd>0 .AND.;
       oFrm:IsDef("CCG_RIF") .AND. !Empty(oFrm:CCG_RIF)

      cRif    :=PADR(oFrm:CCG_RIF   ,10)
      cNombre :=PADR(oFrm:CCG_NOMBRE,40)
	 cDir1   :=PADR(oFrm:CCG_DIR1  ,40)
	 cDir2   :=PADR(oFrm:CCG_DIR2  ,40)
      cDir3   :=PADR(oFrm:CCG_DIR3  ,40)
      cDir4   :=PADR(oFrm:CCG_DIR4  ,40)
      cArea   :=oFrm:CCG_AREA
      cTel1   :=oFrm:CCG_TEL1 
      cTel2   :=oFrm:CCG_TEL2  
      cTel3   :=oFrm:CCG_TEL3  
      cCelular:=oFrm:CCG_CELUL1
      cEmail  :=oFrm:CCG_EMAIL
  
   ENDIF

   IF ValType(oGet)="O" .AND. oGet:hWnd>0
     oWnd   :=oGet:oWnd
     aPoint := AdjustWnd( oGet, nWidth, nHeight )
     nTop   :=aPoint[1]
     nleft  :=aPoint[2]
   ENDIF


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -10 BOLD

   oDp:CCG_NOMBRE:=SPACE(40)

   nColor:=14671839
   nColor:=16772313

   oDp:lDlg:=.T.

   DEFINE BRUSH oBrush;
                FILE "BITMAPS\dpclientecero.bmp"

   DEFINE DIALOG oDlg TITLE "";
          STYLE nOr( WS_POPUP, WS_VISIBLE );
          BRUSH oBrush OF oWnd

   @ 1.4,1 GET oRif VAR cRif SIZE NIL,10 FONT oFontB;
           VALID VALRIF(cRif,oDlg)

   SAYTEXTO("Rif o Cédula:",oFontB)

   // Si en la configuracion de la empresa esta tildado Verificacion
   // automatica del RIF se podra consultar el Rif o cedula a los clientes cero
   IF oDp:lAutRif=.T.

      @ 1,8 BUTTON " > " ACTION VALRIF(cRif,oDlg,.T.);
            SIZE 20,10
   ENDIF


   @ 2.9,1 GET oNombre VAR cNombre SIZE NIL,10 FONT oFontB

   SAYTEXTO("Nombre del Comprador:",oFontB)


   @ 4.5,1 GET oDir1 VAR cDir1   SIZE NIL,10 FONT oFont UPDATE

   SAYTEXTO("Dirección:",oFontB)

   @ 5.3,1 GET oDir2 VAR cDir2   SIZE NIL,10 FONT oFont UPDATE
   @ 6.0,1 GET oDir3 VAR cDir3   SIZE NIL,10 FONT oFont UPDATE

   @ 7.7,1 GET cEmail  SIZE NIL,10 FONT oFont UPDATE

   SAYTEXTO("Correo Electrónico:",oFontB)

   @ 9.2,1 GET cArea   SIZE NIL,10 FONT oFont;
           VALID CERO(cArea,NIL,.T.) UPDATE

   SAYTEXTO("Cód. Area:",oFontB)

   @ 9.2,05 GET oTel1 VAR cTel1  SIZE NIL,10 FONT oFont;
            UPDATE
 
   SAYTEXTO("Teléfonos:",oFontB)

   @09.95,05 GET cTel2 SIZE NIL,10 FONT oFont UPDATE
   @10.75,05 GET cTel3 SIZE NIL,10 FONT oFont UPDATE

   @ 9.2,13 GET cCelular SIZE NIL,10 FONT oFont

   SAYTEXTO("Celular:",oFontB)

   @ 11.7+1,14.2-04 SBUTTON oBtn;
                 SIZE 56,20 FONT oFontB;
                 FILE "BITMAPS\OK2.BMP","BITMAPS\OK2.BMP","BITMAPS\OK2G.BMP";
                 BORDER;
                 TOP PROMPT "Aceptar F11";
                 COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                 ACTION (lAceptar:=.T.,oDlg:End());
                 WHEN !Empty(cRif) .AND. !Empty(cNombre) UPDATE

   @ 11.7+1,24     SBUTTON oBtn;
                 SIZE 56,20 FONT oFontB;
                 FILE "BITMAPS\XCANCEL.BMP","BITMAPS\XCANCEL.BMP","BITMAPS\XCANCEL.BMP";
                 BORDER;
                 TOP PROMPT "Cancelar";
                 COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                 ACTION (lAceptar:=.F.,oDlg:End());
                 UPDATE

   oBtn:cToolTip:=" Cerrar sin Cambios "
   oBtn:cToolTip:=" Aceptar Datos "

// bKeyF10:=SetKey(VK_F10,{||MensajeErr("F10"),lAceptar:=(!Empty(cRif) .AND. !Empty(cNombre)),IIF(lAceptar,oDlg:End(),NIL)})
// bKeyF10:=SetKey(VK_F10,{||MensajeErr("F10"),lAceptar:=(!Empty(cRif) .AND. !Empty(cNombre)),IIF(lAceptar,oDlg:End(),NIL)})

   bKey:={|nKey|lAceptar:=(nKey=VK_F11) .AND. (!Empty(cRif) .AND. !Empty(cNombre)),IIF(lAceptar,oDlg:End(),NIL)}

   AEVAL(oDlg:aControls,{ |o,n| IIF("GET"$o:ClassName() , o:bKeyDown:=bKey , NIL ) })

   ACTIVATE DIALOG oDlg  ON INIT;
            oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.)

   oBrush:End()

//   SetKey(VK_F10,bKeyF10)

   IF lAceptar .AND. ValType(oFrm)="O"

       oFrm:CCG_RIF   :=cRif
       oFrm:CCG_NIT   :=cNit
       oFrm:CCG_NOMBRE:=cNombre
       oFrm:CCG_DIR1  :=cDir1
       oFrm:CCG_DIR2  :=cDir2
       oFrm:CCG_DIR3  :=cDir3
       oFrm:CCG_DIR4  :=cDir4
       oFrm:CCG_AREA:=cArea
       oFrm:CCG_TEL1  :=ctel1
       oFrm:CCG_TEL2  :=cTel2
       oFrm:CCG_TEL3  :=cTel3
       oFrm:CCG_CELUL1:=cCelular
       oFrm:CCG_EMAIL :=cEMail

   ENDIF

   IF lAceptar .AND. !Empty(cWhere)
      oTable:=OpenTable("SELECT * FROM DPCLIENTESCERO WHERE "+cWhere,.T.)
      oTable:Replace("CCG_RIF"   ,cRif    )
      oTable:Replace("CCG_NIT"   ,cNit    )
      oTable:Replace("CCG_NOMBRE",cNombre )
      oTable:Replace("CCG_DIR1"  ,cDir1   )
      oTable:Replace("CCG_DIR2"  ,cDir2   )
      oTable:Replace("CCG_DIR3"  ,cDir3   )
      oTable:Replace("CCG_DIR4"  ,cDir4   )
      oTable:Replace("CCG_AREA"  ,cArea   )
      oTable:Replace("CCG_TEL1"  ,ctel1   )
      oTable:Replace("CCG_TEL2"  ,cTel2   )
      oTable:Replace("CCG_TEL3"  ,cTel3   )
      oTable:Replace("CCG_CELUL1",cCelular)
      oTable:Replace("CCG_EMAIL" ,cEMail  )
      oTable:Commit(cWhere)
      oTable:End()
   ENDIF

   oDp:lDlg:=.F.

RETURN lAceptar

/*
// Lee la Ultima Transacción con este Cliente
*/
FUNCTION VALRIF(cRif,oDlg,lSeniat)

  LOCAL oTable

  DEFAULT lSeniat:=.F.


  IF lSeniat
     IF !RUNVALRIF()
         RETURN .F.
     ENDIF
  ENDIF


  oTable:=OpenTable(SELECTFROM("DPCLIENTESCERO",.T.)+;
                    " INNER JOIN DPDOCCLI ON DOC_CODSUC=CCG_CODSUC AND DOC_TIPDOC=CCG_TIPDOC AND DOC_NUMERO=CCG_NUMDOC "+;
                    " WHERE CCG_RIF"+GetWhere("=",cRif)+;
                    " ORDER BY DOC_FECHA DESC,DOC_HORA DESC LIMIT 1",.T.)


  IF oTable:RecCount()>0

    cRif    :=oTable:CCG_RIF 
    cNit    :=oTable:CCG_NIT
    cNombre :=oTable:CCG_NOMBRE
    cDir1   :=oTable:CCG_DIR1  
    cDir2   :=oTable:CCG_DIR2 
    cDir3   :=oTable:CCG_DIR3
    cDir4   :=oTable:CCG_DIR4
    cArea   :=oTable:CCG_AREA
    cTel1   :=oTable:CCG_TEL1 
    cTel2   :=oTable:CCG_TEL2  
    cTel3   :=oTable:CCG_TEL3  
    cCelular:=oTable:CCG_CELUL1
    cEmail  :=oTable:CCG_EMAIL

    Aeval(oDlg:aControls,{|o| IIF(o:ClassName()="TGET" , o:Refresh(.T.) ,   NIL )} )

  ENDIF

  oTable:End()

RETURN .T.


FUNCTION RUNVALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.,cRif_:=cRif,lView:=.F.

  IF !VALRIFCLI(cRif)
      DPFOCUS(oRif)
      RETURN .F.
  ENDIF

  IF ISDIGIT(cRif)
    cRif:=STRZERO(VAL(cRif),8)
    oRif:VarPut(cRif,.T.)
  ENDIF

  // QUITAR ESPACIOS
  cRif:=PADR(STRTRAN(cRif," ",""),LEN(cRif))
  cRif:=UPPER(cRif)

  oRif:VarPut(cRif,.T.)

  oDp:cSeniatErr:=""

  MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
         {|| lOk:=EJECUTAR("VALRIFSENIAT",cRif,NIL,!ISDIGIT(cRif),lView)})


  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF !lOk .AND. oDp:lAutRif=.T. .AND. ISDIGIT(cRif)

    MsgRun("Autodectando RIF "+cRif+" no Encontrado","Por favor espere..",;
           {||lOk:=EJECUTAR("RIFVAUTODET",cRif,oRif) })
   
  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF lOk

     lValRif:=.T.
 
     IF !Empty(oDp:aRif)

       cRif:=oDp:aRif[6]
       oRif:VARPUT(cRif,.T.)  
       oRif:Refresh(.T.)

       oNombre:VARPUT(oDp:aRif[1],.T.)
       ///oRetiva:VARPUT(oDp:aRif[2],.T.)

       DPFOCUS(oDir1)

     ENDIF

  ELSE

     lRifVal:=.F.

     cRif:=cRif_
     oRif:VarPut(cRif_,.T.)

     MensajeErr(oDp:cRifErr,"RIF no fué Validado")

  ENDIF

RETURN .T.

FUNCTION VALRIFCLI(cRif2)
  LOCAL cRif3:=""

  lExiste:=.F.

  IF Empty(cRif2)
     RETURN .F.
  ENDIF

  oDp:aRow:={}

  IF ISALLDIGIT(ALLTRIM(cRif2))

     cRif2 :=STRZERO(VAL(cRif2),8)

     cRif3:=SQLGET("DPCLIENTES","CLI_RIF,CLI_NOMBRE,CLI_DIR1,CLI_DIR2,CLI_DIR3,CLI_TEL1,CLI_RETIVA","CLI_RIF"+GetWhere(" LIKE ","%"+ALLTRIM("V"+cRif2)+"%"))

     IF Empty(cRif3)
       cRif3:=SQLGET("DPCLIENTES","CLI_RIF,CLI_NOMBRE,CLI_DIR1,CLI_DIR2,CLI_DIR3,CLI_TEL1,CLI_RETIVA","CLI_RIF"+GetWhere(" LIKE ","%"+ALLTRIM("E"+cRif2)+"%"))
     ENDIF

  ELSE

     cRif3:=SQLGET("DPCLIENTES","CLI_RIF,CLI_NOMBRE,CLI_DIR1,CLI_DIR2,CLI_DIR3,CLI_TEL1,CLI_RETIVA","CLI_RIF"+GetWhere("=",cRif2))

  ENDIF

  IF !Empty(oDp:aRow)

    oRif:VarPut(oDp:aRow[1]   ,.T.)
    cRif:=oDp:aRow[1]
    oNombre:VarPut(oDp:aRow[2],.T.)
    oDir1:VarPut(oDp:aRow[3],.T.)
    oDir2:VarPut(oDp:aRow[4],.T.)
    oDir3:VarPut(oDp:aRow[5],.T.)
    oTel1:VarPut(oDp:aRow[6],.T.)
    // oRetIva:VarPut(oDp:aRow[7],.T.)

    DPFOCUS(oDir1)

    lExiste:=.T.

  ENDIF

RETURN .T.
// EOF
