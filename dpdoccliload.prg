// Programa   : DPDOCCLILOAD
// Fecha/Hora : 08/10/2005 22:34:37
// Propósito  : Carga de Valores en DPFACTURAV
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc)
  LOCAL oTable,oCol,oGet,dFecha,cNumero:="",cLetra:="",cNumFis
  LOCAL oData,cIp:=oDp:cIpLocal,cWhere,aItems:={},nAt

  IF oDoc=NIL
    RETURN .T.
  ENDIF

  SysRefresh(.T.)

  dFecha:=IIF(oDoc:nOption=1 , oDp:dFecha , oDoc:DOC_FECHA )

  oDoc:lSelCodSuc:=.F. // Seleccionar Codigo Sucursal
  oDoc:lImportAut:=.F. 

  // Valida la Fecha de Documentos Fiscales, no se puede incluir,Modifica o Anular Documentos Fiscales
  oDoc:oDOC_FECHA:Refresh(.T.)

  IF oDoc:lPar_LibVta .AND. (!oDoc:nOption=0 .AND. !EJECUTAR("DPVALFECHA" , dFecha , .T. , .T., oDoc:oDOC_FECHA ))
    oDoc:Cancel()
    RETURN .F.
  ENDIF

  // Direccion de Entrega
  IF .T.

    cWhere:="DIR_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
            "DIR_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
            "DIR_NUMDOC"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
            "DIR_TIPTRA"+GetWhere("=",oDoc:DOC_TIPTRA)

    IF oDoc:nOption=1
      oTable:=OpenTable("SELECT * FROM DPDOCCLIDIR",.F.)
    ELSE
      oTable:=OpenTable("SELECT * FROM DPDOCCLIDIR WHERE "+cWhere,.T.)
    ENDIF

    AEVAL(oTable:aFields,{|a,n| oDoc:SetValue(a[1],oTable:FieldGet(n))})
    oTable:End()
 
  ENDIF

  IF oDoc:nOption=3

    IF !EJECUTAR("DPDOCCLIISDEL",oDoc) // Verifica si Puede ser Modificado
      oDoc:Cancel()
      RETURN .F.
    ENDIF

    IF !SQLGET("DPDOCCLICTA","SUM(CCD_MONTO)",;
                             "CCD_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                             "CCD_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                             "CCD_NUMERO"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
                             "CCD_ACT = 1 ")=0

      MensajeErr(oDoc:cNomDoc+" ["+oDoc:DOC_NUMERO+"]"+" Posee Cuentas Contables","Debe Utilizar la Opción Documentos")
      oDoc:Cancel()
      RETURN .F.

    ENDIF

    IF(oDoc:oScroll=NIL,NIL,oDoc:oScroll:UpdateFromForm())

    IF oDoc:DOC_CODIGO=STRZERO(0,10)
      EJECUTAR("DPCLICEROLEER",oDoc)
    ENDIF

  ENDIF

  oDoc:SetValue("DOC_TIPDOC" ,oDoc:cTipDoc)

  oDoc:lEditCli   :=.T.
  oDoc:cCodigo    := oDoc:DOC_CODIGO
  oDoc:cNumero    := oDoc:DOC_NUMERO
  oDoc:DOC_DOCORG :="V" 
  oDoc:DOC_CXC    := oDoc:nPar_CxC
  oDoc:SetValue("DOC_TIPTRA","D")
  oDoc:cZonaNL    :=""
  oDoc:cInvCodMon :=""
  oDoc:oFocusFind :=IIF(oDoc:oFocusFind=NIL,oDoc:oDOC_NUMERO,oDoc:oFocusFind)

  IF oDoc:nOption=1

    oDoc:nBruto    :=0
    oDoc:nIva      :=0
    oDoc:nItems    :=0    // Numero de Items
    oDoc:cCliPrecio:="" 
    oDoc:DOC_INVMON:=.F.
    oDoc:lImportAut:=.F.

    oDoc:SetValue("DOC_FECHA" ,DPFECHA()    )
    oDoc:SetValue("DOC_CODSUC",oDp:cSucursal)
    oDoc:SetValue("DOC_HORA"  ,DPHORA()     )

    IF oDoc:lPar_LibVta
       oDoc:DOC_FCHDEC:=EJECUTAR("GETVALFCHDEC",oDoc:DOC_FECHA)
    ENDIF

    IF ValType(oDp:cCenCos)="C"
      oDoc:SetValue("DOC_CENCOS",oDp:cCenCos  )
    ENDIF

// ? oDp:cCenCos,"oDp:cCenCos"

    oDoc:DOC_FCHDEC:=CTOO(oDoc:DOC_FCHDEC,"D")

    oDoc:SetValue("DOC_DESTIN","N"            ) // Nacional
    oDoc:SetValue("DOC_CODMON",oDp:cMoneda    )
    oDoc:SetValue("DOC_NETO"  ,0              )
    oDoc:SetValue("DOC_NUMMEM",0              )
    oDoc:SetValue("DOC_CODTRA",oDp:cCodTrans  )
    oDoc:SetValue("DOC_FCHDEC",oDoc:DOC_FCHDEC)

   // oDoc:SetValue("cNumEpson" ,""           ) // Número de Ultima Factura EPSON Se inactivo para volver a imprimir con EPSON  de antes TJ

    oDoc:cCodigo:=""
    oDoc:cNumero:=""
    oDoc:cZonaNL:="N" // Nacional Es cambiado VALCODCLI
    oDoc:SetValue("DOC_ESTADO" ,"AC")  // Pendiente
    oDoc:DOC_ANUFIS :=.F.  

    IF(oDoc:oScroll=NIL,NIL,oDoc:oScroll:UpdateFromForm())

    IF !oDoc:lPar_CODCLI

      oDoc:SetValue("DOC_CODIGO",STRZERO(0,10))
      IF !EJECUTAR("DPDOCCLIVALCLI",oDoc:oDOC_CODIGO,oDoc)
        oDoc:CANCEL()
      ENDIF

      IF !oDoc:oCliNombre=NIL
        oDoc:oCliNombre:Refresh(.T.)
      ENDIF

    ENDIF

    // Se activo TJ
    // Desactivado 17/09/2020 IRON, no es necesario
    IF oDoc:nEpson<>0 .AND. oDocCli:nPar_CxC<>0 .AND. .F.

      cNumero:=EJECUTAR("EPSONPF-NUM",oDocCli:nPar_CxC=1)

      IF Empty(cNumero)
         RETURN .F.
      ENDIF

      oDocCli:oDOC_NUMERO:VarPut(cNumero,.T.)

    ENDIF 

    // Se inactivo para volver a imprimir con EPSON  de antes TJ
    // Numeracion de la Impresora Fiscal

   /*
    IF oDoc:nEpson<>0 .AND. oDocCli:nPar_CxC<>0 

      EJECUTAR("EPSONDOCNUM",oDocCli)
   */

   /*

      cNumero:=EJECUTAR("EPSONPF-NUM",oDocCli:nPar_CxC=1)

      cLetra:=ALLTRIM(SQLGET("DPEQUIPOSPOS","EPV_SERIEF,EPV_NUMERO","EPV_IP"    +GetWhere("=",oDp:cPcName)+" AND "+;
                                                                    "EPV_TIPDOC"+GetWhere("=",cTipDoc )))

      // Cada PC posee su Impresora   
      IF !Empty(cLetra)
          cNumero:=cLetra+STRZERO(VAL(cNumero)+1,9)
      ELSE
          cNumero:=STRZERO(VAL(cNumero)+1,10)
      ENDIF

//? cNumero,cLetra,"IMPRESORA FISCAL"

      IF Empty(cNumero)
         RETURN .F.
      ENDIF

      oData:=DATASET("SUC_V"+oDp:cSucursal,"ALL")
      oData:Set(oDoc:cTipDoc+"Numero",cNumero)
      oData:Set(oDoc:cTipDoc+"NumFis",cNumero)
      oData:Save(.T.)
      oData:End()

      oDocCli:oDOC_NUMERO:VarPut(cNumero,.T.)
*/
      // Numeración fiscal
      cLetra:=SQLGET("DPTIPDOCCLI","TDC_SERIEF","TDC_TIPO"+GetWhere("=",oDoc:DOC_TIPDOC))

      // Numero del Documento
      EJECUTAR("DPDOCCLIGETNUM",oDoc:DOC_TIPDOC,oDoc:cScope,oDoc)

//? "NUMERO FISCAL",oDoc:DOC_NUMERO

/*
// 02/11/2020 Epson genera DOC_NUMFIS 
      IF oDoc:nEpson=0 .OR. .T.

        oData:=DATASET("SUC_V"+oDp:cSucursal,"ALL")
        cNumero:=oData:Get(oDoc:cTipDoc+"Numero",cNumero)
        cNumFis:=oData:Get(oDoc:cTipDoc+"NumFis",cNumero)
        oData:End()

        // Caso de numeracion en caso de Serie Fiscal
        IF cNumero>oDoc:DOC_NUMERO
           oDoc:DOC_NUMERO:=cNumero
        ENDIF

        WHILE oDoc:nEpson=0 .AND. COUNT("DPDOCCLI",oDoc:cScope+" AND DOC_NUMERO"+GetWhere("=",oDoc:DOC_NUMERO))>0
          oDoc:DOC_NUMERO:=DPINCREMENTAL(oDoc:DOC_NUMERO)
          SysRefresh(.T.)
        ENDDO

        oDoc:oDOC_NUMERO:VarPut(oDoc:DOC_NUMERO,.T.)

      ENDIF
*/

   // ENDIF

  ELSE

    // Obtengo la Cantidad de Items, Modificar

    IF oDoc:nOption=3

      oDoc:nItems:=COUNT("DPMOVINV","MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+; 
                                    "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                                    "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+; 
                                    "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO)+" AND "+; 
                                    "MOV_APLORG"+GetWhere("=", "V")+" AND "+; 
                                    "MOV_INVACT"+GetWhere("=",1))

      oDoc:cCliPrecio:=SQLGET("DPCLIENTES","CLI_LISTA","CLI_CODIGO"+GetWhere("=",oDoc:DOC_CODIGO))

    ENDIF

    // 11/2/2025 no puede modificar documentos fiscales.
    IF ASCAN({"FAV","DEB","CRE","NEN","DEV","TIK"},oDoc:DOC_TIPDOC)=0

      EJECUTAR("DPDOCCLIIMP",oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:DOC_CODIGO,oDoc:DOC_NUMERO,.F.,oDoc:DOC_DCTO,oDoc:DOC_RECARG,;
                           oDoc:DOC_OTROS ,"V",0,oDoc:DOC_DOCORG,oDoc:DOC_ACT)
 
     oDoc:nBruto:=oDp:nBruto
     oDoc:nIva  :=oDp:nIva

    ENDIF

  ENDIF

//  IF oDoc:nOption=3 .AND. oDoc:DOC_CODIGO=STRZERO(0,10)
//
//      EJECUTAR("DPCLICEROLEER",oDoc)
//
//  ENDIF

  oDoc:DOC_CODIGO_:=oDoc:DOC_CODIGO // Cliente Validad

  IF  "COMBO"$oDocCli:oDOC_CODMON:ClassName()

    // 15/11/2023
    IF oDoc:nOption=0

       nAt   :=ASCAN(oDp:aMonedas,{|a,n| LEFT(a,3)=LEFT(oDocCli:DOC_CODMON,3)})
       COMBOINI(oDocCli:oDOC_CODMON)

       IF nAt>0
         aItems:={oDp:aMonedas[nAt]}
       ELSE
         aItems:=oDp:aMonedas
       ENDIF

       oDocCli:oDOC_CODMON:SetItems(aItems)
       oDocCli:oDOC_CODMON:Select(1)
       oDocCli:oDOC_CODMON:Refresh(.T.)

    ELSE


      cWhere:="DOC_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D")

      oDoc:_DOC_CODMON:=SQLGET("DPDOCCLI","DOC_CODMON,DOC_VALCAM",cWhere)
      oDoc:_DOC_VALCAM:=DPSQLROW(2)

//? oDp:cSql,oDoc:DOC_CODMON,"<-oDoc:DOC_CODMON"
//       oDocCli:oDOC_CODMON:SetItems(oDp:aMonedas)
//      IF oDocCli:nOption=3
//         oDocCli:oDOC_CODMON:VarPut(oDoc:_DOC_CODMON,.T.)
//      ENDIF
// COMBOINI(oDocCli:oDOC_CODMON)
// ? oDoc:_DOC_CODMON,oDoc:DOC_CODMON,"al modificar"

    ENDIF

    IF Empty(oDocCli:oDOC_CODMON:aItems) 
       oDocCli:oDOC_CODMON:SetItems(oDp:aMonedas)
       COMBOINI(oDocCli:oDOC_CODMON)
    ENDIF
  
  ENDIF

  IF !oDoc:oEstado=NIL

    EVAL(oDoc:bEstado)

    oDoc:nClrEstado:=oDp:nClrOptions

    IF oDoc:nClrEstado<>0
      oDoc:oEstado:SetColor(oDoc:nClrEstado,oDp:nGris2)
    ENDIF

    oDoc:oEstado:Refresh(.T.)
  ENDIF

  IF(oDoc:oCliNombre =NIL,NIL,oDoc:oCliNombre:Refresh(.T.))
  IF(oDoc:oVenNombre =NIL,NIL,oDoc:oVenNombre:Refresh(.T.))
  IF(oDoc:oNeto      =NIL,NIL,oDoc:oNeto:Refresh(.T.))
  IF(oDoc:oIva       =NIL,NIL,oDoc:oIva:Refresh(.T.))
  IF(oDoc:oSayNeto   =NIL,NIL,oDoc:oSayNeto:Refresh(.T.))

  oDocCli:cVeces:=0

RETURN .T.

// EOF
