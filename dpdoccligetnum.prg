// Programa   : DPDOCCLIGETNUM 
// Fecha/Hora : 02/11/2020 11:11:16
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc,cWhere,oDoc,cCodSuc,cLetra)
   LOCAL nLen   :=10
   LOCAL cNumero:=STRZERO(0,nLen),cNumMax:=STRZERO(1,nLen)
   LOCAL oData,cVarNum,cVarFis,cSerie,cNumSer:="",cWhereD

  
   DEFAULT cTipDoc:="FAV",;
           cCodSuc:=oDp:cSucursal,;
           cLetra :=oDp:cImpLetra,;
           cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
                    "DOC_TIPDOC"+GetWhere("=",cTipDoc )+" AND "+;
                    "DOC_TIPTRA"+GetWhere("=","D"     )

  DEFAULT oDp:cTkSerie:=""

// ? cTipDoc,oDoc,cCodSuc,cLetra,"dpdoccligetnum",cWhere

  // SERIES NO FISCALES
  IF ISDOCFISCAL(cTipDoc)

     IF !(cLetra==oDp:cImpLetra)
       EJECUTAR("DPSERIEFISCALLOAD","SFI_LETRA"+GetWhere("=",cLetra))
       ? "debe recargar la serie fiscal",cLetra,"<-cLetra",oDp:cImpLetra,"<-oDp:cLetra",oDp:cTkSerie,"<-oDp:cTkSerie"
     ENDIF

     IF "BEMA"$oDp:cImpFiscal .AND. !oDp:lImpFisModVal

       // toma el número fiscal como número fiscal
       cNumero:=IF(ValType(oDoc)="O",oDoc:DOC_NUMFIS,""    )
       cSerie :=IF(ValType(oDoc)="O",oDoc:cLetra    ,cSerie)
 
       IF !Empty(cSerie)
          oDp:cImpLetra:=cSerie
       ENDIF
       
       IF Empty(cNumero)

        IF cTipDoc="FAV" .OR. cTipDoc="TIK"
           cNumero:=EJECUTAR("DLL_BEMATECH_FAV",nil,nil,oDp:cImpLetra)
        ENDIF

        IF cTipDoc="CRE" .OR. cTipDoc="DEV"
           cNumero:=EJECUTAR("DLL_BEMATECH_CRE",nil,nil,oDp:cImpLetra)
        ENDIF

       ENDIF

       IF !Empty(cNumero)

         IF !oDoc=NIL
           oDoc:oDOC_NUMERO:VarPut(cNumero,.T.)
         ENDIF

         oDp:cNumero:=cNumero

         RETURN cNumero

       ENDIF

     ENDIF


     IF oDp:nCantFormaFiscal>1 .AND. !Empty(oDp:cTkSerie)

       cNumero:=cNumMax
       nLen   :=nLen-LEN(oDp:cTkSerie)
       cNumero:=RIGHT(cNumero,nLen)
       cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen) // nuevo Numero

     ENDIF

     cWhereD:=cWhere+" AND LENGTH(DOC_NUMERO)"+GetWhere("=",nLen)
 
     IF !Empty(oDp:cTkSerie)
       cWhere+" AND DOC_SERFIS"+GetWhere("=",cLetra)
     ENDIF

    ELSE

    // Documentos no fiscales
    cLetra:=""

   ENDIF
   
   cNumMax:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere)

   // No existe factura
   IF Empty(cNumMax)
      cNumMax:=SQLGET("DPTIPDOCCLINUM","TDN_NUMERO","TDN_CODSUC"+GetWhere("=",cCodSuc)+" AND TDN_TIPDOC"+GetWhere("=",cTipDoc))
      // =TDC_TIPO LEFT JOIN DPSERIEFISCAL ON TDN_SERFIS=SFI_LETRA
   ENDIF

   cNumMax:=RIGHT(cNumMax,nLen)

   // documento fiscal no dejar huecos

   IF Empty(oDp:cTkSerie) 
      cNumero:=IF(cNumero<cNumMax,cNumMax,cNumero)
   ELSE
      // numeración fiscal no se puede adelantar
      cNumero:=cNumMax
   ENDIF

   // busca el numero no se repita
   cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
            "DOC_TIPDOC"+GetWhere("=",cTipDoc )+" AND "+;
            "DOC_TIPTRA"+GetWhere("=","D"     )

   IF !Empty(cLetra)
      // Documento fiscal, valida con la letra de la serie
      // NO PUEDE Incluir la Serie Fiscal cWhere:=cWhere+" AND DOC_SERFIS"+GetWhere("=",cLetra )
   ENDIF

   WHILE ISSQLFIND("DPDOCCLI",cWhere+" AND DOC_NUMERO"+GetWhere("=",cNumero))
     cNumero:=DPINCREMENTAL(cNumero)
   ENDDO

   IF !oDoc=NIL
     oDoc:oDOC_NUMERO:VarPut(cNumero,.T.)
   ENDIF

RETURN cNumero
// EOF

/*


   cTipDoc:=ALLTRIM(cTipDoc)
   cVarNum:=cTipDoc+"Numero"
   cVarFis:=cTipDoc+"NumFis"
   // nLen   :=SQLGET("DPTIPDOCCLI","TDC_LEN","TDC_TIPO"+GetWhere("=",cTipDoc))


   IF !oDoc=NIL

     oData:=DATASET("SUC_V"+oDp:cSucursal,"ALL")
     cNumero:=oData:Get(oDoc:cTipDoc+"Numero",cNumero)
     cNumFis:=oData:Get(oDoc:cTipDoc+"NumFis",cNumero)
     oData:End()

   ELSE

     oData:=DATASET("SUC_V"+oDp:cSucursal,"ALL")

     cVarNum:=cTipDoc+"Numero"

     IF oData:IsDef(cVarNum)
       cNumero:=oData:Get(cTipDoc+"Numero",cNumero)
       cNumFis:=oData:Get(cTipDoc+"NumFis",cNumero)
       oData:End()
     ENDIF

   ENDIF

   IF (cTipDoc="DEV" .OR. cTipDoc="TIK") .AND. !Empty(oDp:cTkSerie)
      cWhere:=cWhere+" AND LEFT(DOC_NUMERO,1)"+GetWhere("=",oDp:cTkSerie)
   ENDIF

   // ? cNumMax,"cNumMax",cWhere,oDp:cTkSerie,"oDp:cTkSerie"
   // Buscamos el numero en la serie fiscal
   cSerie :=SQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF","TDC_TIPO"  +GetWhere("=",cTipDoc))

? cSerie,"cSerie"

   // nLen   :=DPSQLROW(2)
   nLen   :=LEN(cNumero)
   nLen   :=IF(nLen=0,10,nLen) 
   cNumSer:=SQLGET("DPSERIEFISCAL","SFI_NUMERO","SFI_MODELO"+GetWhere("=",cSerie ))

   cWhere :=cWhere+" AND LENGTH(DOC_NUMERO)"+GetWhere("=",nLen)
   cNumMax:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere)

? cNumMax,oDp:cSql

// ? cNumero,nLen,"cNumero,nLen"

   IF (cNumMax=REPLI("0",10) .OR. Empty(cNumMax)) .AND. !Empty(cNumSer)
     // 21/08/2023 no aplica con numero de correlativo DPDOCCLI cNumMax:=cNumSer
   ENDIF

   cNumMax:=RIGHT(cNumMax,nLen)
   cNumero:=IF(cNumero<cNumMax,cNumMax,cNumero)

   //  IF (cTipDoc="DEV" .OR. cTipDoc="TIK" .OR. cTipDoc="FAV" .OR. cTipDoc="CRE") .AND. !Empty(oDp:cTkSerie)

   IF (cTipDoc="DEV" .OR. cTipDoc="TIK") .AND. !Empty(oDp:cTkSerie)
      cNumero:=cNumMax
      // nLen   :=10-LEN(ALLTRIM(oDp:cTkSerie))
      nLen   :=nLen-LEN(oDp:cTkSerie)
      cNumero:=RIGHT(cNumero,nLen)
      cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen)

   ELSE

      cNumero:=ALLTRIM(cNumero)

      // ? "antes de DPINCREMENTAL",cNumero,LEN(cNumero)
     
      cNumero:=DPINCREMENTAL(cNumero)

      // ? cNumero,"LUEGO INCREMENTAL",LEN(cNumero)

   ENDIF

   // 17/06/2024
   // cWhere:=cWhere+" AND LENGTH(DOC_NUMERO)"+GetWhere("=",nLen)

   // ? cWhere,"cWhere",nLen,"nLen",LEN(cNumero),"<-cNumero"
   // ? ISSQLFIND("DPDOCCLI",cWhere+" AND DOC_NUMERO"+GetWhere("=",cNumero)),CLPCOPY(oDp:cSql)

   WHILE ISSQLFIND("DPDOCCLI",cWhere+" AND DOC_NUMERO"+GetWhere("=",cNumero))
      cNumero:=DPINCREMENTAL(cNumero)
   ENDDO

// ? cNumero,"DPDOCCLIGETNUM",oDp:cSql
//   nLen:=10
   IF LEN(cNumero)<nLen
      cNumero:=ALLTRIM(cNumero)
      cNumero:=REPLI("0",nLen-LEN(cNumero))+cNumero
   ENDIF
   
   IF !oDoc=NIL
     oDoc:oDOC_NUMERO:VarPut(cNumero,.T.)
   ENDIF

   oDp:cNumero:=cNumero
*/


