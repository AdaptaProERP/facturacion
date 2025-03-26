// Programa   : DPCONDPAGO_CREAREG
// Fecha/Hora : 20/02/2025 04:17:18
// Propósito  : Crear Registros
// Creado Por : Juan Navas
// Llamado por: DATACREA
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
 LOCAL oDb:=OpenOdbc(oDp:cDsnData)

 LOCAL lCliente:=.T.
 LOCAL lProvee :=.T.
 LOCAL lIntern :=.T.
 LOCAL lOperat:=.T.
 LOCAL lComerc:=.T.
 LOCAL lFiscal:=.T.
 LOCAL I,aData:={}

 IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPCONDPAGO","CPG_FISCAL") 
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_FISCAL","L",01,0,"Fiscal")      // facturas
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_COMERC","L",01,0,"Comercial")   // cotizaciones 
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_OPERAT","L",01,0,"Operativo")   // proyectos
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_CLIENT","L",01,0,"Clientes")    // Clientes
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_PROVEE","L",01,0,"Proveedores") // Proveedores
   EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_INTERN","L",01,0,"Interno")     // Interno
 ENDIF


 AADD(aData,{"CREDITO"               ,!lOperat,lComerc ,lFiscal, lCliente, lProvee,!lIntern})
 AADD(aData,{"CONTADO"               ,!lOperat,lComerc ,lFiscal, lCliente, lProvee,!lIntern})
 AADD(aData,{"TRASLADO PARA MAQUILA" , lOperat,!lComerc,lFiscal,!lCliente, lProvee, lIntern})
 AADD(aData,{"TRASLADO PARA SUCURSAL", lOperat,!lComerc,lFiscal,!lCliente,!lProvee, lIntern})
 AADD(aData,{"TRASLADO PARA OBRAS"   , lOperat,!lComerc,lFiscal,!lCliente,!lProvee, lIntern})
 AADD(aData,{"TRASLADO PARA REPARAR" , lOperat,!lComerc,lFiscal,!lCliente, lProvee, lIntern})

 FOR I=1 TO LEN(aData)

   IF .t. 
//!ISSQLFIND("DPCONDPAGO","CPG_CODIGO"+GetWhere("=",aData[I,1]))

     EJECUTAR("CREATERECORD","DPCONDPAGO",{"CPG_CODIGO","CPG_ACTIVO","CPG_OPERAT","CPG_COMERC","CPG_FISCAL","CPG_CLIENT","CPG_PROVEE","CPG_INTERN"},;
                                          {aData[I,1]  ,.T.         ,aData[I,2]  ,aData[I,3]  ,aData[I,3]  ,aData[I,4]  ,aData[I,5]  ,aData[I,6]},;
                                   NIL,.T.,"CPG_CODIGO"+GetWhere("=",aData[I,1]))

   ENDIF

 NEXT I

RETURN
/*

  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_FISCAL","L",01,0,"Fiscal")      // facturas
  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_COMERC","L",01,0,"Comercial")   // cotizaciones 
  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_OPERAT","L",01,0,"Operativo")   // proyectos
  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_CLIENT","L",01,0,"Clientes")    // Clientes
  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_PROVEE","L",01,0,"Proveedores") // Proveedores
  EJECUTAR("DPCAMPOSADD","DPCONDPAGO","CPG_INTERN","L",01,0,"Interno")     // Interno


C001=CPG_CODIGO          ,'C',060,0,'PRIMARY KEY NOT NULL','Descripción',0,''
 C002=CPG_ACTIVO          ,'L',001,0,'','Activo',0,'.T.'
 C003=CPG_COMERC          ,'L',001,0,'','Comercial',0,''
 C004=CPG_CUOTAS          ,'N',003,0,'','Cantidad de Cuotas',0,''
 C005=CPG_DIAS            ,'N',003,0,'','Plazo de Pago',0,''
 C006=CPG_EDICUO          ,'L',001,0,'','Edita Cuotas',0,'.T.'
 C007=CPG_EDITA           ,'L',001,0,'','Dias editables',0,''
 C008=CPG_ENTREG          ,'L',001,0,'','Entregable',0,'.F.'
 C009=CPG_FISCAL          ,'L',001,0,'','Fiscal',0,''
 C010=CPG_GASADM          ,'L',001,0,'','Gastos Administrativos',0,'.F.'
 C011=CPG_MEMO            ,'M',010,0,'','Comentario',0,''
 C012=CPG_NUMDOC          ,'C',010,0,'','Número Documento',1,''
 C013=CPG_OPERAT          ,'L',001,0,'','Operativo',0,''
 C014=CPG_OPERAV          ,'L',001,0,'','Operativo',0,''
[END_FIELDS]
*/


RETURN
