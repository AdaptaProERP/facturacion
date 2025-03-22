// Programa   : DPTIPDOCCLITOT_CREA
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
   LOCAL cTable:="DPTIPDOCCLITOT" // totalizador diario
   
   IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable)) .OR. ;
      !ISSQLFIND("DPCAMPOS","CAM_NAME"  +GetWhere("=","TDT_SERFIS"))

     AADD(aFields,{"TDT_CODSUC","C",006,0,"Código Sucursal"    ,""})
     AADD(aFields,{"TDT_TIPDOC","C",003,0,"Tipo de Documento"  ,""})
     AADD(aFields,{"TDT_FECHA" ,"D",010,0,"Fecha"              ,""})
     AADD(aFields,{"TDT_SERFIS","C",002,0,"Serie;Fiscal"       ,""})
     AADD(aFields,{"TDT_CANTID","N",010,0,"Cant.;Reg."         ,""})
     AADD(aFields,{"TDT_CANMOV","N",010,0,"Reg.;Items"         ,""})
     AADD(aFields,{"TDT_BASIMP","N",019,2,"Base Imponible"     ,""})
     AADD(aFields,{"TDT_MTOIVA","N",019,2,"Monto IVA"          ,""})
     AADD(aFields,{"TDT_MTOEXE","N",019,2,"Monto Exento"       ,""})
     AADD(aFields,{"TDT_MTONET","N",019,2,"Monto Neto"         ,""})
     AADD(aFields,{"TDT_ENCRIP","C",250,2,"Encriptado"         ,""})

     EJECUTAR("DPTABLEADD",cTable,"Totales por Tipo de Documento","<MULTIPLE>",aFields)

     EJECUTAR("SETPRIMARYKEY",cTable,"TDT_CODSUC,TDT_TIPDOC,TDT_SERFIS,TDT_FECHA",.T.)

     AEVAL(aFields,{|a,n|  EJECUTAR("DPCAMPOSADD" ,cTable,a[1],a[2],a[3],a[4],a[5])})

  ENDIF

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cTable,.F.)
     Checktable(cTable)
  ENDIF

  EJECUTAR("SETFIELDLONG",cTable,"TDT_SERFIS" ,2) // Número de Serie Fiscal

  EJECUTAR("SETPRIMARYKEY",cTable,"TDT_CODSUC,TDT_TIPDOC,TDT_SERFIS,TDT_FECHA",.T.)
  EJECUTAR("DPLINKADD"  ,"DPSERIEFISCAL",cTable,"SFI_LETRA" ,"TDT_SERFIS",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD"  ,"DPTIPDOCCLI"  ,cTable,"TDC_TIPO"  ,"TDT_TIPDOC",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD"  ,"DPSUCURSAL"   ,cTable,"SUC_CODIGO","TDT_CODSUC",.T.,.T.,.T.)

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"VIEW_DPDOCCLI_RDF",.F.)
     EJECUTAR("VIEW_DPDOCCLI_RDF")
  ENDIF
 
RETURN .T.
// EOF
