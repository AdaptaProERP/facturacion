// Programa   : CALIMPPVP
// Fecha/Hora : 21/03/2025 13:47:21
// Propósito  : Calcular Impuesto al PVP
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
  LOCAL nUt    :=0
  LOCAL cTipIva:=oGrid:oInv:INV_IVA
  LOCAL nPvpOrg:=oGrid:oInv:INV_PVPORG
  LOCAL nPorPvp:=oGrid:oInv:INV_IMPPVP
  LOCAL nGrados:=oGrid:oInv:INV_GRADOS
  LOCAL nCapaci:=oGrid:oInv:INV_CAPACI

  IF oGrid:nUt=0
    oGrid:nUt:=EJECUTAR("CALC_UT",oGrid:MOV_FECHA) 
  ENDIF

 // Otro Impuesto Calculado desde la Ficha del producto
 // oGrid:MOV_IMPOTR:=PORCEN(oGrid:MOV_TOTAL,nPorPvp)
 // Corrección Nicolas Montaño

/*
   cTipIva:=MYSQLGET("DPINV","INV_IVA,INV_PVPORG,INV_IMPPVP,INV_GRADOS,INV_CAPACI","INV_CODIGO"+GetWhere("=",oGRID:MOV_CODIGO))
   nPvpOrg:=oDp:aRow[2]
   nPorPvp:=oDp:aRow[3]      
   nGrados:=oDp:aRow[4]
   nCapaci:=oDp:aRow[5]
*/

  oGrid:MOV_IMPOTR:=PORCEN(oGrid:oInv:INV_IMPPVP*oGrid:MOV_CANTID*oGrid:MOV_CXUND,oGrid:oInv:INV_PVPORG) 

   IF !Empty(oDp:nImpProd) .AND. !Empty(nPorPvp) .AND. LEFT(oDoc:DOC_ZONANL,1)="N"
      nUt  :=oGrid:nUt // EJECUTAR("CALC_UT",oGrid:MOV_FECHA) 
      oGrid:MOV_PRODUC:=oGrid:MOV_CANTID*oGrid:MOV_CXUND // Unidades
      oGrid:MOV_PRODUC:=oGrid:MOV_PRODUC*nCapaci         // Litros
      oGrid:MOV_PRODUC:=((oGrid:MOV_PRODUC*nGrados)/100) // Litros según grados Alcoholicos
	 oGrid:MOV_PRODUC:=oGrid:MOV_PRODUC*(nUt*oDp:nImpProd)
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

