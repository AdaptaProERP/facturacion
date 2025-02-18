// Programa   : DPTIPDOCCLICOLPAR
// Fecha/Hora : 20/10/2020 16:10:51
// Propósito  : Parámetros del Tipo de Documentos
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc)
 LOCAL oTable,cSql,aData:={},I,cField

 DEFAULT cTipDoc:="FAV"

 SETDOCFISCAL() // Activa documentos Fiscales
 EJECUTAR("DPCREATERCEROS")

 cSql:=" SELECT "+;
       " CTD_FIELD ,"+;
       " CTD_TITLE ,"+;
       " CTD_SIZE  ,"+;
       " CTD_PICTUR,"+;
       " CTD_ACTIVO,"+;
       " CTD_MEMOEJ "+;
       " FROM DPTIPDOCCLICOL"+;
       " WHERE CTD_TIPDOC "+GetWhere("=",cTipDoc)+;
       " ORDER BY CTD_NUMPOS"+;
       " "

  aData :=ASQL(cSql)

  IF Empty(aData) 

     // 26/01/2023, clona tipo documento desde factura

     IF !cTipDoc="FAV"
        EJECUTAR("DPTIPDOCCLICOLCLONE","FAV",cTipDoc,.F.)
        aData :=ASQL(cSql)
     ENDIF
    
     IF Empty(aData)
       EJECUTAR("DPTIPDOCCLICOLADD",cTipDoc)
       aData :=ASQL(cSql)
     ENDIF

  ENDIF

  oTable:=OpenTable(" SELECT CTD_FIELD AS MOV_ITEM_TITLE FROM "+;
                    " DPTIPDOCCLICOL"+;
                    " WHERE CTD_TIPDOC "+GetWhere("=",cTipDoc),.F.)


  oTable:PESO_PRIMERO:=SQLGET("DPTIPDOCCLI","TDC_PESPRI","TDC_TIPO"+GetWhere("=",cTipDoc))

  oTable:MOV_LOTE_TITLE  :="Precio"+CRLF+"Divisa"
  oTable:MOV_LOTE_ACTIVO :=.F.
  oTable:MOV_LOTE_SIZE   :=80
  oTable:MOV_LOTE_MEMOEJ :=""


  oTable:MOV_X_TITLE  :="Medida"+CRLF+"X"
  oTable:MOV_X_ACTIVO :=.F.
  oTable:MOV_X_SIZE   :=80
  oTable:MOV_X_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_X_MEMOEJ :=""


  oTable:MOV_Y_TITLE  :="Medida"+CRLF+"Y"
  oTable:MOV_Y_ACTIVO :=.F.
  oTable:MOV_Y_SIZE   :=80
  oTable:MOV_Y_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_Y_MEMOEJ :=""

  oTable:MOV_X_TITLE  :="Medida"+CRLF+"X"
  oTable:MOV_X_ACTIVO :=.F.
  oTable:MOV_X_SIZE   :=80
  oTable:MOV_X_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_X_MEMOEJ :=""

  oTable:MOV_W_TITLE  :="Medida"+CRLF+"W"
  oTable:MOV_W_ACTIVO :=.F.
  oTable:MOV_W_SIZE   :=80
  oTable:MOV_W_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_W_MEMOEJ :=""


  oTable:MOV_VOLUME_TITLE  :="Volumen"
  oTable:MOV_VOLUME_ACTIVO :=.F.
  oTable:MOV_VOLUME_SIZE   :=80
  oTable:MOV_VOLUME_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_VOLUMEN_MEMOEJ:=""


  oTable:MOV_CODCOM_TITLE  :="Componente"
  oTable:MOV_CODCOM_ACTIVO :=.F.
  oTable:MOV_CODCOM_SIZE   :=80
  oTable:MOV_CODCOM_PICTURE:=""
  oTable:MOV_CODCOM_MEMOEJ :=""


  oTable:MOV_PREDIV_TITLE  :="Precio"+CRLF+"Divisa"
  oTable:MOV_PREDIV_ACTIVO :=.F.
  oTable:MOV_PREDIV_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_PREDIV_SIZE   :=120
  oTable:MOV_PREDIV_MEMOEJ :=""


  oTable:MOV_TOTDIV_TITLE  :="Total"+CRLF+"Divisa"
  oTable:MOV_TOTDIV_ACTIVO :=.F.
  oTable:MOV_TOTDIV_PICTURE:="99,999,999,999,999.99"
  oTable:MOV_TOTDIV_SIZE   :=120
  oTable:MOV_TITDIV_MEMOEJ :=""

  oTable:MOV_ALMORG_TITLE  :="Alm."+CRLF+"Org"
  oTable:MOV_ALMORG_ACTIVO :=.F.
  oTable:MOV_ALMORG_PICTURE:=NIL
  oTable:MOV_ALMORG_SIZE   :=60
  oTable:MOV_ALMORG_MEMOEJ :=""


  oTable:MOV_SUCORG_TITLE  :="Suc."+CRLF+"Org"
  oTable:MOV_SUCORG_ACTIVO :=.F.
  oTable:MOV_SUCORG_PICTURE:=NIL
  oTable:MOV_SUCORG_SIZE   :=60
  oTable:MOV_SUCORG_MEMOEJ :=""


  oTable:CRC_NOMBRE_TITLE  :="Recurso"+CRLF+"Cliente"
  oTable:CRC_NOMBRE_ACTIVO :=.F.
  oTable:CRC_NOMBRE_PICTURE:=""
  oTable:CRC_NOMBRE_SIZE   :=120
  oTable:CRC_NOMBRE_MEMOEJ :=""


  FOR I=1 TO LEN(aData)
    cField:=ALLTRIM(aData[I,1])
    oTable:Replace(cField+"_TITLE"  ,aData[I,2])
    oTable:Replace(cField+"_SIZE"   ,aData[I,3])
    oTable:Replace(cField+"_PICTURE",aData[I,4])
    oTable:Replace(cField+"_ACTIVO" ,aData[I,5])
    oTable:Replace(cField+"_MEMOEJ" ,aData[I,6])
  NEXT I

  oTable:End()

  IF oTable:FIELDPOS("MOV_MTODIV_TITLE")=0
     oTable:MOV_MTODIV_TITLE  :=oTable:MOV_TOTDIV_TITLE
     oTable:MOV_MTODIV_ACTIVO :=oTable:MOV_TOTDIV_ACTIVO
     oTable:MOV_MTODIV_PICTURE:=oTable:MOV_TOTDIV_PICTURE
     oTable:MOV_MTODIV_SIZE   :=oTable:MOV_TOTDIV_SIZE
  ENDIF

  // no pueden personalizarlos
  oTable:MOV_TITDIV_MEMOEJ :=""
  oTable:MOV_TOTAL_MEMOEJ  :=""

//ViewArray(oTable:aFields)

RETURN oTable
// EOF
