// Programa   : DPFACTURAVPAGFUNC
// Fecha/Hora : 07/06/2024 13:52:42
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oBrw)

  ? oBrw:ClassName(),"DPFACTURAVPAGFUNC"

RETURN .t.

FUNCTION RUNCLICK()
    LOCAL aLine:=oBrw:aArrayData[oBrw:nArrayAt]
    LOCAL oCol :=oBrw:aCols[4]

    IF oBrw:nGetColSel()=3
       oBrw:PUTMONTO(oCol,aLine[3],4) // ,nAt,lRefresh)
    ENDIF

RETURN .T.

FUNCTION BRWCHANGE()
RETURN .T.

FUNCTION PUTMONTO(oCol,uValue,nCol,nAt,lRefresh)
  LOCAL oBrw    :=oCol:oBrw
  LOCAL aLine   :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL aTotales:={}
  LOCAL nRowSel :=oBrw:nRowSel

  DEFAULT lRefresh:=.T.,;
          nAt     :=oBrw:nArrayAt

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=uValue
  oBrw:aArrayData[oBrw:nArrayAt,5   ]:=ROUND(uValue*aLine[2],2)

  IF oDoc:nMtoIGTF=aLine[5] 
     oBrw:aArrayData[oBrw:nArrayAt,11]:=0
  ENDIF

  oBrw:aArrayData[oBrw:nArrayAt,oDoc:nColSelP]:=(uValue>0)

  oBrw:SETSUGERIDO()
  // 15/10/2022  oBrw:aArrayData:=oRecDiv:CALDIVISA(oBrw:aArrayData,oBrw)

RETURN .T.

/*
// Sugerido en Panel de Pagos
*/
FUNCTION SETSUGERIDO()
   LOCAL aData  :=oBrw:aArrayData,I,nAt:=oBrw:nArrayAt,nRowSel:=oBrw:nRowSel
   LOCAL nMtoSug:=0

   oDoc:nMtoIGTF:=0
   oBrw:CALIGTF(.T.)

   nMtoSug:=oDoc:nTotal*-1

   FOR I=1 TO LEN(aData)
      aData[I,3]:=oBrw:CALSUG(nMtoSug,aData[I,2],aData[I,7])
   NEXT I

   IF oDoc:nTotal<0

    nMtoSug:=oDoc:nTotal*-1

     FOR I=1 TO LEN(aData)
        aData[I,3]:=oBrw:CALSUG(nMtoSug,aData[I,2],aData[I,7])
     NEXT I

   ENDIF

   FOR I=1 TO LEN(aData)

     IF aData[I,5]>0 .AND. aData[I,oDoc:nColPorITG]>0
        aData[I,oBrw:nColMtoITG]:=PORCEN(aData[I,5],aData[I,oDoc:nColPorITG],2)
     ELSE
        aData[I,oDoc:nColMtoITG]:=0
     ENDIF

     IF aData[I,4]>0
      //  aData[I,6]:=aData[I,4]
     ENDIF

   NEXT I

   // no tiene sugerido
   oBrw:aArrayData:=ACLONE(aData)
   oBrw:CALIGTF(.T.)

   IF oDoc:nTotal=0

     FOR I=1 TO LEN(aData)
        aData[I,3]:=0
     NEXT I

   ENDIF
  
   oBrw:aArrayData:=aData
   oBrw:CALIGTF(.T.)

   IF oDoc:nMtoIGTF>0 .AND. ROUND(oDoc:nTotal,2)=ROUND(oDoc:nMtoIGTF,2)

      nMtoSug:=oDoc:nMtoIGTF

      FOR I=1 TO LEN(aData)
        aData[I,3]:=oBrw:CALSUG(nMtoSug,aData[I,2],aData[I,7])
      NEXT I

   ENDIF

   oBrw:aArrayData:=aData

   oBrw:CALIGTF(.T.)

   IF oDoc:nTotal<0

     nMtoSug:=oDoc:nTotal*-1

     FOR I=1 TO LEN(aData)
       aData[I,3]:=oBrw:CALSUG(nMtoSug,aData[I,2],aData[I,7])
     NEXT I

   ENDIF

   oBrw:aArrayData:=aData
   oBrw:CALIGTF(.T.)

   oBrw:Refresh(.F.)
   oBrw:nArrayAt:=nAt
   oBrw:nRowSel :=nRowSel

   IF ValType(oBrwR)="O"
     oBrw:TOTALRESDIVISA(oBrw:aArrayData,oBrwR) // Resumen por Divisa
   ENDIF

   IF ValType(oDoc:oBtnSave)="O"
      oDoc:oBtnSave:ForWhen(.T.)
   ENDIF

RETURN .T.

FUNCTION TOTALRESDIVISA()
RETURN NIL

FUNCTION CALIGTF(lRefresh)

  DEFAULT lRefresh:=.F.

  oBrw:CALTOTAL()
  
RETURN .T.

FUNCTION CALTOTAL(lRefresh)
RETURN EJECUTAR("DPRECIBODIV_CALTOTAL",oDoc,lRefresh)

FUNCTION TOTALRESDIVISA()
   ? "TOTALRESDIVISA"
RETURN .T.

FUNCTION CALSUG(nMtoSug,nMoneda,cCodMon)
    LOCAL nMonto:=0

    oDoc:nValCam :=oDoc:DOC_VALCAM

    IF cCodMon=oDp:cCodCop
       nMonto:=EJECUTAR("CALCOP",nMtoSug,oDoc:nValCam)
    ELSE
       nMonto:=ROUND(nMtoSug/nMoneda,2)
    ENDIF

RETURN nMonto

FUNCTION CALTOTAL(lRefresh)
   LOCAL aTotal:={},oCol,aTotalD
 
   aTotal          :=ATOTALES(oBrw:aArrayData)

   oDoc:nMtoDoc   :=oDoc:DOC_NETO 

   oDoc:nMtoDifCam:=0
   oDoc:nMtoIGTF  :=0

   IF oDoc:lCruce

      // total debitos es la suma de los documentos seleccionados
      oDoc:nMtoPag:=0
      oDoc:nMtoDoc:=oDoc:DOC_NETO
/*
      AEVAL(oBrwD:aArrayData,{|a,n| oDoc:nMtoPag:=oDoc:nMtoPag+IF(a[9]>0,a[9]*+1,0),;
                                            oDoc:nMtoDoc:=oDoc:nMtoDoc+IF(a[9]<0,a[9]*-1,0)})

      oDoc:nTotal:=oDoc:nMtoPag-oDoc:nMtoDoc
*/

   ELSE

      oDoc:nMtoIGTF:=ROUND(aTotal[oDoc:nColMtoITG] ,2)

      IF !oDoc:lIGTF
        oDoc:nMtoIGTF:=0
      ENDIF

      oDoc:nMtoPag :=ROUND(aTotal[05] ,2)

/*
      IF oDoc:cTipDes="OPA" .OR. oDoc:cTipDes="OIN"
        oDoc:nMtoDoc :=ROUND(aTotalD[07+1],2)
      ELSE
        oDoc:nMtoDoc :=ROUND(aTotalD[09],2)
      ENDIF
*/

      oDoc:nTotal :=ROUND(oDoc:nMtoPag-(oDoc:nMtoDoc+IF(oDoc:lIGTFCXC,0,oDoc:nMtoIGTF)),2)

      oDoc:nTotal :=oDoc:nTotal - IF(oDoc:lDifAnticipo,oDoc:nMtoAnticipo,0) // Excede -> Anticipo

      oDoc:nTotal :=INT(oDoc:nTotal*100)/100

      // 17/03/2023 Si el total de pagos es 0, el total debe ser su valor invertido
      IF oDoc:nMtoPag=0
        oDoc:nTotal:=oDoc:nMtoDoc*-1
      ENDIF

      // oDoc:nMtoDifCam:=aTotalD[10]

   ENDIF

   oDoc:nTotal :=IF("-0.00"$LSTR(oDoc:nTotal,19,2),0.00,oDoc:nTotal)

   // Si cuadra documentos y pagos, la diferencia será el IGTF
   IF oDoc:nMtoPag=oDoc:nMtoDoc .AND. !oDoc:lIGTFCXC
      oDoc:nTotal:=oDoc:nMtoIGTF
   ENDIF 
   
   oCol:=oBrw:aCols[4]
   oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)

   oCol:=oBrw:aCols[5]
   oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)

   oCol:=oBrw:aCols[12]
   oCol:cFooter      :=FDP(aTotal[12],oCol:cEditPicture)

   oBrw:RefreshFooters()

/*
   oDoc:oMtoPag:Refresh(.t.)
   oDoc:oMtoDoc:Refresh(.t.)
   oDoc:oMtoIGTF:Refresh(.T.)
   oDoc:oTotal:Refresh(.t.)
*/

   IF ValType(oDoc:oBtnSave)="O"
     oDoc:oBtnSave:ForWhen(.T.)
   ENDIF

RETURN .T. 
// EOF


