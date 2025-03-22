// Programa   : DPTIPDOCCLIMNU
// Fecha/Hora : 12/01/2011 17:22:34
// Propósito  : Menú Finalizar Tipo Documento del Cliente
// Creado Por : Juan Navas
// Llamado por: DPTIPDOCCLI Finalizar solo cuando se Modifica
// Aplicación : Tipos de Documentos del Cliente
// Tabla      : DPTIPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc)
   LOCAL cDescri:="",cSql,I,nGroup,cCxC
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={},lReqSca:=.F.,cCodRep
   LOCAL lLibVta:=.F.,lDelete,lMoven,lMovef,lCxC,lDepura,lDifPag,lProduc
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFAULT cTipDoc:="FAV"

   lLibVta:=SQLGET("DPTIPDOCCLI","TDC_LIBVTA,TDC_DELETE,TDC_MOVED,TDC_MOVEF,TDC_CXC,TDC_DEPURA,TDC_DIFPAG,TDC_PRODUC","TDC_TIPO"+GetWhere("=",cTipDoc))

   lDelete:=DPSQLROW(2,.F.)
   lMoven :=DPSQLROW(3,.F.)
   lMovef :=DPSQLROW(4,.F.)
   cCxC   :=DPSQLROW(5,"" )
   lCxC   :=("N"$cCxC     )
   lDepura:=DPSQLROW(6,.F.)
   lDifPag:=DPSQLROW(7,.F.)
   lProduc:=DPSQLROW(8,.F.)
  
   cDescri:=SQLGET("DPTIPDOCCLI","TDC_DESCRI,TDC_REQSCA","TDC_TIPO"+GetWhere("=",cTipDoc))
   lReqSca:=IF( Empty(oDp:aRow) , lReqSca , oDp:aRow[2])

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

   DpMdi(GetFromVar("{oDp:DPTIPDOCCLI}"),"oTdcMnu","")

   oTdcMnu:cTipDoc   :=cTipDoc
   oTdcMnu:cDescri   :=cDescri
   oTdcMnu:lSalir    :=.F.
   oTdcMnu:nHeightD  :=45
   oTdcMnu:lMsgBar   :=.F.
   oTdcMnu:oGrp      :=NIL
   oTdcMnu:lLibVta   :=lLibVta
   oTdcMnu:lDelete   :=lDelete
   oTdcMnu:lMoven    :=lMoven
   oTdcMnu:lMovef    :=lMovef
   oTdcMnu:lCxC      :=lCxC // (lCxC<>"N")
   oTdcMnu:lDepura   :=lDepura
   oTdcMnu:lDifPag   :=lDifPag
   oTdcMnu:lProduc   :=lProduc

   SetScript("DPTIPDOCCLIMNU")

//   AADD(aBtn,{"Definición para Importar Documentos"       ,"IMPORTAR.BMP"         ,"IMPORT"}) 
   AADD(aBtn,{"Definir Importación desde Otros Documentos","IMPORTAR.BMP"         ,"DEFIMPORTAR"}) 
// AADD(aBtn,{"Impresoras Fiscales"                       ,"IMPRESORATXT.BMP"     ,"SERIESFISCALES"})
   AADD(aBtn,{"Autorización de Usuarios"                  ,"PRIVILEGIOS.BMP"      ,"PRIVILEGIOS"}) 

   IF ISRELEASE("17.01")

     AADD(aBtn,{"Privilegio de Usuarios"                                  ,"USUARIO.BMP"          ,"USUARIOS"  }) 
     AADD(aBtn,{"Plantillas Permitidas"                                   ,"PLANTILLAS.BMP"       ,"PLANTILLAS"}) 
     AADD(aBtn,{"Detectar Números Faltantes"                              ,"XFIND.BMP"            ,"NUMEROS"   })
     AADD(aBtn,{"Detectar Registros Repetidos"                            ,"PASTE.BMP"            ,"REPETIDOS" })


//     IF lDelete .OR. lMoven .OR. lMovef

     IF !ISDOCFISCAL(cTipDoc)
       AADD(aBtn,{"Corregir y Eliminar Documentos"                          ,"SWAP.BMP"            ,"SWAP"  }) 
     ENDIF

//     ENDIF

   ENDIF
//  IF oDp:nVersion>=5
//     AADD(aBtn,{"Temas para Expediente","EXPEDIENTES.BMP"     ,"EXPEDIENTES"}) 
//  ENDIF

//   AADD(aBtn,{"Importar Tipos de Documentos"                   ,"IMPORTAR.BMP"         ,"IMPORTAR"}) 


   IF lReqSca .AND. oDp:nVersion>=5
     AADD(aBtn,{"Usuarios con Scanner"                      ,"SCANNER.BMP"          ,"SCANNER"}) 
   ENDIF

   IF oTdcMnu:lProduc
     AADD(aBtn,{"Formulario","FORM.BMP"         ,"FORM"}) 
   ENDIF

   AADD(aBtn,{"Visualizar Variables","VARIACION.BMP"         ,"VARIACION"}) 



   oTdcMnu:Windows(0,0,aCoors[3]-164-20,410+5)

//   oASIENTOSINDEF:Windows(0,0,aCoors[3]-160,620,.T.) // Maximizado


  @ 48, -1 OUTLOOK oTdcMnu:oOut ;
     SIZE 150+250, oTdcMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oTdcMnu:oWnd;
     COLOR CLR_BLACK,oDp:nGris

//14085099

   DEFINE GROUP OF OUTLOOK oTdcMnu:oOut PROMPT "&Opciones  "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oTdcMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oTdcMnu:oOut:aGroup)
      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oTdcMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   // Vinculos
   DEFINE GROUP OF OUTLOOK oTdcMnu:oOut PROMPT "&Vínculos  "

   aBtn:={}

   IF lDifPag
     AADD(aBtn,{oDp:XDPCTAEGRESO+" para Crear Diferencias de Pago","RECIBIRDINERO.BMP"           ,"DIFPAGCTAEGRESO"}) 
   ENDIF

   AADD(aBtn,{"Utilización de Productos"                  ,"PRODUCTO.BMP"         ,"DEFPRODUCTOS"}) 

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oTdcMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oTdcMnu:oOut:aGroup)
      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oTdcMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I


   DEFINE GROUP OF OUTLOOK oTdcMnu:oOut PROMPT "&Procesos  "

   aBtn:={}

   AADD(aBtn,{"Recalcular Cuentas por Cobrar"   ,"RUN.BMP"         ,"REPLA_CXC"})

   IF oTdcMnu:lDepura 
     AADD(aBtn,{"Depurar Registros"             ,"XDELETE.BMP"      ,"DEPURAR"})
   ENDIF


   IF oTdcMnu:cTipDoc="DEV"
      AADD(aBtn,{"Exportar hacia Notas de Crédito"             ,"exports.bmp"      ,"DEVTOCRE"})
   ENDIF

   AADD(aBtn,{"Replantear Movimientos "                   ,"MOVIMIENTOINV.BMP"    ,"REPLA_MOV"}) 

   AADD(aBtn,{"Resolver Repetidos"                        ,"BUG.BMP"              ,"DOCFIX"})

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oTdcMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oTdcMnu:oOut:aGroup)
      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oTdcMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

IF .T.
// ISRELEASE("20.01")

 DEFINE GROUP OF OUTLOOK oTdcMnu:oOut PROMPT "&Personalizar  "

   aBtn:={}

   AADD(aBtn,{"Personalizar Columnas"            ,"FIELDS.BMP"      ,"PERSONALIZAR"}) 
   AADD(aBtn,{"Cuentas Contables DEBE x Cliente" ,"CONTABILIDAD.BMP","CTAXCLIENTE_CRE"})

   IF ISTABMOD("DPREPORTES") 

     AADD(aBtn,{"Editar Reporte"                   ,"genrep.BMP"      ,"REPORTE"}) 

     cCodRep:="DOCCXC_"+cTipDoc

     IF ISSQLFIND("DPREPORTES","REP_CODIGO"+GetWhere("=",cCodRep))
       AADD(aBtn,{"Editar Reporte Documento" ,"genrep.BMP"      ,"REPORTEDOC"}) 
     ENDIF

   ENDIF

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oTdcMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oTdcMnu:oOut:aGroup)
      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oTdcMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oTdcMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I


ENDIF



   @ 0, 100 SPLITTER oTdcMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oTdcMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oTdcMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oTdcMnu:oDlg FROM 0,oTdcMnu:oOut:nWidth() TO oTdcMnu:nHeightD,700;
          TITLE "Cliente Contado" STYLE WS_CHILD OF oTdcMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oTdcMnu:oGrp TO 10,10 PROMPT "Código ["+oTdcMnu:cTipDoc+"]"

   @ .5,.5 SAY oTdcMnu:cDescri SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oTdcMnu:oDlg NOWAIT VALID .F.

   oTdcMnu:Activate("oTdcMnu:FRMINIT()",,"oTdcMnu:oSpl:AdjRight()")
 
RETURN

FUNCTION FRMINIT()

   oTdcMnu:oWnd:bResized:={||oTdcMnu:oDlg:Move(0,0,oTdcMnu:oWnd:nWidth(),50,.T.),;
                             oTdcMnu:oGrp:Move(0,0,oTdcMnu:oWnd:nWidth()-15,oTdcMnu:nHeightD,.T.)}

   EVal(oTdcMnu:oWnd:bResized)

RETURN .T.

FUNCTION INVACTION(cAction)
   LOCAL cGrupo,cUsuario,cWhere
   LOCAL cCodSuc,nPeriodo,dDesde,dHasta,cTitle
   LOCAL cCodRep:="DOCCLI"+oTdcMnu:cTipDoc

   CursorWait()

   IF cAction="REPLA_CXC"
      EJECUTAR("CXCFIX",oTdcMnu:cTipDoc)
   ENDIF

   IF cAction="DOCFIX"
      EJECUTAR("DPDOCCLIREPETIDOS")
   ENDIF

   IF cAction="REPLA_MOV"
      EJECUTAR("DPMOVINVREPLAN",oTdcMnu:cTipDoc)
   ENDIF

   IF cAction="DEFIMPORTAR"
      EJECUTAR("DPTIPDOCCLIIMP",oTdcMnu:cTipDoc,oTdcMnu:cNombre )
   ENDIF

   IF cAction="DEFPRODUCTOS"
//    EJECUTAR("DPTIPCLIINV",oTdcMnu:cTipDoc)
      EJECUTAR("DPTIPDOCCLIUTILIZ",oTdcMnu:cTipDoc)
   ENDIF

   IF cAction="SCANNER"
       EJECUTAR("DPTABXUSU",oTdcMnu:cTipDoc,oTdcMnu:cDescri,"DPTIPDOCCLISCANNER","Usuarios con Scanner para el [Tipo de Documento "+oTdcMnu:cTipDoc+" ]")
   ENDIF

   IF cAction="VARIACION"
       EJECUTAR("MODIMPCXP",oTdcMnu:cTipDoc)
   ENDIF

   IF cAction="SERIESFISCALES"
       EJECUTAR("DPEQUIPOSPOLBX",oTdcMnu:cTipDoc,.F.,.T.)
   ENDIF

   IF cAction="EXPEDIENTES"
       EJECUTAR("DPTIPCLITEMEXP",oTdcMnu:cTipDoc)
   ENDIF

   IF cAction="PRIVILEGIOS"
      EJECUTAR("DPTABXUSU",oTdcMnu:cTipDoc,oTdcMnu:cDescri,"DPTIPDOCCLI","Usuarios por ["+oDp:DPTIPDOCCLI+"]")
   ENDIF

//   IF cAction="IMPORT"
//      EJECUTAR("DPTIPDOCCLIIMP",oTdcMnu:cTipDoc,oTdcMnu:cDescri)
//   ENDIF

   IF cAction="EXPORT"
      EJECUTAR("DPTIPDOCCLIDEFEXP",oTdcMnu:cTipDoc,oTdcMnu:cDescri)
   ENDIF

  IF cAction="USUARIOS"
    EJECUTAR("BRUSUTIPDOCCLI",NIL,NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
  ENDIF

  IF cAction="PLANTILLAS"
    EJECUTAR("DPTIPDOCXPLANT",oTdcMnu:cTipDoc,oTdcMnu:cDescri)
  ENDIF

  IF cAction="NUMEROS"
    EJECUTAR("DPDOCCLINUM",NIL,oTdcMnu:cTipDoc)
  ENDIF

  IF cAction="SWAP"
     EJECUTAR("BRDOCCLIMOVNUM",NIL,NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
  ENDIF

  IF cAction="IMPORTAR"
     EJECUTAR("DPUPDATECATALOG",.T.,"DPTIPDOCCLI")
  ENDIF

  IF cAction="RUNCXC"
     EJECUTAR("CXCFIX",oTdcMnu:cTipDoc )
  ENDIF

  IF cAction="PERSONALIZAR"
    EJECUTAR("BRTIPDOCCLICOL",NIL,NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
  ENDIF

  IF cAction="CTAXCLIENTE_CRE"
//  EJECUTAR("BRTIPDOCCLICOL",NIL,NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
    cWhere:="CXC_TIPDOC"+GetWhere("=",oTdcMnu:cTipDoc)+" AND "+;
            "CXC_CTACRE"+GetWhere("<>","")

    EJECUTAR("BRDPCLIENTECTAC",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
  ENDIF

  IF cAction="DEPURAR"


     IF oTdcMnu:lCxC
       EJECUTAR("BRDOCCLIPAGDEP","DOC_TIPDOC"+GetWhere("=",oTdcMnu:cTipDoc),NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
     ENDIF

  ENDIF

  IF cAction="DIFPAGCTAEGRESO"
    EJECUTAR("BRTIPDOCCLICTAE",NIL,NIL,NIL,NIL,NIL,NIL,oTdcMnu:cTipDoc)
  ENDIF

  IF cAction=="REPORTE" .AND. oTdcMnu:cTipDoc="IGT"
     cCodRep:="DOCCXCIGTF"
     RETURN EJECUTAR("DPREPORTES",3,cCodRep)
  ENDIF

  IF cAction=="REPORTE" .AND. oTdcMnu:cTipDoc="DEB"
     cCodRep:="DOCCXC_DEB"
     RETURN EJECUTAR("DPREPORTES",3,cCodRep)
  ENDIF

  IF cAction=="REPORTE" .AND. oTdcMnu:cTipDoc="CRE"
     cCodRep:="DOCCLICRE"
     RETURN EJECUTAR("DPREPORTES",3,cCodRep)
  ENDIF

  IF cAction=="REPORTEDOC" .AND. oTdcMnu:cTipDoc="CRE"
     cCodRep:="DOCCXC_CRE"
     RETURN EJECUTAR("DPREPORTES",3,cCodRep)
  ENDIF

  IF cAction=="REPORTE"

      IF ISSQLFIND("DPREPORTES","REP_CODIGO"+GetWhere("=",cCodRep))
        EJECUTAR("DPREPORTES",3,cCodRep)
      ELSE
        cCodRep:="DOCCLIGEN"
        EJECUTAR("DPREPORTES",3,cCodRep)
      ENDIF

  ENDIF

  IF cAction=="REPORTEDOC"

      cCodRep:="DOCCXC_"+oTdcMnu:cTipDoc

      EJECUTAR("DPREPORTES",3,cCodRep)

  ENDIF


  IF cAction="REPETIDOS"
     EJECUTAR("DPTABLASREGREP","TAB_NOMBRE"+GetWhere("=","DPDOCCLI"))
  ENDIF

  IF cAction="FORM"
     EJECUTAR("DPFACTURAV",oTdcMnu:cTipDoc)
  ENDIF

  IF cAction="DEVTOCRE"
     EJECUTAR("DEVTOCRE")
  ENDIF

RETURN .T.
// EOF
