// Programa   : DPSERIEFISCALFIX
// Fecha/Hora : 01/03/2025 06:00:05
// Propósito  : Resolver series fiscales
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL oDb:=OpenOdbc(oDp:cDsnData),cSql,cWhere,oTable,cNumero

/*
   EJECUTAR("DPTIPDOCCLINUM_CREA")  // Numeración de Documentos
   EJECUTAR("DPTIPDOCCLINUM_IMPOR") // Crea los registros

   cSql:=[ UPDATE dpdoccli ]+;
         [ INNER JOIN dpsucursal     ON SUC_CODIGO=DOC_CODSUC AND SUC_ACTIVO=1 ]+;
         [ INNER JOIN dptipdocclinum ON DOC_CODSUC=TDN_CODSUC AND DOC_TIPDOC=TDN_TIPDOC ]+;
         [ SET DOC_SERFIS=TDN_SERFIS ]+;
         [ WHERE LEFT(DOC_NUMERO,1)<>"" AND  (DOC_TIPDOC="TIK" OR DOC_TIPDOC="DEV" OR DOC_TIPDOC="FAV" OR DOC_TIPDOC="CRE" OR DOC_TIPDOC="DEB" OR DOC_TIPDOC="FAM") ]

   oDb:EXECUTE(cSql)

*/

   /*
   // Crea series fiscales segun primer digito, no se puede agregar letras
   */

   cSql:=[SELECT DOC_CODSUC,DOC_TIPDOC,DOC_SERFIS,SFI_IMPFIS,SFI_MODELO,SFI_PUERTO,TDN_SERFIS,]+;
         [ LEFT(DOC_NUMERO,1) AS DOC_LETRA,MIN(DOC_NUMERO) AS NUMDESDE,]+;
         [ MAX(DOC_NUMERO) AS NUMHASTA,]+;
         [ MIN(DOC_FECHA)  AS DESDE,]+;
         [ MAX(DOC_FECHA)  AS HASTA,]+;
         [ COUNT(*) AS CUANTOS ]+;
         [ FROM dpdoccli ]+;
         [ INNER JOIN dpsucursal ON SUC_CODIGO=DOC_CODSUC AND SUC_ACTIVO=1 ]+;
         [ INNER JOIN dpseriefiscal  ON DOC_SERFIS=SFI_LETRA ]+; 
         [ INNER JOIN dptipdocclinum ON DOC_CODSUC=TDN_CODSUC AND DOC_TIPDOC=TDN_TIPDOC ]+;
         [ WHERE (DOC_TIPDOC="FAV" OR DOC_TIPDOC="CRE" OR DOC_TIPDOC="DEB" OR DOC_TIPDOC="FAM") ]+;
         [ AND LEFT(DOC_NUMERO,1)<>"" AND  LEFT(DOC_NUMERO,1)<>TDN_SERFIS ]+;
         [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_SERFIS,LEFT(DOC_NUMERO,1) ]

   oTable:=OpenTable(cSql,.t.)

   WHILE !oTable:Eof()

     IF !ISSQLFIND("DPSERIEFISCAL","SFI_LETRA"+GetWhere("=",oTable:DOC_LETRA))

         EJECUTAR("CREATERECORD","DPSERIEFISCAL" ,{"SFI_LETRA"      ,"SFI_MODELO"               ,"SFI_IMPFIS"    ,"SFI_ACTIVO","SFI_PUERTO"   ,"SFI_CODSUC" },;
                                                  {oTable:DOC_LETRA ,"DESDE->"+oTable:DOC_SERFIS,oTable:SFI_IMPFIS,.T.          ,oTable:SFI_PUERTO,oTable:DOC_CODSUC},;
            NIL,.T.,"SFI_LETRA"+GetWhere("=",oTable:DOC_LETRA))


     ENDIF

     cWhere:="TDN_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
             "TDN_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
             "TDN_SERFIS"+GetWhere("=",oTable:DOC_LETRA )

     EJECUTAR("CREATERECORD","DPTIPDOCCLINUM",;
             {"TDN_CODSUC"     ,"TDN_TIPDOC"     ,"TDN_SERFIS"    ,"TDN_LEN","TDN_ZERO","TDN_PICTUR","TDN_ACTIVO","TDN_NUMERO"},;
             {oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_LETRA,10       ,.T.       ,"999999999" ,.T.         ,cNumero},;
             NIL,.T.,cWhere)

     cWhere:=[DOC_CODSUC]+GetWhere("=",oTable:DOC_CODSUC)+[ AND ]+;
             [DOC_TIPDOC]+GetWhere("=",oTable:DOC_TIPDOC)+[ AND ]+;
             [DOC_SERFIS]+GetWhere("=",oTable:DOC_SERFIS)+[ AND ]+;
             [LEFT(DOC_NUMERO,1)]+GetWhere("=",oTable:DOC_LETRA)

     SQLUPDATE("DPDOCCLI","DOC_SERFIS",oTable:DOC_LETRA,cWhere)

? CLPCOPY(oDp:cSql),cWhere

     oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN .T.
// EOF
