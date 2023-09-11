// Programa   : DPCLIENTESSLD
// Fecha/Hora : 01/05/2006 08:12:09
// Propósito  : Consulta de Saldo de Productos
// Creado Por : Juan Navas
// Llamado por: DPCLIENTESCON
// Aplicación : Inventario
// Tabla      : DPINV
// Julio Calderón
// 18/04/2008
//linea 19 se agrego el filtro del where para solo documentos activos
//"AND DOC_ACT=1"

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,cTitle,cCodSuc)
   LOCAL cWhere,oTable,cSql,nSaldo:=0,cAno,aLine:={}
   LOCAL oTable,aData,nSaldo:=0,nCuantos:=0,I
   LOCAL cAno:="",nDebe:=0,nTDebe:=0,nHaber:=0,nTHaber:=0,nSaldo:=0,nTTran:=0,nTran:=0

   DEFAULT cCodCli:=STRZERO(1,10),;
           cTitle :="Resumen Anual de Saldos",;
           cCodSuc:=oDp:cSucursal

   cWhere:="DOC_CODIGO"+GetWhere("=",cCodCli)+" AND DOC_CXC<>0 AND DOC_ACT=1 "

   IF cCodSuc!=NIL .AND. !Empty(cCodCli)
      cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+cWhere
   ENDIF

   cSql:=" SELECT YEAR(DOC_FECHA) AS ANO, MONTH(DOC_FECHA) AS MES,COUNT(*) AS CUANTOS, "+;
         " SUM(IF(DOC_CXC= 1,DOC_NETO,0)) AS DEBE ,"+;
         " SUM(IF(DOC_CXC=-1,DOC_NETO,0)) AS HABER "+;
         "  FROM DPDOCCLI "+;
         " WHERE "+cWhere+;
         " GROUP BY YEAR(DOC_FECHA),MONTH(DOC_FECHA) "+;
         " ORDER BY DOC_FECHA "

   oTable:=OpenTable(cSql,.T.)

   IF oTable:RecCount()=0
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   oTable:CTONUM("CUANTOS")
   oTable:CTONUM("DEBE")
   oTable:CTONUM("HABER")
   oTable:CTONUM("ANO")
   oTable:CTONUM("MES")

   oTable:Replace("SALDO",nSaldo)
   oTable:GoTop()
   cAno:=oTable:ANO

   WHILE !oTable:EOF()

      // Cambio de Ano

      nCuantos:=oTable:CUANTOS
      nCuantos:=CTOO(nCuantos,"N")

      oTable:Replace("CUANTOS", nCuantos)

      IF !cAno=oTable:ANO 

         aLine:=ACLONE(oTable:aDataFill[1])

         aLine[1]:=cAno
         aLine[2]:="Total"
         aLine[3]:=nTran
         aLine[4]:=nDebe
         aLine[5]:=nHaber
         aLine[6]:=nSaldo 

         AADD(oTable:aDataFill , NIL ) 
         AINS(oTable:aDataFill , oTable:Recno() ) 
         oTable:aDataFill[oTable:Recno()]:=aLine 
         cAno:=oTable:ANO
         oTable:DbSkip()
         nTran :=0
         nDebe :=0
         nHaber:=0

         LOOP

      ENDIF

      nTran :=nTran +oTable:CUANTOS
      nTTran:=nTtran+oTable:CUANTOS

      nDebe :=nDebe +oTable:DEBE
      nHaber:=nHaber+oTable:HABER

      nTDebe :=nTDebe +oTable:DEBE
      nTHaber:=nTHaber+oTable:HABER

      oTable:Replace("CUANTOS",STR(oTable:CUANTOS,5))
      oTable:Replace("MES"    ,CMES(oTable:MES))

      nSaldo:=nSaldo+oTable:DEBE-oTable:HABER
      oTable:Replace("SALDO",nSaldo)
      oTable:DbSkip()

  ENDDO

  ViewData(oTable:aDataFill,cCodCli,cTitle)

  oTable:End()
              
RETURN .T.

FUNCTION ViewData(aData,cCodCli,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oInvSld:=DPEDIT():New(cTitle,"DPCLIENTESSLD.EDT","oInvSld",.T.)
   oInvSld:cCodCli :=cCodCli
   oInvSld:cNombre :=MYSQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
   oInvSld:cField  :=cField
   oInvSld:cPicture:="99,999,999,999,999.99"
   oInvSld:lMsgBar :=.F.

   oInvSld:oBrw:=TXBrowse():New( oInvSld:oDlg )
   oInvSld:oBrw:SetArray( aData, .F. )
   oInvSld:oBrw:SetFont(oFont)
   oInvSld:oBrw:lFooter     := .T.
   oInvSld:oBrw:lHScroll    := .F.
   oInvSld:oBrw:nHeaderLines:= 1
   oInvSld:oBrw:lFooter     :=.T.

   oInvSld:cCodCli  :=cCodCli
   oInvSld:cNombre  :=cNombre
   oInvSld:aData    :=ACLONE(aData)

   AEVAL(oInvSld:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oInvSld:oBrw:aCols[1]   
   oCol:cHeader      :="Año"
   oCol:nWidth       :=055

   oCol:=oInvSld:oBrw:aCols[2]
   oCol:cHeader      :="Mes"
   oCol:nWidth       :=70

   oCol:=oInvSld:oBrw:aCols[3]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="# Regs"
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oInvSld:oBrw:aArrayData[oInvSld:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"99999999")}

   oCol:cFooter      :=TRAN(nTTran,"99999999")


   oCol:=oInvSld:oBrw:aCols[4]   
   oCol:cHeader      :="Debe"
   oCol:nWidth       :=120
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oInvSld:oBrw:aArrayData[oInvSld:oBrw:nArrayAt,4],;
                                TRAN(nMonto,oInvSld:cPicture)}
   oCol:cFooter      :=TRAN( aTotal[4],oInvSld:cPicture)


   oCol:=oInvSld:oBrw:aCols[5]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Haber"
   oCol:nWidth       :=160
   oCol:bStrData     :={|nMonto|nMonto:=oInvSld:oBrw:aArrayData[oInvSld:oBrw:nArrayAt,5],;
                                TRAN(nMonto,oInvSld:cPicture)}

   oCol:cFooter      :=TRAN( aTotal[5],oInvSld:cPicture)


   oCol:=oInvSld:oBrw:aCols[6]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Saldo"
   oCol:nWidth       :=160
   oCol:bStrData     :={|nMonto|nMonto:=oInvSld:oBrw:aArrayData[oInvSld:oBrw:nArrayAt,6],;
                                TRAN(nMonto,oInvSld:cPicture)}

   oCol:cFooter      :=TRAN(ATAIL(aData)[6],oInvSld:cPicture)


   oInvSld:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oInvSld:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oInvSld:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oInvSld:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

/*
   oCol:bLClickFooter:={|oBrw| oBrw:=oInvSld:oBrw,;
                               EJECUTAR("DPDOCCLIVIEW",;
                               oInvSld:cCodCli,;
                               NIL,;
                               NIL,;
                               oInvSld:aData[oBrw:nArrayAt,2],,,,,"Transacciones",oInvSld:cField)}
*/

   oCol:bLClickFooter:={|oBrw|oBrw:=oInvSld:oBrw,;
                              EJECUTAR("DPDOCCLIVIEW",;
                              oInvSld:cCodCli,;
                              NIL,;
                              NIL,;
                              oInvSld:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}

  
   FOR I=1 TO LEN(oInvSld:oBrw:aCols)
       oInvSld:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I


//  oINV:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 


   oInvSld:oBrw:bLDblClick:={|oBrw|oBrw:=oInvSld:oBrw,;
                                   EJECUTAR("DPDOCCLIVIEW",;
                                   oInvSld:cCodCli,;
                                   oInvSld:aData[oBrw:nArrayAt,1],;
                                   oInvSld:aData[oBrw:nArrayAt,2],;
                                   oInvSld:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}


   oInvSld:oBrw:CreateFromCode()

   oInvSld:Activate({||oInvSld:ViewDatBar(oInvSld)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oInvSld)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oInvSld:oDlg

   oInvSld:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oInvSld:oRep:=REPORTE("CLISLD"),;
                  oInvSld:oRep:SetRango(1,oInvSld:cCodCli,oInvSld:cCodCli))

   oBtn:cToolTip:="Imprimir Resumen de Saldos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\DOCCXC.BMP";
          ACTION EJECUTAR("DPCLIENTESDOC",oInvSld:cCodCli)

   oBtn:cToolTip:="Documentos de Cuentas por Cobrar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oInvSld:oBrw,oInvSld:cTitle,oInvSld:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oInvSld:oBrw:GoTop(),oInvSld:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oInvSld:oBrw:PageDown(),oInvSld:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oInvSld:oBrw:PageUp(),oInvSld:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oInvSld:oBrw:GoBottom(),oInvSld:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oInvSld:Close()

  oInvSld:oBrw:SetColor(0,16773862)

  @ 0.1,55 SAY "Código: "+oInvSld:cCodCli OF oBar BORDER SIZE 345,18
  @ 1.4,55 SAY "Nombre: "+oInvSld:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodCli)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oInvSld:cCodCli,oInvSld:cCodCli)

RETURN .T.



