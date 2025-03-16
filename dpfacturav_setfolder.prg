// Programa   : DPFACTURAV_SETFOLDER          
// Fecha/Hora : 15/03/2025 04:18:22
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc)
  LOCAL nAltoBtn:=40 // area botones y totales del pago

//  oDp:oFrameDp:SetText(LSTR(oDoc:oFolder:nOption),"OPTION")

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
       oDoc:oBrwPag:SetSize(oDoc:oDlg:nWidth()-15,oDoc:oFolder:nHeight()-25-nAltoBtn,.T.)
     ENDIF

  ENDIF

  IF oDoc:oFolder:nOption=1 .OR. oDoc:oFolder:nOption=3 .OR. oDoc:oFolder:nOption=4
    oDoc:aGrids[1]:oBrw:Show()
    oDoc:oFolder:Move(oDocCli:aSizeFolder[1],0,oDocCli:aSizeFolder[3],oDocCli:aSizeFolder[4],.T.)
  ENDIF

RETURN
