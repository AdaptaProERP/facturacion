// Programa   : DPCLIENTESPROG
// Fecha/Hora : 01/08/2011 08:12:09
// Propósito  : Documentos Periódicos para el cliente
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Gerencia 
// Tabla      : DPCLIENTESPROG

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,nPeriodo,dDesde,dHasta)

   LOCAL aData,cTitle,cWhere,dDesde,dHasta,aFechas,cWhere

   DEFAULT cCodSuc:=oDp:cSucursal,;
           nPeriodo:=4

   cTitle:="Resumen por Documentos de "+oDp:xDPPROVEEDOR

   IF Empty(dDesde)
     aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

   aData :=LEERDOCPRO(GetWhereAnd("DPG_FCHFIN",dDesde,dHasta))

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)
            
RETURN .T.

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aPeriodos:={"Diario","Semanal","Quincenal","Mensual","Bimestral","Trimestral","Semestral","Anual","Indicada"}

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oCliProg:=DPEDIT():New(cTitle,"DPTIPDOCPRORES.EDT","oCliProg",.T.)
   oCliProg:cCodSuc :=oDp:cSucursal
   oCliProg:lMsgBar :=.F.
   oCliProg:cPeriodo:=aPeriodos[nPeriodo]
   oCliProg:cCodSuc :=cCodSuc

   oCliProg:dDesde  :=dDesde
   oCliProg:dHasta  :=dHasta

   oCliProg:oBrw:=TXBrowse():New( oCliProg:oDlg )
   oCliProg:oBrw:SetArray( aData, .T. )
   oCliProg:oBrw:SetFont(oFont)

   oCliProg:oBrw:lFooter     := .T.
   oCliProg:oBrw:lHScroll    := .F.
   oCliProg:oBrw:nHeaderLines:= 1
   oCliProg:oBrw:lFooter     :=.T.

   oCliProg:aData            :=ACLONE(aData)

   AEVAL(oCliProg:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCliProg:oBrw:aCols[1]   
   oCol:cHeader      :="Tipo"
   oCol:nWidth       :=045

   oCol:=oCliProg:oBrw:aCols[2]
   oCol:cHeader      :="Descripción"
   oCol:nWidth       :=200

   oCol:=oCliProg:oBrw:aCols[3]   
   oCol:cHeader      :="Base Imponible"
   oCol:nWidth       :=135
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[3],"999,999,999,999.99")

   oCol:=oCliProg:oBrw:aCols[4]   
   oCol:cHeader      :="Monto de IVA"
   oCol:nWidth       :=135
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,4],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[4],"999,999,999,999.99")


   oCol:=oCliProg:oBrw:aCols[5]   
   oCol:cHeader      :="Monto Neto"
   oCol:nWidth       :=135
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[5],"999,999,999,999.99")



   oCol:=oCliProg:oBrw:aCols[6]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="# Regs"
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"99999999")}

   oCol:cFooter      :=TRAN( aTotal[6],"9999999")



   oCliProg:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCliProg:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15724510, 15000777 ) } }

   oCliProg:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCliProg:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oCliProg:oBrw:bLDblClick:={|oBrw|oCliProg:oRep:=oCliProg:VERPROVEEDOR() }

   oCliProg:oBrw:CreateFromCode()

   oCliProg:Activate({||oCliProg:ViewDatBar(oCliProg)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oCliProg)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oCliProg:oDlg,oBtnCal

   oCliProg:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP",NIL,"BITMAPS\PROVEEDORESH.BMP";
          ACTION oCliProg:oRep:=oCliProg:VERPROVEEDOR();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPPROVEEDOR


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PRODUCTO.BMP",NIL,"BITMAPS\PRODUCTOH.BMP";
          ACTION oCliProg:oRep:=oCliProg:VERPRODUCTO();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPINV

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\GRUPOS.BMP",NIL,"BITMAPS\GRUPOSH.BMP";
          ACTION oCliProg:oRep:=oCliProg:VERGRUPO();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPGRU

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\clasificaclientes.BMP",NIL,"BITMAPS\clasificaclientesh.BMP";
          ACTION oCliProg:oRep:=oCliProg:VERCLASIFICA();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:xDPCLICLA


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\acteconomica.BMP",NIL,"BITMAPS\acteconomicah.BMP";
          ACTION oCliProg:oRep:=oCliProg:VER_ACT_ECO();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:xDPACTIVIDAD_E


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CALENDAR.BMP",NIL,"BITMAPS\CALENDARH.BMP";
          ACTION oCliProg:oRep:=oCliProg:VERPERIODOS()

            
   oBtn:cToolTip:="Ver Resumen por Periodos"
   oBtnCal:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSE.BMP";
          ACTION oCliProg:LISTARDOCS();
          WHEN !Empty(oCliProg:oBrw:aArrayData[1,1])
              
   oBtn:cToolTip:="Ver lista de Documentos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\COMPARATIVO.BMP",NIL,"BITMAPS\COMPARATIVOH.BMP";
          ACTION oCliProg:oRep:=oCliProg:COMPARATIVOS()
            
   oBtn:cToolTip:="Ver Comparativos"
   oBtnCal:=oBtn

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oCliProg:oRep:=REPORTE(oCliProg:cRep),;
                  oCliProg:oRep:SetRango(1,oCliProg:cCodInv,oCliProg:cCodInv))

   oBtn:cToolTip:="Imprimir"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCliProg:oBrw,oCliProg:cTitle,oCliProg:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCliProg:oBrw:GoTop(),oCliProg:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCliProg:oBrw:GoBottom(),oCliProg:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCliProg:Close()

  oCliProg:oBrw:SetColor(0,15724510)
// 15724510, 15000777 
  oBar:SetColor(CLR_BLACK,oDp:nGris )

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


  //
  // Campo : Periodo
  //

  @ 1.0, 084-22.0 COMBOBOX oCliProg:oPeriodo  VAR oCliProg:cPeriodo ITEMS aPeriodos;
               SIZE 100,NIL;
               OF oBar;
               FONT oFont;
               ON CHANGE oCliProg:LEEFECHAS()

  @ oCliProg:oPeriodo:nTop,080 SAY "Periodo:" OF oBar BORDER SIZE 34,24

  ComboIni(oCliProg:oPeriodo )

  @ 1.15, 078-3 GET oCliProg:oDesde  VAR oCliProg:dDesde PICTURE "99/99/9999";
                SIZE 76,23;
                OF   oBar;
                WHEN oCliProg:oPeriodo:nAt=LEN(oCliProg:oPeriodo:aItems);
                FONT oFont

  @ 1.15, 088-3 GET oCliProg:oHasta  VAR oCliProg:dHasta PICTURE "99/99/9999";
                SIZE 76,23;
                WHEN oCliProg:oPeriodo:nAt=LEN(oCliProg:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   @ 0.75, 126 BUTTON oCliProg:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               WHEN oCliProg:oPeriodo:nAt=LEN(oCliProg:oPeriodo:aItems);
               ACTION oCliProg:LEERDOCPRO(GetWhereAnd("DPG_FCHFIN",oCliProg:dDesde,oCliProg:dHasta),oCliProg:oBrw)


   oCliProg:oDesde:ForWhen(.T.)
   oCliProg:oBtn:Refresh(.T.)

   oCliProg:oBar:=oBar
   oBtnCal:bWhen:={|| !Empty(oCliProg:oBrw:aArrayData[1,1]) .AND. ;
                      !(oCliProg:oPeriodo:nAt=LEN(oCliProg:oPeriodo:aItems)) }


RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oCliProg:cCodInv,oCliProg:cCodInv)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCliProg:oPeriodo:nAt,cWhere

  IF oCliProg:oPeriodo:nAt=LEN(oCliProg:oPeriodo:aItems)

     oCliProg:oDesde:ForWhen(.T.)
     oCliProg:oHasta:ForWhen(.T.)
     oCliProg:oBtn  :ForWhen(.T.)

     DPFOCUS(oCliProg:oDesde)

  ELSE

     oCliProg:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCliProg:oDesde:VarPut(oCliProg:aFechas[1] , .T. )
     oCliProg:oHasta:VarPut(oCliProg:aFechas[2] , .T. )

     cWhere:=GETWHEREAND("DPG_FCHFIN",oCliProg:aFechas[1],oCliProg:aFechas[2])

     oCliProg:LEERDOCPRO(cWhere,oCliProg:oBrw)

  ENDIF

RETURN .T.

FUNCTION LEERDOCPRO(cWhere,oBrw)
   LOCAL aData:={},aTotal:={}
   LOCAL cSql,cCodSuc:=oDp:cSucursal

   cSql:=" SELECT DOC_TIPDOC,TDC_DESCRI,SUM(DOC_BASNET),SUM(DOC_MTOIVA),SUM(DOC_NETO),COUNT(*) AS CUANTOS FROM DPDOCPRO "+;
         " INNER JOIN DPTIPDOCPRO ON TDC_TIPO=DOC_TIPDOC "+;
         " WHERE DOC_ACT=1 AND DOC_TIPTRA='D' AND DOC_CODSUC"+GetWhere("=",cCodSuc)+;
         " "+IIF( Empty(cWhere),""," AND ")+cWhere+;
         " GROUP BY DOC_TIPDOC,TDC_DESCRI "+;
         " ORDER BY DOC_TIPDOC "

   aData:=ASQL(cSql)

   IF EMPTY(aData)
      AADD(aData,{"","",0,0,0,0})
   ENDIF

   IF ValType(oBrw)="O"
      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oBrw:aCols[3]:cFooter      :=TRAN( aTotal[3],"999,999,999,999.99")
      oBrw:aCols[4]:cFooter      :=TRAN( aTotal[4],"999,999,999,999.99")
      oBrw:aCols[5]:cFooter      :=TRAN( aTotal[5],"999,999,999,999.99")

      oBrw:aCols[6]:cFooter      :=TRAN( aTotal[6],"9999999")


      oBrw:Refresh(.T.)
      AEVAL(oCliProg:oBar:aControls,{|o,n| o:ForWhen(.T.)})
   ENDIF

RETURN aData

FUNCTION VERPROVEEDOR()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

   EJECUTAR("DPTIPDOCPROPRO",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.


FUNCTION VERPRODUCTO()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

   EJECUTAR("DPTIPDOCPROINV",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.

FUNCTION VERGRUPO()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

   EJECUTAR("DPTIPDOCPROGRU",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.

FUNCTION VERPERIODOS()
   LOCAL nAno:=YEAR(oCliProg:dDesde)
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]

   EJECUTAR("DPDOCPROVIEWPE",nPeriodo,nAno,cTipDoc)

RETURN .T.

/*
// Listar Documentos
*/
FUNCTION LISTARDOCS()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

   EJECUTAR("DPDOCPRODETVIEW",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.

FUNCTION VERCLASIFICA()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

  EJECUTAR("DPTIPDOCPROCLA",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.

FUNCTION VER_ACT_ECO()
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL nPeriodo:=oCliProg:oPeriodo:nAt

   EJECUTAR("DPTIPDOCACTECO",oCliProg:cCodSuc,cTipDoc,nPeriodo,oCliProg:dDesde,oCliProg:dHasta)

RETURN .T.

/*
// Visualizar Comparativos
*/
FUNCTION COMPARATIVOS()
   LOCAL cScope
   LOCAL cTipDoc :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,1]
   LOCAL cNombre :=oCliProg:oBrw:aArrayData[oCliProg:oBrw:nArrayAt,2]
   LOCAL cTitle  :="Valores Comparativos"

   cScope:="DOC_CODSUC "+GetWhere("=",oDp:cSucursal)+ " AND "+;
           "DOC_TIPDOC "+GetWhere("=",cTipDoc      )+ " AND "+;
           "DOC_TIPTRA='D' AND DOC_CXP<>0  AND DOC_ACT=1 "
 

   EJECUTAR("DPRUNCOMP","DPDOCPRO",cTipDoc,cNombre,cTitle,oCliProg:cPeriodo,cScope)

RETURN .T.
