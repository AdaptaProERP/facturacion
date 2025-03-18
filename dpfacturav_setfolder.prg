// Programa   : DPFACTURAV_SETFOLDER          
// Fecha/Hora : 15/03/2025 04:18:22
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc,lReset)
  LOCAL nAltoBtn:=40 // area botones y totales del pago

  DEFAULT lReset:=.F.

  IF lReset .AND. LEN(oDoc:oFolder:aDialogs)>4

     oDoc:nMtoPag     :=0
     oDoc:nMtoIGTF    :=0
     oDoc:nMtoReqBSD  :=0 
     oDoc:nMtoReqUSD  :=0 // Necesario para PRE-GRABAR

     AEVAL(oDoc:oBrwPag:aArrayData,{|a,n| oDoc:oBrwPag:aArrayData[n,03]:=0,;
                                          oDoc:oBrwPag:aArrayData[n,04]:=0,;
                                          oDoc:oBrwPag:aArrayData[n,05]:=0,;
                                          oDoc:oBrwPag:aArrayData[n,12]:=0})

     oDoc:oFolder:SetOption(1)

     RETURN .T.

  ENDIF

  IF Empty(oDocCli:aSizeFolder)
     oDocCli:aSizeFolder:={oDoc:oFolder:nTop(),0,oDoc:oFolder:nWidth(),oDoc:oFolder:nHeight()}
  ENDIF

  IF oDoc:oFolder:nOption=5 .OR. oDoc:oFolder:nOption=2

     oDoc:lPagosFolder:=.T.
     oDoc:aGrids[1]:oBrw:Hide()
     oDoc:oFolder:SetSize(oDoc:oDlg:nWidth(),oDoc:oWnd:nHeight()-oDoc:oBar:nHeight()-120,.T.) // oDoc:oDlg:nWidth()-8,1000,.T.)

     IF oDoc:oFolder:nOption=2
       oDocCli:oScroll:oBrw:SetSize(oDoc:oDlg:nWidth()-15,oDoc:oFolder:nHeight()-25,.T.)
     ELSE
  
       oDoc:nMtoDoc:=oDoc:DOC_NETO 
       oDoc:oBrwPag:SETSUGERIDO()

       oDoc:oBrwPag:Move(40+4,0,oDoc:oDlg:nWidth()-15,oDoc:oFolder:nHeight()-25-nAltoBtn,.T.)
       oDoc:oBrwPag:SetColor(0,oDp:nClrPane1)

//     oDoc:oBrwPag:SetSize(oDoc:oDlg:nWidth()-15,oDoc:oFolder:nHeight()-25-nAltoBtn,.T.)
     ENDIF

  ENDIF

  IF oDoc:oFolder:nOption=1 .OR. oDoc:oFolder:nOption=3 .OR. oDoc:oFolder:nOption=4
    oDoc:aGrids[1]:oBrw:Show()
    oDoc:oFolder:Move(oDocCli:aSizeFolder[1],0,oDocCli:aSizeFolder[3],oDocCli:aSizeFolder[4],.T.)
  ENDIF

RETURN
