// Programa   : DPCLIENTESALQ
// Fecha/Hora : 21/03/2006 22:47:01
// Propósito  : Cargar los Productos de Interes
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES
// Aplicación : Ventas
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,nOption)
 LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB
 LOCAL cTitle:="Productos de Alquiler "
 LOCAL cScope:="MOV_APLORG='A'"
 LOCAL cTipDoc:="ALQ"
 
  DEFAULT cCodCli:=STRZERO(1,10),;
          nOption:=2

  IF Empty(SQLGET("DPTIPDOCCLI","TDC_TIPO","TDC_TIPO"+GetWhere("=",cTipDoc)))

    EJECUTAR("DPTIPDOCCLI",1,cTipDoc)
    oTIPDOCCLI:oTDC_TIPO:VarPut(cTipDoc,.T.)
    oTIPDOCCLI:oTDC_DESCRI:VarPut("Productos en Alquiler",.T.)
    RETURN .F.

  ENDIF

  // Font Para el Browse
  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -12

  oCliAlq:=DOCENC(cTitle,"oCliAlq","DPCLIENTESAQL.EDT")
  oCliAlq:cCodCli:=cCodCli
  oCliAlq:cTipDoc:=cTipDoc
  
  oCliAlq:lBar:=.F.
  oCliAlq:lAutoEdit:=.T.
  oCliAlq:nOption  :=nOption
  oCliAlq:SetTable("DPCLIENTES","CLI_CODIGO"," WHERE CLI_CODIGO"+GetWhere("=",cCodCli))
  oCliAlq:cNombre:=oCliAlq:CLI_NOMBRE
  oCliAlq:Windows(0,0,410,790+90)

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT GetFromVar("{oDp:xDPCLIENTES}")+" [ "+ALLTRIM(oCliAlq:CLI_CODIGO)+" ]"
  @ 2,5 SAY oCLI_NOMBRE PROMPT oCliAlq:CLI_NOMBRE
	
  cSql :=" SELECT *  FROM DPMOVINV "+;
         " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO"

  oGrid:=oCliAlq:GridEdit( "DPMOVINV" , oCliAlq:cPrimary , "MOV_CODCTA" , cSql , cScope ) 

  oGrid:AddBtn("FACTURAPER.BMP","Facturación Periodica","oGrid:nOption=0",;
               [oGrid:FACTURAPER()])


  oGrid:cScript  :="DPCLIENTESALQ"
  oGrid:aSize    :={110-20,0,782+90,250}
  oGrid:oFont    :=oFontB
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.t.
  oGrid:cMetodo  :=""
 
  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
//oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:cPresave :="GRIDPRESAVE"

  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:nClrPane2:=11595007
  oGrid:nClrPane1:=14613246
  oGrid:nRecSelColor:=14671839 // 245500
  oGrid:nClrPaneH   :=14671839 // 245500


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
  oCol:nWidth:=249
  oCol:bWhen :=".F."
  oCol:bCalc :={||SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))}

  // Observación
  oCol:=oGrid:AddCol("MOV_CODCOM")
  oCol:cTitle:="Serial del Activo"
  oCol:nWidth:=180
  oCol:bValid   :={||oGrid:VALCODACT(oGrid:MOV_CODCOM)}
  oCol:cMsgValid:="Activo no Registrado"
  oCol:nWidth   :=160
  oCol:cListBox :="DPACTIVOS.LBX"
  oCol:lPrimary :=.T. // No puede Repetirse
  oCol:lRepeat  :=.F.
  oCol:nEditType:=EDIT_GET_BUTTON

  // Cantidad 
  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle:="Contador"
  oCol:nWidth:=100
  oCol:cPicture:="99,999,999"

  // Documento
  oCol:=oGrid:AddCol("MOV_DOCUME")
  oCol:cTitle:="Registro"
  oCol:nWidth:=80
  oCol:bWhen :=".F."

  // FechaDocumento
  oCol:=oGrid:AddCol("MOV_FECHA")
  oCol:cTitle:="Fecha"
  oCol:nWidth:=70
  oCol:bWhen :=".F."

//oCol:cPicture:="99,999,999"

  oCliAlq:oFocus:=oGrid:oBrw

  oCliAlq:Activate()

RETURN
// EOF

/*
// Carga los Datos
*/
FUNCTION LOAD()

   IF oCliAlq:nOption=1
     oGrid:MOV_FECHA :=oDp:dFecha
   ENDIF

   oGrid:MOV_APLORG:="A"
   oGrid:MOV_CODTRA:="S000"
   oGrid:MOV_CODALM:=oDp:cAlmacen
   oGrid:MOV_CODSUC:=oDp:cSucursal
   oGrid:MOV_CODCTA:=oCliAlq:cCodCli
   oGrid:MOV_USUARI:=oDp:cUsuario


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
    oGrid:MOV_DOCUME=oCliAlq:GetDocume()

    IF Empty(oGrid:MOV_DOCUME)
       RETURN .F.
    ENDIF

  ENDIF

  oGrid:MOV_TIPDOC:=oCliAlq:cTipDoc

RETURN .T.

/*
// Crea el Documento del Cliente
*/
FUNCTION GETDOCUME()
  LOCAL cNumero,oTable,oNew,oNew,cCodVen,cTipDoc:=oCliAlq:cTipDoc
  LOCAL aData  :=ASQL("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=","CTZ"))
  LOCAL aUsuari:={},cTipDes:="CTZ"

  cCodVen:=SQLGET("DPCLIENTES","CLI_CODVEN","CLI_CODIGO"+GetWhere("=",oCliAlq:cCodCli))

  IF Empty(cCodVen)

     MensajeErr("No hay "+oDp:xDPVENDEDOR+" Vinculado con "+oDp:xDPCLIENTES+" "+oCliAlq:cCodCli)
     cCodVen:=EJECUTAR("REPBDLIST","DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE")

     IF Empty(cCodVen)
        // oDp:xDPCLIENTES+" no tiene "+oDp:cDPVENDEDOR)
        RETURN ""
     ENDIF

     SQLUPDATE("DPCLIENTES","CLI_CODVEN",cCodVen,"CLI_CODIGO"+GetWhere("=",oCliAlq:cCodCli))


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

     oCliAlq:ASGTIPDOCIMP(cTipDoc,cTipDes,"")

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
  oNew:Replace("DOC_CODIGO" , oCliAlq:cCodCli  ) // Cliente
  oNew:Replace("DOC_CODVEN" , cCodVen)
  oNew:Replace("DOC_CODMON" , oDp:cMoneda)
  oNew:Replace("DOC_CENCOS" , oDp:cCenCos)
  oNew:Replace("DOC_USUARI" , oDp:cUsuario)
  oNew:Replace("DOC_TIPTRA" , "D"         )
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

/*
// Validar Codigo de Activo
*/
FUNCTION VALCODACT(cCodAct)
  local lRet:=.t.

  lRet:=(cCodAct==SQLGET("DPACTIVOS","ATV_CODIGO,ATV_ESTADO","ATV_CODIGO"+GetWhere("=",cCodAct)))

  IF !Empty(oDp:aRow)
    oGrid:cEstado:=oDp:aRow[2]
  ENDIF

RETURN lRet	
/*
// Facturación Periódica
*/
FUNCTION FACTURAPER()
   LOCAL cTitle
   LOCAL cWhere,oLbx

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPCLIENTEPROG}"))+;
           " ["+oCliAlq:cCodCli+" "+ALLTRIM(oCliAlq:cNombre)+" ]"

   cWhere:="DPG_CODIGO"+GetWhere("=",oCliAlq:cCodCli)

   oDp:aRowSql:={} // Lista de Campos Seleccionados
   oDpLbx:=TDpLbx():New("DPCLIENTEPROG.LBX",cTitle,cWhere)
   oDpLbx:uData1:=oCliAlq:cCodCli
   oDpLbx:uData2:=oCliAlq:cTipDoc
   oDpLbx:Activate()

RETURN .T.
// EOF







