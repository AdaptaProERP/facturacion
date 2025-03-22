// Programa   : DPDOCCLIPREGRA
// Fecha/Hora : 08/10/2005 21:41:57
// Propósito  : Pregrabar Documento Cliente
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(oDoc,lSave)
  LOCAL lResp:=.T.,oForm:=oDoc,lFound:=.F.,cNumero:=""
  LOCAL nItemMax:=0,lLibVta:=.F.,I
  LOCAL aControls:={}

  DEFAULT lSave:=.F.

  oDoc:DOC_USUARI:="INC" //  27/02/2025 oDp:cUsuario

  AADD(aControls,oDoc:oDOC_CODIGO)
  AADD(aControls,oDoc:oDOC_FECHA )
  AADD(aControls,oDoc:oDOC_CODVEN)
  AADD(aControls,oDoc:oDOC_NUMERO)

  //? GETPROCE(),"PREGABAR"
  // Incluir

  IF !oDoc:lSaved .AND. oDoc:nOption=1

//? oDoc:DOC_TIPDOC,NIL,oDoc,oDoc:DOC_CODSUC,oDoc:DOC_SERFIS,"oDoc:DOC_TIPDOC,NIL,oDoc,oDoc:DOC_CODSUC,oDoc:DOC_SERFIS"

     oDoc:DOC_NUMERO:=EJECUTAR("DPDOCCLIGETNUM",oDoc:DOC_TIPDOC,NIL,oDoc,oDoc:DOC_CODSUC,oDoc:DOC_SERFIS)


// cTipDoc,cWhere,oDoc,cCodSuc,cLetra
// ? "AQUI DEBE GENERAR EL NUMERO DE LA FACTURA",oDoc:DOC_NUMERO," DE DONDE SALIO EL NUMERO" 

/*
    WHILE AllDigit(oDoc:DOC_NUMERO) 

      // JN 15/05/2023, requier actualizar uso de DLL

      lFound:=SQLGET("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                                "DOC_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                                "DOC_NUMERO"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
                                "DOC_TIPTRA='D'")=oDoc:DOC_NUMERO

      IF !lFound 
        EXIT
      ENDIF

      oDoc:DOC_NUMERO:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                                                 "DOC_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                                                 "DOC_TIPTRA='D'")

      oDoc:oDOC_NUMERO:VarPut(oDoc:DOC_NUMERO,.T.)

? "AQUI ASIGNA EL NUMERO"

    ENDDO
*/

  ENDIF

  // JN 11/01/2015 Si el usuario modifico la factura y removio los ITEMS la factura si puede quedar en CERO

  oGrid:=oDoc:aGrids[1] // 25/05/2023

  DEFAULT oDocCli:lMoneta:=.T.

// ? oDocCli:lMoneta,"oDocCli:lMoneta"

  IF lSave .AND. oDoc:nOption=1 .AND. oDoc:DOC_NETO=0 .AND. oDocCli:lMoneta
    // IF lSave .AND. oDoc:nOption=1 .AND. (oDoc:DOC_NETO=0) 
    //    oDoc:oProducto:SetText("No se puede Grabar ["+oDoc:cNomDoc+"] sin Monto")
    //  IF lSave .AND. oDoc:nOption=1 .AND. oDoc:DOC_NETO=0 .OR. oGrid:Count()=0) 25/05/2023 Count(), cuenta el ultimo registro 

    oDoc:oDOC_CODIGO:MsgErr("No se puede Grabar ["+oDoc:cNomDoc+"] sin Monto")

    IF EMPTY(oDoc:DOC_CODIGO)
      DpFocus(oDoc:oDOC_CODIGO)
    ENDIF

    RETURN .F.
  ENDIF

  IF !Empty(oDoc:cCodCli) .AND. oDoc:cCodCli<>oDoc:DOC_CODIGO

    lResp:=EJECUTAR("DPDOCCLICLI",oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:cNumero,oDoc:cCodCli,;
                                  oDoc:DOC_CODIGO,oDoc:DOC_NUMERO)

    IF lResp
      oDoc:cCodCli:=""
    ENDIF
  ENDIF

  oDoc:DOC_ESTADO:="AC"
  oDoc:DOC_ACT   :=1 // Activo
  oDoc:DOC_FCHVEN:=EJECUTAR("CALFCHVEN",oDoc:DOC_FECHA,oDoc:DOC_PLAZO)
  oDoc:DOC_FCHVEN:=IIF(Empty( oDoc:DOC_FCHVEN ),oDoc:DOC_FECHA , oDoc:DOC_FCHVEN)
  oDoc:DOC_DOCORG:="V"
  oDoc:nItemMax  :=SQLGET("DPTIPDOCCLI","TDC_NITEMS","TDC_TIPO"+GetWhere("=",oDoc:DOC_TIPDOC))

  /* 06/06/2024
  // lPar_FavPen = Factura Pendiente (parametro de Usuario) Factura Pendiente. Si no puede queda pendiente de pago, sera impreso luego del pago
  */
  IF oDoc:nOption=1 .AND. oDoc:nPar_CxC<>0 .AND. oDoc:lPar_LibVta .AND. oDoc:lPar_FavPen .AND. lSave .AND. lResp .AND. ;
     !EJECUTAR("DPDOCNUMFIS",oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:DOC_CODIGO,oDoc:DOC_NUMERO,.T.,oForm)
    lResp:=.F.
    oDoc:Prepare()
  ENDIF

  oDoc:Prepare()
  
  nItemMax:=SQLGET("DPTIPDOCCLI","TDC_NITEMS","TDC_TIPO"+GetWhere("=",oDoc:DOC_TIPDOC))

  IF lSave .AND. nItemMax>0 .AND. oDoc:nItems>nItemMax 
    MensajeErr("Número de Items "+LSTR(oDoc:nItems)+" de la Factura Excedio el Permitido ("+LSTR(nItemMax)+")","Numero de Items Excedido") 
    RETURN .F. 
  ENDIF 

RETURN lResp

// EOF
