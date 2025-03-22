// Programa   : DPTIPDOCCLINUM_CREA
// Fecha/Hora : 23/10/2024 05:34:36
// Propósito  : Registro de Afiliados para acceder mediante SAS
// Creado Por : Juan Navas
// Llamado por: DPINIADDFIELD       
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL aFields:={}
   LOCAL cCodigo,cDescri,lRun,cSql
   LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
   LOCAL cTable:="DPTIPDOCCLINUM" 

   // Registros DPDOCCLI, debe tener integridad referencial

   IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable)      ) .OR. ;
      !ISSQLFIND("DPCAMPOS","CAM_NAME"  +GetWhere("=","TDN_EDITAR")) 

     AADD(aFields,{"TDN_CODSUC","C",006,0,"Código Sucursal"   ,""})
     AADD(aFields,{"TDN_TIPDOC","C",003,0,"Tipo de Documento" ,""})
     AADD(aFields,{"TDN_SERFIS","C",002,0,"Serie;Fiscal"      ,""})
     AADD(aFields,{"TDN_LEN"   ,"N",010,0,"Longitud"          ,""})
     AADD(aFields,{"TDN_ZERO"  ,"L",001,0,"Relleno"           ,""})
     AADD(aFields,{"TDN_NUMERO","C",010,0,"Número;Doc."       ,""})
     AADD(aFields,{"TDN_PICTUR","C",015,0,"Picture"           ,""})
     AADD(aFields,{"TDN_ACTIVO","L",001,0,"Activo"            ,""})
     AADD(aFields,{"TDN_EDITAR","L",001,0,"Editar"            ,""})
     AADD(aFields,{"TDN_NUMULT","C",010,0,"Ultimo;Número"     ,""})
     AADD(aFields,{"TDN_LLAVE" ,"C",250,0,"Llave"             ,""})

     EJECUTAR("DPTABLEADD",cTable,"Tipo de Documento Númeración","<MULTIPLE>",aFields)

     EJECUTAR("SETPRIMARYKEY",cTable,"TDN_CODSUC,TDN_TIPDOC,TDN_SERFIS",.T.)

     AEVAL(aFields,{|a,n|  EJECUTAR("DPCAMPOSADD" ,cTable,a[1],a[2],a[3],a[4],a[5])})

  ENDIF

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cTable,.F.)
     Checktable(cTable)
  ENDIF

  EJECUTAR("SETFIELDLONG",cTable,"TDN_SERFIS" ,2) // Número de Serie Fiscal

  EJECUTAR("DPLINKADD"  ,"DPSERIEFISCAL",cTable,"SFI_LETRA" ,"TDN_SERFIS",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD"  ,"DPTIPDOCCLI"  ,cTable,"TDC_TIPO"  ,"TDN_TIPDOC",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD"  ,"DPSUCURSAL"   ,cTable,"SUC_CODIGO","TDN_CODSUC",.T.,.T.,.T.)

RETURN .T.
// EOF
