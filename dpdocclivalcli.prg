// Programa   : DPDOCCLIVALCLI
// Fecha/Hora : 08/10/2005 21:36:19
// Propósito  : Valida Código del Cliente
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGet,oDoc,oSay,lMovInv)
  LOCAL cCodVen,lCliZero:=.F.,lChange:=.F.,nAt,cWhere
  LOCAL oDatCli,aData:={},I,oMov,cTipIva:="",cDescri:=""
  LOCAL oGrid,cTipDoc:=""

  DEFAULT lMovInv:=.T.

  // Crea Terceros
  // EJECUTAR("DPCREATERCEROS")

  IF !Empty(oDoc:cKey)
     Return .F.
  ENDIF

  IF Empty(oDoc:DOC_CODIGO)
    oDoc:oDOC_CODIGO:KeyBoard(VK_F6)
//  EVAL(oDoc:oDOC_CODIGO:bAction)
    oDoc:oCliNombre:Refresh(.T.)
    RETURN .F.

  ENDIF
// oDoc:cZonaNL:="N"

  IF (!oDoc:DOC_CODIGO_=oDoc:DOC_CODIGO) .AND. oDoc:DOC_CODIGO_=STRZERO(0,10)
    oDoc:BtnPaint() // Cliente Zero fué Cambiado
    lChange  :=.T.
  ENDIF

  IF oDoc:cTipDoc="PLA"
     RETURN .T.
  ENDIF

  IF oDoc:DOC_CODIGO=STRZERO(0,10) 

    lCliZero:=.T.
    oDoc:oCliNombre:Refresh(.T.)
    oDoc:BtnPaint()

    IF !EJECUTAR("DPCLIENTESCERO",oDoc,oDoc:oDOC_CODIGO)
      RETURN .F.
    ENDIF

    // Forza el Nuevo acceder al siguiente Control
    oDoc:oCliNombre:Refresh(.T.)
    oDoc:oDOC_CODIGO:oWnd:nLastKey == VK_TAB
    oDoc:oDOC_CODIGO:oWnd:GoNextCtrl( oDoc:oDOC_CODIGO:hWnd )
    lChange:=.F.

  ELSE

    IF !EJECUTAR("DOCCLIVALID",oDoc:DOC_CODIGO,oDoc:oDOC_CODIGO) // Valida Código del Cliente
      EVAL(oDoc:oDOC_CODIGO:bAction)
      RETURN .F.
    ENDIF

// ? oDoc:lPar_Limite,"oDoc:lPar_Limite",oDoc:nPar_CxC

//  IF oDoc:nPar_CxC>0 .AND. oDoc:cValCodCli<>oDoc:DOC_CODIGO .AND. !EJECUTAR("DPCLIENTEVENC",oDoc:DOC_CODIGO,NIL,NIL,oDoc:lPar_Limite,oGet)

// ? oDoc:lPar_Limite,"oDoc:lPar_Limite, ES .f.  no debe aplicar en ningun documento"

    IF !oDoc:lPar_Limite .AND. oDoc:cValCodCli<>oDoc:DOC_CODIGO .AND. !EJECUTAR("DPCLIENTEVENC",oDoc:DOC_CODIGO,NIL,NIL,oDoc:lPar_Limite,oGet)

      oDoc:cValCodCli:=""
      RETURN .F.
    ENDIF

    oDoc:cValCodCli:=oDoc:DOC_CODIGO

  ENDIF

  IF oDoc:nOption=1 .AND. Empty(oDoc:DOC_CODVEN) .AND. !lCliZero
    EJECUTAR("DPDOCCLIULT",oDoc,oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:DOC_CODIGO)
  ENDIF

  oDatCli:=OpenTable(" SELECT CLI_DESCUE,CLI_CONDIC,CLI_DIAS,CLI_PRECIO,CLI_ZONANL,CLI_LISTA,CLI_CODMON,CLI_INVMON,CLI_CODVEN,CLI_ENOTRA,CLI_TERCER, "+;
                     " CLI_CDESC,CLI_RESIDE,CLI_PAGELE,CLI_RIF,CLI_DESFIJ,CLI_NOMBRE " +; 
                     " FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=", oDoc:DOC_CODIGO),.T.)

  oDoc:cZonaNL    :=oDatCli:CLI_ZONANL
  oDoc:cCliPrecio :=oDatCli:CLI_LISTA
  oDoc:cInvCodMon :=oDatCli:CLI_INVMON
  oDoc:lPar_Moneda:=UPPE(oDatCli:CLI_ENOTRA)="S"
  oDoc:cTerceros  :=oDatCli:CLI_TERCER
  oDoc:DOC_DESTIN :=IF(oDatCli:CLI_RESIDE="S" .OR. Empty(oDatCli:CLI_RESIDE),"N","E")
  oDoc:cZonaNL    :=IF(Empty(oDoc:cZonaNL),"N",oDoc:cZonaNL)
  oDoc:lPagEle    :=LEFT(oDatCli:CLI_PAGELE,1)="S"
  oDoc:cRif       :=oDatCli:CLI_RIF
  oDoc:cCodMon    :=oDatCli:CLI_CODMON
  oDoc:cDesFij    :=oDatCli:CLI_DESFIJ

// ? oDoc:DOC_DESTIN,"oDoc:DOC_DESTIN"

  oDatCli:End()

  // cRif,oRif,lMsg,lZero,cNombre
  IF !EJECUTAR("VALRIFLEN",oDoc:cRif,oDoc:oDOC_CODIGO,.F.,NIL,oDatCli:CLI_NOMBRE)
     EJECUTAR("DPCLIENTESEDITRIF",oDoc:DOC_CODIGO,oDoc:oDOC_CODIGO,NIL,oDoc:oCliNombre)
     // oDoc:oDOC_CODIGO:MsgErr(oDp:cRifErr,"Incorrecto")
     RETURN .F.
  ENDIF

  oDoc:SET("DOC_DESCCO",oDatCli:CLI_CDESC)

  IF oDoc:cTerceros="N"
     // No requiere Terceros, asume Indefinido
     oDoc:SET("DOC_CODTER",oDp:cCodter,.T.)
  ENDIF

  // Lo Asume por Defecto
  IF Empty(oDoc:DOC_CODTER)
     oDoc:SET("DOC_CODTER",oDp:cCodter,.T.)
  ENDIF

  IF oDoc:DOC_CXC=0 .AND. !Empty(oDatCli:CLI_INVMON)
    // Documento Comercial
    oDatCli:CLI_CODMON:=oDatCli:CLI_INVMON
  ENDIF

  IF Empty(oDatCli:CLI_CODMON)
    oDatCli:CLI_CODMON:=oDp:cMoneda
  ENDIF

  IF UPPE(oDatCli:CLI_ENOTRA)="S" .AND. !Empty(oDatCli:CLI_CODMON)
    oDatCli:CLI_CODMON:=oDp:cMonedaExt
  ENDIF

//? oDatCli:CLI_CODVEN,"oDatCli:CLI_CODVEN"

  IF !Empty(oDatCli:CLI_CODVEN) .AND. oDoc:nOption=1 
    oDoc:oDOC_CODVEN:VarPut(oDatCli:CLI_CODVEN,.T.)
  ENDIF

  IF !Empty(oDatCli:CLI_CODMON) .AND. oDoc:nOption=1 

    oDoc:oDOC_CODMON:SETITEMS(oDp:aMonedas)

    nAt:=ASCAN(oDoc:oDOC_CODMON:aItems,{|a,n|LEFT(a,3)=oDatCli:CLI_CODMON })

    IF nAt>0
      oDoc:oDOC_CODMON:SELECT(nAt)
      oDoc:DOC_CODMON:=oDoc:oDOC_CODMON:aItems[nAt]
      Eval(oDoc:oDOC_CODMON:bChange)
      COMBOINI(oDoc:oDOC_CODMON)
    ENDIF

  ENDIF

  COMBOINI(oDoc:oDOC_CODMON)

  oDatCli:End()

  IF oDoc:nOption=1 .AND. Empty(oDoc:DOC_DCTO)
    oDoc:DOC_DCTO :=oDatCli:CLI_DESCUE
    oDoc:DOC_PLAZO:=oDatCli:CLI_DIAS
//  oDoc:DOC_CONDIC :=oDatCli:CLI_CONDIC
    oDoc:oDOC_DCTO:VarPut(oDoc:DOC_DCTO,.T.)
  ENDIF

  // Requiere el Ultimo Precio de Venta
  oDoc:CODCLI:="" 
  IF oDatCli:CLI_PRECIO="S"
    oDoc:CODCLI:=oDoc:DOC_CODIGO
  ENDIF

  IF ((oDoc:nOption=3 .OR. oDoc:lSaved)  .AND. !oDoc:DOC_CODIGO_=oDoc:DOC_CODIGO) 

     cWhere:="MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC )+" AND "+;
             "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC )+" AND "+;
             "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO )+" AND MOV_APLORG='V' "

      SQLUPDATE("DPMOVINV","MOV_CODCTA",oDoc:DOC_CODIGO,cWhere)
      SQLUPDATE("DPDOCCLI","DOC_CODIGO",oDoc:DOC_CODIGO,"DOC_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC )+" AND "+;
                                                        "DOC_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC )+" AND "+;
                                                        "DOC_NUMERO"+GetWhere("=",oDoc:DOC_NUMERO ))


      oDoc:DOC_CODIGO_:=oDoc:DOC_CODIGO // Cliente Validado

      IF lMovInv
        EJECUTAR("DOCTOTAL",oDoc,.T.,.T., NIL , .T. ,.T.)
      ENDIF

   ENDIF

   oDoc:DOC_CODIGO_:=oDoc:DOC_CODIGO // Cliente Validado

   EJECUTAR("DPDOCCLISUC",oDoc,oGet) // Solicita Sucursal del Cliente

   IF lChange
     oDoc:BtnPaint()
     oDoc:oBar:Refresh(.T.)
   ENDIF

   EJECUTAR("DPDOCCLIVALCAM",oDoc)

   IIF( ValType(oSay)="O" , oSay:Refresh(.T.) , NIL )

   /*
   // Sera AgregadO los productos Automáticos
   */

   // JN 13/12/2013, Hace lento hacer facturas, lee demasiados producos
   IF !oDoc:lImportAut .AND. oDp:nVersion>=5 .AND. oDoc:lIsProdAutm .AND. .F.

     aData:=ASQL(" SELECT MOV_CODIGO,MOV_UNDMED,MOV_CANTID,MOV_PRECIO,INV_DESCRI,INV_NUMMEM FROM DPMOVINV "+;
                 " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
                 " WHERE MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+;
                 "   AND MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+;
                 "   AND MOV_APLORG"+GetWhere("=","T"))
     oDoc:lIsProdAutm:=!Empty(aData)
	
     oGrid:=oDoc:aGrids[1]

     FOR I=1 TO LEN(aData)

        cTipIva:=SQLGET("DPINV","INV_IVA,INV_DESCRI","INV_CODIGO"+GetWhere("=",aData[I,1]))

        oGrid:Set("MOV_CODIGO",aData[I,1] ,.T.)
        oGrid:Set("MOV_UNDMED",aData[I,2] ,.T.)
        oGrid:Set("INV_DESCRI",aData[I,5] ,.T.)

        oGrid:Set("MOV_CANTID",aData[I,3] ,.T.)
        oGrid:Set("MOV_PRECIO",aData[I,4] ,.T.)
        oGrid:Set("MOV_NUMMEM",aData[I,6]     )

        oGrid:Set("MOV_TOTAL" ,aData[I,3]*aData[I,4],.T.)

        oGrid:Set("MOV_CODSUC",oDoc:DOC_CODSUC)
        oGrid:Set("MOV_APLORG","V"            )
        oGrid:Set("MOV_TIPDOC",oDoc:DOC_TIPDOC)
        oGrid:Set("MOV_FECHA" ,oDoc:DOC_FECHA )
        oGrid:Set("MOV_HORA"  ,oDoc:DOC_HORA  )
        oGrid:Set("MOV_DOCUME",oDoc:DOC_NUMERO)
        oGrid:Set("MOV_DOCCTA",oDoc:DOC_CODIGO)

        oGrid:Set("MOV_INVACT",1              )
        oGrid:Set("MOV_USUARI",oDp:cUsuario   )
        oGrid:Set("MOV_CXUND" ,1              )
        oGrid:Set("MOV_CODALM",oDp:cAlmacen   )
        oGrid:Set("MOV_CENCOS",oDp:cCenCos    )

        oGrid:Set("MOV_TIPIVA",cTipIva        )
        oGrid:Set("MOV_APLORG","V"            )
        oGrid:Set("MOV_ITEM"  ,STRZERO(I,5)   )
        oGrid:Set("MOV_CODTRA","S000"         )
        oGrid:Set("MOV_TIPO"  ,"I"            )

        IF !Empty(oGrid:MOV_NUMMEM)
          
           oGrid:aMemo[7]:=0
           oGrid:aMemo[8]:=SQLGET("DPMEMO","MEM_MEMO,MEM_DESCRI","MEM_NUMERO"+GetWhere("=",oGrid:MOV_NUMMEM)+;
                                                          "  AND  MEM_ID"    +GetWhere("=", oDp:cIdMemo    ))
           oGrid:aMemo[9]:=IIF(!Empty(oDp:aRow[2]),oDp:aRow[2],"")
           oGrid:MOV_NUMMEM:=0 

        ENDIF

        oDoc:lImportAut:=.T.

        oGrid:IsFinish(.T.)

        oDoc:lImportAut:=.T.

     NEXT I

     oDoc:lImportAut:=.T.

   ENDIF
   
   SysRefresh(.T.)

RETURN .T.

// EOF
