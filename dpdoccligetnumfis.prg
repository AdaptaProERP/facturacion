// Programa   : DPDOCCLIGETNUMFIS
// Fecha/Hora : 15/04/2017 22:42:11
// Propósito  : Devuelve Ultimo Número de Control Fiscal, Compara con el Ultimo Número Indicado en la Serie
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cSerie,cTipDoc,cNumDoc)
    LOCAL cNumero:="",lZero:=NIL,nLen:=NIL,cNumAnt:="",cWhere:="",oData
    LOCAL cNumCtr,cSerFis,cNumFis,cOcho:=STRZERO(0,8),cMax,nContar:=0
    LOCAL cWhere:="",cUltimo,oTalonario

    DEFAULT cTipDoc:="FAV"

// ? oDp:cImpFiscal,"oDp:cImpFiscal",oDp:lImpFisModVal,"oDp:lImpFisModVal,DPDOCCLIGETNUMFIS"

    // Impresora Fiscal
    IF "BEMA"$oDp:cImpFiscal .AND. !oDp:lImpFisModVal

       IF Empty(cNumDoc)

         oDp:cImpLetra:=cSerie //8/8/2024
       
         IF cTipDoc="FAV" .OR. cTipDoc="TIK"
            cNumero:=EJECUTAR("DLL_BEMATECH_FAV",nil,nil,oDp:cImpLetra)
         ENDIF

         IF cTipDoc="CRE" .OR. cTipDoc="DEV"
            cNumero:=EJECUTAR("DLL_BEMATECH_CRE",nil,nil,oDp:cImpLetra)
         ENDIF

       ELSE

         cNumero:=cNumDoc // numero Documento es numero fiscal, primero lee el número del documento

       ENDIF

       IF !Empty(cNumero)
          RETURN cNumero
       ENDIF

   ENDIF

   /*
   // Impresoras fiscales que no proveen numero deberá ubicar el ultimo número
   */
   IF "_FISCAL"$oDp:cImpFiscal 
      ? "AQUI DEBE GENERAR IMPRESORA FISCAL"
      RETURN cNumero
   ENDIF


   /*
   // Código basado en talonarios (FORMATO,SERIE FISCAL O FACTURA DIGITAL)
   */

   IF "LIBRE"$oDp:cImpFiscal .OR. "DIGI"$oDp:cImpFiscal

     cWhere:=" DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             " DOC_SERFIS"+GetWhere("=",cSerie )+" AND "+;
             " DOC_TIPTRA"+GetWhere("=","D"    )
   ELSE

     // FORMATO UTILIZA EXCLUSIVO POR TIPO DE DOCUMENTO

     cWhere:=" DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             " DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             " DOC_SERFIS"+GetWhere("=",cSerie )+" AND "+;
             " DOC_TIPTRA"+GetWhere("=","D"    )
   ENDIF

   cWhere:=cWhere+"  AND DOC_NUMFIS"+GetWhere("<>","")

   cUltimo:=SQLGET("DPDOCCLI","DOC_NUMFIS",cWhere+" ORDER BY DOC_NUMFIS DESC LIMIT 1")
   cNumero:=DPINCREMENTAL(cUltimo)

   /*
   // Buscamos estado del documento fiscal en el Talonario,
   */

   cWhere           :="DCN_CODSUC"+GetWhere("=",cCodSuc)
   oDp:cDocFisEstado:=""

   IF !"LIBRE"$cImpFis
     cWhere:=cWhere+" AND DCN_TIPDOC"+GetWhere("=",cTipDoc)
   ENDIF

   cWhere :=cWhere+" AND DCN_SERFIS"+GetWhere("=",cSerie)+;
                   " AND DCN_NUMERO"+GetWhere("=",RIGHT(cNumero,8))

   oDp:cWhereDocCliNum:=cWhere

   oDp:cDocFisEstado:=SQLGET("dpdocclinum","DCN_ESTADO",cWhere)

   IF oDp:cDocFisEstado="D"
      oDp:cDocFisEstado:="Disponible"
   ENDIF

   IF oDp:cDocFisEstado="N"
      oDp:cDocFisEstado:="Nulo"
   ENDIF

   IF oDp:cDocFisEstado="U"
      oDp:cDocFisEstado:="Utilizado"
   ENDIF

RETURN cNumero

/*
    oData  :=DATASET("SUC_V"+oDp:cSucursal,"ALL")

    cNumCtr:=oData:Get(cTipDoc+"Numero","")
    cSerFis:=oData:Get(cTipDoc+"Serie" ,"")
    cNumFis:=oData:Get(cTipDoc+"NumFis","")
    oData:End(.F.)

    DEFAULT cCodSuc:=oDp:cSucursal,;
            cSerie :=SQLGET("DPSERIEFISCAL","SFI_LETRA","SFI_LETRA"+GetWhere("<>","")+" AND SFI_ACTIVO=1 ORDER BY SFI_LETRA")

    cNumAnt:=SQLGET("DPSERIEFISCAL","SFI_NUMERO","SFI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                 "SFI_LETRA" +GetWhere("=",cSerie))

    IF (Empty(cNumAnt) .OR. cNumAnt=STRZERO(0,8)) .AND. !Empty(cNumFis)
      cNumAnt:=cNumFis
    ENDIF

    // Impresora Fiscal
    // IF (cTipDoc="DEV" .OR. cTipDoc="TIK" .OR. cTipDoc="FAV" .OR. cTipDoc="CRE") .AND. !Empty(oDp:cTkSerie)

    IF (cTipDoc="DEV" .OR. cTipDoc="TIK") .AND. !Empty(oDp:cTkSerie)

       nLen   :=10
       nLen   :=nLen-LEN(oDp:cTkSerie)
       cNumFis:=LEFT(cNumFis,nLen)
       cNumFis:=ALLTRIM(oDp:cTkSerie)+cNumFis

       cNumAnt:=LEFT(cNumAnt,nLen)
       cNumAnt:=ALLTRIM(oDp:cTkSerie)+cNumAnt

    ENDIF


  cWhere:=" DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          " DOC_SERFIS"+GetWhere("=",cSerie )+" AND "+;
          "(DOC_NUMFIS"+GetWhere("<>",""    )+" AND "+;
          " DOC_NUMERO"+GetWhere("<>",cOcho )+") AND "+;
            " DOC_TIPTRA"+GetWhere("=","D"    )

  // 15/06/2022
  cWhere:=" DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          " DOC_SERFIS"+GetWhere("=",cSerie )+" AND "+;
          " DOC_NUMFIS"+GetWhere("<>",""    )+" AND "+;
          " DOC_TIPTRA"+GetWhere("=","D"    )

   cMax   :=SQLGET("DPDOCCLI","MAX(DOC_NUMFIS)",cWhere+" ORDER BY DOC_NUMFIS LIMIT 1")

    IF Empty(cMax) .AND. !Empty(cNumAnt)
       cMax:=cNumAnt
    ENDIF

    WHILE ++nContar<100

       cMax:=EJECUTAR("DPINCREMENTAL",cMax)

       IF !ISSQLFIND("DPDOCCLI",cWhere+" AND DOC_NUMFIS"+GetWhere("=",cMax))
          EXIT
       ENDIF

    ENDDO

    IF !Empty(cMax)

       cNumero:=cMax

    ELSE

       cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMFIS",cWhere,NIL,cNumAnt,lZero,nLen)

//? cNumero,"AQUI DEBE INCREMENTAR"
    ENDIF

    cWhere:=cWhere+" AND DOC_NUMFIS"+GetWhere("=",cNumero)

    IF cNumAnt<>cOcho
      cNumero:=IF(cNumero>cNumAnt,cNumero,cNumAnt)
    ENDIF

    IF COUNT("DPDOCCLI",cWhere)>0
       cNumero:=DPINCREMENTAL(cNumero)
    ENDIF
 
RETURN cNumero
*/
// EOF
