// Programa   : DPCLIENTESRECDEF
// Fecha/Hora : 21/05/2019 04:21:49
// Propósito  : Definiciones del Recurso Humano
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  oDp:DPCLIENTESREC_HUMANO   :=GETINI("DATAPRO.INI","DPCLIENTESREC_HUMANO" ,"Humano")  
  oDp:DPCLIENTESREC_PLANTAS  :=GETINI("DATAPRO.INI","DPCLIENTESREC_PLANTAS","Plantas")  
  oDp:DPCLIENTESREC_EQUIPOS  :=GETINI("DATAPRO.INI","DPCLIENTESREC_EQUIPOS","Equipos")  
  oDp:DPCLIENTESREC_VEHICULO :=GETINI("DATAPRO.INI","DPCLIENTESREC_EQUIPOS","Vehiculo")  


RETURN .T.
// EOF
