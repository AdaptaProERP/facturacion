// Programa   : DPFACTURAV_ADATAPAGOS
// Fecha/Hora : 15/03/2025 04:30:54
// Propósito  : Obtener los Datos de Pago
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oRecDiv:=NIL,cRif,nValCam:=oDp:nValCam,oBrw:=NIL,nColIsMon:=NIL,lCliente:=.T.,cNumRec:=NIL,cCodSuc:=NIL,cTipDoc:=NIL,nOption:=NIL
  LOCAL aData

  aData:=EJECUTAR("DPRECIBODIV_CAJBCO",oRecDiv,cRif,nValCam,oBrw,nColIsMon,lCliente,cNumRec,cCodSuc,cTipDoc,nOption)

  IF LEFT(oDp:cTipCon,1)<>"E"
    AEVAL(aData,{|a,n| aData[n,11]:=0  })
  ELSE
    AEVAL(aData,{|a,n| aData[n,11]:=IF(a[11]>0,3,0)})
  ENDIF

RETURN aData
// eof
