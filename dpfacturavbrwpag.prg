// Programa   : DPFACTURAVSETPAG
// Fecha/Hora : 07/06/2024 13:17:16
// Propósito  : Formulario de Pago
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc)
   LOCAL aData :={},cRif:=NIL,nValCam:=1,oBrw:=NIL,nColIsMon:=14-1,oDlg,oFont:=NIL
   LOCAL aTotal:={},oCol,oFontB,oFontH,nAt,oBar,oCursor

   IF !ValType(oDoc)="O"
      RETURN NIL
   ENDIF

   oDoc:lDifCambiario:=.F. 
   oDoc:cCodCaja     :=oDp:cCodCaja
   oDoc:nTotal       :=0
   oDoc:oBrwR        :=NIL // browse total divisas
   oDoc:oBtnSave     :=NIL
   oDoc:nValCam      :=oDoc:DOC_VALCAM
   oDoc:lIGTFCXC     :=.F.  
   oDoc:lCruce       :=.F.
   oDoc:lIGTF        :=.T.
   oDoc:lDifAnticipo :=.F.
   oDoc:lAnticipo    :=!(oDoc:DOC_TIPDOC="FAV" .OR. oDoc:DOC_TIPDOC="TIK" .OR. oDoc:DOC_TIPDOC="FAM") // Otro documento será anticipo

   oDoc:nMtoAnticipo:=0
   oDoc:nMtoDifCam  :=0
   oDoc:nMtoPag     :=0
   oDoc:nMtoIGTF    :=0
   oDoc:nMtoDoc     :=0

   oDoc:nMtoReqBSD  :=0 // oDoc:nMtoDoc-oDoc:nMtoDoc             // monto requerido BS
   oDoc:nMtoReqUSD  :=0 // ROUND(oDoc:nMtoReqBSD/oDoc:nValCam,2) // monto requerido Divisa

   IF LEN(oDoc:oFolder:aDialogs)<5 
      RETURN .F.
   ENDIF

   IF Empty(oDoc:aDataPagos) 
     oDoc:oFolder:aEnable[5]:=.F.
     RETURN .F.
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFontH NAME "Tahoma"   SIZE 0, -11 BOLD

   // MONTOS


   // oDoc:nColMtoITG:=13-1        // 13 Monto IGTF
   // COLUMNAS
   oDoc:nColSelP  :=7-1         // Seleccionar Pago
   oDoc:nColCodMon:=8-1         // Código de Moneda
   oDoc:nColCajBco:=9-1         // Caja/Banco
   
   oDoc:nColIsMon   :=nColIsMon
   oDoc:nColMarcaFin:=oDoc:nColIsMon+1
   oDoc:nColInsPag  :=oDoc:nColCajBco+1
   oDoc:nColPorITG  :=11 
   oDoc:nColMtoITG  :=12 
   oDoc:nColDuplicar:=oDoc:nColMarcaFin+4

   oDoc:nTotal5 :=0
   oDoc:nMontoBs:=0

   oDoc:nClrText1:=0
   oDoc:nClrText3:=CLR_HBLUE
   oDoc:nClrText4:=CLR_HRED

   oDoc:nClrText5:=4557312 // VERDE
   oDoc:nClrPane1:=oDp:nClrPane1
   oDoc:nClrPane2:=oDp:nClrPane2

   oDoc:nClrPane1 :=16774120
   oDoc:nClrPane2 :=16771538
   oDoc:nClrText1 :=0 // 6208256
   oDoc:nClrText2 :=16751157  // CLR_HRED // 8667648
   oDoc:nClrText3 :=16744576 // 32768
   oDoc:nClrText4 :=10440704

   oDlg :=oDoc:oFolder:aDialogs[5]

//   DEFINE CURSOR oCursor HAND
//   DEFINE BUTTONBAR oBar SIZE 50,50 OF oDlg 3D CURSOR oCursor
  
   aData :=ACLONE(oDoc:aDataPagos) // EJECUTAR("DPRECIBODIV_CAJBCO",NIL,cRif,nValCam,oBrw,nColIsMon,.T.)
   aTotal:=ATOTALES(aData) 

/*
   @    0,1 SAY " Pagar "+oDp:cMoneda   +"  " OF oDlg PIXEL FONT oFontB SIZE 45,09 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL RIGHT
   @ 10.0,1 SAY " Pagar "+oDp:cMonedaExt+"  " OF oDlg PIXEL FONT oFontB SIZE 45,09 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL RIGHT

   @    0,46 SAY oDoc:oPagosBSD PROMPT FDP(oDoc:nMtoReqBSD,"999,999,999,999.99") OF oDlg PIXEL FONT oFontB SIZE 55,09 COLOR oDp:nClrYellowText,oDp:nClrYellow  PIXEL RIGHT 
   @ 10.0,46 SAY oDoc:oPagosUSD PROMPT FDP(oDoc:nMtoReqUSD,"999,999,999,999.99") OF oDlg PIXEL FONT oFontB SIZE 55,09 COLOR oDp:nClrYellowText,oDp:nClrYellow  PIXEL RIGHT
*/

   oBrw:=TXBrowse():New( oDlg)
   oBrw:oLbx        :=oDoc // Formulario DPFACTURAV 
   oBrw:oLbx:oBrwPag:=oBrw

   oBrw:SetScript("DPFAVPAGFUNCTION")

   oDoc:oBrwPag:=oBrw

   PUBLICO("oBrwPag",oBrw)



   oBrw:SetArray( aData , .F. )

   oBrw:SetFont(oFont)
   oBrw:lHScroll    :=.T.
   oBrw:nHeaderLines:=2
   oBrw:lFooter     :=.T.
   oBrw:nDataLines  :=1 

   // aData :=ACLONE(aData)
   oBrw:oLbx:aData :=ACLONE(aData)


   oCol:=oBrw:aCols[1]
   oCol:cHeader      :="Moneda"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 120
   oCol:cFooter      :="#"+LSTR(LEN(aData)) // FDP(aTotal[4],"999,999,999.99")

   oCol:=oBrw:aCols[2]
   oCol:cHeader      :="Tasa "+CRLF+"en "+oDp:cMoneda
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:nWidth       := 80
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw  :=oCol:oBrw,;
                                          nMonto:= oBrw:aArrayData[oBrw:nArrayAt,2],FDP(nMonto,oDp:cPictValCam)}

   oCol:=oBrw:aCols[3]
   oCol:cHeader      :="Monto"+CRLF+"Sugerido"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:nWidth       := 110
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw  :=oCol:oBrw,;
                                          nMonto:= oBrw:aArrayData[oBrw:nArrayAt,3],FDP(nMonto,"999,999,999,999.99")}
  
   oCol:=oBrw:aCols[4]
   oCol:cHeader      :="Recibido"+CRLF+"Divisa"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture := "999,999,999,999.99"
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw:=oCol:oBrw,;
                                          nMonto:= oBrw:aArrayData[oBrw:nArrayAt,4],FDP(nMonto,"999,999,999.99")}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue| oCol:oBrw:PUTMONTO(oCol,uValue,4)}
   oCol:oDataFont    :=oFontB
   oCol:cFooter      :=FDP(aTotal[4],"999,999,999.99")

   oCol:=oBrw:aCols[5]
   oCol:cHeader      :="Monto"+CRLF+"Recibido ("+oDp:cMoneda+")"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw  :=oCol:oBrw,;
                                          nMonto:=oBrw:aArrayData[oBrw:nArrayAt,5],FDP(nMonto,"999,999,999.99")}

   oCol:cEditPicture := "999,999,999,999.99"
   oCol:cFooter      :=FDP(aTotal[5],"999,999,999.99")



   oCol:=oBrw:aCols[6] //  oBrw:oLbx:nColSelP]
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:cHeader      :="Caja"
   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}
   oCol:bBmpData    := { |oCol,oBrw|oBrw:=oCol:oBrw,;
                                    IIF(oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColIsMon],1,2) }
   oCol:nWidth      := 40


   oCol:=oBrw:aCols[oDoc:nColCodMon]
   oCol:cHeader      :="Mon"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 30

   oCol:=oBrw:aCols[oDoc:nColCajBco]
   oCol:cHeader      :="Caja"+CRLF+"Bco"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:nWidth       := 30
   oCol:bClrStd      := {|oCol,oBrw,nClrText,aLine|oBrw    :=oCol:oBrw,;
                                                   aLine   :=oBrw:aArrayData[oBrw:nArrayAt],;
	                                              nClrText:=IF("CAJ"$aLine[oBrw:oLbx:nColCajBco],oBrw:oLbx:nClrText5,oBrw:oLbx:nClrText3),;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oBrw:oLbx:nClrPane1, oBrw:oLbx:nClrPane2 ) } }

   oCol:=oBrw:aCols[oDoc:nColInsPag]
   oCol:cHeader      :="Inst"+CRLF+"Pago"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 40

   oCol:=oBrw:aCols[oDoc:nColInsPag+1]
   oCol:cHeader      :="Instrumento"+CRLF+"Pago"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 110

   oCol:=oBrw:aCols[oDoc:nColPorITG]
   oCol:cHeader      :="%"+CRLF+"IGTF"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:nWidth       := 35
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw:=oCol:oBrw,;
                                          nMonto:= oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColPorITG],FDP(nMonto,"9.99")}
   oCol:bClrStd      := {|oCol,oBrw,nClrText,nMonto|oBrw    :=oCol:oBrw,;
                                                    nMonto  :=oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColPorITG],;
	                                               nClrText:=IF(nMonto>0,oBrw:oLbx:nClrText3,oBrw:oLbx:nClrText1),;
                                                   {nClrText,iif( oBrw:nArrayAt%2=0, oBrw:oLbx:nClrPane1, oBrw:oLbx:nClrPane2 ) } }

   oCol:=oBrw:aCols[ oDoc:nColMtoITG]
   oCol:cHeader      :="Monto"+CRLF+"IGTF "+oDp:cMoneda
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrw:aArrayData ) } 
   oCol:nWidth       := 80
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture := "999,999,999.99"
   oCol:bStrData     :={|oCol,oBrw,nMonto|oBrw:=oCol:oBrw,;
                       nMonto:= oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColMtoITG],FDP(nMonto,"999,999,999.99")}
   oCol:cFooter      :=FDP(aTotal[oDoc:nColMtoITG],oCol:cEditPicture)


   oCol:=oBrw:aCols[oDoc:nColIsMon]
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:cHeader      :="Mone"+CRLF+"da"
   oCol:AddBmpFile("BITMAPS\monedas2.bmp")
   oCol:AddBmpFile("BITMAPS\cheque2.bmp")
   oCol:bBmpData    := { |oCol,oBrw|oBrw:=oCol:oBrw,;
                                    IIF(oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColIsMon],1,2) }

   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}



   oCol:=oBrw:aCols[oDoc:nColMarcaFin]
   oCol:cHeader      :="Marca"+CRLF+"Financiera"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 100

   oCol:=oBrw:aCols[oDoc:nColMarcaFin+1]
   oCol:cHeader      :="Banco"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 100

   oCol:=oBrw:aCols[oDoc:nColMarcaFin+2]
   oCol:cHeader      :="Cuenta"+CRLF+"Bancaria"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth       := 100

   oCol:=oBrw:aCols[oDoc:nColMarcaFin+3]
   oCol:cHeader       :="Referencia"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, o:oBrw:aArrayData ) } 
   oCol:nWidth        := 100

   oCol:=oBrw:aCols[oDoc:nColDuplicar]
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBrwPag:aArrayData ) } 
   oCol:cHeader      :="Dupli-"+CRLF+"car"
   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:AddBmpFile("BITMAPS\xcheckon.BMP")
   oCol:bBmpData    := { |oCol,oBrw|oBrw:=oCol:oBrw,;
                                    IIF(oBrw:aArrayData[oBrw:nArrayAt,oBrw:oLbx:nColDuplicar],1,2) }

   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}
  
   oBrw:bLDblClick:={|nRow,nCol,nKeyFlags,oBrw| oBrw:RUNCLICK() }

   oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrw:bChange:={|oBrw| oBrw:BRWCHANGEPAGOS(),;
                         PUBLICO("oBrwPag",oBrw),;
                         PUBLICO("oBrwDoc",oBrw:oLbx) } 


   oBrw:bClrStd:= {|oCol,oBrw,nClrText,aLine,oDoc| oBrw    :=oCol:oBrw,oDoc:=oBrw:oLbx,;
                                                   aLine   :=oBrw:aArrayData[oBrw:nArrayAt],;
                                                   nClrText:=IF(aLine[4]=0,0,9652480),;
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oDoc:nClrPane1, oDoc:nClrPane2 ) } }

   AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontH})

   oBrw:CreateFromCode()

   oBrw:bGotFocus:={|oBrw| PUBLICO("oBrwPag",oBrw),;
                           PUBLICO("oBrwDoc",oBrw:oLbx)} 

   oBrw:SetColor(0,oDoc:nClrPane1)

 RETURN oBrw
// EOF
