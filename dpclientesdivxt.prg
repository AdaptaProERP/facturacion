// Programa   : DPCLIENTESDIVXTIP  
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Definición de Documentos para Importar
// Creado Por : Juan Navas
// Llamado por: DPTIPDOCCLI.LBX
// Aplicación : Ventas y CxC
// Tabla      : DPTIPDOCCLIIMP


#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc,cDescri)
  LOCAL cTitle
  LOCAL aData:={},I,oFontBrw,oFont,oBrw,oTable,oCol,cName:="cName"
  LOCAL aUsuari:={},aCodUsu:={},aDataTip:={},nAt

  DEFAULT cTipDoc:="FAV",cDescri:="Factura de Venta"

  aClafisica:={}

  aUsuari:=ASQL("SELECT OPE_NUMERO,OPE_NOMBRE FROM DPUSUARIOS")

  AADD(aUsuari,NIL)
  AINS(aUsuari,1)
  aUsuari[1]:={"  ","<Todos>"}

  AEVAL(aUsuari,{|a,n|AADD(aCodUsu,a[1]),aUsuari[n]:=a[2]})

  cTitle    :="Definir Importación de Productos "

  // Si tiene Versión Anterior puede Quedar sin Estos Valores

  IF MYCOUNT("DPTIPDOCCLI","TDC_PRODUC=1")=0  
     MensajeErr("No hay Tipos de Documentos definidos con Requerimiento de Productos")
     SQLUPDATE("DPTIPDOCCLI","TDC_PRODUC",.T.,"TDC_ALMACE=1 OR TDC_INVFIS<>0 OR TDC_INVLOG<>0 OR TDC_INVCON<>0")
  ENDIF

  aData:=ASQL(" SELECT TDC_TIPO  ,TDC_DESCRI,0 AS COL FROM DPTIPDOCCLI "+;
              " WHERE TDC_PRODUC=1")

  aDataTip:=ASQL("SELECT TIM_TIPIMP FROM DPTIPDOCCLIIMP "+;
                 " WHERE TIM_USUARI"+GetWhere("=","")+" AND  "+;
                 "       TIM_TIPDOC"+GetWhere("=",cTipDoc))

  AEVAL(aDataTip,{|a,n|aDataTip[n]:=a[1] })

  FOR I=1 TO LEN(aData)

     nAt:=ASCAN(aDataTip,aData[I,1])
     aData[I,3]:=nAt>0

  NEXT I

  IF Empty(aData)
     MensajeErr("No hay Documentos para Seleccionar con "+cTitle)
     RETURN .T.
  ENDIF

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0,-12
  DEFINE FONT oFont    NAME "Verdana" SIZE 0, -10 BOLD

  oDefImp:=DPEDIT():New(cTitle,"DPTIPDOCCLIIMP.EDT","oDefImp",.T.)

  oDefImp:cTipDoc:=cTipDoc
  oDefImp:lMsgBar:=.F.
  oDefImp:cDescri:=cDescri
  oDefImp:lTodos :=.F.
  oDefImp:aUsuari:=ACLONE(aUsuari)
  oDefImp:aCodUsu:=ACLONE(aCodUsu)
  oDefImp:cUsuari:=aUsuari[1]

  @ 0,0 GROUP oGrp TO 4, 70 PROMPT " Documento Destino "

  @ 0,0 SAY "Tipo:"        RIGHT     
  @ 1,0 SAY "Descripción:" RIGHT
  @ 2,0 SAY "Usuario:"     RIGHT

  @ 0,5 SAY oDefImp:cTipDoc 
  @ 1,5 SAY oDefImp:cDescri 

  @ 1,1 COMBOBOX oDefImp:oUsuari VAR oDefImp:cUsuari;
                 ITEMS oDefImp:aUsuari;
                 ON CHANGE oDefImp:LOADDATOS()

  @09, 33  SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XSALIR.BMP" NOBORDER;
           LEFT PROMPT "Cerrar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (EJECUTAR("DPBUILDWHERE"),oDefImp:Close())

  oDefImp:oBrw:=TXBrowse():New( oDefImp:oDlg )
  oDefImp:oBrw:SetArray( aData )

  oBrw:=oDefImp:oBrw
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Tipo"
  oCol:nWidth     := 40

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Descripción"
  oCol:nWidth       := 400

  oCol:=oBrw:aCols[3]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oDefImp:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,3],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oDefImp:SaveData(oDefImp)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oDefImp:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,3], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 14737632 ,  16777215  ) } }
  oBrw:bClrSel   := {|oBrw|oBrw:=oDefImp:oBrw, { 65535,  16733011}}

  oDefImp:oBrw:CreateFromCode()

  oBrw:bClrHeader := {|| { 0,  12632256}}

  oDefImp:Activate({|| oDefImp:oBrw:SetColor(0,16777215) , DPFOCUS(oDefImp:oBrw) , .F. })

RETURN NIL

/*
// Guardar Relación
*/
FUNCTION SaveData(oDefImp)
  LOCAL oBrw:=oDefImp:oBrw,oTable,cWhere,cCodUsu
  LOCAL nArrayAt,nRowSel
  LOCAL cTipDoc,cCodUsu,lSelect,cWhere
  LOCAL nCol:=3
  LOCAL lSelect

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]
  cCodUsu :=oDefImp:aCodUsu[oDefImp:oUsuari:nAt]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

  oTable  :=OpenTable("SELECT * FROM DPTIPDOCCLIIMP WHERE"         +;
                      " TIM_TIPDOC"+GetWhere("=",oDefImp:cTipDoc)+" AND "+;
                      " TIM_TIPIMP"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,1])+" AND "+;
                      " TIM_USUARI"+GetWhere("=",cCodUsu),.T.)

               
  cWhere:=oTable:cWhere       

  IF  oTable:RecCount()=0
     oTable:Append()
     cWhere:=""
  ENDIF

  oTable:Replace("TIM_TIPDOC",oDefImp:cTipDoc)
  oTable:Replace("TIM_TIPIMP",oBrw:aArrayData[oBrw:nArrayAt,1])
  oTable:Replace("TIM_SELECT",!lSelect)
  oTable:Replace("TIM_USUARI",cCodUsu )
  oTable:Commit(cWhere)
  oTable:End()

RETURN .T.

FUNCTION LOADDATOS()

   LOCAL aData,aDataTip,I,nAt

   oDefImp:cCodUsu :=oDefImp:aCodUsu[oDefImp:oUsuari:nAt]

   aData:=ASQL(" SELECT TDC_TIPO  ,TDC_DESCRI,0 AS COL FROM DPTIPDOCCLI "+;
               " WHERE TDC_PRODUC=1")

   aDataTip:=ASQL("SELECT TIM_TIPIMP FROM DPTIPDOCCLIIMP "+;
                  " WHERE TIM_USUARI"+GetWhere("=",oDefImp:cCodUsu)+" AND  "+;
                  "       TIM_TIPDOC"+GetWhere("=",oDefImp:cTipDoc))

   AEVAL(aDataTip,{|a,n|aDataTip[n]:=a[1] })

   FOR I=1 TO LEN(aData)

     nAt:=ASCAN(aDataTip,aData[I,1])
     aData[I,3]:=nAt>0

   NEXT I

   oDefImp:oBrw:aArrayData:=ACLONE(aData)
   oDefImp:oBrw:Refresh(.F.)

RETURN .T.


// EOF





