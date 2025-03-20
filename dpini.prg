// Programa   : DPINI
// Fecha/Hora:  02/01/2003 13:15:55
// Prop?sito  : Carga Inicial DpWin32
// Creado Por : Juan Navas
// Llamado por: DPNMWIN
// Aplicaci?n : Inicio
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "INKEY.CH"

#INCLUDE "DPXBASE.CH"
#INCLUDE "INKEY.CH"

FUNCTION DPINI(lConfig)
  LOCAL nAt,aOdbc,cPc
  LOCAL cFile:="SOUNDS\adaptapro.wav"
  LOCAL oData,oReg,cKey,cDirDll,oDb:=OpenOdbc(oDp:cDsnConfig)

  oDp:cOs:=GETENV("OS")

  DEFAULT lConfig:=.F.

  oDp:aSiglasEmp:={"C.A.","S.R.L.","S.A.","S.A.I.C.A.","S.C."}
  oDp:aSiglaEmp :={"CA" ,"SRL","SA","SAICA","SC"}


  // Desactiva la ejecución de este programa MYSQLCHKCONN
  oDp:lMYSQLCHKCONN:=.F. // MYSQLCHKCONN

  //KillProcessByName("DPCRPE.EXE") // 29/09/2023

  oDp:cDpProgra:=IF(ISPCPRG(),"DPPROGRA","DPMYPROGRA")
  oDp:cTipCon  :=""

  // Respuesta Factura Digital
  oDp:nFavD_Seconds  :=0
  oDp:oFavD_Ole      :=NIL // Conector
  oDp:cFavD_Ret      :=""  // Respuesta Impresora Fiscal
  oDp:cFavD_Send     :=""
  oDp:cFavD_Param    :=""
  oDp:cFavD_cToken   :=""
  oDp:cFavD_Authoriza:="Bearer "  // Pre-fijo del token https://keepcoding.io/blog/token-bearer-guia-para-desarrolladores/
  oDp:cFavD_cPrg     :=""         // Programa DpXbase
  oDp:cFavD_oDpXbase :=NIL        // Compilado
  oDp:cFavD_cUrl     :=""         // URL    
  oDp:cFavD_cAction  :="" // "/facturacion" ->NOVUS   //   ../anulacion   ../email
  oDp:cFavD_Version  :="" // "/v3" ->NOVUSS

  oDp:dFchInt:={|dFecha|SQLGET("NMTASASINT","INT_HASTA","INT_TASA>0 ORDER BY INT_HASTA DESC LIMIT 1")}

  oDp:aFieldUpdateDpX:={}

  oDp:aDataBases:=MyGetDataBases() // necesario para MYSQLCHKCONN 
 
  oDp:cPictureDivisa:="999,999,999.99999"
  lmkdir("bematech")
  lmkdir("trazasql")


//  IF COUNT("DPPCLOG")=1 .OR. oDp:cRif="V06196585"
//     SQLUPDATE("DPUSUARIOS","OPE_ALLPC",.T.)
//  ENDIF

  // EN EL CASO DE INSTALADOR SERVICE PACK REMOVERA LOS RELEASE DESCARGADOS
  IF FILE("DP\SERVICEPACK.TXT")
    EJECUTAR("DPDELDICCDAT",.T.)
    FERASE("DP\SERVICEPACK.TXT")
  ENDIF

  // 12/01/2023
  // migrado hacia DPINIADDFIELD EJECUTAR("DPFILEXPCCHK")
  PUBLICO("CRLF",CRLF)
  
  oDp:lConEsp   :=.F. // contribuyente especial
  oDp:oTableDocFlow:=NIL

  oDp:aInsertDef:=ASQL([SELECT RTRIM(CAM_TABLE),RTRIM(CAM_NAME),RTRIM(CAM_DEFAUL) FROM DPCAMPOS WHERE CAM_DEFAUL<>"" ORDER BY CAM_TABLE,CAM_NAME])

IF .F.
  // 14/09/2023 tiempo de procesamiento innecesario
  AEVAL(DIRECTORY("CRYSTAL\*.DBF"),{|a,n| FERASE("CRYSTAL\"+a[1])})
  AEVAL(DIRECTORY("CRYSTAL\*.FPT"),{|a,n| FERASE("CRYSTAL\"+a[1])})
  AEVAL(DIRECTORY("CRYSTAL\*.CDX"),{|a,n| FERASE("CRYSTAL\"+a[1])})
ENDIF

/*
28/01/2025
  IF !ISPCPRG()
    EJECUTAR("DELDIRADPTMP")     // Remueve Carpetas temporales 26/09/2023
  ENDIF
*/

  EJECUTAR("FILETEMPERRTOSOP") // Incidencias técnicas sera reportadas hacia la oficina virtual
  EJECUTAR("DPINIDELTEMPDXBX")

  IF ISPCPRG() 
     FERASE("DP\LICENSE.TXT")
  ENDIF

  IF COUNT("DPREPORTES")=0
 
    IF FILE("DATADBF\DPREPORTES.DBF")
      IMPORTDBF32("DPTABLAS","DATADBF\DPTABLAS.DBF",oDp:cDsnConfig,oDp:oSay,.T.,.T.)
    ELSE
      cPc:=SQLGET("DPPCLOG","PC_NOMBRE","PC_ISDICD=1")
      MensajeErr("Es necesario Realizar Importar Reportes desde el PC "+cPc+" Contentivo del Diccionario Virtual")
    ENDIF

  ENDIF

  RDDSETDEFAULT("DBFCDX")

  oDp:lUpdate:=GETINI("DATAPRO.INI","UPDATE","L")   // Descarga AdaptaPro Server
  oDp:lUpdate:=IIF( Empty(oDp:lUpdate) , .F. , CTOO(oDp:lUpdate,"L") )

  // 04/10/2023 Ejecuta los programas DpXbase en las Vistas
  oDp:lRunPrgView:=GETINI("DATAPRO.INI","RUNPRGVIEW","L")
  oDp:lRunPrgView:=IIF( ValType(oDp:lRunPrgView)="L", oDp:lRunPrgView , .T.)

  oDp:aTablasChk:={} // Tablas
  oDp:aVistasChk:={} // Vistas
  oDp:lPanel    :=.F. 
  oDp:cDbDepura :=""
  oDp:lLock     :=.F.
  oDp:lLoadCnf  :=.F.
  oDp:oMsgRun   :=NIL
  oDp:cPeriodo  :=""
  oDp:lColegio  :=.F. // PlugIn Colegio Activo
  oDp:lConfid   :=.F. // Nómina confidencial tabla NMCARGOS
  oDp:cTipoNom  :=NIL // detectar si nómina fue seleccionada
  oDp:lAutoRif  :=.F. // Validación del RIF
  oDp:lCliToRif :=.F. // Copiar Clientes  hacia RIF
  oDp:lProToRif :=.F. // Copiar Proveedor hacia RIF

  oDp:lImpFisModVal:=NIL // impresora fiscal en modo validación
  oDp:RepBdList_nWidth:=0 // Ancho

  oDp:cTipDocClb:="CUO"
  oDp:cTipDocAlq:="ALQ"
  oDp:cTipDocTra:="TRA"
  oDp:cTipDocClg:="CUO"     // Cuotas de Colegio
  oDp:cClgCodIns:=SPACE(20) // Código de Inscripción


  oDp:lCatorcenal:=NIL

  // subtitulo utilizado Programa CREATEHEAD para crear sub-titulos para reportes de crystal report
  oDp:cSubTitulo1:=""
  oDp:cSubTitulo2:=""
  oDp:cSubTitulo3:=""



  oDp:lEmanager   :=.F.
  oDp:cCodServer  :=""
  oDp:nIdEmanager :=0
  oDp:cTipEmanager:=""
  oDp:cPicture    :=""
  oDp:lLoadCnf    :=.F. // no ha sido ejecutado DPLOADCNF evitar ser ejecutado varias Veces

  PUBLICO("RGO_C1",NIL)
  PUBLICO("RGO_C2",NIL)
  PUBLICO("RGO_C3",NIL)
  PUBLICO("RGO_C4",NIL)
  PUBLICO("RGO_C5",NIL)
  PUBLICO("RGO_C6",NIL)
  PUBLICO("RGO_C7",NIL)
  PUBLICO("RGO_C8",NIL)
  PUBLICO("RGO_C9",NIL)
  PUBLICO("RGO_C10",NIL)
  PUBLICO("RGO_C11",NIL)
  PUBLICO("RGO_C12",NIL)
  PUBLICO("RGO_C13",NIL)

  PUBLICO("RGO_I1",NIL)
  PUBLICO("RGO_I2",NIL)
  PUBLICO("RGO_I3",NIL)
  PUBLICO("RGO_I4",NIL)
  PUBLICO("RGO_I5",NIL)
  PUBLICO("RGO_I6",NIL)
  PUBLICO("RGO_I7",NIL)
  PUBLICO("RGO_I8",NIL)
  PUBLICO("RGO_I9",NIL)
  PUBLICO("RGO_I10",NIL)
  PUBLICO("RGO_I11",NIL)
  PUBLICO("RGO_I12",NIL)
  PUBLICO("RGO_I13",NIL)

  PUBLICO("RGO_F1",NIL)
  PUBLICO("RGO_F2",NIL)
  PUBLICO("RGO_F3",NIL)
  PUBLICO("RGO_F4",NIL)
  PUBLICO("RGO_F5",NIL)
  PUBLICO("RGO_F6",NIL)
  PUBLICO("RGO_F7",NIL)
  PUBLICO("RGO_F8",NIL)
  PUBLICO("RGO_F9",NIL)
  PUBLICO("RGO_F10",NIL)
  PUBLICO("RGO_F11",NIL)
  PUBLICO("RGO_F12",NIL)
  PUBLICO("RGO_F13",NIL)

  oDp:aAcentos:={}

  LMKDIR("MYFORMS")
  LMKDIR("SCRIPT_BAK") // copia de los programas fuentes

  EJECUTAR("DELDXBXMULTI")
 
  MSGRUNVIEW("Iniciando Sistema","Leyendo Parámetros",0,.F.)
  //oDp:oMsgRun:oWnd:HIDE()
  DpMsgHide()

  oDp:lDataCrea :=.F. // Crear datos


  oDp:lTracerSql:=.F.

  oDp:cLocalRecover:=""
  oDp:aCoors:=GetCoors( GetDesktopWindow() )

  oDp:lMenuLbx      :=.T. // Permiso para opciones del Menú LBX
  oDp:lCrearTablas  :=.T. // Crear vistas
  oDp:lIndFin       :=.F.
  oDp:nBemaDll      :=NIL // 18/08/2024 Será cerrado en DPFIN, 

  DEFAULT oDp:lSaveSqlFile  :=.F. 

  oDp:cIpLocal    :=GETHOSTBYNAME() // Necesaria en DPDATACNF

  PUBLICO("oDpCom",TPublic():New( .T. ))
  PUBLICO("oDpVta",TPublic():New( .T. ))

  // Diccionario de datos para los indicadores financieros
  PUBLICO("oFRX",NIL)

  // SQLUPDATE("DPTABLAS","TAB_DSN",".CONFIGURACION","TAB_DSN"+GetWhere("=","ADMCONFIG51"))

  EJECUTAR("DPLOADCNFCHKFCH") // Fecha de Revisión de la BD

/*
10/01/2025
  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPEMPRESA","EMP_CODSAS")
    EJECUTAR("DPAFILIASAS_CREA")
  ENDIF

*/
  EJECUTAR("DPINIADDFIELD") // 30/06/2017 Agregar Nuevos Campos en DICCIONARIO DE DATOS

  IF COUNT("DPINTREF","INT_BD"+GetWhere("=",oDp:cDsnConfig))>0

      MsgRun("Reparando Tablas de BD "+oDp:cDsnConfig,"Procesando",{||EJECUTAR("INTREFFIXFIELD",oDp:cDsnConfig)})

      IF COUNT("DPINTREF","INT_BD"+GetWhere("=",oDp:cDsnConfig))>0

      ENDIF

  ENDIF

  EJECUTAR("DPREADDPSTD") // 27/10/2016 Recuperar Componentes DPSTD Previamente guardados en DPDIRAPL (Nota:2055)
  EJECUTAR("GETDEFAULTALL") 

// oDp:lTracer:=.F.
// oDp:cFileToScr:="C:\X\X.TXT"

  oDp:aAplAuditar:={}  // Utilizado por DPTASK Auditar solo las Aplicaciones que necesita Registrar

  oDp:lMsgErrGetProce:=.F.     // No muestra la traza GETPROCE() en MensajeErr()

  EJECUTAR("SQLDB_UPDATECNF")

  EJECUTAR("SETLANGUAGE")

  oDp:aPeso:={}

  oDp:cNit:="RIF"

  AADD(oDp:aPeso,{"NI","Ninguno" ,0    })
  AADD(oDp:aPeso,{"GR","Gramo"   ,1/100})
  AADD(oDp:aPeso,{"KG","Kilo"    ,1    })
  AADD(oDp:aPeso,{"TN","Tonelada",1000 })

  // JN 12/05/2016, Menu y Barra de botones segun DATAPRO.INI 24/05/2018 Migrado DPINIADD
//  EJECUTAR("DPBOTBARNEW")
//  EJECUTAR("DPMENUNEW")

  // No realiza Revisión de Integridad Referencial
  oDp:lChkIntRef :=GETINI("DATAPRO.INI","CHKINTREF")
  oDp:lChkIntRef  :=IIF( Empty(oDp:lChkIntRef) , .F. , CTOO(oDp:lChkIntRef ,"L") )

  oDp:lCheckNull :=GETINI("DATAPRO.INI","CHECKNULL")
  oDp:lCheckNull :=IIF( Empty(oDp:lCheckNull) , .F. , CTOO(oDp:lCheckNull ,"L") )

  oDp:lDropAllView:=GETINI("DATAPRO.INI","DROPALLVIEW")
  oDp:lDropAllView:=IIF( Empty(oDp:lDropAllView) , .F. , CTOO(oDp:lDropAllView ,"L") )

  oDp:lCreateView:=GETINI("DATAPRO.INI","CREATEVIEW")
  oDp:lCreateView:=IIF( Empty(oDp:lCreateView) , .T. , CTOO(oDp:lCreateView ,"L") )

  oDp:cCodServer :=""  // Servidor Remoto Segun Empresa
  // oDp:aInsertDef :={}
  oDp:aMapaCampos:={}
  oDp:lEmanager  :=.F. // 16/02/2016 Lee desde EMP_EMANAGER, para almacenar en la tabla DPPANELERPEMP, el resultado de eManager
//oDp:lChkIntRef :=.F. // No revisa Integridad Referencial METHOD CreaRegIntRef() INLINE EJECUTAR("DPCREAREGINTREF",SELF) 13/11/2016
  oDp:lLabel     :=.F. // No restaura el contenido de etiquetas SAY registrada en formulario forms\forms.edt, requiere Repinta el Contenido en Caso de @ 0,0 SAY oSay PROMPT "Texto"
  oDp:lRunDefault:=.T. // 15/04/2016 Los formularios Asumen valores por defecto definidos en los campos.


//EJECUTAR("DPINIEM")       // Iniciar Variables para eManager JN 20/03/2016

  IF !ISDPSTD()
     oDp:cFileSource:=""
  ENDIF

  //6x
  oDp:lFin      :=.F.
  oDp:cRunServer:=NIL
  oDp:cNumEje   :="" // Número de Ejercicios
  oDp:nWndTop   :=90

  oDp:aMeses :={"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"} 

  DEFAULT oDp:lNomina:=.F.

  // Programas que no sera Mostrados en la Traza de Ejecución 6x
  oDp:cScrNoTracer:="DPTRAZASQL,TTABLEINSERT,DPERRSQLINSERT,BRWLOSTFOCUS,BRWGOTFOCUS,GRIDLOSTFOCUS,GRIDGOTFOCUS,DOCGRIDLOSTFOCUS,MYSQLCHKCONN"


  // Titulo para la funcion MsgNoYes
  oDp:cMsgNoYes   :="Seleccione Una Opción"
  oDp:cTableDpFile:="DPFILEEMP"
  oDp:nMySeconds  :=(60*60)*1  // Cantidad de Segundos para realizar Reconección de MySql
  oDp:cNumPro     :=""         // número de proceso Contable

  // Indica si el usuario tiene datos encriptados
  oDp:lUsEncript  :=.T.


  // Si la licencia adquirida posee contabilidad. Con el fin de inhabilitar todo 6x
  // lo referente a contabilidad configuracion de empresa, formularios, etc
  oDp:lContab:=.T.


  IF Valtype(oDp:lUpdate)="L" .AND. oDp:lUpdate .AND. !lConfig
    EJECUTAR("DPSVRDOWN")   
  ENDIF

  // Recuperar Actualizaciones
  EJECUTAR("DPPERSONALIZREC")
// DPINIADDFIELD  EJECUTAR("DPCREASTRUCT")
// DPINIADDFIELD  EJECUTAR("DPCONFIGCHK") // Revisa Estrctura e Integridad Referencial BD DPCONFIG

  // Revisa si Hay Actualizaciones del Sistema
//EJECUTAR("DPAADONCREA")
  EJECUTAR("DPADDPLUGIN")
//EJECUTAR("AAACHKUPDATE")
  EJECUTAR("DPLOADPICTURE")

  lMkDir("TEMP")
  lMkDir("USER")

  // 
  // Valor Utilizado por TTABLE:Commit(), para asumir los valores del campos con integridad referencial
  // Caso: DPDOCCLI,DOC_CODTER,oDp:cCodTer . Este contenido asume por defecto el valor del campo en caso
  // de estar vacio. Evita rechazo SQL por Integridad Referencial
  // 

  // oDp:aInsertDef:={}

/*
  cKey:="Volatile Environment"
  oReg    := TReg32():New(HKEY_CURRENT_USER, cKey )
  oDp:cHomeDrive := GetEnv("HOMEDRIVE")
  oDp:cHomePath  := GetEnv("USERPROFILE")
  oReg:Close()
*/

  // Carpeta FTP
  oDp:cFtpDir    :="www/dpsge-v4"
  oDp:cSysDp     :=oDp:cType // "SGE"

// oData:End()

/*
// Ingreso del Usuario, Seleccionar Empresa. Su valor es almacenado en DPSELEMPINI    
*/

  EJECUTAR("DPINIERP")

  oData:=DATACNF("GETUSUARIO","PC")
  oDp:lIniSelEmp:=oData:Get("lIniSelEmp" ,.F.)
  oData:End()

  oData:=DATACONFIG("POS","PC")

  IF FILE(cFile) .AND. !oData:Get("cSound","")="O"
     oData:Set("cSound","O")
     oData:Save()
     oData:End(.T.)
     SndPlaySound( cFile,1 )
     SysRefresh(.T.)
  ENDIF

  oData:End()

  IF !FILE(oDp:cFileDll) 
    oDp:cFileDll:="c:\WINDOWS\System32\CRPE32.DLL"
  ENDIF
 
  IF !FILE(oDp:cFileDll) 
    oDp:cFileDll:="c:\winnt\System32\CRPE32.DLL"
  ENDIF

  IF !FILE(oDp:cFileDll) 
    oDp:cFileDll:="c:\Windows\SysWOW64\CRPE32.DLL"
  ENDIF

  IF !FILE(oDp:cFileDll) 
    oDp:cFileDll:="c:\Windows\SysWOW64\CRPE32.DLL"
  ENDIF

  // JN 16/07/2019
  // Implementacion, Buscar DLL en carpeta Windows, caso de 64 Bits

  IF !FILE(oDp:cFileDll) 

     oData  :=DATACNF("CRPE32","ALL")
     cDirDll:=oData:Get("DIRDLL" ,"")

     IF !Empty(cDirDll)
       cDirDll     :=STRTRAN(cDirDll,"\"+"\","\")
       oDp:cFileDll:=cDirDll+"\CRPE32.DLL"
     ENDIF

     oData:End()

  ENDIF


  IF !FILE(oDp:cFileDll) 

     cDirDll:=EJECUTAR("FINDCRPE32DLL2",NIL,"CRPE32.DLL")

     IF !Empty(cDirDll)

        oDp:cFileDll:=cDirDll+"\CRPE32.DLL"

        oData:=DATACNF("CRPE32","ALL")
        oData:Set("DIRDLL" ,cDirDll)
        oData:Save()
        oData:End()

     ELSE

       EJECUTAR("DLLCRYSTALDOWNLOAD")

       IF !FILE(oDp:cFileDll)
         EJECUTAR("INSTALLCRYSTAL_DLL")
         // Ejecuta el Programa Instalador
       ENDIF

     ENDIF

  ENDIF

  IF !FILE(oDp:cFileDll) 

     MensajeErr("Archivo :"+oDp:cFileDll+" de Crystal Report no Existe"+CRLF+;
                "no será posible emitir Reportes de Crystal"+CRLF+"Recomendación: Instalar Crystal Report" )

  ENDIF

  // Fin de la Implementación
  // JN 16/07/2019

//  oDp:lMySqlNativo:=.T.

// 10-09-2008 Marlon Ramos (Impresoras Fiscales configuradas)
     oDp:aImprFiscEps:={"Epson TMU220AF","Epson PF-220","Epson PF-300"}
     oDp:aImprFiscBem:={"Bematech MP-20 FI II","Bematech MP-2100 TH FI"}
     oDp:aImprFiscBmc:={"BMC Spark614","BMC Camel","SAMSUNG","ACLAS PP1F3","OKIDATA ML1120","STAR HSP-7000"}
// Fin 10-09-2008 Marlon Ramos 

  oDp:Btn_New    :="BITMAPS\NEW.BMP"        // Incluir  (Nuevo)
  oDp:Btn_Open   :="BITMAPS\EDIT.BMP"       // Abrir    (Modificar)
  oDp:Btn_Save   :="BITMAPS\SAVE.BMP"       // Grabar   (Grabar)
  oDp:Btn_Run    :="BITMAPS\RUN.BMP"        // Ejecutar (Grabar)
  oDp:Btn_Close  :="BITMAPS\SHUTDOWN.BMP"   // Cerrar   (Cerrar)
  oDp:Btn_Print  :="BITMAPS\xPRINT.BMP"     // Impresi?n(Imprimir)
  oDp:Btn_Cut    :="BITMAPS\CUT.BMP"        // Cortar
  oDp:Btn_Paste  :="BITMAPS\PASTE.BMP"      // Pegar
  oDp:Btn_UnDo   :="BITMAPS\UNDOE.BMP"      // Deshacer
  oDp:Btn_Copy   :="BITMAPS\COPY.BMP"       // Copy
  oDp:Btn_Select :="BITMAPS\SELECT.BMP"     // Select All
  oDp:Btn_Pack   :="BITMAPS\DEPURAR.BMP"    // Depurar
  oDp:Btn_Compile:="BITMAPS\COMPILE.BMP"    // Compilar

   // Ubicaci?n de Carpetas

  oDp:cPathBitMaps:=GETINI(oDp:cPathExe+"DATAPRO.INI","BMPPATH")  // Ubicaci?n del BitMap
  oDp:cPathLbx    :=GETINI(oDp:cPathExe+"DATAPRO.INI","LBXPATH")  // Ubicaci?n de ListBox
  oDp:cPathRep    :=GETINI(oDp:cPathExe+"DATAPRO.INI","REPPATH")  // Ubicaci?n de Reportes

  oDp:cPathLbx    :=IF(Empty(oDp:cPathLbx)    ,"FORMS\"  ,oDp:cPathLbx    )
//oDp:cPathRep    :=IF(Empty(oDp:cPathRep)    ,"REPORT\" ,oDp:cPathLbx    )
  oDp:cPathBitMaps:=IF(Empty(oDp:cPathBitMaps),"BITMAPS\",oDp:cPathBitMaps) 

  oDp:lSavePanelErp:=GETINI(oDp:cPathExe+"DATAPRO.INI","SAVEPANELERP",.F.)  // Guardar 
  oDp:lSavePanelErp:=CTOO(oDp:lSavePanelErp,"L")


  // Area de los Botones de Barra en ListBox 
  oDp:nBar_nWidth:=36 // Ancho
  oDp:nBar_nHight:=36 // Alto

  // Color Get en GotFocus
  oDp:Get_nClrText:=nRGB(0,0,0)
  oDp:Get_nClrPane:=nRGB(243,250,200)

  // Color Say de los Campos Relacionados
  oDp:nSayClrPaneL:=16711680            // Color Fondo Say de los Campos Relacionados
  oDp:nSayClrtextL:=nRGB(255,255,255)   // Color Texto de Say de Campos Relacionados

  //oDp:lTracerSql :=.F. // Monitore los Comandos Actualizar de SQL se Inicia desde DATAPRO.INI
  oDp:lRunShell  :=.T. // As? puede Ejecutar Aplicaciones Open-Office
  oDp:lRunLoadCnf:=.F. // Est? ejecutando Carga de la Empresa
  oDp:nSqlBegin  :=.F. // Transacciones SQL
  oDp:lChkSql    :=.F. // Revisi?n de SQL
  oDp:lRepHead   :=.T. // Titulos en los Reportes
  oDp:lSayTable  :=.F. // Muestra en Frame el nombre de la Tabla Abierta
  oDp:lMdiLbx    :=.F. // Indica si la Lista LBX es MDI
  oDp:lDebug     :=IIF(GETINI(oDp:cPathExe+"DATAPRO.INI","DEBUGMODE")=".T.",.T.,.F.)  // Inicia Modo Debug
  oDp:lDevel     :=IIF(GETINI(oDp:cPathExe+"DATAPRO.INI","DEVELOPMENT")=".T.",.T.,.F.)  // Version para Desarrollo
  oDp:lRunPrgView:=.T. // Ejecuta los programas asociados a la creación de las Vistas

  // Colores del Men?
  oDp:nMenuMainClrText :=CLR_BLACK // CLR_WHITE
  oDp:nMenuMainClrPane :=NIL       // oDp:nGris // 16762809 // CLR_HBLUE // NRGB( 225, 225, 240 ) // ;CLR_YELLOW
  oDp:nMenuMainSelPane :=16772313 // 12118526 
 
  oDp:nMenuItemClrText := CLR_BLACK
//oDp:nMenuItemClrPane := 16773862   // 15400938 // 16704472 // 16707559 // NRGB( 225, 225, 240 )
//oDp:nMenuItemSelPane := 16768185   // 16770250 // 14086398 // 12644350 // nRGB(243,250,200)
  
  oDp:cBmpAplicaciones :="bitmaps\barraaplicacion.bmp"
  oDp:nMenuHeight      :=22
  oDp:lMenu3D          :=.F.
  oDp:nMenuBoxClrText  :=CLR_HBLUE // RED  // CLR_GREEN


  //6x
  // Color del Mensaje cToolTip
  oDp:nMsgToolClrText  :=CLR_WHITE 
  oDp:nMsgToolClrPane  :=9984315 
  //  oDp:nMsgToolClrPane  :=RGB( 255, 255, 225 )


  oDp:aMenuHlp         :={}

  AADD(oDp:aMenuHlp     ,{"Instalación e Implantación","capitulo	1.chm"       ,"main"      ,"cajains2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Inventario"                ,"capitulo2.chm"       ,"main"      ,"trabajador2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Compras "                  ,"capitulo3.chm"       ,"main"      ,"rrhh2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Ventas "                   ,"capitulo4.chm"       ,"main"      ,"rrhh2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Tesoreria "                ,"capitulo5.chm"       ,"main"      ,"rrhh2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Contabilidad "             ,"capitulo6.chm"       ,"main"      ,"rrhh2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Activos"                   ,"capitulo7.chm"       ,"main"      ,"rrhh2.bmp"})
  //AADD(oDp:aMenuHlp   ,{"Gerencia y Estadisticas"   ,"capitulo3.chm"     ,"main"      ,"rrhh2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Definiciones de Nómina"    ,"capitulo11.chm"      ,"main"      ,"confignm2.bmp"})
  //AADD(oDp:aMenuHlp   ,{"Administración del Sistema","administracion.chm","main"      ,"administrar2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Programación"              ,"dpxbase.chm"         ,"main"      ,"programa2.bmp"})
  AADD(oDp:aMenuHlp     ,{"Bitácora de Mejoras"       ,"dp\datapro.txt"          ,"bitacora"   ,"text.bmp"})
  AADD(oDp:aMenuHlp     ,{"Generador de Reportes"     ,"generadorreporte.chm","dpreportes","genrep2.bmp"})

  // FIN MENU
  oDp:cTipProd     :="SGE"
  
  // Usuario por Defecto
  DEFAULT oDp:cUsuario:="00" 

  oDp:cSucursal    :=STRZERO(1,6)
  oDp:cSucMain     :=oDp:cSucursal // Sucursal Principal
  oDp:cAlmacen     :=STRZERO(1,3) 
  oDp:lFechaNew    :=.F. // No ha realizado Cambio de Fecha
  oDp:cFormatoFecha:="99/99/9999"
  //oDp:lPanel       :=.F.  // Panel ERP
  oDp:lCambioFecha :=.T.  // Para control del timer de cambio de fecha
  oDp:nDec         :=2    // Decimales a Utilizar por Defecto..
  
// HrbLoad("DPXBASE.HRB") // Carga M?dulo DpXbase

  aOdbc :=LOADDSN()
  nAt   :=ASCAN(aODBC,{|aVal| ALLTRIM(aVal[1]) == ALLTRIM(oDp:cDsnConfig) })

  IF nAt>0
     oDp:cIpConfig :=aOdbc[nAt,6]
  ENDIF

  // Titulos del Men?
  oDp:cIdTras:="DPMENU"

  oDp:nMenuInfo:=8+1 // Indica en que Parte del Menú, incluye los MDI Activos (VENTANA)
  oDp:cMenu01:=" "+MI("&Macros"      ,650)+" "
  oDp:cMenu02:=" "+MI("&Aplicaciones",651)+" "
  oDp:cMenu03:=" "+MI("Ficheros"     ,652)+" "
  oDp:cMenu04:=" "+MI("Transacciones",653)+" "
  oDp:cMenu05:=" "+MI("Informes"     ,654)+" "
  oDp:cMenu06:=" "+MI("Procesos"     ,655)+" "
  oDp:cMenu07:=" "+MI("Otros"        ,656)+" "
  oDp:cMenu08:=" "+MI("Ventana"      ,657)+" "
  oDp:cMenu09:=" "+MI("A&yuda"       ,658)+" "
  oDp:cMenu10:=" "+MI("S&alir"       ,659)+" "

  // nNombre de las Opciones
  oDp:cIdTras:="DPEDIT"
  oDp:cInc:=MI("Incluir"  ,601)
  oDp:cMod:=MI("Modificar",603)
  oDp:cEli:=MI("Eliminar" ,604)
  oDp:cBus:=MI("Buscar"   ,605)
  oDp:cLoc:=MI("Localizar",616)
  oDp:cImp:=MI("Imprimir" ,607)

  oDp:cDpMemo   :="DPMEMO"      // Nombre de la Tabla DPMEMO
  oDp:cDpAudita :="DPAUDITORIA" // Nombre de la Tabla de Autitoría para la Configuracion del Sistema, empresa se llama DPAUDITOR
  oDp:cDpDataSet:="DPDATASET"   // Tabla del DataSet
  oDp:cCal_Topic:="00M35"       // Topic/Help Calendario
  oDp:cPrecio   :="A"
  oDp:nPorReg   :=0 // :=oData:Get("nPorReg"       , 0           )

  // Valores P?blicos para el Generador de Informes
  AADD(oDp:aVarPub,{"oDp:cEmpresa"    ,"Nombre de la Empresa"})
  AADD(oDp:aVarPub,{"oDp:cSucursal"   ,"Código de Sucursal"})
  AADD(oDp:aVarPub,{"oDp:cAlmacen"    ,"Código de Almacen"})
  AADD(oDp:aVarPub,{"oDp:cDocNumIni"  ,"Número Inicial Documento Compra o Venta"})
  AADD(oDp:aVarPub,{"oDp:cDocNumFin"  ,"Número Final Documento Compra o Venta"})
  AADD(oDp:aVarPub,{"oDp:cDocCodIni"  ,"Código Inicial Documento Cliente o Proveedor"})
  AADD(oDp:aVarPub,{"oDp:cDocCodFin"  ,"Código Final Documento del Cliente o Proveedor"})
  AADD(oDp:aVarPub,{"oDp:cReciboIni"  ,"Número del Recibo de Ingreso Inicial"})
  AADD(oDp:aVarPub,{"oDp:cReciboFin"  ,"Número del Recibo de Ingreso Final"})
  AADD(oDp:aVarPub,{"oDp:cCbtePagoIni","Número del Comprobante de Pago Inicial"})
  AADD(oDp:aVarPub,{"oDp:cUsuario"    ,"Código de Usuario "})
  AADD(oDp:aVarPub,{"oDp:cImpFiscal"  ,"Impresora Fiscal Seleccionada "})

  // Fechas

  AADD(oDp:aVarPub,{"oDp:dFecha"      ,"Fecha del Sistema"})

  AADD(oDp:aVarPub,{"oDp:dSmnIni"     ,"Inicio de la Semana"})
  AADD(oDp:aVarPub,{"oDp:dSmnFin"     ,"Fin de la Semana"})

  AADD(oDp:aVarPub,{"oDp:dQuiIni"     ,"Inicio de la Quincena"})
  AADD(oDp:aVarPub,{"oDp:dQuiFin"     ,"Fin de la Quincena"})
  AADD(oDp:aVarPub,{"oDp:dMesIni"     ,"Inicio del Mes"})
  AADD(oDp:aVarPub,{"oDp:dMesFin"     ,"Fin del Mes"})
  AADD(oDp:aVarPub,{"oDp:dBimIni"     ,"Inicio del Bimestre"})
  AADD(oDp:aVarPub,{"oDp:dBimFin"     ,"Fin del Bimestre"})
  AADD(oDp:aVarPub,{"oDp:dTriIni"     ,"Inicio del Trimestre"})
  AADD(oDp:aVarPub,{"oDp:dTriFin"     ,"Fin del Trimestre"})
  AADD(oDp:aVarPub,{"oDp:dSemIni"     ,"Inicio del Semestre"})
  AADD(oDp:aVarPub,{"oDp:dSemFin"     ,"Fin del Semestre"})
  AADD(oDp:aVarPub,{"oDp:dAnoIni"     ,"Inicio del Año"})
  AADD(oDp:aVarPub,{"oDp:dAnoFin"     ,"Fin del Año"})
  AADD(oDp:aVarPub,{"oDp:dFchInicio"  ,"Fecha de Inicio del Ejercicio"})
  AADD(oDp:aVarPub,{"oDp:dFchCierre"  ,"Fecha de Cierre del Ejercicio"})

  AADD(oDp:aVarPub,{"oDp:nVenceCli1","Intervalo #1 en Días para NO Vencidos / Clientes"})
  AADD(oDp:aVarPub,{"oDp:nVenceCli2","Intervalo #2 en Días para Vencimiento / Clientes"})
  AADD(oDp:aVarPub,{"oDp:nVenceCli3","Intervalo #3 en Días para Vencimiento / Clientes"})
  AADD(oDp:aVarPub,{"oDp:nVenceCli4","Intervalo #4 en Días para Vencimiento / Clientes"})
  AADD(oDp:aVarPub,{"oDp:nVenceCli5","Intervalo #5 en Días para Vencimiento / Clientes"})

  AADD(oDp:aVarPub,{"oDp:cDir1","Dirección Línea 1"})
  AADD(oDp:aVarPub,{"oDp:cDir2","Dirección Línea 2"})
  AADD(oDp:aVarPub,{"oDp:cDir3","Dirección Línea 3"})
  AADD(oDp:aVarPub,{"oDp:cDir4","Dirección Línea 4"})

  AADD(oDp:aVarPub,{"oDp:cTel1","Teléfono 1"})
  AADD(oDp:aVarPub,{"oDp:cTel2","Teléfono 2"})
  AADD(oDp:aVarPub,{"oDp:cTel3","Teléfono 3"})
  AADD(oDp:aVarPub,{"oDp:cTel4","Teléfono 4"})

  AADD(oDp:aVarPub,{"oDp:cRif" ,"Rif"})
  AADD(oDp:aVarPub,{"oDp:cNit" ,"Nit"})
  AADD(oDp:aVarPub,{"oDp:cMail","Mail"})
  AADD(oDp:aVarPub,{"oDp:cWeb ","Página Web"})

  // MY-SQL CON TEMPORALES 
  oDp:lTemporal:=(oDp:cTypeBD="MYSQL")
  oDp:lTemporal:=.F.
  oDp:lConChk:=.F.
  // Fecha mm-dd-aa

  oDp:bFecha_:={|cFecha,cDia,cMes,cAno| cDia:=SUBS(cFecha,4,2),;
                                        cMes:=LEFT(cFecha,3  ),;
                                        cAno:=RIGHT(cFecha,4 ),;
                                        CTOD(cDia+"/"+cMes+"/"+cAno)}

  oDp:bFecha :={|bParam| IIF(ValType(bParam)="C",IF("-"$bParam,EVAL(oDp:bFecha_,bParam),CTOD(bParam)),bParam)} // Bloque de c¢digo que certifica las Fechas

//  oDp:aPeriodos:={"Diario","Semanal","Quincenal","Mensual","Bimestral","Trimestral","Semestral","Anual","Indefinida","Indicada"}
//  oDp:aField_Per:={"DIA_FECHA","DIA_SEMANA","DIA_QUINCE","DIA_MES","DIA_BIMEST","DIA_TRIMES","DIA_SEMEST","DIA_ANO","DIA_EJERC"}

//  oDp:aPeriodos :={"Diario"   ,"Semanal"   ,"Quincenal","Mensual" ,"Bimestral" ,"Trimestral","Semestral","Anual"   ,"Ejercicio","Indefinida","Indicada"}
//  oDp:aField_Per:={"DIA_FECHA","DIA_SEMANA","DIA_QUINCE","DIA_MES","DIA_BIMEST","DIA_TRIMES","DIA_SEMEST","DIA_ANO","DIA_EJERC"}

  // Incluye Cuatrimestral
  oDp:aPeriodos  :={"Diario"   ,"Semanal"   ,"Quincenal","Mensual" ,"Bimestral" ,"Trimestral","Cuatrimestral","Semestral","Anual"   ,"Ejercicio","Indefinida","Indicada"}
  oDp:aField_Per :={"DIA_FECHA","DIA_SEMANA","DIA_QUINCE","DIA_MES","DIA_BIMEST","DIA_TRIMES","DIA_CUATRI"   ,"DIA_SEMEST","DIA_ANO","DIA_FECHA"}

  oDp:nDiario       :=1
  oDp:nSemana       :=2
//oDp:nCatorcenal   :=3
  oDp:nQuincena     :=3
  oDp:nQuincenal    :=3
  oDp:nMensual      :=4
  oDp:nBimensual    :=5
  oDp:nTrimestral   :=6
  oDp:nCuatrimestral:=7
  oDp:nSemestral    :=08
  oDp:nAnual        :=09
  oDp:nEjercicio    :=10
  oDp:nIndefinida   :=11
  oDp:nIndicada     :=12

  oDp:cCodProCero   :=STRZERO(0,10) // proveedor cero
  oDp:cItem         :=""

  // Sucursal principal, utilizado para crear presupuesto General
  oDp:cSucMain   :=STRZERO(0,6)


  oDp:lPryStd  :=.T. // Indica Proyectos Estandar
  oDp:lPryAutoM:=.F. // Indica Proyectos Estandar

  oDp:lDpPos02:=.F.


   oDp:lDpPos02:=.F.

 // RIGC.  Ejemplo de como configurar un boton al llamado de un programa.
 // SetKey( VK_F7, {||EJECUTAR("DPFACTURAV","PED")} )  
 //

  // Teclas Utilizadas en TGET, Metodo KeyDown
  oDp:aKeyFK:={}
  AADD(oDp:aKeyFK,{116,BLOQUECOD('EJECUTAR("ABREVIA_KEY")')})

  oDp:lVistas:=.F. // (oDp:nVersion>=5)
  EJECUTAR("MYSQLTABENGINE")
  AUDITAR("DINI")

/*
  ejecutados desde GETUSUARIO, Luego que ingresa el usuario
  IF ISFIELD("DPPROCESOS","PRC_INICIA") .AND. COUNT("DPPROCESOS","PRC_ACTIVO=0 AND PRC_INICIA=1 AND PRC_FIN=0")>0
     EJECUTAR("BRPRCFALLIDO")
  ENDIF

  EJECUTAR("PRCREADCOMP")  // Recompila Procesos Automáticos
*/

  // no puede ser PC Master (Quien Realiza la Descarga del sistema desde DPLLAVE.SERVERDESCARGAR()
  IF !ISDPSTD() .AND. !SQLGET("DPPCLOG","PC_MASTER","PC_NOMBRE"+GetWhere("=" ,oDp:cPcName)) .AND. !lConfig
    // Si este PC es quien hace las descargas desde el Servidor No debera ejecuta
    EJECUTAR("DPAPLDIRGET",.F.)  // Recupera los Archivos Descargados y Almacenados en DPDIRAPL
  ENDIF

  EJECUTAR("TEMPTOREGSOPORTE") // Publica las Incidencias
  //  27/01/2025 EJECUTAR("DELETETDIR" )      // Borra la Carpeta TEMP

//  // Actualiza Contenido de las Tablas desde DATADBF\ Removido para SQLDB_UPDATE 4/8/2015
//  EJECUTAR("DPCREA_DATA","DPAUDTIPOS","UDT_CODIGO") // Actualiza Tipos de Auditoria

  // No requiere Uso Nativo

  IF !oDp:lNativo

     MySqlCloseAll()

     IF ValType(oDp:oMySqlCon)="O"
       oDp:oMySqlCon:Close()
     ENDIF

     oDp:oMySqlCon:=NIL

  ENDIF

  // Determina si este PC posee Scanner Conectado
  oDp:lScanner:=.F.

  oDp:cTipFch :="S"
  oDp:dFchUlt :=oDp:dFecha

  // IF ISFIELD("DPPCLOG","PC_SCANNER")
  oDp:lScanner:=SQLGET("DPPCLOG","PC_SCANNER","PC_NOMBRE"+GetWhere("=",oDp:cPcName))
  // ENDIF

//  IF !Empty(oDp:cLocalRecover) .AND. ISFIELD("DPPCLOG","PC_EDOACT") 
//    SQLUPDATE("DPPCLOG","PC_EDOACT",oDp:cLocalRecover,"PC_NOMBRE"+GetWhere("=",oDp:cPcName))
//  ENDIF

  // EJECUTAR("DPCAMPOSADD","DPPCLOGAPP","PCL_OS"    ,"C",120,0,"Sistema Operativo",NIL,NIL,NIL,"oDp:cOs")
  // IF ISFIELD("DPPCLOG","PC_EDOACT") 

  SQLUPDATE("DPPCLOG",{"PC_EDOACT"      ,"PC_EDOACT","PC_EDOACT"      },;
                      {oDp:cLocalRecover,oDp:cOs    ,oDp:cLocalRecover},;
                      "PC_NOMBRE"+GetWhere("=",oDp:cPcName))

  // ENDIF
  // Impresoras Remotas
  // Ejecutar Punto de Venta
  // EJECUTAR("DPPOS01")

  EJECUTAR("PLUGIN_INI")

  EJECUTAR("DPFILEDIRSAV","CRYSTAL\") 
  EJECUTAR("DPFILEDIRSAV","FORMS\") 

  IF(FILE("BITMAPS\XCANCELH.BMP"),FRENAME("BITMAPS\XCANCELH.BMP","BITMAPS\XCANCELG.BMP"),NIL)
  EJECUTAR("CHKDLL64") // Revisa si el OS de 64 Bits tienes los DLLs de Crystal Report   
  RELEASEDATASET()

  oDp:lOpenTableChk:=.T. // EJECUTAR("OPENTABLECHK",cTable,oOdbc)

  oDp:nDivide   :=100000
  oDp:dFchIniRm :=CTOD("01/08/2018") // Fecha de Inicio Reconversion Monetaria
  oDp:bDivRecMon:={|cCampo,cExp| cExp:="/(IF("+cCampo+GetWhere("<",oDp:dFchIniRm)+","+LSTR(oDp:nDivide)+",1))"}

  IF oDp:cType="NOM"
    oDp:cDpMemo   :="NMMEMO"      // Nombre de la Tabla DPMEMO
    EJECUTAR("DPINI_NOM")
  ENDIF

  IF ISPCPRG()
     EJECUTAR("DPAUDELIMODCNF_HIS")
  ENDIF

  EJECUTAR("DPPARXLS") // parámetros para migracion de datos desde excel
  EJECUTAR("DPXBASECERO")
// 27/01/2025  EJECUTAR("DPDELDICCDAT")

  EJECUTAR("MYDPINI")

  oDp:lCondominio:=.F.

  // 03/03/2024 evitar caida del sistema en GETUSUARIO cuando el sistema esta inactivo.
  oDp:cUsuario:="000"
  DPSETTIMER({||oDp:lMYSQLCHKCONN:=.T.,SQLUPDATE("DPUSUARIOS","OPE_ACTIVO",.T.,"OPE_NUMERO"+GetWhere("=",oDp:cUsuario)),oDp:lMYSQLCHKCONN:=.F.},"UPDATEUSUARIO",500-100)


RETURN NIL
// EOF
