// Programa   : VALNOMBRE
// Fecha/Hora : 20/01/2025 03:59:09
// Propósito  : Validar Nombre de la Empresa
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNombre,oNombre,cRif,lMsg)
  LOCAL lResp:=.T.,cMsg:="",nAt,cSigla
  LOCAL nLen :=10,nLenN
 
  DEFAULT cNombre:="LA EMPRESA SIN CAPUNTO,C.A.",;
          cRif   :="J312344202",;
          lMsg   :=.T.

  nLenN      :=LEN(cNombre)
  oDp:cNombre:=""

  IF !oDp:lVen
     oDp:cNombre:=cNombre
     RETURN .T.
  ENDIF

  cRif:=ALLTRIM(UPPER(cRif))
  cRif:=STRTRAN(cRif,"-","")

  IF LEN(ALLTRIM(cRIF))<>10 
    cMsg:="Su longitud es de "+LSTR(LEN(cRif))+" dígitos, debe tener "+LSTR(nLen)+" dígitos"
  ENDIF

  IF !LEFT(cRIF,1)$"JVGEPC" 

    cMsg:=cMsg+IF(Empty(cMsg),"",CRLF)+;
          "Primera letra debe ser: J,V,G,E,P o C"

  ENDIF

  oDp:aSiglasEmp:={"C.A.","S.R.L.","S.A.","S.A.I.C.A.","S.C."}
  oDp:aSiglaEmp :={"CA" ,"SRL","SA","SAICA","SC"}

  // Jurídico, debe termina en C.A. 
  IF LEFT(cRIF,1)$"J" 

     nAt   :=RAT(" ",cNombre)

     IF nAt=0 .OR. ","$cNombre
        nAt   :=RAT(",",cNombre)
     ENDIF

     IF nAt>0
        cSigla:=SUBS(cNombre,nAt+1,LEN(cNombre))
     ENDIF

     cSigla:=IF(nAt>0,SUBS(cNombre,nAt+1,LEN(cNombre)),"")
     cSigla:=ALLTRIM(cSigla)

     nAt   :=ASCAN(oDp:aSiglasEmp,{|a,n| a==cSigla})

     IF nAt=0
       cNombre:=ALLTRIM(cNombre)+", C.A."
       cNombre:=PADR(cNombre,MAX(LEN(cNombre),nLenN))
     ENDIF

     oDp:cNombre:=cNombre

  ENDIF
 

  IF !Empty(cMsg)
    
   oDp:cRifErr:=cMsg
  
    IF lMsg
 
     IF ValType(oRif)="O" 
       oRif:MsgErr(cMsg,"RIF "+cRif+" Incorrecto")
     ELSE
       MsgMemo(cMsg,"RIF "+cRif+" Incorrecto",200,100)
     ENDIF

   ENDIF

   lResp:=.F.

  ENDIF

RETURN lResp
// EOF
