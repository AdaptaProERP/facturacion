// Programa   : CALIMPPVP
// Fecha/Hora : 21/03/2025 13:47:21
// Prop�sito  : Calcular Impuesto al PVP
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
  LOCAL nUt    :=0,nPrecio:=0
  LOCAL cTipIva:=oGrid:oInv:INV_IVA
  LOCAL nPvpOrg:=oGrid:oInv:INV_PVPORG
  LOCAL nPorPvp:=oGrid:oInv:INV_IMPPVP
  LOCAL nGrados:=oGrid:oInv:INV_GRADOS
  LOCAL nCapaci:=oGrid:oInv:INV_CAPACI
  LOCAL nDivisa:=oGrid:oHead:DOC_VALCAM
  
  nDivisa:=IIF(nDivisa=0 .OR. nDivisa=1, oDp:nKpiValor, nDivisa) // Valor del Dolar

  IF oGrid:nUt=0
    oGrid:nUt:=EJECUTAR("CALC_UT",oGrid:MOV_FECHA) 
  ENDIF

 // Otro Impuesto Calculado desde la Ficha del producto
 // oGrid:MOV_IMPOTR:=PORCEN(oGrid:MOV_TOTAL,nPorPvp)
 // Correcci�n Nicolas Monta�o

/*
   cTipIva:=MYSQLGET("DPINV","INV_IVA,INV_PVPORG,INV_IMPPVP,INV_GRADOS,INV_CAPACI","INV_CODIGO"+GetWhere("=",oGRID:MOV_CODIGO))
   nPvpOrg:=oDp:aRow[2]
   nPorPvp:=oDp:aRow[3]      
   nGrados:=oDp:aRow[4]
   nCapaci:=oDp:aRow[5]
*/

  nPrecio:=ROUND(oGrid:oInv:INV_PVPORG*nDivisa,2) // Precio calculado en bs
  // Utiliza % para ser aplicado en el precio
  IF oGrid:oInv:INV_PVPORG>0
     oGrid:MOV_IMPOTR:=PORCEN(nPrecio*oGrid:MOV_CANTID*oGrid:MOV_CXUND,oGrid:oInv:INV_IMPPVP) 
  ELSE
     // sin % de Impuesto, el usuario introduce el impuesto neteado en la ficha del producto
     oGrid:MOV_IMPOTR:=PORCEN(nPrecio*oGrid:MOV_CANTID*oGrid:MOV_CXUND)
  ENDIF

//  oGrid:MOV_IMPOTR:=PORCEN(oGrid:oInv:INV_IMPPVP*oGrid:MOV_CANTID*oGrid:MOV_CXUND,oGrid:oInv:INV_PVPORG) 

   IF !Empty(oDp:nImpProd) .AND. !Empty(nPorPvp) .AND. LEFT(oDoc:DOC_ZONANL,1)="N"
      nUt  :=oGrid:nUt // EJECUTAR("CALC_UT",oGrid:MOV_FECHA) 
      oGrid:MOV_PRODUC:=oGrid:MOV_CANTID*oGrid:MOV_CXUND // Unidades
      oGrid:MOV_PRODUC:=oGrid:MOV_PRODUC*nCapaci         // Litros
      oGrid:MOV_PRODUC:=((oGrid:MOV_PRODUC*nGrados)/100) // Litros seg�n grados Alcoholicos
	 oGrid:MOV_PRODUC:=oGrid:MOV_PRODUC*(nUt*oDp:nImpProd) // oDp:nImpProd ? en donde se incluye?
   ELSE
      oGrid:MOV_PRODUC:=0
   ENDIF

   IF !Empty(oDp:nImpExpe) .AND. !Empty(nPorPvp) .AND. LEFT(oDoc:DOC_ZONANL,1)="N"
   
      oGrid:MOV_EXPE:=oGrid:MOV_CANTID*oGrid:MOV_CXUND    // Unidades * Caja
      oGrid:MOV_EXPE:=oGrid:MOV_EXPE  *nCapaci              // Litros*Envases
      oGrid:MOV_EXPE:=oGrid:MOV_EXPE  *(nUt*oDp:nImpExpe)   // Impuesto de Expendio
   ELSE

      oGrid:MOV_EXPE:=0

   ENDIF

   IF !Empty(oDp:nImpBand) .AND. !Empty(nPorPvp) .AND. LEFT(oDoc:DOC_ZONANL,1)="N"

       oGrid:MOV_BAND:=oGrid:MOV_CANTID*oGrid:MOV_CXUND  //UNIDADES POR CAJA
       oGrid:MOV_BAND:=oGrid:MOV_BAND  *oDp:nImpBand      //Impuesto por Bandas           
   ELSE

      oGrid:MOV_BAND:=0

   ENDIF

  // ?"UNIDAD TRIBUTARIA",nUt,"BANDA:",oGrid:MOV_BAND,"EXPENDIO:",oGrid:MOV_EXPE,"PRODUCCION:",oGrid:MOV_PRODUC

  // INV_IVA,INV_PVPORG,INV_IMPPVP,INV_GRADOS,INV_CAPACI

  // Totaliza Impuestos al Licor
  oGrid:MOV_IMPOTR:=oGrid:MOV_IMPOTR+oGrid:MOV_PRODUC+oGrid:MOV_EXPE+oGrid:MOV_BAND
  oGrid:Set("MOV_IMPOTR",oGrid:MOV_IMPOTR,.T.)

RETURN .T.
// EOF

