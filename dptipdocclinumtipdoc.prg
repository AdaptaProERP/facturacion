// Programa   : dptipdocclinumtipdoc
// Fecha/Hora : 19/03/2025 14:24:43
// Propósito  : Crear tipo de documento 
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cLetra,cTipDoc)
    LOCAL aTipDoc:={},cZeta:="ZFF",I,U,aCodSuc:={},oTable,cNumero,cImpFis:="",cWhere:=""
    LOCAL lActivo:=.T.

    DEFAULT cCodSuc:=oDp:cSucursal,;
            cLetra :="00",;
            cTipDoc:=""

    // caso de FORMATO y CONTIGENCIA solo a una serie fiscal

    cImpFis:=SQLGET("DPSERIEFISCAL","SFI_IMPFIS","SFI_LETRA"+GetWhere("=",cLetra))

    IF "LIBRE"$cImpFis .OR. "DIGI"$cImpFis
       aTipDoc:={"FAV","DEB","CRE","NEN","GDC"}
    ENDIF

    IF !Empty(cTipDoc)
       aTipDoc:={}
       AADD(aTipDoc,cTipDoc)
    ENDIF

    IF Empty(aCodSuc).OR. .T.
       aCodSuc:={oDp:cSucursal}
    ENDIF

    IF "DIGI"$cImpFis
       aCodSuc:=ATABLA("SELECT SUC_CODIGO FROM DPSUCURSAL WHERE SUC_ACTIVO=1 AND SUC_EMPRES=0")
    ENDIF

    IF "_FISCAL"$cImpFis 
      
       IF !ISSQLFIND("DPTIPDOCCLI","TDC_TIPO"+GetWhere("=",cZeta))
          EJECUTAR("DPTIPDOCCLICREA",cZeta,"Reporte Z Factura Fiscal","N")
       ENDIF

       aTipDoc:={cZeta}  // solo para el ZETA {"TIK","DEV",cZeta}

    ENDIF

    // Crea formato NO-FISCAL para pedidos
    EJECUTAR("DPSERIEFISCALCREA") // crea serie fiscal NO-FISCAL para documentos no fiscales

    oTable:=OpenTable("SELECT * FROM DPTIPDOCCLINUM",.F.)

    FOR I=1 TO LEN(aCodSuc)

      FOR U=1 TO LEN(aTipDoc)

        cWhere:="TDN_CODSUC"+GetWhere("=",aCodSuc[I])+" AND "+;
                "TDN_SERFIS"+GetWhere("=",cLetra    )+" AND "+;
                "TDN_TIPDOC"+GetWhere("=",aTipDoc[U])  

        IF !ISSQLFIND("DPTIPDOCCLINUM",cWhere)
             
          cWhere:="DOC_CODSUC"+GetWhere("=",aCodSuc[I])+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",aTipDoc[U])+" AND "+;
                  "DOC_SERFIS"+GetWhere("=",cLetra    )+" AND "+;
                  "DOC_TIPTRA"+GetWhere("=","D"       )  

          cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere)
          cNumero:=STRZERO(1,10)

          oTable:lAuditar:=.T.
          oTable:Replace("TDN_CODSUC",aCodSuc[I])
          oTable:Replace("TDN_SERFIS",cLetra    )
          oTable:Replace("TDN_TIPDOC",aTipDoc[U])
          oTable:Replace("TDN_LLAVE" ,.T.       )
          oTable:Replace("TDN_NUMERO",cNumero   )
          oTable:Replace("TDN_ACTIVO",lActivo   )
          oTable:Replace("TDN_ZERO"  ,.T.       )
          oTable:Replace("TDN_EDITAR",.F.       )
          oTable:Replace("TDN_LEN"   ,10        )
          oTable:Replace("TDN_PICTUR","9999999999")
          oTable:Commit("")

        ENDIF

      NEXT U

    NEXT I

    // FORMATO Y CONTIGENCIA

RETURN NIL
// EOF
