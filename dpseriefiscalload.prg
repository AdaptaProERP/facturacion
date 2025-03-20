// Programa   : DPSERIEFISCALLOAD
// Fecha/Hora : 27/07/2022 23:59:34
// Propósito  : Cargar variables de la Impresora Fiscal
// Creado Por : Juan Navas, 
// Llamado por: DPPOS04, DPFACTURAV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,lSay)
   LOCAL oSerFis,lResp:=.T.,cLetra

   oDp:nImpFisEntPre:=0
   oDp:nImpFisEntCan:=0
   oDp:cModSerFis   :=""
 
   // Autorizado por PC
   IF Empty(cWhere) .AND. COUNT("DPSERIEFISCAL","SFI_IMPFIS"+GetWhere(" LIKE ","%DIG%")+" AND SFI_ACTIVO=1" )>0

      cWhere  :=[ INNER JOIN DPSERIEFISCAL ON TXU_CODIGO=SFI_LETRA AND SFI_ACTIVO=1 ]+;
                [ WHERE TXU_REFERE='SERIEFISCAL' AND TXU_PERMIS=1 AND TXU_PC]+GetWhere("=",oDp:cPcName)

      cLetra  :=SQLGET("DPTABXUSU","SFI_LETRA",cWhere)
      cWhere  :="SFI_LETRA"+GetWhere("=",cLetra)

   ENDIF

   DEFAULT cWhere:="SFI_PCNAME"+GetWhere("=",oDp:cPcName),;
           lSay  :=.T.

   oSerFis       :=OpenTable("SELECT * FROM DPSERIEFISCAL WHERE "+cWhere,.T.) 

   IF oSerFis:RecCount()=0 .AND. lSay .AND. "SFI_PCNAME"$cWhere
      lResp:=.F.
      MsgMemo("Este PC "+oDp:cPcName+" no tiene Serie Fiscal Asignada")
      DPLBX("DPSERIEFISCAL.LBX")
   ENDIF
  
   oDp:cFavD_cToken :=""
   oDp:cFavD_cUrl   :=""
   oDp:cFavD_cPrg   :=""
   oDp:cFavD_cAction:="" // "/facturacion" ->NOVUS   //   ../anulacion   ../email
   oDp:cFavD_Version:="" // "/v3" ->NOVUSS
   // 
   IF "DIG"$oSerFis:SFI_IMPFIS

      oDp:cFavD_cToken:=ALLTRIM(oSerFis:SFI_TOKEN )
      oDp:cFavD_cUrl  :=ALLTRIM(oSerFis:SFI_URL   )
      oDp:cFavD_cPrg  :=ALLTRIM(oSerFis:SFI_PRGRUN)

      IF "NOVUS"$oSerFis:SFI_IMPFIS
         oDp:cFavD_cAction:="/facturacion" // ->NOVUS   //   ../anulacion   ../email
         oDp:cFavD_Version:="/v3"          // ->NOVUSS
      ENDIF

   ENDIF
 
   SETBASEURLDX() // Asigna el Url del Proveedor de Factura Digital

   // 07/07/2022
   oDp:cImpFiscal   :=oSerFis:SFI_IMPFIS
   oDp:cImpLetra    :=oSerFis:SFI_LETRA
   oDp:cModSerFis   :=oSerFis:SFI_MODELO

   oDp:cImpFisCom   :=ALLTRIM(oSerFis:SFI_PUERTO)
   oDp:nImpFisLen   :=oSerFis:SFI_ANCHO

   oDp:nImpFisEntPre:=oSerFis:SFI_PREENT
   oDp:nImpFisDecPre:=oSerFis:SFI_PREDEC

   oDp:nImpFisEntCan:=oSerFis:SFI_CANENT
   oDp:nImpFisDecCan:=oSerFis:SFI_CANDEC
   oDp:cTkSerie     :=oSerFis:SFI_LETRA
   oDp:cImpFisSer   :=oSerFis:SFI_SERIMP // Serial Impresora
   oDp:lImpFisModVal:=oSerFis:SFI_MODVAL // Impresora Fiscal en Modelo Evaluación
   oDp:lImpFisRegAud:=oSerFis:SFI_REGAUD // Registro de Auditoría
   oDp:SFI_PAGADO   :=oSerFis:SFI_PAGADO // Requiere Pagada para imprimirla

   oDp:nImpFisEntPre:=IF(oDp:nImpFisEntPre=0,14,oDp:nImpFisEntPre)
   oDp:nImpFisDecPre:=IF(oDp:nImpFisDecPre=0,02,oDp:nImpFisDecPre)

   oDp:nImpFisEntCan:=IF(oDp:nImpFisEntCan=0,14,oDp:nImpFisEntCan)
   oDp:nImpFisDecCan:=IF(oDp:nImpFisDecCan=0,02,oDp:nImpFisDecCan)

   IF "NO-FISCAL"$oDp:cImpFiscal

      oDp:cImpPuerto:=""
      oDp:cImpFisCom:=""
      oDp:cImpLetra :=""

      oDp:nImpFisEntPre:=0
      oDp:nImpFisDecPre:=0

      oDp:nImpFisEntCan:=0
      oDp:nImpFisDecCan:=0
   ENDIF

   oSerFis:End(.T.) 

   oDp:nCantFormaFiscal:=COUNT("dpseriefiscal",[ SFI_ACTIVO=1 AND  SFI_LETRA<>" " AND (SFI_IMPFIS  LIKE "%LIBRE%" OR SFI_IMPFIS LIKE "%_FISCAL%")])

// ? oDp:cImpFiscal

RETURN lResp
// EOF
