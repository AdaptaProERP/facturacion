// Programa   : DPFACTURAVPAGFUNC
// Fecha/Hora : 07/06/2024 13:52:42
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION RUNCLICK(lClonar)
    LOCAL aLine:=oBrw:aArrayData[oBrw:nArrayAt]
    LOCAL oCol :=oBrw:aCols[4]
    LOCAL nAt  :=oBrw:nArrayAt,nRowSel:=oBrw:nRowSel

    DEFAULT lClonar:=.F.

    IF oBrw:nGetColSel()=3
       oBrw:PUTMONTO(oCol,aLine[3],nil,nil,nil,.T.) 
    ENDIF

    IF oBrw:nGetColSel()=oDoc:nColPorITG .AND. aLine[4]<>0 
      oBrw:ADDIGTF(oBrw:nArrayAt) // Agrega el IGTF como pago con la misma moneda
      oBrw:SETSUGERIDO()
      RETURN .F.
    ENDIF

    IF lClonar .OR. (oBrw:nGetColSel()=18)

      aLine[18]:=.T.
      aLine[04]:=0
      aLine[05]:=0

      AINSERTAR(oBrw:aArrayData,nRowSel,ACLONE(aLine))

      oBrw:nArrayAt:=nAt
      oBrw:aArrayData:Refresh(.F.)
      oBrw:SETSUGERIDO()
    
     RETURN .F.

   ENDIF


RETURN .T.

/*
// Agrega el IGTF como pago con la misma moneda
*/
FUNCTION ADDIGTF(nAt,lRefresh)
   LOCAL aLine,nMtoIGTF,cCodMon,nPos

   DEFAULT nAt     :=oBrw:nArrayAt,;
           lRefresh:=.T.

   aLine   :=ACLONE(oBrw:aArrayData[nAt])

   nMtoIGTF:=aLine[oDoc:nColMtoITG] // monto del IGTF
   cCodMon :=aLine[1]
   nPos    :=ASCAN(oBrw:aArrayData,{|a,n| a[1]=cCodMon .AND. a[5]=nMtoIGTF})

   // Desmarcar pago con IGTF
   IF !aLine[oDoc:nColSelP] .AND. nPos=0
	 RETURN .F.
   ENDIF

   IF nPos>0

      // Eliminar el IGTF
      ARREDUCE(oBrw:aArrayData,nPos)

   ELSE

      aLine[05]:=aLine[oDoc:nColMtoITG]
      aLine[04]:=oBrw:CALSUG(aLine[oDoc:nColMtoITG],aLine[02],aLine[07])

      aLine[oDoc:nColMtoITG]:=0
      aLine[oDoc:nColPorITG]:=0

      AINSERTAR(oBrw:aArrayData,nAt+1,aLine)

      nAt:=nAt+1

    ENDIF

    IF lRefresh
      oBrw:Refresh(.F.)
      oBrw:nArrayAt:=nAt
      // oBrw:CALTOTAL()
    ENDIF

RETURN .t.



/*
// Resuelve el residio del calculo de la Divisa
*/
FUNCTION ADDRESIDUO(nExp,nValReq)
   LOCAL nFraccion:=nExp-nValReq
   
   IF ABS(nFraccion)<1
      nExp:=nValReq
   ENDIF

RETURN nExp

/*
// Colocar Banco
*/
FUNCTION PUTBANCO(oCol,uValue,nCol)
RETURN .T.

FUNCTION BRWCHANGEPAGOS()
   LOCAL aLine:=oBrw:aArrayData[oBrw:nArrayAt]
   LOCAL oCol :=oBrw:aCols[15]
   LOCAL oDoc :=oBrw:oLbx

//   oDp:oFrameDp:SetText(LSTR(LEN(aLine))+" VALTYPE ALINE[8]"+ValType(aLine[8]))

   IF aLine[08]="BCO" .AND. oDoc:nMtoDoc>0 .AND. aLine[oDoc:nColSelP] .AND. LEN(oDp:aCuentaBco)>0

      oCol:nEditType     :=EDIT_LISTBOX
      oCol:aEditListTxt  :=ACLONE(oDp:aNombreBco)
      oCol:aEditListBound:=ACLONE(oDp:aNombreBco)
      oCol:bOnPostEdit   :={|oCol,uValue|oBrw:PUTBANCO(oCol,uValue,15)} // Debe seleccionar las cuentas bancarias
      oBrw:DrawLine(.T.)
      
   ELSE

      oCol:nEditType    :=0
      oCol:bOnPostEdit  :=NIL

   ENDIF

RETURN .T.

FUNCTION PUTMONTO(oCol,uValue,nCol,nAt,lRefresh,lTodo)
  LOCAL oBrw    :=oCol:oBrw
  LOCAL aLine   :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL aTotal  :=ATOTALES(oBrw:aArrayData) // {}
  LOCAL nRowSel :=oBrw:nRowSel
  LOCAL nMtoCal :=0
  LOCAL nValReq :=oDoc:nMtoDoc

  DEFAULT lRefresh:=.T.,;
          nAt     :=oBrw:nArrayAt,;
          lTodo   :=.F.

  nMtoCal:=ROUND(uValue*aLine[2],2)

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=uValue

  nMtoCal:=oBrw:ADDRESIDUO(nMtoCal,nValReq)

  // si es pago total asume el neto del documento

  IF lTodo

     nMtoCal:=oDoc:nMtoReqBSD  // oDoc:DOC_NETO-aTotal[05] // Pago total
     nMtoCal:=IF(nMtoCal=0,uValue,nMtoCal)

// ? nMtoCal,"nMtoCal",uValue,"uValue"

     oBrw:aArrayData[oBrw:nArrayAt,4]:=nMtoCal/aLine[2]

  ENDIF

  oBrw:aArrayData[oBrw:nArrayAt,5]:=nMtoCal // ROUND(uValue*aLine[2],2)

  
  IF oDoc:nMtoIGTF=aLine[5] 
     // OJO NO PUEDE SER CEROoBrw:aArrayData[oBrw:nArrayAt,11]:=0
  ENDIF

  oBrw:aArrayData[oBrw:nArrayAt,oDoc:nColSelP]:=(uValue>0)

//  IF !lTodo
   oBrw:SETSUGERIDO()
//  ELSE
//    oBrw:CALIGTF(.T.)
//  ENDIF
  // 15/10/2022  oBrw:aArrayData:=oRecDiv:CALDIVISA(oBrw:aArrayData,oBrw)

RETURN .T.

/*
// Sugerido en Panel de Pagos
*/
FUNCTION SETSUGERIDO()
   LOCAL aData  :=oBrw:aArrayData,I,nAt:=oBrw:nArrayAt,nRowSel:=oBrw:nRowSel
   LOCAL nMtoSug:=0
   LOCAL oBrwR  :=oDoc:oBrwR 

   // sin valor divisa
   IF oDoc:nValCam=1 .OR. oDoc:nValCam=0
      nAt:=ASCAN(aData,{|a,n| a[7]=="DBC"})
      IF nAt>0
         oDoc:nValCam:=aData[nAt,2]
      ENDIF
   ENDIF

   nAt:=oBrw:nArrayAt

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
        aData[I,oDoc:nColMtoITG]:=PORCEN(aData[I,5],aData[I,oDoc:nColPorITG],2)
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

RETURN .T.

FUNCTION TOTALRESDIVISA()
RETURN NIL

FUNCTION CALIGTF(lRefresh)
   LOCAL aTotal :={},oCol,aTotalD
   LOCAL nAt    :=oBrw:nArrayAt
   LOCAL nRowSel:=oBrw:nRowSel

   DEFAULT lRefresh:=.F.

   aTotal:=ATOTALES(oBrw:aArrayData)

   oDoc:nMtoDifCam:=0
   oDoc:nMtoIGTF  :=0

   oDoc:nMtoIGTF:=ROUND(aTotal[oDoc:nColMtoITG] ,2)

   IF !oDoc:lIGTF
      oDoc:nMtoIGTF:=0
   ENDIF

   // Total Documentos debe ser igual al monto del Documento, evitar residuos
   aTotal[05]:=ADDRESIDUO(aTotal[05],oDoc:nMtoDoc)
   
   oDoc:nMtoPag:=ROUND(aTotal[05] ,2)

   oDoc:nTotal :=ROUND(oDoc:nMtoPag-(oDoc:nMtoDoc+IF(oDoc:lIGTFCXC,0,oDoc:nMtoIGTF)),2)
   oDoc:nTotal :=oDoc:nTotal - IF(oDoc:lDifAnticipo,oDoc:nMtoAnticipo,0) // Excede -> Anticipo
   oDoc:nTotal :=INT(oDoc:nTotal*100)/100


// ? oDoc:nTotal
   // 17/03/2023 Si el total de pagos es 0, el total debe ser su valor invertido
   IF oDoc:nMtoPag=0
      oDoc:nTotal:=oDoc:nMtoDoc*-1
   ENDIF

   oDoc:nMtoDifCam:=0 // No hay diferencial cambiario aTotalD[10]

   oDoc:nTotal    :=IF("-0.00"$LSTR(oDoc:nTotal,19,2),0.00,oDoc:nTotal)

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

   
   oDoc:nMtoDoc     :=oDoc:DOC_NETO+oDoc:nMtoIGTF


   oDoc:nMtoReqBSD  :=oDoc:nMtoDoc-oDoc:nMtoPag             // monto requerido BS
   oDoc:nMtoReqUSD  :=ROUND(oDoc:nMtoReqBSD/oDoc:nValCam,2) // monto requerido Divisa

   oDoc:oPagosBSD:Refresh(.T.)
   oDoc:oPagosUSD:Refresh(.T.)

   oDoc:nTotal:=oDoc:nMtoReqBSD*-1

   IF lRefresh
     oBrw:Refresh(.F.)
     oBrw:nArrayAt:=nAt
     oBrw:nRowSel :=nRowSel
   ENDIF

RETURN .T. 

FUNCTION CALSUG(nMtoSug,nMoneda,cCodMon)
    LOCAL nMonto:=0

    IF cCodMon=oDp:cCodCop
       nMonto:=EJECUTAR("CALCOP",nMtoSug,oDoc:nValCam)
    ELSE
       nMonto:=ROUND(nMtoSug/nMoneda,2)
    ENDIF

RETURN nMonto
// EOF


