// Programa   : DPCLIENTESMOVIN
// Fecha/Hora : 27/12/2011 23:25:25
// Propósito  : Consultar Todos los Movimientos del Producto Vinculados con  Cliente
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESCON
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,cTipDoc,cNomDoc,cCodSuc,dDesde,dHasta,cWhere)
   LOCAL cSql,oTable,cTitle,aData:={},aTipDoc:={},aTipDocCbx:={},nAt,I

   DEFAULT cCodCli:="J312344202",;
           cTipDoc:="",;
           cWhere :=""

//? cCodCli,cTipDoc,cNomDoc,cCodSuc,dDesde,dHasta,"cCodCli,cTipDoc,cNomDoc,cCodSuc,dDesde,dHasta"

   aData:=GETDATA(cCodCli,cTipDoc,cCodSuc,dDesde,dHasta,NIL,NIL,cWhere)

 
   IF Empty(aData)
      MensajeErr(GetFromVar("{oDp:xDPCLIENTES}")+" no posee transacciones en "+GetFromVar("{oDp:DPMOVONV}"))
      RETURN NIL
   ENDIF

   cTitle:="Movimientos de "+oDp:DPINV+" del "+;
           oDp:xDPCLIENTES+" ["+cCodCli+"- "+;
           ALLTRIM(SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli)))+"]"

   IF !Empty(dDesde)
      cTitle:=ALLTRIM(cTitle)+" : ["+DTOC(dDesde)+" "+DTOC(dHasta)+"]"
   ENDIF

   FOR I=1 TO LEN(aData)

     IF ASCAN(aTipDoc,aData[I,3])=0
        AADD(aTipDoc   ,aData[I,3])
        AADD(aTipDocCbx,aData[I,3]+SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",aData[I,3])))
     ENDIF

   NEXT I

   AADD(aTipDoc   ,""      )
   AADD(aTipDocCbx,"-Todos")


   VIEWDATA(aData,cCodCli,cTitle)

RETURN NIL

FUNCTION VIEWDATA(aData,cCodCli,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

//   oMovCli:=DPEDIT():New(cTitle,"DPCLIENTESMOVIN.EDT","oMovCli",.T.)

   DpMdi(cTitle,"oMovCli","BRINVULTCOM.EDT")

   oMovCli:Windows(0,0,aCoors[3]-160,1080,.T.) // Maximizado

   oMovCli:cCodCli   :=cCodCli
   oMovCli:cTipDoc   :=cTipDoc
   oMovCli:cNombre   :=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
   oMovCli:cField    :=cField
   oMovCli:dDesde    :=dDesde
   oMovCli:cCodSuc   :=cCodSuc
   oMovCli:dHasta    :=dHasta
   oMovCli:cFind     :=SPACE(60)
   oMovCli:lMsgBar   :=.F.
   oMovCli:aTipDoc   :=ACLONE(aTipDoc)
   oMovCli:cTipDocCbx:=""

   oMovCli:oBrw1:=TXBrowse():New( oMovCli:oDlg )
   oMovCli:oBrw1:SetArray( aData, .f. )
   oMovCli:oBrw1:SetFont(oFont)
   oMovCli:oBrw1:lFooter     := .T.
   oMovCli:oBrw1:lHScroll    := .T.
   oMovCli:oBrw1:nHeaderLines:= 2
   oMovCli:oBrw1:lFooter     :=.T.

   oMovCli:cCodCli  :=cCodCli

   oMovCli:dDesde   :=dDesde
   oMovCli:dHasta   :=dHasta
   oMovCli:cNombre  :=cNombre
   oMovCli:aData    :=ACLONE(aData)
  oMovCli:nClrText :=16711680
  oMovCli:nClrPane1:=16773862
  oMovCli:nClrPane2:=16773862

   AEVAL(oMovCli:oBrw1:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oMovCli:oBrw1:aCols[1]   
   oCol:cHeader      :=GetFromVar("{oDp:xDPINV}")
   oCol:nWidth       :=100
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 


   oCol:=oMovCli:oBrw1:aCols[2]
   oCol:cHeader      :="Nombre del "+GetFromVar("{oDp:xDPINV}")
   oCol:nWidth       :=400
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 


   oCol:=oMovCli:oBrw1:aCols[3]
   oCol:cHeader      :="Tip"+CRLF+"Doc"
   oCol:nWidth       :=35
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 


   oCol:=oMovCli:oBrw1:aCols[4]
   oCol:cHeader      :="Número"+CRLF+"Documento"
   oCol:nWidth       :=80
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 

   oCol:=oMovCli:oBrw1:aCols[5]
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=76
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 

   oCol:=oMovCli:oBrw1:aCols[6]
   oCol:cHeader      :="Und"+CRLF+"Medida"
   oCol:nWidth       :=40
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 

   oCol:=oMovCli:oBrw1:aCols[7]   
   oCol:cHeader      :="Cant."+CRLF+"Unidades"
   oCol:nWidth       :=80
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,7],;
                                TRAN(nMonto,oDp:cPictCanUnd)}
   oCol:cFooter      :=TRAN( aTotal[7] , oDp:cPictCanUnd)
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 

   oCol:=oMovCli:oBrw1:aCols[8]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Precio"
   oCol:nWidth       :=110
   oCol:bStrData     :={|nMonto|nMonto:=oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,8],;
                                TRAN(nMonto,oDp:cPictCanUnd)}
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 
 

   oCol:=oMovCli:oBrw1:aCols[9]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Total"+CRLF+"Renglón"
   oCol:nWidth       :=110
   oCol:bStrData     :={|nMonto|nMonto:=oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,9],;
                                TRAN(nMonto,oDp:cPictCanUnd)}

   oCol:cFooter      :=TRAN( aTotal[9],oDp:cPictCanUnd)
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 


   oCol:=oMovCli:oBrw1:aCols[10]   
   oCol:cHeader      :="Cód."+CRLF+"Suc."




   oCol:=oMovCli:oBrw1:aCols[11]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Reg"+CRLF+"Memo"
   oCol:nWidth       :=60
   oCol:bStrData     :={|nMonto|nMonto:=oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,11],;
                                TRAN(nMonto,"99999999")}
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 


   oCol:=oMovCli:oBrw1:aCols[12]  
   oCol:cHeader      := "Memo"
   oCol:nWidth       := 25
   oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
   oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
   oCol:bBmpData    := { |oBrw|oBrw:=oMovCli:oBrw1,IIF(oBrw:aArrayData[oBrw:nArrayAt,12],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)


   oCol:=oMovCli:oBrw1:aCols[13]  
   oCol:cHeader      :="Compuesto"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oMovCli:oBrw1:aArrayData ) } 




   oMovCli:oBrw1:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oMovCli:oBrw1,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oMovCli:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 12316381, 14678001 ) } }

   oMovCli:oBrw1:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oMovCli:oBrw1:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oMovCli:oBrw1:CreateFromCode()
    oMovCli:bValid   :={|| EJECUTAR("BRWSAVEPAR",oMovCli)}
    oMovCli:BRWRESTOREPAR()

   oMovCli:oWnd:oClient := oMovCli:oBrw1

   oMovCli:Activate({||oMovCli:ViewDatBar()})

   DPFOCUS(oMovCli:oFind)


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oMovCli:oDlg,nLin:=0

//   oMovCli:oBrw1:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

IF !EMPTY(oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,1])

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PRODUCTO.BMP";
          ACTION (EJECUTAR("DPINV",0,oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,1]))

   oBtn:cToolTip:="Consultar Producto"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION (EJECUTAR("DPINVCON",NIL,oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt,1]))

   oBtn:cToolTip:="Consultar Producto"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oMovCli:VERDOCUMENTO()

   oBtn:cToolTip:="Consultar Documento"


ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oMovCli:oBrw1))

   oBtn:cToolTip:="Generar Archivo html"   


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XMEMO.BMP";
          ACTION oMovCli:VERMEMO()

   oBtn:cToolTip:="Consultar Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oMovCli:oBrw1)


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oMovCli:oBrw1)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oMovCli:oBrw1);
          WHEN LEN(oMovCli:oBrw1:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oMovCli:oRep:=REPORTE("DPCLIENTEMOVINV"),;
                  oMovCli:oRep:SetRango(1,oMovCli:cCodCli,oMovCli:cCodCli),;
                  oMovCli:oRep:SetRango(2,oMovCli:dDesde ,oMovCli:dHasta ),;
                  oMovCli:oRep:SetCriterio(2,oMovCli:cTipDoc)             ,;
                  oMovCli:oRep:SetCriterio(3,oMovCli:cFind  ))

   oBtn:cToolTip:="Imprimir Resumen"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oMovCli:oBrw1,oMovCli:cTitle,oMovCli:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oMovCli:oBrw1:GoTop(),oMovCli:oBrw1:Setfocus())
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oMovCli:oBrw1:PageDown(),oMovCli:oBrw1:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oMovCli:oBrw1:PageUp(),oMovCli:oBrw1:Setfocus())
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oMovCli:oBrw1:GoBottom(),oMovCli:oBrw1:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oMovCli:Close()

  oMovCli:oBrw1:SetColor(0,14678001)

  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  @ 0,nLin+12 SAY " Buscar " OF oBar BORDER SIZE 65,21 PIXEL RIGHT

  @ 0,nLin+80 GET oMovCli:oFind VAR oMovCli:cFind;
               SIZE 420,20 OF oBar PIXEL

  @ oMovCli:oFind:nTop(),oMovCli:oFind:nRight()+2 BUTTON " > ";
              ACTION oMovCli:BUSCARMEMO();
              SIZE 20,20 OF oBar;
              PIXEL


  @ 22,nLin+12 SAY "Tipos " OF oBar BORDER SIZE 65,21 RIGHT PIXEL

  ADEPURA(aTipDocCbx,{|a,n| Empty(a)})

  @ 22,nLin+80 COMBOBOX  oMovCli:oTipDocCbx VAR oMovCli:cTipDocCbx;
              ITEMS aTipDocCbx ON CHANGE (oMovCli:cTipDoc:=oMovCli:aTipDoc[oMovCli:oTipDocCbx:nAt],;
              oMovCli:BUSCARMEMO()) OF oBAR PIXEL SIZE 420,20 WHEN LEN(oMovCli:oTipDocCbx:aItems)>1

  oMovCli:oTipDocCbx:Select(LEN(oMovCli:aTipDoc))
//  COMBOINI(oMovCli:oTipDocCbx)

  oMovCli:oTipDocCbx:ForWhen(.T.)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

//  oMovCli:oTipDocCbx:Select(LEN(oMovCli:oTipDocCbx:aItems))

  DPFOCUS(oMovCli:oFind)

  oMovCli:oBrw1:Gotop()

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodCli)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oMovCli:cCodCli,oMovCli:cCodCli)

RETURN .T.


PROCE GETDATA(cCodCli,cTipDoc,cCodSuc,dDesde,dHasta,cFind,oBrw,cWhere)
   LOCAL cSql,oTable,cTitle,aData:={}

   DEFAULT cCodCli:="J312344202",;
           cTipDoc:="FAV",;
           cFind  :="",;
           cWhere :=""

//? "cCodCli,cTipDoc,cCodSuc,dDesde,dHasta,cFind,oBrw",cCodCli,cTipDoc,cCodSuc,dDesde,dHasta,cFind,oBrw,VALTYPE(cCodCli),VALTYPE(cTipDoc),VALTYPE(cCodSuc),VALTYPE(dDesde),VALTYPE(dHasta),VALTYPE(cFind),VALTYPE(oBrw)

   CursorWait()

   IF !Empty(dDesde)
     cWhere:=IF(!Empty(cWhere)," AND ", "" )+cWhere+" AND "+GetWhereAnd("MOV_FECHA",dDesde,dHasta)
   ENDIF

   cSql:=" SELECT MOV_CODIGO,INV_DESCRI,MOV_TIPDOC,MOV_DOCUME,MOV_FECHA,MOV_UNDMED,MOV_CANTID*MOV_CXUND AS CANTID,MOV_PRECIO, "+;
         " MOV_TOTAL,MOV_CODSUC, MOV_NUMMEM, 0 AS LOGICO, MOV_CODCOM"+;
         " FROM DPMOVINV "+;
         " INNER JOIN DPINV  ON MOV_CODIGO=INV_CODIGO "+;
         " LEFT  JOIN DPMEMO ON MOV_NUMMEM=MEM_NUMERO "+IIF( Empty(cFind  ), "" , " AND MEM_MEMO"  +GetWhere(" LIKE ","%"+ALLTRIM(cFind)+"%"))+;
         " WHERE "+IIF( cCodSuc=NIL   , "" , " MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND ")+;
                   IIF( Empty(cTipDoc), "" , " MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND ")+;
         "       MOV_APLORG='V' AND "+;
         "       MOV_INVACT=1 "+cWhere+" AND "+;
         "       MOV_CODCTA"+GetWhere("=",cCodCli)

   cSql:=STRATRAN(cSql," AND AND ","AND")

 ? CLPCOPY(cSql)

   aData:=ASQL(cSql)

   IF Empty(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,NIL)
      aData[1,2]:="Registro no encontrado"
   ENDIF

   AEVAL(aData,{|a,n| aData[n,12]:=Empty(a[11]) })

//ViewArray(aData)

   IF ValType(oBrw)="O"

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt:=1
      obrw:Refresh(.T.)

   ENDIF

RETURN aData 


FUNCTION VERDOCUMENTO()
   LOCAL aLine:=ACLONE(oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt])
   LOCAL oFrm,cCodSuc:=oDp:cSucursal,cTipDoc:=aLine[3],cNumero:=aLine[4],cCodigo
  
   EJECUTAR("DPDOCCLIFAVCON",oFrm,cCodSuc,cTipDoc,cNumero,oMovCli:cCodCli)
   
RETURN .T.



FUNCTION VERMEMO()
   LOCAL aLine:=ACLONE(oMovCli:oBrw1:aArrayData[oMovCli:oBrw1:nArrayAt])
   LOCAL cRef:=aLine[3]+"-"+aLine[4]
  
   EJECUTAR("DPVERMEMO",aLine[9],cRef)
   
RETURN .T.

FUNCTION BUSCARMEMO()

     GETDATA(oMovCli:cCodCli,oMovCli:cTipDoc,oMovCli:cCodSuc,oMovCli:dDesde,oMovCli:dHasta,oMovCli:cFind,oMovCli:oBrw1)


RETURN .T.



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oMovCli)
// EOF