// Programa   : DPLOADCNF   
// Fecha/Hora : 06/02/2005 01:29:02
// Prop½sito  : Carga la Configuraci½n de la Empresa
// Creado Por : Juan Navas
// Llamado por: DPINI
// Aplicaci¢n : Todas
// Tabla      : Todas

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lDpConfig,cCodSuc)
  LOCAL oTable,nCantid,oData
  LOCAL aVarl :={},I,cVar,bValFecha,lField,cIdConfig:=""
  LOCAL dFecha:=FCHANUAL(oDp:dFecha,DPFECHA())
  LOCAL cCodigo,cWhere,oDb:=OpenOdbc(oDp:cDsnData)

  DEFAULT lDpConfig     :=.T.,;
          oDp:lRet_Mun  :=.F.,;
          oDp:lActDivisa:=.T.

  oDp:oDsnData:=oDb // 

  DEFAULT oDp:lLoadCnf:=.F.

  // No esta ejecutando DPCONFIG
  DEFAULT oDp:lConfig:=.T.

  oDp:lAplNomina:=.F. // Arrancó nómina
 
  RELEASEOPENTABLE() //08/01/2024 Optimiza tablas para la inserción de Registros

  oDp:lExcluye:=.F.

  IF Empty(oDp:cEmpCod)
     oDp:cEmpCod:=SQLGET("DPEMPRESA","EMP_CODIGO","EMP_BD"+GetWhere("=",oDp:cDsnData)+" AND EMP_CODIGO"+GetWhere("<>",""))
  ENDIF

  oDp:lSucEmpresa  :=.F. // Sucursal como Empresa
  oDp:lGyPBrowse   :=.T. // Browse de GYP 
  oDp:lFavtocompras:=.F. // Factura de venta, exporta hacia compras del proveedor de otra empresa segun RIF del cliente:

  // utilizado en AFTESAVE en Factura, guarda documento destino
  IF ValType(oDp:oTableDocFlow)="O"
    oDp:oTableDocFlow:Close()
    oDp:oTableDocFlow:=NIL
  ENDIF

  oDp:POR_GN       :=NIL // necesario para factura digital

  oDp:lImpFisRegAud:=.T.
  // oTable        :=OpenTable("SELECT * FROM DPEMPRESA WHERE EMP_CODIGO"+GetWhere("=",oDp:cEmpCod),.T.,NIL,NIL,.F.)
  oTable           :=OpenTable("SELECT * FROM DPEMPRESA WHERE EMP_BD"+GetWhere("=",oDp:cDsnData),.T.,NIL,NIL,.F.)


  oDp:dFchInicio  :=oTable:EMP_FECHAI
  oDp:dFchCierre  :=oTable:EMP_FECHAF
  oDp:cEmpCod     :=oTable:EMP_CODIGO
  oDp:cCodServer  :=oTable:EMP_CODSER

  // Para cambiar el ejercicio
  oDp:EMP_FECHAI:=oTable:EMP_FECHAI
  oDp:EMP_FECHAF:=oTable:EMP_FECHAF
  oDp:EMP_BDREL    :=ALLTRIM(oTable:EMP_BDREL)
  oTable:End(.T.)

  // ? MESES(oDp:dFchInicio,oDp:dFchCierre),oDp:dFchInicio,oDp:dFchCierre

  IF Empty(oDp:dFchInicio) .OR. (MONTH(oDp:dFchInicio)=MONTH(oDp:dFchCierre)) .OR. MESES(oDp:dFchInicio,oDp:dFchCierre)<11
     EJECUTAR("DPEMPRESA",3,oDp:cEmpCod)
     DPFOCUS(oEMPRESA:oEMP_FECHAI)
  ENDIF

  IF !oDp:cType="SGE"
     RETURN .T.
  ENDIF

  IF oDp:lConfig .OR. oDp:lLoadCnf 
     RETURN .T.
  ENDIF

  // 11/01/2025 Aqui realiza revisión de la base de datos. Solo cuando se actualiza el RELEASE
  //  ? oDp:EMP_BDREL,oDp:cBdRelease,"AQUI COMPARA",oDp:cDsnData,"oDp:cDsnData"

  // "DPTIPPROVEEDOR","TIP_PLANIF",

  lField:=!EJECUTAR("ISFIELDMYSQL",oDb,"DPTIPPROVEEDOR","TIP_PLANIF"  ,.F.) .OR. ;
          !EJECUTAR("ISFIELDMYSQL",oDb,"DPPRECIOTIP"   ,"TPP_PRGCND"  ,.F.) .OR. ;
          !EJECUTAR("ISFIELDMYSQL",oDb,"DPDOCCLI"      ,"DOC_CHKSUM"  ,.F.) .OR. ;
          !EJECUTAR("ISFIELDMYSQL",oDb,"DPTIPDOCCLICOL","CTD_MEMOEJ"  ,.F.)


  IF COUNT("DPPRECIOTIP")=0
     EJECUTAR("DPDATACREA",.T.)
  ENDIF

  IF oDp:EMP_BDREL<>oDp:cBdRelease .OR. lField 
    EJECUTAR("DPLOADCNFADDFIELD") // Valida el RELEASE
  ENDIF

  // oDp:lRunDefault:=.T. // 20/04/2024
  // 10/11/2025 EJECUTAR("GETDEFAULTALL") // lo ejecuta en DPINI INNECESARIO
  EJECUTAR("DPPRECIOS_LABEL") // oDp:cPrecioA
  EJECUTAR("DPPARXLS") // parámetros para importar desde excel


  oDp:nCantFormaFiscal:=0 // Cantidad de Series Fiscales Necesario para el incrementador
 
  // Parámetros para importar archivo XLS
  oParXls:cCodBco   :=""
  oParXls:cCtaBco   :=""
  oParXls:cCodIBP   :=""
  oParXls:cNumero   :=""
  oParXls:cBcoNombre:=""
  oParXls:lBrowse   :=.F.

  // Necesario para los valores de las referencias de los campos

  IF !TYPE("oRef")="O"
     PUBLICO("oRef")
     oRef:=TPublic():New( .T. )
  ENDIF

  // 16/10/2023
  IF(ValType(oDp:oDPAUDITOR   )="O",oDp:oDPAUDITOR:End()   ,NIL)  // 16/10/2023
  IF(ValType(oDp:oDPAUDITORFIS)="O",oDp:oDPAUDITORFIS:End(),NIL)  // 26/01/2025
  IF(ValType(oDp:oDPAUDITORIA )="O",oDp:oDPAUDITORIA:End() ,NIL)  // 16/10/2023
  IF(ValType(oDp:oAsiento     )="O",oDp:oAsiento:End()     ,NIL)  // 16/10/2023
  IF(ValType(oDp:oDPDOCPROPROG)="O",oDp:oDPDOCPROPROG:End(),NIL) // 05/02/2024

  oDp:oDPAUDITOR   :=NIL
  oDp:oDPAUDITORFIS:=NIL
  oDp:oDPAUDITORIA :=NIL
  oDp:oAsiento     :=NIL
  oDp:oDPDOCPROPROG:=NIL
  oDp:cEmpLargo    :=oDp:cEmpresa

  oDp:cCodRmu:=NIL
  oDp:lChkTableDocPro:=.F. // necesario para remover registros 14/02/2024
  oDp:lChkTableDocCli:=.F. // necesario para remover registros 14/02/2024

  oDp:cRunData:=oDp:cDsnData

  oDb:=OpenOdbc(oDp:cDsnData)

  oDp:cCtaCajNac :=NIL // Cuenta Contable Nacional, Resetea las Cuentas, evitar lectura en cada documento

  oDp:aNumCbte   :={} // Número de Cbte Contable
  oDp:cCbteNombre:={} // Nombre del Comprobante Contable
  oDp:cTipAsiento:="" // Tipo de Asiento, utilizado en DPASIENTOCREA

  oData   :=DATACONFIG("RECONVERSION","ALL")
 
  oDp:dFchIniRec:=oData:Get("dFchIniRec"  ,CTOD("30/09/2021"))
  oDp:dFchFinRec:=oData:Get("dFchFinRec"  ,CTOD("30/09/2021"))
  oDp:nRecMonDiv:=oData:Get("nRecMonDiv"  ,1000000)
  oDp:cCodMonDiv:=oData:Get("cCodMon"     ,"BSD")
  oDp:cNmExclue :="FCH_OTRNOM"+GetWhere("<>","RM") // Excluye Nómina reconversión Monetaria en Salario Promedio
  oData:End(.T.)

  oDp:dFchIniRm:=oDp:dFchFinRec
  oDp:nDivide  :=oDp:nRecMonDiv

  DEFAULT oDp:lCliXSuc:=.T.

  oDp:aGyP        :={}
  oDp:cPicture    :="999,999,999,999,999.99"
  oDp:cPictHora   :="99:99:A"
  oDp:cNmContab   :=""  // Nómina por defecto será por Pagar, Requier leer NMLOADCNF

  oDp:lCheckAsql  :=.T. // Valida Tablas en funcion ASQL()
  oDp:P_LDpFchEjer:=.F. // No permite registrar Operaciones con Fechas de Ejercicios Pasado

  // Lotes como Color
  oDp:lColorLotes:=.T. 

  // 19/11/2020, Asegurar campos logicos, si esta vacio los campos 0 AS MONTO serán logicos
  IF Empty(oDp:aLogico)
    oDp:aLogico:=ASQL("SELECT RTRIM(CAM_TABLE),RTRIM(CAM_NAME) FROM DPCAMPOS WHERE CAM_TYPE='L'")
  ENDIF

  //  oDp:aCamposOpc:={}
  IF Empty(oDp:aCamposOpc)
    LoadCamposOpc() 
  ENDIF

  oDp:cErp_cMsg:=""

  // Dolar BCV
  oDp:cUsdBcv  :="DBC"   ,;
  oDp:dFechaBcv:=CTOD(""),;
  oDp:nUsdBcv  :=0
  
  oDp:aBancoTip:={}
  oDp:aCajaInst:={}


  // Tesoro Nacional 
  DEFAULT oDp:cRifSeniat:="G200003030" 

  oDp:cEurBcv  :="EBC"   
  oDp:nEurBcv  :=0

  oDp:aFeriados:={}
  oDp:lLoadCnf :=.T.
  oDp:nKpiValor:=1
  oDp:nMtoXRecC:=1 // Monto que será multiplicado para el proceso de contabilización
  oDp:lDPDOCCLI_COPY:=EJECUTAR("ISTABLE",oDp:cDsnData,"DPDOCCLI_COPY") 
  oDp:lDPDOCPRO_COPY:=EJECUTAR("ISTABLE",oDp:cDsnData,"DPDOCPRO_COPY")
  
  IF Empty(cCodSuc)
    cCodSuc:=EJECUTAR("GETCODSUCCALFISCAL") // 7/12/2025
    // cCodSuc:=IF(SQLGET("DPSUCURSAL","SUC_EMPRES","SUC_CODIGO"+GetWhere("=",oDp:cSucursal)),oDp:cSucursal,"")
  ENDIF

  cIdConfig    :=""

  oDp:lSucEmpresa:=SQLGET("DPSUCURSAL","SUC_EMPRES","SUC_CODIGO"+GetWhere("=",cCodSuc))

  IF oDp:lSucEmpresa
     cIdConfig    :=cCodSuc
     // IF cCodSuc=oDp:cSucMain
     // cIdConfig:=""
     // oDp:cIdConfig:=""
  ENDIF

  oDp:cIdConfig:=cIdConfig // Configuración leida

  EJECUTAR("DPPARCONTABILIZ")   // Parámetros Contables

  // Crear las Variables para crear las vistas
  AEVAL(ASQL("SELECT DFC_CODIGO,DFC_DIAS FROM DPCATEGORIZACLI"),{|a,n|  oDp:Set("nDiasCategoria_"+ALLTRIM(a[1]),a[2])})

  oDp:cCountry:=GETINI("DATAPRO.INI","COUNTRY","VEN")  // Pais
  oDp:cNit    :=GETINI("DATAPRO.INI","NIT"    ,"RIF")  // Nombre de Identificación Tributaria

  // Proveedores seran Creados según RIF 02/02/2025

  DEFAULT oDp:lRifPro :=.T.

  DpMsgClose()

  // Utilizados por el Programa ISSENIAT Y Proceso Automático ISSENIAT
  oDp:lIsSeniat :=.T.
  oDp:cIpSeniat :=""
  oDp:cUrlSeniat:=""
  oDp:cCtaIndef :="Indefinida"
  oDp:cCedulaUs :=""
  oDp:cCodRmu   :=NIL // Su valor sera reiniciado en DPRETMUNCREA

  oDp:P_LDpCreaPro :=.T.
  oDp:P_LDpeManager:=.T. // Subir Datos para eManager


  oDp:cCedulaUs :=SQLGET("DPUSUARIOS","OPE_CEDULA,OPE_CARGO,OPE_EMAIL,OPE_FIRMA,OPE_TELEFO,OPE_EXT","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))
  oDp:cUsCargo  :=DPSQLROW(2,"") // Cargo
  oDp:cUsEmail  :=DPSQLROW(3,"") // Correo Electrónico
  oDp:cUsFirma  :=DPSQLROW(4,"") // Firma
  oDp:cUsTelefo :=DPSQLROW(5,"") // Teléfono
  oDp:cUsExt    :=DPSQLROW(6,"") // Extension

  oDp:cTareaAut:=STRZERO(0,5)
  oDp:cComPIndef:="Indefinida"

  //  22/01/2018  EJECUTAR("DPDATACREA",.T.) // Carga el Tabulador de Iva si no Existe
  // evitar ejercicio de EJERCICIOS
  // EJECUTAR("UNIQUETABLAS","DPEJERCICIOS","EJE_CODSUC,EJE_NUMERO")

  SQLGET("DPCTA","CTA_CODIGO","CTA_CODIGO"+GetWhere("=",oDp:cCtaIndef))

  IF !Empty(oDp:aRow)
   oDp:cCtaIndef:=oDp:aRow[1]
  ENDIF

  // Mantiene la conexion con MySQL, evitando salidas por falta de conectividad
  // JN 22/02/2016 

  oDp:lMYSQLCHKCONN:=.F. // Desactivado para mayor optimización, solo se activa en SQLUPDATE

  DPSETTIMER({||oDp:lMYSQLCHKCONN:=.T.,SQLUPDATE("DPUSUARIOS","OPE_ACTIVO",.T.,"OPE_NUMERO"+GetWhere("=",oDp:cUsuario)),oDp:lMYSQLCHKCONN:=.F.},"UPDATEUSUARIO",500-100)

  IF ISPCPRG()
    // POR AHORA PARA GUARDAR VIDEO DPSETTIMER({||oDp:oFrameDp:SetText("UPDATEUSUARIOS "+TIME()),oDp:lMYSQLCHKCONN:=.T.,SQLUPDATE("DPUSUARIOS","OPE_ACTIVO",.T.,"OPE_NUMERO"+GetWhere("=",oDp:cUsuario)),oDp:lMYSQLCHKCONN:=.F.},"UPDATEUSUARIO",500-100)
  ELSE
    DPSETTIMER({||oDp:lMYSQLCHKCONN:=.T.,SQLUPDATE("DPUSUARIOS","OPE_ACTIVO",.T.,"OPE_NUMERO"+GetWhere("=",oDp:cUsuario)),oDp:lMYSQLCHKCONN:=.F.},"UPDATEUSUARIO",500-100)
  ENDIF

  DEFAULT oDp:lOpe_AudApp:=.F.
  
  IF ValType(oDp:lOpe_AudApp)="L" .AND. oDp:lOpe_AudApp
    DPSETTIMER({||EJECUTAR("DPGETTASK")},"DPGETTASK",100*2) 
  ELSE
    DPSETTIMER({||.T.},"DPGETTASK",0) 
  ENDIF

  // Documentos del Cliente para Imprimir
  oDp:cDocNumIni:=""
  oDp:cDocNumFin:=""
  oDp:cReciboIni:="" // N£mero de Recibo Inicial
  oDp:cReciboFin:="" // N£mero del Recibo Final
  oDp:cUndMed   :="UND" // Unidad de Medida

  oDp:cSelUnaOpc:="Seleccione una Opcion"

  oDp:cCbtePagoIni:="" // N£mero Cbte de Pago Inicial
  oDp:cCbtePagoFin:="" // N£mero Cbte de Pago Final

  oDp:cImpFiscal :=""        // DPPOSLOAD Asigna el Valor
  oDp:cImpFisCom :=""        // Puerto Serial
  oDp:cImpFisSer :=""        // Serial de la Impresora Fiscal, Obtiene desde la Serie Fiscal
  oDp:nImpFisLen :=0         // Ancho Impresora
  oDp:nImpFisEnt :=0         // Precios Enteros
  oDp:nImpFisDec :=0         // Precios Decimales
  oDp:lImpFisPago:=.F.       // Imprime si está pagado

  oDp:cNumIslr   :=SPACE(10) // Nœmero de ISLR para Imprimir

  // Cantidad Mas Baja
  nCantid    :=SqlGetMin("DPUNDMED","UND_CANUND") 

  IF COUNT("DPUNDMED")=0
     EJECUTAR("DPUNDMEDCREA")
  ENDIF

  // Unidad mÿs Baja
  // oDp:cUndMed:=SQLGET("DPUNDMED"      , "UND_CODIGO" ,  "UND_CANUND "+GetWhere("=",nCantid)) 
  // oDp:cPrecio:=SqlGetMin("DPPRECIOTIP", "TPP_CODIGO") 

  // Sintaxis para MYSQL 5
  IF Empty(oDp:cPrecio)

    EJECUTAR("DPPRECIOACTIVO")
    oDp:cPrecio:=SqlGet("DPPRECIOTIP", "TPP_CODIGO"," WHERE TPP_ACTIVO ORDER BY TPP_CODIGO LIMIT 1 ") 

    IF Empty(oDp:cPrecio)
       EJECUTAR("DPDATACREA")
       oDp:cPrecio:=SqlGet("DPPRECIOTIP", "TPP_CODIGO"," WHERE TPP_ACTIVO ORDER BY TPP_CODIGO LIMIT 1 ") 
    ENDIF

  ENDIF


  // Código del Vendedor
  // JN 15/03/2016
  oDp:cVendedor:=SQLGET("DPVENDEDOR", "VEN_CODIGO"," WHERE VEN_SITUAC"=+GetWhere("=","A")+" ORDER BY VEN_CODIGO LIMIT 1 ") 

  IF Empty(oDp:cPrecio)
     MensajeErr("Es necesario Registrar Catálogo de Precios")
  ENDIF

  oDp:cPais     :="Venezuela" // Pais por defecto
//  oDp:cEstado   :="-Indefinido"
//  oDp:cMunicipio:="-Indefinido"
//  oDp:cParroquia:="-Indefinido"

  // Impuestos al Licor
  oData:=DATACONFIG("LICORES","ALL")

  oDp:nImpProd:=oData:Get("nImpProd"     ,0.0)
  oDp:nImpExpe:=oData:Get("nImpExpe"     ,0.0)
  oDp:nImpBand:=oData:Get("nImpBand"     ,0.0)

  oData:End(.F.)

  oData:=DATASET("REGION","ALL")

  oDp:cPais      :=oData:Get("cPais"     ,oDp:cPais    ) // "-Indefinido")
  oDp:cEstado    :=oData:Get("cEstado"   ,"-Indefinido")
  oDp:cMunicipio :=oData:Get("cMunicipio","-Indefinido")
  oDp:cParroquia :=oData:Get("cParroquia","-Indefinido")
  oData:End(.F.)

  cCodSuc:=ALLTRIM(cCodSuc)

  oData:=DATASET("CONFIG"+oDp:cIdConfig,"ALL")
  oData:LOAD(.T.) // Recarga Valores

  IF Empty(oDp:cPrecio)
     oDp:cPrecio:="A"
  ENDIF

  oDp:nMenuItemClrPane:=oData:Get("nMClrPane" ,oDp:nMenuItemClrPane    ) // Color del Menú en Cada Empresa
  
// ? oDp:nMenuItemClrPane,"oDp:nMenuItemClrPane"

  oDp:cCodPer      :=oData:Get("cCodPer"      , DPGETPERSONAL())  // Personal de la Empresa
  oDp:cCodTran     :=oData:Get("cCodTran"     , DPGETDPINVTRAN()) // Transacciones

  oDp:cMetodoCos   :=oData:Get("cMetodoCos"   , "P"            ) // Por Defecto es Promedio
  oDp:cInvContab   :=oData:Get("cInvContab"   , "G"            ) // Contabilizar por Grupo
  oDp:cCalPrecio   :=oData:Get("cCalPrecio"   , "P"            ) // Precio - Costo
  oDp:nRedondeo    :=oData:Get("nRedondeo"    , 0              ) // Redondeo de Precios
  oDp:nDec_0_4     :=oData:Get("nDec_0_4"     , 5              ) // Aproximar Decima del 0-4
  oDp:lInvConsol   :=oData:Get("lInvConsol"   , .F.            ) // Consolida Inventario
  oDp:cForInv      :=oData:Get("cForInv"      , "Estandar"     ) // Formularios de Inventario
  oDp:lInvAut      :=oData:Get("lInvAut"      , .F.            ) // Códigos Automáticos
  oDp:nInvLen      :=oData:Get("nInvLen"      , 5              ) // Longitud del Código Automático
  oDp:lCosProCom   :=oData:Get("lCosProCom"   , .F.            ) // Costo Promedio Según Compras
  oDp:lCosProHis   :=oDaTa:Get("lCosProHis"   , .T.            ) // Costo Promedio Histórico

  oDp:lConFchDec   :=oData:Get("lConFchDec"   , .F.            ) // Contabilizar por Fecha de Declaracion
  oDp:cUndSer      :=oData:Get("cUndSer"      , "UND"          ) // Unidad de Medida para Seriales
  oDp:lIdSucMemo   :=oDaTa:Get("lIdSucMemo"   , .F.            ) // Usar Codigo de Sucursal como ID Memo
  oDp:cUndMed      :=oData:Get("cUndMed"      , "UND"          ) // Unidad de Medida por defecto, cuando se crea un producto
  oDp:cPrecio      :=oData:Get("cPrecio"      , oDp:cPrecio    ) // Precio de Venta por Defecto
  oDp:cLista       :=oDp:cPrecio 

  oDp:cHoraAmIni   :=oData:Get("cHora_AmIni"  , "08:00:A"      ) // Horario Am Inicio
  oDp:cHoraAmFin   :=oData:Get("cHora_AmFin"  , "12:00:P"      ) // Horario Am Fin

  oDp:cHoraPmIni   :=oData:Get("cHora_PmIni"  , "01:00:P"      ) // Horario Pm Inicio
  oDp:cHoraPmFin   :=oData:Get("cHora_PmFin"  , "05:00:P"      ) // Horario Pm Fin

  oDp:cGruLibros   :=oData:Get("cGruLibros"   , "03"       ) // Grupo de Libros


  oDp:lCbteRes  :=oData:Get("lCbteRes"  ,.F.    )  // Asientos Resumidos
  oDp:lResInv   :=oData:Get("lResInv"   ,.F.    )  // Resumir Inventario
  oDp:lResCom   :=oData:Get("lResCom"   ,.F.    )  // Resumir Compras
  oDp:lResVen   :=oData:Get("lResVen"   ,.F.    )  // Resumir Ventas
  oDp:lResCaj   :=oData:Get("lResCaj"   ,.F.    )  // Resumir Caja
  oDp:lResBco   :=oData:Get("lResBco"   ,.F.    )  // Resumir Banco
  oDp:lResAct   :=oData:Get("lResAct"   ,.F.    )  // Resumir Activos
  oDp:lCbteInc  :=oData:Get("lCbteInc"  ,.F.    )  // Incrementar Comprobante
  oDp:lVtaPag   :=oData:Get("lVtaPag"   ,.F.    )  // Venta Con pago el Contado
  oDp:lComPag   :=oData:Get("lComPag"   ,.F.    )  // Compra Con pago el Contado

  oDp:lLimCreDiv:=oData:Get("oDp:lLimCreDiv" ,.T.    )  // Limite de Crédito en Divisa

  oDp:cCodEdt   :="Indef"
  oDp:cCodRuta  :=REPLI("0",6)

  oDp:lAvicola  :=("Ave"$ALLTRIM(oDp:cForInv))

  //
  oDp:lRifCli      :=oData:Get("lRifCli"   ,.F.  )    // Rif utilizado para generar codigo del Cliente
  oDp:lRifPro      :=oData:Get("lRifPro"   ,.T.  )    // Rif utilizado para Generar Codigo del Proveedor 02/05/2025 Código=RIF
  oDp:lAutRif      :=oData:Get("lAutRif"   ,.F.  )    // Rif Automático

  // Activos
  oDp:lActAut      :=oData:Get("lActAut"      , .T.         ) // Códigos Automáticos
  oDp:nActLen      :=oData:Get("nActLen"      , 5           ) // Longitud del Código Automático

  IF oDp:cForInv="Estandar"
     oDp:cForInv:=""
  ENDIF

  //
  // Retenciones de IVA Automáticas.
  //

  oDp:lRetIva_A  :=oData:Get("lRetIva_A"  ,.F.            )  // Retención de IVA. Automático
  oDp:nRetIvaBase:=oData:Get("nRetIvaBase",0              )  // Retención de IVA (Base)
  oDp:cRetIslr_C :=oData:Get("cRetIslr_C" ,"R"            )  // Cuando se Aplica??? Cuando se Registra o Paga.
  oDp:cRetIva_C  :=oData:Get("cRetIva_C"  ,"R"            )  // Retención de IVA. Automático
  oDp:lAutoSeniat:=oData:Get("lAutoSeniat",.F.            )  // En las Versiones Anteriores no Existia por esto es .F.
  oDp:lRetIva_M  :=oData:Get("lRetIva_M"  ,.F.            )  // Retenciones de IVA Infinitas o Mensuales
  //oDp:nUTRetIva  :=oData:Get("nUTRetIva",20             )  // Unidad Tributaria para Aplicar Retenciones deIVA
  oDp:nRTIUT     :=oData:Get("nRTIUT"     ,20             )  // Unidad Tributaria para Aplicar Retenciones deIVA
  oDp:lDateSrv   :=oData:Get("lDateSrv"   ,oDp:lDateSrv   )  // Obtener la Fecha desde la Base de Datos
  oDp:lRetIvaMul :=oData:Get("lRetIvaMul"  ,.F.           )  // Retenciones de IVA Multiples
  oDp:lRTItodos  :=oData:Get("lRTItodos"  ,.T.            )  // Aplica retencion de IVA, todos los Casos
  oDp:lIncVtaInc :=oData:Get("lIncVtaInc" ,.T.            )  // Ventas Entes Públicos Declara Cuando se Factura
  oDp:lRTIFCHVEN :=oData:Get("lRTIFCHVEN" ,.F.            )  // Retenciones de IVA

  
  oDp:nNumRti    :=1
  oDp:aNumRti    :={"General"   ,"Multi-Retención","Correlativo" } //,"Año y Mes"}
  oDp:aFieldRti  :={"RTI_DOCNUM","RTI_NUMTRA"     ,"RTI_NUMCRR"} // ,"RTI_NUMRET"}

//? oDp:nNumRti,"oDp:nNumRti "
  oDp:nNumRti    :=oData:Get("nNumRti"    ,1                        )  // Número de Items

// ? oDp:nNumRti,"oDp:nNumRti"

  oDp:nNumRti    :=CTOO(oDp:nNumRti,"N")

  IF (oDp:nNumRti<1 .OR. oDp:nNumRti>LEN(oDp:aFieldRti))
    oDp:nNumRti:=1
  ENDIF

  oDp:cRif       :="" // RIF de la empresa depende de GETODRIF
  oDp:cNumRti    :=oData:Get("cNumRti"    ,oDp:aNumRti[oDp:nNumRti] )  // Campo del Numero

// ? oDp:cNumRti,oDp:nNumRti,"oDp:nNumRti"
//? ValType(oDp:nFchRti),"oDp:nFchRti",oDp:nNumRti,LEN(oDp:aFieldRti)

  oDp:cFieldRti  :=oDp:aFieldRti[oDp:nNumRti]

// ? oDp:cFieldRti,"EL PRIMER DIGITO",
  oDp:cFieldRti  :=IF(Empty(oDp:cFieldRti),"RTI_DOCNUM",oDp:cFieldRti)

// ? oDp:cFieldRti,"desde DPLOADCNF",oDp:nFchRti
// ? oDp:nFchRti,"oDp:nFchRti",ValType(oDp:nFchRti),LEN(oDp:aFieldRti),"? oDp:nFchRti",oDp:cFieldRti 
 
  oDp:aFchRti    :={"Emisión de la Retención","Declaración de Factura" }
  oDp:aFieldRtiF :={"DPDOCPRORTI.RTI_FECHA"  ,"DPDOCPRO.DOC_FCHDEC"}
  oDp:nFchRti    :=oData:Get("nFchRti"       ,1            ) 
  oDp:cFchRti    :=oDp:aFchRti[oDp:nFchRti]
  oDp:cFieldRtiF :=oDp:aFieldRtiF[oDp:nFchRti]

// oDp:cNumRti    :=oDp:aNumRti[oDp:nNumRti]
// ? oDp:nNumRti,ValType(oDp:nNumRti),oDp:cNumRti
// ? oDp:cFieldRtiF,"oDp:cFieldRtiF"

  //
  // Retenciones de ISLR Automáticas
  // 
  oDp:lRetIslr_A   :=oData:Get("lRetIslr_A"   ,.F.            )  // Retención de ISLR Automático
  oDp:lRetIslr_Cer :=oData:Get("lRetIslr_Cer" ,.F.            )  // Retención de ISLR en Cero

  oDp:lLib_Vta_CXC :=oData:Get("lLib_Vta_CXC" ,.F.            )  // Generar libro ventas si no tiene facturas pendientes

  // Origen de Libros Fiscales
  oDp:cLib_Vta_Org :=oData:Get("cLib_Vta_ORG" ,"Local"        )  // Origen de Libro de Ventas
  oDp:cLib_Com_Org :=oData:Get("cLib_Com_ORG" ,"Local"        )  // Origen de Compras de Ventas
  oDp:cLib_Inv_Org :=oData:Get("cLib_Inv_ORG" ,"Local"        )  // Origen de Compras de Inventaris
  oDp:cRet_Nom_Org :=oData:Get("cRet_Nom_ORG" ,"Local"        )  // Origen de Retenciones de Nómina
  oDp:cRet_Isr_Org :=oData:Get("cRet_Isr_ORG" ,"Local"        )  // Origen de Retenciones de ISLR
  oDp:cCaj_Itf_Org :=oData:Get("cCaj_Itf_ORG" ,"Local"        )  // Origen de ITF de Caja

  oDp:cLib_Vta_Xls :=oData:Get("cLib_Vta_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de Libro de Ventas
  oDp:cLib_Com_Xls :=oData:Get("cLib_Com_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de Compras de Ventas
  oDp:cLib_Inv_Xls :=oData:Get("cLib_Inv_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de Compras de Inventaris
  oDp:cRet_Nom_Xls :=oData:Get("cRet_Nom_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de Retenciones de ISLR Nómina
  oDp:cRet_Isr_Xls :=oData:Get("cRet_Isr_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de Retenciones de ISLR Pagos
  oDp:cCaj_Itf_Xls :=oData:Get("cCaj_Itf_Xls" ,SPACE(40)      )  // Modelo XLS,Origen de ITF de Caja
  oDp:cRifIva_ISLR :=oData:Get("cRifIva_ISLR" ,oDp:cId_Rif    )  // Código de Proveedor Seniat
  oDp:cCiiu        :=oData:Get("cCiiu"        ,""             )  // Código Actividad Económica
  oDp:cRifSeniat   :=oDp:cRifIva_ISLR

  // Conteo Físico
  oDp:cCodEnt   :=oDaTa:Get("cCodEnt"    ,"E001"   ) 
  oDp:cCodSal   :=oDaTa:Get("cCodSal"    ,"S001"   )

  // Entrega Productos del Personal
  oDp:cCodEntPer:=oDaTa:Get("cCodEntPer"    ,"E004"   ) 
  oDp:cCodSalPer:=oDaTa:Get("cCodSalPer"    ,"S004"   ) 

  oDp:cCodSalPic:=oDaTa:Get("cCodSalPic"    ,"S001" ) 
  oDp:cCodSalPac:=oDaTa:Get("cCodSalPac"    ,"S001" )  
  oDp:cCodTraNeu:=oDaTa:Get("cCodTraNeu"    ,"N000" ) 

  oDp:cMoneda      :=LEFT(oData:Get("cMoneda   ",oDp:cMoneda_Nac),3)  // Moneda Nacional
  oDp:cMonedaExt   :=LEFT(oData:Get("cMonedaExt",oDp:cMoneda_Ext),3)  // Moneda Extranjera

  IF Empty(oDp:cMoneda_Ext)
     oDp:cMoneda_Ext:="DBC"
  ENDIF

  IF ALLTRIM(oDp:cMonedaExt)$ALLTRIM(oDp:cMoneda) 
     oDp:cMonedaExt:=oDp:cMoneda_Ext
  ENDIF

  oDp:cMonedaPvP   :=ALLTRIM(SQLGET("DPPRECIOTIP","TPP_CODMON","TPP_CODIGO"+GetWhere("=",oDp:cPrecio)))

  IF Empty(oDp:cMonedaPvP)
     oDp:cMonedaPvP:=oDp:cMoneda
     SQLUPDATE("DPPRECIOTIP","TPP_CODMON",oDp:cMoneda,"TPP_CODMON IS NULL OR TPP_CODMON"+GetWhere("=",""))
  ENDIF

//? oDp:cMoneda,"oDp:cMoneda",oDp:cPrecio,oDp:cLista,"oDp:cMonedaPvP",oDp:cMonedaPvP,"<-oDp:cMonedaPvP"

  oDp:aTipPrecioExt:=ASQL("SELECT TPP_CODIGO FROM DPPRECIOTIP WHERE TPP_CODMON"+GetWhere("=",oDp:cMonedaPvP))
  oDp:cTipPrecioExt:=GetWhereOr("TPP_CODIGO",oDp:aTipPrecioExt)

  oDp:aMonExt      :=ASQL("SELECT TPP_CODMON FROM DPPRECIOTIP INNER JOIN DPTABMON ON MON_CODIGO=TPP_CODMON WHERE TPP_CODMON"+GetWhere("<>",oDp:cMoneda)+" AND TPP_CODMON"+GetWhere("<>",""))
  oDp:cMonExt      :=GetWhereOr("PRE_CODMON",oDp:aMonExt)
 
  IF !Empty(oDp:cMonExt)
    oDp:cMonExt:=" AND "+oDp:cMonExt
  ENDIF

  oDp:cMonedaBcv:="DBC"

  oDp:cClaCli    :=oData:Get("cClaCli"     ,STRZERO(1,6))  // Clasificacion de Clientes
  oDp:cActividad :=oData:Get("cActividad"  ,STRZERO(1,6))  // Actividad Econ½mina
  oDp:cActProvee :=oData:Get("cActProvee"  ,STRZERO(1,6))  // Actividad Proveedor

  oDp:cCaja      :=oData:Get("cCaja"       ,STRZERO(1,6))  // Codigo de Caja por Defecto
  oDp:cGrupoInv  :=oData:Get("cGrupoInv"   ,STRZERO(1,6))  // Grupos
  oDp:cMarcaInv  :=oData:Get("cMarcaInv"   ,STRZERO(1,6))  // Marcas
  oDp:cBilletes  :=oData:Get("cBilletes"   ,PADR("0.10,0.125,0.25,0.50,1,5,10,20,50,100,500,1000,2000,5000,10000,20000,50000",100))  // Marcas
  oDp:nPorRti    :=oData:Get("nPorRti"     ,75.00) // % Retenci½n de IVA
  oDp:cTipPer    :=oData:Get("cTipPer"     ,"Jurídica")    // Persona
  oDp:cTipCon    :=oData:Get("cTipCon"     ,"Ordinario")   // Contribuyente del IVA

  oDp:lConEsp    :=LEFT(oDp:cTipCon,1)="E" // Especial
  oDp:cTipCon    :=LEFT(oDp:cTipCon,1)

  oDp:lConEsp    :=oData:Get("lConEsp"   ,oDp:lConEsp )  // Contribuyente Especial

  oDp:cWhereTipConFyT:="FYT_CONORD=1"

  IF LEFT(oDp:cTipCon,1)="E"
    oDp:cWhereTipConFyT:="FYT_CONESP=1"
  ENDIF

  IF LEFT(oDp:cTipCon,1)="G"
    oDp:cWhereTipConFyT:="FYT_CONGUB=1"
  ENDIF

  // No puede Hacer Retenciones de IVA Automáticas
  IF !LEFT(oDp:cTipCon,1)="E"
     oDp:lRetIva_A  :=.F.
  ENDIF

  oDp:cOtrosImp  :=oData:Get("cOtrosImp" ,"R")           // Otros Impuestos (Absoluto o Relativo)
  oDp:cNumCom    :=oData:Get("cNumCom"   ,STRZERO(1,8))  // Comprobante  
  oDp:cCodTrans  :=oData:Get("cCodTrans" ,STRZERO(1,6))  // Transporte por Defecto
  oDp:lGuber     :=.F.  // Gubernamental

  IF oDp:cTipPer="Gobierno" //.OR. oDp:cTipPer="Jurídica Corporativa"
     oDp:lGuber:=.T.
  ENDIF


  // Datos de la Empresa
  oDp:cDir1         :=oData:Get("cDir1" ,SPACE(40))   // Dir 1
  oDp:cDir2         :=oData:Get("cDir2" ,SPACE(40))   // Dir 2
  oDp:cDir3         :=oData:Get("cDir3" ,SPACE(40))   // Dir 3
  oDp:cDir4         :=oData:Get("cDir4" ,SPACE(40))   // Dir 4
  oDp:cTel1         :=oData:Get("cTel1" ,SPACE(12))   // Tel 1
  oDp:cTel2         :=oData:Get("cTel2" ,SPACE(12))   // Tel 2
  oDp:cTel3         :=oData:Get("cTel3" ,SPACE(12))   // Tel 3
  oDp:cTel4         :=oData:Get("cTel4" ,SPACE(12))   // Tel 4
  oDp:cRif          :=oData:Get("cRif"  ,SPACE(10))   // RIF  
  oDp:cRif_         :=oData:Get("cRif"  ,SPACE(10))   // RIF 

  // 19/01/2025 Desde configurar empresa, sus valores podra cambiar según parametros del usuario. DPPRIGENLEE  
  // por defecto debe utilizar el plan de cuenta.

  oDp:P_LCtaEgrCxP:=oData:Get("LCtaEgrCxP",.F.)   // Cuentas de Egreso para uso Presupuestario
  oDp:P_LCtaEgrCxC:=oData:Get("LCtaEgrCxC",.F.)   // Cuentas de Egreso para uso Presupuestario

  // Si la empresa no tiene RIF, toma el RIF de la Licencia
  IF Empty(oDp:cRif) .AND. oDp:cEmpCod="0000"
     oDp:cRif:=oDp:cRifLic
  ENDIF

//  IF Empty(oDp:cRif)
//     oDp:cRif:=ALLTRIM(SQLGET("DPEMPRESA","EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod)))
//  ENDIF

  IF Empty(oDp:cRif)
     oDp:lExcluye:=.F.
     oDp:cRif:=ALLTRIM(SQLGET("DPEMPRESA","EMP_RIF","EMP_BD"+GetWhere("=",oDp:cDsnData)))
  ELSE
     SQLUPDATE("DPEMPRESA","EMP_RIF",oDp:cRif,"EMP_BD"+GetWhere("=",oDp:cDsnData))
  ENDIF

//?  oDp:cRif,"cambio de empresa dploadcnf" 

  oDp:cMail         :=oData:Get("cMail"    ,SPACE(30))    // Mail
  oDp:cCiudad       :=oData:Get("cCiudad"  ,SPACE(30))    // Ciudad
  oDp:dFchIniReg    :=oData:Get("dFchIniReg",CTOD(""))    // Fecha Inicio de Registro(constitución) de la Empresa
  oDp:dFchFinReg    :=oData:Get("dFchFinReg",CTOD(""))    // Fecha de Fin del Registro(constitución) de la Empresa 
  oDp:dFchInCalF    :=oData:Get("dFchInCalF",CTOD(""))    // Fecha Inicio Calendario Fiscal y Deberes Formales
  oDp:dFchConEsp    :=oData:Get("dFchConEsp",CTOD(""))    // Fecha de Inicio Contribuyente especial
  oDp:dFchActInv    :=oData:Get("dFchActInv",CTOD(""))    // Fecha de Inicio Actualización de Inventario
  oDp:dFchCxCDiv    :=oData:Get("dFchCxCDiv" ,CTOD("01/01/2021"))    // Fecha CxC Divisas
  oDp:dFchVencRif   :=oData:Get("dFchVencRif",CTOD(""))   // Fecha Vencimiento de RIF

  oDp:dFchCxCDiv    :=CTOO(oDp:dFchCxCDiv,"D")

// ? oDp:dFchIniReg,"oDp:dFchIniReg"

  IF Empty(oDp:dFchCxCDiv)
     oDp:dFchCxCDiv:=CTOD("01/01/2021")
  ENDIF

  oDp:cEmailEmp     :=oData:Get("cEmailEmp" , SPACE(250))

  oDp:cWeb          :=oData:Get("cWeb"  ,SPACE(30))   // Web

  //Aplicaciones por Sucursal, 5.1 Se define por Sucursal 14/10/2015
  oDp:lInvXSuc:=.F. // oData:Get("lInvXSuc",.F.)
  oDp:lProXSuc:=.F. // oData:Get("lProXSuc",.F.)
  oDp:lCliXSuc:=.F. // oData:Get("lCliXSuc",.F.)
  oDp:lBcoXSuc:=.F. // Cuentas Bancarias 

  // Reconversión Monetaria
  oDp:dFchIniRec:=oData:Get("dFchIniRec" , CTOD("  /  /    "))
  oDp:dFchFinRec:=oData:Get("dFchFinRec" , CTOD("  /  /    "))
  oDp:cCtaMonRec:=oData:Get("cCtaMonRec" , SPACE(20)         )

  // oDp:lSucComoEmp:=.F. // Sucursal Funciona como Empresa, su valor cambie en DPRUNEMP
  // Opciones de Men£

  // Debito Bancario
  oDp:nDebBanc   :=oData:Get("nDebBanc"   ,0       ,"N" ) // D‚bito Bancario
  oDp:dIdbIni    :=oData:Get("dIdbIni"    ,CTOD("") ) // Inicio Debito Bancario
  oDp:dIdbFin    :=oData:Get("dIdbFin"    ,CTOD("") ) // Inicio Debito Bancario
  oDp:cCtaIdb    :=oData:Get("cCtaIdb"    ,SPACE(20)) // Cuenta D‚bito Bancario
  oDp:cMotIGTF   :=oData:Get("cMotIGTF","007")     // IGTF documento del Cliente, el usuario decide si aplica Nota de Débito o no
  oDp:cMotDIFC   :=oData:Get("cMotDIFC","003")     // Credito por Diferencial Cambiario
  oDp:cMotDIFD   :=oData:Get("cMotDIFD","004")     // Débito  por Diferencial Cambiario

  // Uso de las Cuentas Contables

  oDp:cCtaBg1:=ALLTRIM(oData:Get("cCtaBg1" ,"1"))
  oDp:cCtaBg2:=ALLTRIM(oData:Get("cCtaBg2" ,"2")) 
  oDp:cCtaBg3:=ALLTRIM(oData:Get("cCtaBg3" ,"3")) 
  oDp:cCtaBg4:=ALLTRIM(oData:Get("cCtaBg4" ," ")) 


  oDp:cCtaGp1:=ALLTRIM(oData:Get("cCtaGp1" ,"4"))
  oDp:cCtaGp2:=ALLTRIM(oData:Get("cCtaGp2" ,"5"))
  oDp:cCtaGp3:=ALLTRIM(oData:Get("cCtaGp3" ,"6"))
  oDp:cCtaGp4:=ALLTRIM(oData:Get("cCtaGp4" ,"7"))
  oDp:cCtaGp5:=ALLTRIM(oData:Get("cCtaGp5" ,""))
  oDp:cCtaGp6:=ALLTRIM(oData:Get("cCtaGp6" ,"")) 

  oDp:cCtaCo1:=ALLTRIM(oData:Get("cCtaCo1" ,""))  // Cuentas de Orden Activo
  oDp:cCtaCo2:=ALLTRIM(oData:Get("cCtaCo2" ,""))  // Cuentas de Orden Pasivo

  oDp:lDebCre:=oData:Get("lDebCre" ,IF(oDp:nVersion>=5.1,.T.,.F.)) // Columnas de Comprobante

  IF ISPCPRG()
     oDp:lDebCre:=.T.
  ENDIF

  oDp:nClrDebe :=oData:Get("nClrDebe" , IF(oDp:nVersion>=6,CLR_HBLUE,0)) // Color Debe
  oDp:nClrHaber:=oData:Get("nClrHaber", IF(oDp:nVersion>=6,CLR_HRED ,0)) // Color Haber


  oDp:cBalCre:=oData:Get("cBalCre" ,"-") // Créditos en Balance General
  oDp:lCenCos:=oData:Get("lCenCos", .F.) // Cuentas con Centros de Costos
  oDp:lNumCom:=oData:Get("lNumCom", .F.) // Agrupa Asientos por Modulos               

  oDp:lMovBcoPag:=oData:Get("lMovBcoPag" ,.T.) // Asientos Contables de movimientos Bancarios seran realizados Fecha del Comprobantes de Pago
  oDp:lMovBcoRec:=oData:Get("lMovBcoRec" ,.T.) // Asientos Contables de movimientos Bancarios seran realizados Fecha del Recibo de Ingreso

  // Datos de los Seriales
  oDp:cSerialLen :=oData:Get("cSerialLen"  ,  15 )
  oDp:cSerialCant:=oData:Get("cSerialCant" ,   4 )
  oDp:cSerialSep :=oData:Get("cSerialSep"  , "," )
  oDp:lSerialZero:=oData:Get("lSerialZero" , .F. )

  // Indentifica los Memos para los Grid según Cada Sucursal, necesario para las Replicaciones
  IF oDp:lIdSucMemo  .AND. !Empty(oDp:cSucursal)
    oDp:cIdMemo  :=oDp:cSucursal 
  ENDIF

  // Posiblemente DPSUCURSAL esta Vacia , no puede ser NILL
  DEFAULT oDp:cIdMemo:=""  

  oDp:cCodSbd    :=oData:Get("cCodSbd"   ,SQLGET("DPSERVERBD","SBD_CODIGO")) // Código del Servidor de la Base de Datos
  oDp:cCodSbdId  :=oData:Get("cCodSbdId" ,"")                                // Identificación de Sucursal

  // Color del menu por Empresa
  oData:End(.F.)

  // Buscadores Iniciales en LBX
  oData:=DATASET("LBXFIND","ALL")

  oDp:lDPCLIENTES   :=oData:Get("DPCLIENTES"   ,.F.) // Buscador Inicial
  oDp:lDPINV        :=oData:Get("DPINV"        ,.F.) // Buscador Inicial
  oDp:lDPPROVEEDOR  :=oData:Get("DPPROVEEDOR"  ,.F.) // Buscador Inicial
  oDp:lDPCTA        :=oData:Get("DPCTA"        ,.F.) // Buscador Inicial
  oDp:lDPCTAEGRESO  :=oData:Get("DPCTAEGRESO"  ,.F.) // Buscador Inicial
  oDp:lLbxIniFind   :=oData:Get("LBXINIFIND"   ,.F.) // Buscador Inicial

  oData:End(.F.)


  oData:=DATASET("EMPRESA","USER")
  oDp:cSucursal  :=oData:Get("cSucursal" ,STRZERO(1,6))
  oDp:cAlmacen   :=oData:Get("cAlmacen"  ,SQLGET("DPALMACEN","ALM_CODIGO"))

  oDp:cCenCos    :=oData:Get("cCenCos"   ,STRZERO(1,8))
  oDp:cCodDep    :=oData:Get("cCodDep"   ,SQLGET("DPDPTO"    ,"DEP_CODIGO"))
  oDp:cCodCaja   :=oData:Get("cCodCaja  ",SQLGET("DPCAJA","CAJ_CODIGO","CAJ_ACTIVO=1"))
  oDp:dFchUltima :=oData:Get("dFchUltima",oDp:dFecha ) // Determina la ultima Fecha
  oDp:cComGav    :=oData:Get("cComGav"   ,""         ) // Gaveta por Usuario

  IF !ISSQLFIND("DPCAJA","CAJ_CODIGO"+GetWhere("=",oDp:cCodCaja))
     oDp:cCodCaja:=SQLGETMIN("DPCAJA","CAJ_CODIGO")
  ENDIF

  oData:End(.F.)

  // Permisos por Usuario
  oDp:lPermisos:=.T. // Si puede Otorgar permisos por Usuario
  oDp:lCuentas :=.T. // Si puede Asignar Cuentas Contables
  oDp:lTactil  :=.F. // Indica si Tiene TouchScreen
  oDp:lCliToRif:=.F. // Copiar Clientes hacia RIF

  // Por Usuario

  oData:=DATASET("MENUFICHA","USER")
  oDp:lClienteMnu:=oData:Get("lClienteMnu",.T.)   // Menu Cliente
  oDp:lInveMnu   :=oData:Get("lInvMnu"    ,.T.)   // Productos
  oDp:lProveeMnu :=oData:Get("lProveeMnu" ,.T.)   // Proveedor
  oData:End(.F.)

  // D¡as de Vencimiento para Clientes y Proveedores
  oData:=DATASET("DIASVENCE","USER")
  oDp:nVenceCli1:=oData:Get("CLIVENCE1" ,  0 )       // Vencimiento 1
  oDp:nVenceCli2:=oData:Get("CLIVENCE2" , 30 )       // Vencimiento 2
  oDp:nVenceCli3:=oData:Get("CLIVENCE3" , 60 )       // Vencimiento 3
  oDp:nVenceCli4:=oData:Get("CLIVENCE4" , 90 )       // Vencimiento 4
  oDp:nVenceCli5:=oData:Get("CLIVENCE5" ,120 )       // Vencimiento 4

  oDp:lRunLoadCnf:=.T.

  // Valores de Producción
  oDp:cAlmPrd :=oDp:cAlmacen

  EJECUTAR("DPSUCCUANTOS"   ) // Cuenta Cuantas Sucursales y Almacenes estan definidas
  EJECUTAR("DPRUNCENCOS", NIL , .F.)
  EJECUTAR("DPRUNCAJA"  , NIL , .F.)

  // Ejecuta la Sucursal
  DpMsgSetText("Lectura de IVA")

  EJECUTAR("IVALOAD")
  EJECUTAR("DPBUILDWHERE"   ) // Crea las restricciones por usuario, lo hace el Cambio de Usuario
  DpMsgSetText("Lectura de Tipos de Documentos")

  EJECUTAR("DPTIPDOCCLILOAD") // Valores de Documentos del Cliente
  EJECUTAR("DPTIPDOCPROLOAD") // Valores de Documentos del Proveedor
  EJECUTAR("DPTALLAS_INDEF" ) // Crear variable oDp:cCodTalla
  EJECUTAR("DPVENDEDOR_INDEF") // Cliente indefinido

  EJECUTAR("DPGRU_INDEF"    ) // Crear grupos
  EJECUTAR("FCH_EJER"       ) // Toma la Fecha del Ejercicio
  EJECUTAR("DPPRIGENLEE"    ) // Privilegios Generales
  oDp:cNumEje:=EJECUTAR("GETNUMEJE",oDp:dFecha,.T.) // Crea el Nuevo Ejercicio

  // Condiciones para los Precios
  oDp:cFeriados    :=EJECUTAR("NMFERIADOSLEE") // detectar dias feriados
  EJECUTAR("DPPRECIOTIPLOAD")

  oDp:lNomina:=.T. // COUNT("NMTRABAJADOR")>0

  DEFAULT oDp:cCtaMod:=SQLGETMIN("DPCTAMODELO","MPC_CODIGO","MPC_ACTIVO=1")

  oDp:cCodTer:=SQLGETMIN("DPTERCEROS","TDC_CODIGO","TDC_CODIGO"+GetWhere("<>",""))

  IF Empty(oDp:cCodTer)
    EJECUTAR("DPCREATERCEROS",oDp:cCodTer)
  ENDIF

  IF COUNT("DPCTA","CTA_ACTIVO=0")>COUNT("DPCTA","CTA_ACTIVO=1")
    SQLUPDATE("DPCTA","CTA_ACTIVO",.T.) // JN Remover 09/11/2016, Activa todas las cuentas Contables
  ENDIF

  // Debe Activar la Moneda
  SQLUPDATE("DPTABMON","MON_ACTIVO",.T.,"MON_CODIGO"+GetWhere("=",oDp:cMoneda))

  oDp:aMonedas:=aTable("SELECT MON_CODIGO,MON_DESCRI FROM DPTABMON WHERE MON_ACTIVO=1",.T.)

  EJECUTAR("DPDIARIO",oDp:dFecha,.F.) // no debe eliminar el año

  EJECUTAR("EMPSAVECONF")

  IF COUNT("DPDOCPROPROG","PLP_CODSUC"+GetWhere("=",cCodSuc)+" AND YEAR(PLP_FECHA)=2025 AND PLP_TIPDOC"+GetWhere("=","F30"))=0 .AND. !Empty(oDp:cRif)
    EJECUTAR("CREAA26")        // Crear A26
    // EJECUTAR("DPGENCALFISCSV") // Generar Calendario Fiscal
    EJECUTAR("CALFIS2025")     // genera Calendario fiscal 2024
  ENDIF

  *********AG20080129
  *********SE AGREGAN ESTAS VARIABLES PARA SER USADAS EN RANGO POR LOS BROWSE DE LOS DOCUMENTOS
  oDp:dFchIniDoc:=CTOD(SPACE(8))
  oDp:dFchFinDoc:=CTOD(SPACE(8))

  AUDITAR("CINI" , .F. ,NIL , "Ingresar a Empresa",oDp:cDpAudita)

  // Validar Moneda o Divisa.
  IF !ISSQLFIND("DPTABMON","MON_CODIGO"+GetWhere("=",oDp:cMoneda )) .AND. lDpConfig 
     //MensajeErr(oDp:xDPTABMON+" ="+oDp:cMoneda+" no está Registrado")
     EJECUTAR("CREATERECORD","DPTABMON",{"MON_CODIGO","MON_DESCRI","MON_APLICA","MON_ACTIVO"},{oDp:cMoneda,oDp:cMoneda,"*",.T.},NIL,.T.,"MON_CODIGO"+GetWhere("=",oDp:cMoneda))
     EJECUTAR("DPCONFIG",cCodSuc)
  ENDIF

  cWhere:="EOR_CODIGO"+GetWhere("=",oDp:cRif)

  EJECUTAR("PLUGIN_EMP")
  EJECUTAR("DPACTIVIDAD_E_CREA") // crear actividad económica
  EJECUTAR("DPPROCLA_CREA",NIL,NIL,.F.)

  // Indica si usuario Graba Datos para el ERP/EMANAGER
  DEFAULT oDp:lSaveErp:=.F.

//  EJECUTAR("DPLOADCNFCHKFCH")

  oDp:cTipFch :=SQLGET("DPEMPRESA","EMP_TIPFCH,EMP_FCHULT,EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))

  oDp:lExcluye:=.F.

  IF !Empty(DPSQLROW(3)) .AND. Empty(cCodSuc)
    oDp:cRif    :=ALLTRIM(DPSQLROW(3))
  ENDIF

  // Asume la Fecha según el Tipo de Empresa

  oDp:cTipFch :=IIF(Empty(oDp:cTipFch),"S", oDp:cTipFch )
  oDp:dFchUlt :=DPSQLROW(2)
  oDp:dFchUlt :=IIF(Empty(oDp:dFchUlt),oDp:dFecha,oDp:dFchUlt)
  oDp:lDateSrv:=(oDp:cTipFch="S")

  IF LEFT(oDp:cTipFch,1)="U"
     oDp:dFecha:=oDp:dFchUlt
  ENDIF

  IF !LEFT(oDp:cTipFch,1)="U"
    SQLUPDATE("DPEMPRESA",{"EMP_FCHULT","EMP_ACTIVA","EMP_BDREL","EMP_TABUPD"},{oDp:dFecha,.T.,oDp:cBdRelease,oDp:cBdRelease},"EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
  ELSE
    SQLUPDATE("DPEMPRESA",{"EMP_ACTIVA","EMP_BDREL","EMP_TABUPD"},{.T.,oDp:cBdRelease,oDp:cBdRelease},"EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
  ENDIF

  oDp:cRif:=ALLTRIM(oDp:cRif)

  oDp:cCodEst:=SQLGET("DPESTRUCTORG","EOR_CODIGO","EOR_CODIGO"+GetWhere("=",oDp:cRif)) // Codigo para la Planificacion Financiera

  IF Empty(oDp:cCodEst) .AND. !Empty(oDp:cRif)
    EJECUTAR("DPESTRUCTORGCODEST")
    EJECUTAR("DPESTRUCTORGCREA")
    oDp:cCodEst     :=SQLGET("DPESTRUCTORG","EOR_CODIGO","EOR_CODIGO"+GetWhere("=",oDp:cRif)) // Codigo para la Planificacion Financiera
  ENDIF

  // Si la Sucursal es Empresa, asume el RIF de la Sucursal
  DpMsgSetText("Lectura Sucursal")

  EJECUTAR("DPRUNSUC"   , NIL , .F.,.F.) 

  oDp:lSaveErp:=SQLGET("DPUSUARIOS","OPE_ERPEMN","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

  IF (Empty(oDp:dFchIniReg) .AND. oDp:cTipPer<>"N") .AND. lDpConfig .AND. .F.
     MsgMemo("Es necesario Registrar El RIF y fecha de Constitución de la Empresa")
     EJECUTAR("DPCONFIG")
     RETURN .T.
  ENDIF

  DEFAULT  oDp:lDateSrv:=.T.

  // JN 09/11/2016 Cuando se Activa la Traza de Ejecución no se Ejecuta DPFECHASRV

  // Crea el Calendario de Deberes formales del Ejercicio
  IF lDpConfig  
     EJECUTAR("DPFORMYTAREASCREAPRG")
  ENDIF

  // Crear Variable oDp:cCodPer

  DPGETPERSONAL()
  EJECUTAR("DPCTAPRESUP_INDEF") 
  EJECUTAR("DPCLACTAEGRE_CREA") // necesario para las cuentas de Egreso no genere incidencia

  EJECUTAR("MYLOADCNF")
  // DPCREARREGINDEF EJECUTAR("DPTIPCXPPROGSAVE") // Agrega Planificación DPTIPCXPPROG
  EJECUTAR("DPTABMONVAR")      // Genera Variables para Divisas.


  // Determinar Ultima fecha del IPC/INPC
  oDp:bFchIpc:={|dFecha|dFecha:=SQLGET("DPIPC","CONCAT(IPC_ANO,IPC_MES)","IPC_TASA>0 ORDER BY CONCAT(IPC_ANO,IPC_MES) DESC LIMIT 1"),;
                              dFecha  :=CTOD("01/"+RIGHT(dFecha,2)+"/"+LEFT(dFecha,4)),dFecha}

  oDp:bFchInpc:={|dFecha|dFecha:=SQLGET("DPIPC","CONCAT(IPC_ANO,IPC_MES)","IPC_INPC>0 ORDER BY CONCAT(IPC_ANO,IPC_MES) DESC LIMIT 1"),;
                              dFecha  :=CTOD("01/"+RIGHT(dFecha,2)+"/"+LEFT(dFecha,4)),dFecha}

  /*
  // 22/09/2016
  */
  EJECUTAR("NMLOADCNF")
  EJECUTAR("RMULOADCNF")      // 01/10/2016 Retenciones Municipales

  EJECUTAR("GENCALFISNEXT")   // Calendario Fiscal Año siguiente (Creado Diciembre Actual)

  IF ALLTRIM(oDp:cMoneda)=ALLTRIM(oDp:cMonedaExt)
    oDp:cKPI     :="D"       // Indicador Divisa 
    EJECUTAR("KPIIMPDIVISA") // Importar Indicador de Divisa
  ENDIF
  
  IF oDp:lDataCrea
    DpMsgSetText("Creando Catalogos")
    EJECUTAR("DPUPDATECATALOG") // 03/10/2016 Actualiza los Catalogos en tablas maestras incluyendo nuevos tipos de documentos
  ENDIF

  oDp:lDataCrea:=.F.
  EJECUTAR("DPDPTOCREA")  // Crea la Variable oDp:cDepIndef
  EJECUTAR("DPLOADCNFUPDATE")
  EJECUTAR("DPLOADCNFPOST")

  EJECUTAR("KPIDIVISAGET") // Variables Requeridas 

  IF COUNT("DPBANCODIR",[ NOT (BAN_CODIGO="" OR BAN_CODIGO IS NULL)])<=1
     EJECUTAR("DPBANCODIRFROMCSV")
  ENDIF

  oData:End(.F.)
  DpMsgClose()

  cCodigo:=SQLGET("DPCAJAINST","ICJ_CODIGO")

  IF !ValType(cCodigo)="C"
     CHECKTABLE("DPCAJAINST")
  ENDIF

  SQLUPDATE("DPCAJAINST","ICJ_CODMON",oDp:cMoneda,"ICJ_CODIGO"+GetWhere("=","EFE"))

  IF COUNT("DPCAJAINST","ICJ_ACTIVO=1")=0
     SQLUPDATE("DPCAJAINST","ICJ_ACTIVO",.T.)
  ENDIF

  IF COUNT("DPBANCOTIP","TDB_ACTIVO=1")=0
     SQLUPDATE("DPBANCOTIP","TDB_ACTIVO",.T.)
  ENDIF

  // JN 09/11/2016 Cuando se Activa la Traza de Ejecución no se Ejecuta DPFECHASRV
  IF oDp:lDateSrv .AND. !Empty(oDp:cFileToScr)

     bValFecha:={|dFecha|dFecha:=oDp:dFecha,;
                         EJECUTAR("DPFECHASRV"),;
                         IF(dFecha<>oDp:dFecha,EJECUTAR("DPBARMSG"),NIL) }
     // Cada Minuto Revisa la Fecha del Servidor

     DPSETTIMER(bValFecha,"FECHADELSERVIDOR",30) 

  ELSE

     bValFecha:=NIL
     DPSETTIMER(bValFecha,"FECHADELSERVIDOR",0) 

  ENDIF

  EJECUTAR("SETREGVEN") // Asigna Pais Venezuela

  DEFAULT oDp:cPictPrecio:=FIELDPICTURE("DPMOVINV" ,"MOV_PRECIO" ,.T.),;
          oDp:cPictPeso  :=FIELDPICTURE("DPMOVINV" ,"MOV_PESO"   ,.T.),;
          oDp:cPictCanUnd:=FIELDPICTURE("DPMOVINV" ,"MOV_CANTID" ,.T.),;
          oDp:cPictTotRen:=FIELDPICTURE("DPMOVINV" ,"MOV_TOTAL"  ,.T.),;
          oDp:cPictCosto :=FIELDPICTURE("DPMOVINV" ,"MOV_COSTO"  ,.T.),;
          oDp:cPictValCam:=FIELDPICTURE("DPDOCPRO" ,"DOC_VALCAM" ,.T.),;
          oDp:cPictComCan:=FIELDPICTURE("DPCOMPPRODUCCION","COM_CANTID" ,.T.)

  oDp:cPictPrecio:=ALLTRIM(SQLGET("DPCAMPOS","CAM_FORMAT","CAM_TABLE"+GetWhere("=","DPMOVINV")+" AND CAM_NAME"+GetWhere("=","MOV_PRECIO")))
  oDp:cPictValCam:=ALLTRIM(SQLGET("DPCAMPOS","CAM_FORMAT","CAM_TABLE"+GetWhere("=","DPHISMON")+" AND CAM_NAME"+GetWhere("=","HMN_VALOR")))

  IF !".9"$oDp:cPictValCam
    oDp:cPictValCam:=STRTRAN(oDp:cPictValCam,".","")+".9999"
  ENDIF

  // Plan de Cuenta Según el Ejercicio
  EJECUTAR("FCH_EJERGET")
  EJECUTAR("DPBALANZALOAD")

  BuildMenu() // 16/12/2023 Repinta el menú segun al empresa seleccionada	

  EJECUTAR("DPMAPACAMLEE") // lee los permisos de campos por usuarios

  oDp:dFchLibInv:=SQLGET("DPLIBINV","LIV_FECHA","LIV_CODSUC"+GetWhere("=",oDp:cSucursal)+" ORDER BY LIV_FECHA DESC LIMIT 1")

  oData   :=DATACONFIG("PLAFIN","ALL")
     
  oDp:dFchIniPla :=oData:Get("dFchIniPla"  ,CTOD("")       )
  oDp:dFchFinPla :=oData:Get("dFchFinPla"  ,CTOD("")       )
  oDp:cCodMonPla :=oData:Get("cCodMonPla"  ,oDp:cMonedaExt )
  oData:End()

  // Necesario para la listas de Precios, requiere en Bs

  IF COUNT("DPSUCURSAL","SUC_ACTIVO=1")=1
     SQLUPDATE("DPSUCURSAL","SUC_EMPRES",.F.,"SUC_ACTIVO=1")
  ENDIF

  SETDOCFISCAL(NIL,.T.) // Lectura de documentos Fiscales

  DpMsgSetText("Lectura Valores Divisa")

  EJECUTAR("KPIDIVISAGET")

  oDp:lLoadCnf:=.T.

  DpMsgClose()
  CursorArrow()
  oDp:lMYSQLCHKCONN:=.T.
  oDp:lBRWRESTOREPAR:=.T.  // 21/12/2024
  oDp:lEmpresaRunIni:=.F.  // Necesario para el programa SQLMSGERR resuelva automaticamente

RETURN NIL

/*
// Determina el Codigo del Personal
*/
FUNCTION DPGETPERSONAL()

  DEFAULT oDp:cCodPer:=SQLGET("DPPERSONAL","PER_CODIGO")

  IF !Empty(oDp:cCedulaUs)
     oDp:cCodPer:=SQLGET("DPPERSONAL","PER_CODIGO","PER_CEDULA"+GetWhere("=",oDp:cCedulaUs))
  ENDIF

  IF Empty(oDp:cCodPer)
     oDp:cCodPer:=SQLGET("DPPERSONAL","PER_CODIGO")
  ENDIF



RETURN oDp:cCodPer

/*
// Determina el Codigo del Personal
*/
FUNCTION DPGETDPINVTRAN()

  DEFAULT oDp:cCodTran:=SQLGET("DPINVTRAN","TAB_CODIGO","TAB_CODIGO"+GetWhere("<>",""))

RETURN oDp:cCodTran

// EOF
