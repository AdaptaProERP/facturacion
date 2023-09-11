// Programa   : DPCLIENTESMNU
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú del Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación : Ventas y CxC
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
   LOCAL cNombre:="",cSql,I,nGroup,cUtiliz
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={}
   LOCAL Close,cLic=""
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   IF !(oDp:nVersion>=5)
      EJECUTAR("DPCLIENTESMNUOL",cCodCli)
      RETURN .T.
   ENDIF

   DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

   cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_SITUAC","CLI_CODIGO"+GetWhere("=",cCodCli))

   cLic:=SQLGET("DPMOVINV","MOV_CODCOM","MOV_DOCUME"+GetWhere("=",cCodCli))
   
   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

   DpMdi("Menú "+GetFromVar("{oDp:DPCLIENTES}"),"oCliMnu","TEST.EDT")

   oCliMnu:cCodCli   :=cCodCli
   oCliMnu:cNombre   :=cNombre
   oCliMnu:lSalir    :=.F.
   oCliMnu:nHeightD  :=45
   oCliMnu:lMsgBar   :=.F.
   oCliMnu:oGrp      :=NIL

   SetScript("DPCLIENTESMNU")
  

//  IF !oDp:cIdApl$"1"
//    AADD(aBtn,{"Cuentas Contables"                  ,"CONTABILIDAD.BMP" ,"CONTAB"     })
// ENDIF

   IF oDp:cIdApl$"93" .OR. !oDp:cIdApl$"1"
     AADD(aBtn,{"Cuentas Contables"                  ,"CONTABILIDAD.BMP" ,"CONTAB"     })
     AADD(aBtn,{"Factura Periódica"                  ,"FACTURAPER.BMP"   ,"FACTURAPER" })
     AADD(aBtn,{oDp:DPCLIENTES+" Asociados"          ,"COMPONENTE.BMP"   ,"ASOCIADO"   })
     AADD(aBtn,{"Asociar con "+oDp:xDPCLIENTES       ,"COMPONENTE.BMP"   ,"ASOCIAR"    })
   ENDIF

  
//   AADD(aBtn,{"Salir"            ,"XSALIR.BMP"       ,"EXIT"  })

   oCliMnu:Windows(0,0,aCoors[3]-150,415)


  @ 48, -1 OUTLOOK oCliMnu:oOut ;
     SIZE 150+250, oCliMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oCliMnu:oWnd;
     COLOR CLR_BLACK,oDp:nGris2

   IF "DATAPRO"$UPPE(oDp:cEmpresa ) .OR. "ADAPTAPRO"$UPPE(oDp:cEmpresa ) .OR. "GRUPO"$UPPE(oDp:cEmpresa ) .OR. "GLOBAL"$UPPE(oDp:cEmpresa )

     DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&AdaptaPro"

     aBtn:={}

     AADD(aBtn,{"Solicitud de Clave"            ,"LOGODP.BMP" ,"CLAVE" })
     AADD(aBtn,{"Evaluacion de clientes con Lic","XPRINT.BMP" ,"EVALCLI" })
     AADD(aBtn,{"Evalu. de clientes sin Lic."   ,"XPRINT.BMP" ,"EVALCLISLIC" })

     FOR I=1 TO LEN(aBtn)

         DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
                BITMAP "BITMAPS\"+aBtn[I,2];
                PROMPT aBtn[I,1];
                ACTION 1=1
/*
         nGroup:=LEN(oCliMnu:oOut:aGroup)
         oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])

         bAction:=BloqueCod("oCliMnu:CLIACTION(["+aBtn[I,3]+"])")

         oBtn:bAction:=bAction

         oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 3 ])
         oBtn:bLButtonUp:=bAction
*/

         bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"

         SETBTNGRPACTION(oCliMnu,bAction)

      NEXT I


   ENDIF

   IF oDp:nVersion>=6

     DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&Transacciones"

     aBtn:={}
     AADD(aBtn,{"Recibos de Ingreso"                    ,"recibirdinero.BMP"	      ,"RECIBOS" })


     IF oDp:cIdApl$"93" .OR. !oDp:cIdApl$"1"
       AADD(aBtn,{"Cuentas Contables"                  ,"CONTABILIDAD.BMP" ,"CONTAB"     })
       AADD(aBtn,{"Factura Periódica"                  ,"FACTURAPER.BMP"   ,"FACTURAPER" })
       AADD(aBtn,{oDp:DPCLIENTES+" Asociados"          ,"COMPONENTE.BMP"   ,"ASOCIADO"   })
       AADD(aBtn,{"Asociar con "+oDp:xDPCLIENTES       ,"COMPONENTE.BMP"   ,"ASOCIAR"    })
     ENDIF


     FOR I=1 TO LEN(aBtn)

     DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
            BITMAP "BITMAPS\"+aBtn[I,2];
            PROMPT aBtn[I,1];
            ACTION 1=1

      bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"
      SETBTNGRPACTION(oCliMnu,bAction)

     NEXT I

   ENDIF


   aBtn:={}

   AADD(aBtn,{"Menú de Consulta"     ,"VIEW.BMP"         ,"CONSULTAR"   })
   AADD(aBtn,{"Personal"             ,"XPERSONAL.BMP"    ,"PERSONAL"    })

   IF oDp:cIdApl$"93"
     AADD(aBtn,{"Expedientes"          ,"XEXPEDIENTE.BMP"  ,"EXP"         })
     AADD(aBtn,{"Sucursales"           ,"SUCURSALES.BMP"   ,"SUCURSALES"  })
     AADD(aBtn,{oDp:DPCLIENTESREC      ,"RECURSOS.BMP"     ,"RECURSOS"    })
   ENDIF

   AADD(aBtn,{"Datos Jurídicos"      ,"CLIENTE.BMP"      ,"DATJURIDICOS"})

   IF DPVERSION()>=5
     AADD(aBtn,{"Digitalizar"  ,"ADJUNTAR.BMP" ,"DIGITALIZAR" })
   ENDIF

   IF oDp:nVersion>5

    IF oDp:cIdApl$"93"
      AADD(aBtn,{"Actividad Económica"  ,"Actividadesdelexpediente.bmp"      ,"DPCLIENTEACT"})
    ENDIF

    IF oDp:lVen
      AADD(aBtn,{"Verificar RIF","RETIVA.BMP"   ,"VALRIF"      })
    ENDIF

   ENDIF


// DPCLIENTESRECVEH


   DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&Vinculos del "+oDp:xDPCLIENTES

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

/*
      nGroup:=LEN(oCliMnu:oOut:aGroup)
      oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oCliMnu:CLIACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction
*/

      bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"
      SETBTNGRPACTION(oCliMnu,bAction)



   NEXT I


   IF oDp:cIdApl$"93"


       DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&Entrevistas o Evaluaciones"

       aBtn:={}

       AADD(aBtn,{"Entrevistas"            ,"XENTREVISTA.BMP"  ,"ENTREVISTAS"})
       AADD(aBtn,{"Productos de Interés"   ,"PRODUCTO.BMP"     ,"PRODINT" })

       AADD(aBtn,{"Entrevista Inicial"   ,"XENTREVISTA.BMP"  ,"ENTI"      })
       AADD(aBtn,{"Entrevista Pre-Venta" ,"XENTREVISTA.BMP"  ,"ENTS"      })
       AADD(aBtn,{"Entrevista Post-Venta","XENTREVISTA.BMP"  ,"ENTP"      })

       FOR I=1 TO LEN(aBtn)

         DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
                BITMAP "BITMAPS\"+aBtn[I,2];
                PROMPT aBtn[I,1];
                ACTION 1=1
/*
         nGroup:=LEN(oCliMnu:oOut:aGroup)
         oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])

         bAction:=BloqueCod("oCliMnu:CLIACTION(["+aBtn[I,3]+"])")

         oBtn:bAction:=bAction

         oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 3 ])
        oBtn:bLButtonUp:=bAction
*/

       bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"
       SETBTNGRPACTION(oCliMnu,bAction)

      NEXT I

    ENDIF

IF ISRELEASE("18.11")

   DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&Restricciones"

   aBtn:={}

   AADD(aBtn,{oDp:DPSUCURSAL+" Permitidos    ","SUCURSAL.BMP"      ,"SUCXTAB"})

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1
/*
      nGroup:=LEN(oCliMnu:oOut:aGroup)
      oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oCliMnu:CLIACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction
*/


     bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"
     SETBTNGRPACTION(oCliMnu,bAction)


   NEXT I

ENDIF

  
   IF oDp:cIdApl$"93" .OR. !oDp:cIdApl$"1"

     DEFINE GROUP OF OUTLOOK oCliMnu:oOut PROMPT "&Correspondencia"

     aBtn:={}
     AADD(aBtn,{"Correspondencia"                    ,"EMAIL.BMP"	      ,"BLAT"       })

     IF oDp:nVersion>=5.1
       AADD(aBtn,{"Correspondencia en HTML"            ,"HTML.BMP"	      ,"MAILHTML"   })
     ENDIF

     AADD(aBtn,{"Usar Modelo de Carta"               ,"WORD.BMP"	      ,"CLIWORD"    })
     FOR I=1 TO LEN(aBtn)

        DEFINE BITMAP OF OUTLOOK oCliMnu:oOut ;
               BITMAP "BITMAPS\"+aBtn[I,2];
               PROMPT aBtn[I,1];
               ACTION 1=1
/*
        nGroup:=LEN(oCliMnu:oOut:aGroup)
        oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])

        bAction:=BloqueCod("oCliMnu:CLIACTION(["+aBtn[I,3]+"])")

        oBtn:bAction:=bAction

        oBtn:=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 3 ])
        oBtn:bLButtonUp:=bAction
*/

      bAction:="oCliMnu:CLIACTION(["+aBtn[I,3]+"])"
      SETBTNGRPACTION(oCliMnu,bAction)

     NEXT I

   ENDIF



/*

   @ 0, 100 SPLITTER oCliMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oCliMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oCliMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oCliMnu:oDlg FROM 0,oCliMnu:oOut:nWidth() TO oCliMnu:nHeightD,700;
          TITLE "Cliente Contado" STYLE WS_CHILD OF oCliMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oCliMnu:oGrp TO 10,10 PROMPT "Código ["+oCliMnu:cCodCli+"]"

   @ .5,.5 SAY oCliMnu:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oCliMnu:oDlg NOWAIT VALID .F.

*/

   oCliMnu:Activate("oCliMnu:FRMINIT()",,"oCliMnu:oSpl:AdjRight()")

   EJECUTAR("DPSUBMENUCREAREG",oCliMnu,NIL,"M","DPCLIENTES")

RETURN oCliMnu

FUNCTION FRMINIT()
   LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

   DEFINE BUTTONBAR oBar SIZE 42,42 OF oCliMnu:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

   IF oDp:nVersion>6 .OR. ISRELEASE("18.11")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
            ACTION EJECUTAR("OUTLOOKTOBRW",oCliMnu:oOut,oCliMnu:cCodCli,oCliMnu:cNombre,"DPCLIENTES","Menú"),oCliMnu:End();
            WHEN oDp:nVersion>=6

 ENDIF


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliMnu:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 1,nCol SAYREF oCliMnu:oCodCli PROMPT oCliMnu:cCodCli;
           SIZE 80,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  SayAction(oCliMnu:oCodCli,{||EJECUTAR("DPCLIENTES",0,oCliMnu:cCodCli)})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
 
  @ 21,nCol SAY oCliMnu:cNombre;
            SIZE 300,19 BORDER  PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont


  oBar:Refresh(.T.)

  oCliMnu:oWnd:bResized:={||oCliMnu:oWnd:oClient := oCliMnu:oOut,;
                          oCliMnu:oWnd:bResized:=NIL}

                       

//  oCliMnu:oWnd:oClient := oCliMnu:oOut
/*


   oCliMnu:oWnd:bResized:={||oCliMnu:oDlg:Move(0,0,oCliMnu:oWnd:nWidth(),50,.T.),;
                             oCliMnu:oGrp:Move(0,0,oCliMnu:oWnd:nWidth()-15,oCliMnu:nHeightD,.T.)}

   EVal(oCliMnu:oWnd:bResized)
*/

RETURN .T.

// Ejecutar
FUNCTION CLIACTION(cAction)
  LOCAL oRep,nNumMain
  //LOCAL oForm:=oCliMnu:oForm

  IF cAction="EXIT"

   // oCliMnu:Close()

    //IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
      //DpFocus(oForm:oDlg)
    //ENDIF

   // RETURN .T.
  ENDIF

  IF cAction="CONSULTAR"
    EJECUTAR("DPCLIENTESCON",NIL,oCliMnu:cCodCli)
    RETURN .T.
  ENDIF


  IF cAction="PERSONAL"
    EJECUTAR("DPCLIENTESPER",oCliMnu:cCodCli)
    RETURN .T.
  ENDIF

  IF cAction="CLAVE"

    IF MYSQLGET("DPCLIENTES","CLI_SITUAC","CLI_CODIGO"+GetWhere("=",oCliMnu:cCodCli))="S"
	  MsgInfo("Este Cliente esta Suspendido, Revise Expediente","Situacion del Cliente") 		 
    ELSE	
      EJECUTAR("DPLICCLAVE",oCliMnu:cCodCli)
    ENDIF

  ENDIF

  IF cAction="CONTAB"
    RETURN EJECUTAR("DPCLIENTECTA",oCliMnu:cCodCli)
  ENDIF

  IF cAction="DIVISA"
    RETURN EJECUTAR("DPCLIENTESDIV",oCliMnu:cCodCli)
  ENDIF

  IF cAction="ASOCIADO"
    RETURN EJECUTAR("DPCLIASOC"   ,oCliMnu:cCodCli)
  ENDIF

  IF cAction="ASOCIAR"
    RETURN EJECUTAR("DPCLIENTESASOC"   ,oCliMnu:cCodCli)
  ENDIF

  IF cAction="PRINT"
    oRep:=REPORTE("DPCLIFICHA")
    oRep:SetRango(1,oCliMnu:cCodCli,oCliMnu:cCodCli)
    RETURN .T.
  ENDIF

  IF cAction="EXP"
    oCliMnu:EXPEDIENTES()
  ENDIF

  IF cAction="ENTREVISTAS"
    EJECUTAR("DPCLIENTESMNUE",oCliMnu:cCodCli)
  ENDIF

  IF cAction="SUCURSALES"
    oCliMnu:SUCXCLIENTE()
  ENDIF

  IF cAction="DATJURIDICOS"
    EJECUTAR("CLIDATJURIDICO",3,oCliMnu:cCodCli)
  ENDIF


// Inactivado para revisar TJ

  IF cAction="DPCLIENTEACT"
    EJECUTAR("DPCLIENTACT",oCliMnu:cCodCli)
  ENDIF


  IF cAction="PRODINT"
    EJECUTAR("DPCLIENTESINV",oCliMnu:cCodCli,3)
  ENDIF

  IF cAction="PRODALQ" 
    EJECUTAR("DPCLIENTESALQ",oCliMnu:cCodCli,3)
  ENDIF

  IF cAction="DIGITALIZAR" 

    nNumMain:=SQLGET("DPCLIENTES","CLI_FILMAI","CLI_CODIGO"+GetWhere("=",oCliMnu:cCodCli))
    nNumMain:=EJECUTAR("DPFILEEMPMAIN",nNumMain)
    SQLUPDATE("DPCLIENTES","CLI_FILMAI",nNumMain,"CLI_CODIGO"+GetWhere("=",oCliMnu:cCodCli))

  ENDIF

  IF cAction="CLIWORD"
     CursorWait()
     EJECUTAR("DPCLIWORD",oCliMnu:cCodCli)
  ENDIF

  IF cAction="BLAT"
    EJECUTAR("BLAT",oCliMnu:cCodCli)
    oBlat:lEnviaTodos:=.F.
  ENDIF

  IF cAction="MAILHTML"
     EJECUTAR("BRCLIEMAIL",NIL,oCliMnu:cCodCli)
  ENDIF

  // Adaptacion de la version anteriior 
  IF cAction="EVALCLI"
     REPORTE("EVALCLIENTES")
  ENDIF

  // Ejecuta el reporte de clientes sin Licencias 
  IF cAction="EVALCLISLIC"
     REPORTE("EVALCLIENTESSIN")
  ENDIF

  IF cAction="FACTURAPER"
    oCliMnu:FACTURAPER()
  ENDIF

  IF cAction="ENTS"
     oCliMnu:ENTREVISTA("S")
  ENDIF

  IF cAction="ENTI"
     oCliMnu:ENTREVISTA("I")
  ENDIF

  IF cAction="ENTP"
     oCliMnu:ENTREVISTA("P")
  ENDIF

  IF cAction="SUCXTAB"
     EJECUTAR("DPSUCXTAB",oCliMnu:cCodCli,oCliMnu:cNombre,"DPCLIENTES",oDp:xDPCLIENTES+ " por "+oDp:xDPSUCURSAL,NIL,.F.)
  ENDIF

  IF cAction="VALRIF"
     EJECUTAR("BRCLINOVALRIF","CLI_CODIGO"+GetWhere("=",oCliMnu:cCodCli),NIL,NIL,NIL,NIL,"Validar RIF "+oCliMnu:cCodCli)
  ENDIF

  IF cAction="RECURSOS"
     EJECUTAR("DPCLIENTESREC",oCliMnu:cCodCli)
  ENDIF

  IF cAction="RECIBOS"
     EJECUTAR("DPRECIBOSCLIX",.T.,"P",NIL,oCliMnu:cCodCli)
  ENDIF

RETURN .T.

FUNCTION TOTALIZAR()
RETURN .T.


FUNCTION CLOSE()
  // oCliMnu:Close()
RETURN .T.

// Expedientes
FUNCTION EXPEDIENTES()
  LOCAL cTitle:=ALLTRIM(GetFromVar("{oDp:DPEXPEDIENTES}"))+" del "+;
                GetFromVar("{oDp:XDPCLIENTES}")+" ["+oCliMnu:cCodCli+" "+ALLTRIM(oCliMnu:cNombre)+"]"
  LOCAL cWhere,oLbx

  cWhere:="EXP_CODMAE"+GetWhere("=",oCliMnu:cCodCli)+" AND EXP_TABLA='DPCLIENTES'"

  oDp:aCargo:={"",oCliMnu:cCodCli,"DPCLIENTES","",""}
  oLbx:=DPLBX("DPEXPEDIENTES.LBX",cTitle,cWhere)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5N£meroDoc
  oLbx:aCargo:=oDp:aCargo

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
          " ["+oCliMnu:cCodCli+" "+ALLTRIM(oCliMnu:cNombre)+"]"

  cWhere:="ENT_CODIGO"+GetWhere("=",oCliMnu:cCodCli)+" AND "+;
          "ENT_TIPO  "+GetWhere("=",cTipo)

  IF cTipo="I"

     cNumero:=SQLGET("DPCLIENTEENT","ENT_NUMERO",cWhere)

     EJECUTAR("DPCLIENTEENT" , IF(Empty(cNumero),1,3) , cNumero , "I" , oCliMnu:cCodCli )

     RETURN .T.

  ENDIF

  oDp:aCargo:={"",oCliMnu:cCodCli,cTipo,"",""}
  oLbx:=DPLBX("DPCLIENTEENT.LBX",cTitle,cWhere)

  oLbx:aCargo:=oDp:aCargo

RETURN .T.

// Facturación Periódica
FUNCTION FACTURAPER()
   LOCAL cTitle
   LOCAL cWhere,oLbx

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
           " ["+oCliMnu:cCodCli+" "+ALLTRIM(oCliMnu:cNombre)+" ]"

   cWhere:="DPG_CODIGO"+GetWhere("=",oCliMnu:cCodCli)

   oDp:aRowSql:={} // Lista de Campos Seleccionados
   oDpLbx:=TDpLbx():New("DPCLIENTEPROG.LBX",cTitle,cWhere)
   oDpLbx:uData1 :=oCliMnu:cCodCli
   oDpLbx:Activate()

RETURN .T.

/*
// Sucursal por Cliente
*/

FUNCTION SUCXCLIENTE()

  LOCAL cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTESSUC}"))+;
                " ["+oCliMnu:cCodCli+" "+ALLTRIM(oCliMnu:cNombre)+"]"
  LOCAL cWhere,oLbx

  cWhere:="SDC_CODCLI"+GetWhere("=",oCliMnu:cCodCli)

  oDp:aCargo:={"",oCliMnu:cCodCli,"DPCLIENTES","",""}
  oLbx:=DPLBX("DPCLIENTESSUC.LBX",cTitle,cWhere)

  // 1Sucursal,2Cliente,3Tabla,4TipoDoc,5N£meroDoc
  oLbx:aCargo:=oDp:aCargo
  oLbx:cScope:=cWhere

RETURN .T.


FUNCTION SETBTNGRPACTION(oCliMnu,cAction)
   LOCAL nGroup:=LEN(oCliMnu:oOut:aGroup)
   LOCAL oBtn  :=ATAIL(oCliMnu:oOut:aGroup[ nGroup, 2 ])
   LOCAL bAction

   bAction:=BLOQUECOD(cAction)

   oBtn:bAction   :=bAction // BLOQUECOD(cAction)
 //  oBtn:bLButtonUp:=oBtn:bAction
   oBtn:CARGO     :=cAction

RETURN oBtn

// EOF
