// Programa   : DOCCLIDIGITALSEND
// Fecha/Hora : 14/02/2025 03:32:57
// Propósito  : Enviar Factura Digital
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cUrl, cParams, cContentType, cAuthorization, cType, nLen, lBody, lHead )
   LOCAL oOle:=CreateObject_HTTP()

? oOle:ClassName()

RETURN
