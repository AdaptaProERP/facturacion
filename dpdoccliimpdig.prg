// Programa   : DPDOCCLIIMPDIG
// Fecha/Hora : 12/08/2005 15:29:42
// Propósito  : Impresion Digital
// Creado Por : Juan Navas
// Llamado por: DOCTOTAL
// Aplicación : Ventas
// Tabla      : DPDOCCLIIVA

#define XD_ENVIAR   1
#define XD_ANULAR   2
#define XD_EMAIL    3

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cJson,nAction)
   LOCAL cResponse:="",cPing:=""

   IF Empty(cJson)
      RETURN
   ENDIF

   oDp:nFavD_Seconds:=0
   oDp:oFavD_Ole    :=NIL
   oDp:cFavD_Ret    :=""
   oDp:cFavD_Send   :=""
   oDp:cFavD_Param  :=""
   oDp:cScrErrorLin :=""


?  oDp:cFavD_Version,"version",oDp:cRif

?  oDp:cFavD_cUrl,"url"

   // no validar PING con el Servidor por lentitud

   WHILE .T.

     cResponse:=XDFactura( cJson, nAction )

? CLPCOPY(cResponse),"cResponse"

     IF "Error WinHttp.WinHttpRequest/-1"$oDp:cScrErrorLin

       // hacer pista de auditoria

       MsgRun("Obteniendo PING con "+oDp:cFavD_cUrl)

       cPinG:=EJECUTAR("GETPING",oDp:cFavD_cUrl)    
  
       IF MsgYesNo("Documento Digital no pudo ser enviado"+CRLF+"Revise conexión Internet"+CRLF+LEFT(oDp:cScrErrorLin,80),"Desea Reintentar Enviar la Factura")
         LOOP
       ENDIF

     ENDIF

     EXIT

   ENDDO

RETURN .T.

// EOF
