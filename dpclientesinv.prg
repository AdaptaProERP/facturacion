// Programa   : DPCLIENTESINV
// Fecha/Hora : 21/03/2006 22:47:01
// Propósito  : Cargar los Productos de Interes
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación : Ventas
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,nOption)
 LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB
 LOCAL cTitle:="Productos de Interés "
 LOCAL cScope:="MOV_APLORG='V'"

 DEFAULT cCodCli:=STRZERO(1,10),;
         nOption:=2

// para el "+GetFromVar("{oDp:xDPCLIENTES}")


 // Font Para el Browse
 DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

 oCliInv:=DOCENC(cTitle,"oCliInv","DPCLIENTESINV.EDT")
 oCliInv:cCodCli:=cCodCli
 oCliInv:cTipDoc:="PDI"

 oCliInv:lBar:=.F.
 oCliInv:lAutoEdit:=.T.
 oCliInv:nOption  :=nOption
 oCliInv:SetTable("DPCLIENTES","CLI_CODIGO"," WHERE CLI_CODIGO"+GetWhere("=",cCodCli))
 oCliInv:Windows(0,0,410,790+200)

 @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT GetFromVar("{oDp:xDPCLIENTES}")+" [ "+ALLTRIM(oCliInv:CLI_CODIGO)+" ]"
 @ 2,5 SAY oCLI_NOMBRE PROMPT oCliInv:CLI_NOMBRE
	
 cSql :=" SELECT *  FROM DPMOVINV "+;
        " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO"

  oGrid:=oCliInv:GridEdit( "DPMOVINV" , oCliInv:cPrimary , "MOV_CODCTA" , cSql , cScope ) 

  oGrid:cScript  :="DPCLIENTESINV"
  oGrid:aSize    :={110-20,0,782+90+90,250}
  oGrid:oFont    :=oFontB
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.t.
  oGrid:cMetodo  :=""

  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
//oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:cPresave :="GRIDPRESAVE"

  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:nClrPane2:=oDp:nClrPane2
  oGrid:nClrPane1:=oDp:nClrPane1
  oGrid:nRecSelColor:=oDp:nLbxClrHeaderPane // 245500
  oGrid:nClrPaneH   :=oDp:nLbxClrHeaderPane // 245500


  oGrid:SetMemo("MOV_NUMMEM","Comentarios",1,1,100,200)

  // Unidad de medida
  oCol:=oGrid:AddCol("MOV_CODIGO")
  oCol:cTitle   :="Producto"
  oCol:lPrimary :=.T. // No puede Repetirse
  oCol:bValid   :={||oGrid:VMOV_CODIGO(oGrid:MOV_CODIGO)}
  oCol:cMsgValid:="Producto no Existe"
  oCol:nWidth   :=160
  oCol:cListBox :="DPINV.LBX"
  oCol:lPrimary :=.T. // No puede Repetirse
  oCol:bPostEdit:='oGrid:ColCalc("INV_DESCRI")'
  oCol:lRepeat  :=.F.
  oCol:nEditType:=EDIT_GET_BUTTON

  // Descripción
  oCol:=oGrid:AddCol("INV_DESCRI")
  oCol:cTitle:="Descripción"
  oCol:nWidth:=249+190
  oCol:bWhen :=".F."
  oCol:bCalc :={||SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))}

  // Observación
  oCol:=oGrid:AddCol("MOV_CODCOM")
  oCol:cTitle:="Comentario"
  oCol:nWidth:=150

  oCol:=oGrid:AddCol("MOV_UNDMED")
  oCol:cTitle    :="Medida"
  oCol:nWidth    :=60+5
  oCol:aItems    :={||oGrid:BuildUndMed(.T.)}
  oCol:aItemsData:={||oGrid:BuildUndMed(.F.)}

  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle    :="Cantidad"
  oCol:nWidth    :=110


/*
  // Unidad de Medida
  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle:="Cantidad"
  oCol:nWidth:=110
  oCol:cPicture:="99,999,999.99"
  oCliInv:oFocus:=oGrid:oBrw
*/
  oCliInv:Activate()

RETURN
// EOF

/*
// Carga los Datos
*/
FUNCTION LOAD()

   IF oCliInv:nOption=1
     oGrid:MOV_FECHA :=oDp:dFecha
   ENDIF

   oGrid:MOV_APLORG:="V"
   oGrid:MOV_CODTRA:="S000"
   oGrid:MOV_CODALM:=oDp:cAlmacen
   oGrid:MOV_CODSUC:=oDp:cSucursal
   oGrid:MOV_CODCTA:=oCliInv:cCodCli
   oGrid:MOV_USUARI:=oDp:cUsuario
   oGrid:MOV_INVACT:=1
   oGrid:MOV_TIPO  :='I'

RETURN .T.

/*
// Ejecuta la Impresión del Documento
*/
FUNCTION PRINTER()
RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION PREDELETE()
RETURN .T.

/*
// Después de Borrar
*/
FUNCTION POSTDELETE()
RETURN .T.

/*
// Valida Unidad de Medida
*/
FUNCTION VFOR_UNDMED(cUndMed)
  LOCAL lRet:=.T.

  lRet:=(cUndMed==SQLGET("DPUNDMED","UND_CODIGO","UND_CODIGO"+GetWhere("=",cUndMed)))

RETURN lRet

/*
// Carga para Incluir o Modificar en el Grid
*/
FUNCTION GRIDLOAD()
RETURN NIL

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()
RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
RETURN .T.


/*
// Construye las Opciones
*/
FUNCTION BuildUndMed(lData)
  LOCAL aItem:={}

  aItem:=EJECUTAR("INVGETUNDMED",oGrid:MOV_CODIGO,NIL,oGrid:cMetodo,oGrid,.T.)

  IF EMPTY(oGrid:MOV_UNDMED).AND.!Empty(aItem)
     oGrid:Set("MOV_UNDMED",aItem[1])
  ENDIF

RETURN aItem

FUNCTION VMOV_CODIGO(cCodigo)
  local lRet:=.t.

  lRet:=(cCodigo==SQLGET("DPINV","INV_CODIGO,INV_METCOS","INV_CODIGO"+GetWhere("=",cCodigo)))

  IF !Empty(oDp:aRow)
    oGrid:cMetodo:=oDp:aRow[2]
  ENDIF

RETURN lRet

FUNCTION GRIDPRESAVE()

  IF oGrid:nOption=1
     oGrid:MOV_FECHA:=oDp:dFecha
  ENDIF

  // Crea el Numero del Documento del Cliente
  IF Empty(oGrid:MOV_DOCUME) .OR. .T.
    oGrid:MOV_DOCUME=oCliInv:GetDocume()

    IF Empty(oGrid:MOV_DOCUME)
       RETURN .F.
    ENDIF

// ? oGrid:MOV_DOCUME,"oGrid:MOV_DOCUME"

  ENDIF

  oGrid:MOV_APLORG:="V"
  oGrid:MOV_CODTRA:="S000"
  oGrid:MOV_CODALM:=oDp:cAlmacen
  oGrid:MOV_CODSUC:=oDp:cSucursal
  oGrid:Set("MOV_CODCTA",oCliInv:cCodCli)
  oGrid:MOV_USUARI:=oDp:cUsuario
  oGrid:MOV_INVACT:=1
  oGrid:Set("MOV_TIPO"  ,'I')
  oGrid:Set("MOV_IVA"   ,'GN')
  oGrid:Set("MOV_ITEM"  ,STRZERO(1,5))
  oGrid:Set("MOV_TIPDOC",oCliInv:cTipDoc)
  oGrid:Set("MOV_CENCOS",oDp:cCenCos)

RETURN .T.

/*
// Crea el Documento del Cliente
*/
FUNCTION GETDOCUME()
  LOCAL cNumero,oTable,oNew,oNew,cCodVen,cTipDoc:=oCliInv:cTipDoc
  LOCAL aData  :=ASQL("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=","CTZ"))
  LOCAL aUsuari:={},cTipDes:="CTZ"

  cCodVen:=SQLGET("DPCLIENTES","CLI_CODVEN","CLI_CODIGO"+GetWhere("=",oCliInv:cCodCli))

  IF Empty(cCodVen)

     MensajeErr("No hay "+oDp:xDPVENDEDOR+" Vinculado con "+oDp:xDPCLIENTES+" "+oCliInv:cCodCli)
     cCodVen:=EJECUTAR("REPBDLIST","DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE")

     IF Empty(cCodVen)
        // oDp:xDPCLIENTES+" no tiene "+oDp:cDPVENDEDOR)
        RETURN ""
     ENDIF

     SQLUPDATE("DPCLIENTES","CLI_CODVEN",cCodVen,"CLI_CODIGO"+GetWhere("=",oCliInv:cCodCli))


  ENDIF

  oTable:=OpenTable("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=",cTipDoc),.T.)
 
  IF oTable:RecCount()=0

     oTable:AppendBlank()
     oTable:cWhere:=""

     IF !Empty(aData)
       AEVAL(oTable:aFields,{|a,n| oTable:FieldPut(n,aData[1,n]) })
     ENDIF

     oTable:Replace("TDC_TIPO"  ,cTipDoc)
     oTable:Replace("TDC_DESCRI","Productos de Interés")
     oTable:Replace("TDC_CODCTA",oDp:cCtaIndef)
     oTable:Replace("TDC_DOCDES",cTipDes) // Documento Destino
     oTable:Replace("TDC_CXC"   ,"N")

     oTable:Commit()

     aUsuari:=ASQL("SELECT OPE_NUMERO FROM DPUSUARIOS")

     oCliInv:ASGTIPDOCIMP(cTipDoc,cTipDes,"")

  ENDIF

  oTable:End()

  cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                                  "DOC_TIPDOC"+GetWhere("=",cTipDoc))

  oNew:=OpenTable("SELECT * FROM DPDOCCLI",.F.)

  oNew:Replace("DOC_CODSUC" , oDp:cSucursal)
  oNew:Replace("DOC_NUMERO" , cNumero   )
  oNew:Replace("DOC_FECHA " , oDp:dFecha)
  oNew:Replace("DOC_FCHVEN" , oDp:dFecha)
  oNew:Replace("DOC_ACT"    , 1       )
  oNew:Replace("DOC_CXC"    , 0       )
  oNew:Replace("DOC_TIPDOC" , cTipDoc )
  oNew:Replace("DOC_ESTADO" , "AC"             ) // Estado
  oNew:Replace("DOC_CODIGO" , oCliInv:cCodCli  ) // Cliente
  oNew:Replace("DOC_CODVEN" , cCodVen     )
  oNew:Replace("DOC_CODMON" , oDp:cMoneda )
  oNew:Replace("DOC_CENCOS" , oDp:cCenCos )
  oNew:Replace("DOC_USUARI" , oDp:cUsuario)
  oNew:Replace("DOC_TIPTRA" , "D"         )
  oNew:Replace("DOC_DOCORG" , "V"         )
  oNew:Commit()

RETURN cNumero

FUNCTION ASGTIPDOCIMP(cTipDoc,cTipDes,cCodUsu)

  LOCAL oTable
  LOCAL cWhere

  oTable  :=OpenTable("SELECT * FROM DPTIPDOCCLIIMP WHERE "         +;
                      " TIM_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                      " TIM_TIPIMP"+GetWhere("=",cTipDes)+" AND "+;
                      " TIM_USUARI"+GetWhere("=",cCodUsu),.T.)

               
  cWhere:=oTable:cWhere   

  IF  oTable:RecCount()=0
     oTable:Append()
     cWhere:=""
  ENDIF

  oTable:Replace("TIM_TIPDOC",cTipDes)
  oTable:Replace("TIM_TIPIMP",cTipDoc)
  oTable:Replace("TIM_SELECT",.t.)
//oTable:Replace("TIM_USUARI",cCodUsu )
  oTable:Commit(cWhere)
  OTable:End()

RETURN .T.


// EOF







