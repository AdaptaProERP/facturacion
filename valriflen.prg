// Programa   : VALRIFLEN
// Fecha/Hora : 10/01/2025 10:51:31
// Propósito  : Valida longitud del RIF
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif,oRif,lMsg,lZero)
  LOCAL lResp:=.T.,cMsg:=""
  LOCAL nLen :=10

  DEFAULT lZero:=.F.,;
          cRif :="J312344202",;
          lMsg :=.T.

  IF oDp:lVen

   cRif:=ALLTRIM(UPPER(cRif))
   cRif:=STRTRAN(cRif,"-","")

   IF LEN(ALLTRIM(cRIF))<>10 
     cMsg:="Su longitud es de "+LSTR(LEN(cRif))+" dígitos, debe tener "+LSTR(nLen)+" dígitos"
   ENDIF

   IF !LEFT(cRIF,1)$"JVGEPC" 

     cMsg:=cMsg+IF(Empty(cMsg),"",CRLF)+;
           "Primera letra debe ser: J,V,G,E,P o C"

   ENDIF

  ENDIF

  IF !Empty(cMsg)
    
     oDp:cRifErr:=cMsg
  
     IF lMsg

       IF ValType(oRif)="O" 

         IF "COL"$oRif:ClassName()
            EJECUTAR("XSCGMSGERR",oCol:oBrw,cMsg,"RIF "+cRif+" Incorrecto")
         ELSE
           oRif:MsgErr(cMsg,"RIF "+cRif+" Incorrecto")
         ENDIF

       ELSE
         MsgMemo(cMsg,"RIF "+cRif+" Incorrecto",200,100)
       ENDIF

     ENDIF

     lResp:=.F.

  ENDIF

RETURN lResp
// EOF
