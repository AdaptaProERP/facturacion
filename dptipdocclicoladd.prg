// Programa   : DPTIPDOCCLICOLADD          
// Fecha/Hora : 07/02/2020 04:25:33
// Propósito  : Crear las Columnas del Tipo de Documento
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc,lDelete)
   LOCAL aData:={},I,oTable,cWhere
   LOCAL oMovInv:=OpenTable("SELECT * FROM DPMOVINV",.F.)

   DEFAULT cTipDoc:="FAV",;
           lDelete:=.F.
   
   IF lDelete
     SQLDELETE("DPTIPDOCCLICOL")
   ENDIF

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"DPTIPDOCCLICOL",.T.)
     RETURN .T.
   ENDIF

   AADD(aData,{"MOV_ITEM"  ,"Núm.;Item"             ,NIL,0,05,"",.T.})
   AADD(aData,{"MOV_CODALM","Cód;Alm."              ,NIL,0,10,"",.T.})
   AADD(aData,{"MOV_CODIGO","Código"                ,NIL,0,15,"",.T.})


   AADD(aData,{"MOV_SUCORG","Suc.;Org"              ,NIL,0,20,"",.F.})
   AADD(aData,{"MOV_ALMORG","Alc.;Org"              ,NIL,0,25,"",.F.})
 

   AADD(aData,{"MOV_CODCOM"  ,"Componente"          ,NIL,0,30,"",.F.})
   AADD(aData,{"INV_DESCRI","Descripción"           ,NIL,0,35,"",.T.})
   AADD(aData,{"MOV_ASOTIP","Tip.;Org"              ,NIL,0,40,"",.T.})
   AADD(aData,{"MOV_ASODOC","Número;Origen"         ,NIL,0,45,"MOV_ASOTIP",.T.})
   AADD(aData,{"MOV_TIPCAR","Tipo;Característica"   ,NIL,0,50,""          ,.F.})
   AADD(aData,{"MOV_LOTE"  ,"Lote"                  ,NIL,0,55,"MOV_UNDMED",.F.})
   AADD(aData,{"CRC_NOMBRE","Recurso del Cliente"   ,NIL,0,60,""          ,.F.})
   AADD(aData,{"MOV_FCHENT","Fecha;Entrega"         ,NIL,0,65,"",.F.})
   AADD(aData,{"MOV_FCHVEN","Fecha;Vence"           ,NIL,0,70,"",.F.})
   AADD(aData,{"MOV_UNDMED","Unidad;Medida"         ,NIL,0,75,"",.T.})
   AADD(aData,{"MOV_W"     ,"Medida W"              ,"99,999,999.999",0,80,"",.F.})
   AADD(aData,{"MOV_X"     ,"Medida X"              ,"99,999,999.999",0,85,"",.F.})
   AADD(aData,{"MOV_Y"     ,"Medida Y"              ,"99,999,999.999",0,90,"",.F.})
   AADD(aData,{"MOV_Z"     ,"Medida Z"              ,"99,999,999.999",0,95,"",.F.})
   AADD(aData,{"MOV_VOLUME","Volumen"               ,"99,999,999.999",0,100,"",.F.})
   AADD(aData,{"MOV_PESO"  ,"Peso"                  ,NIL,0,105,"",.F.})
   AADD(aData,{"MOV_CANTID","Cant."                 ,NIL,0,110,"",.T.})
   AADD(aData,{"MOV_CXUND" ,"Cant.;x Und"           ,NIL,0,115,"",.T.})
   AADD(aData,{"MOV_PRECIO","Precio;Venta"          ,NIL,0,120,"",.T.})
   AADD(aData,{"MOV_PREDIV","Precio;Divisa"         ,"999,999,999,999.99",0,125,"",.T.})
   AADD(aData,{"MOV_DESCUE","%;Desc"                ,NIL,0,130,"",.T.})
   AADD(aData,{"MOV_LISTA" ,"Lista"                 ,NIL,0,135,"",.T.})
   AADD(aData,{"MOV_MTODES","Precio con;Descuento"  ,NIL,0,140,"",.F.})
   AADD(aData,{"MOV_TIPIVA","Tipo;IVA"              ,NIL,0,145,"",.T.})
   AADD(aData,{"MOV_IVA"   ,"%;IVA"                 ,NIL,0,150,"",.T.})
   AADD(aData,{"MOV_IMPOTR"  ,"Impuesto;PVP"        ,"999,999,999,999.99",0,153,"",.T.}) // Impuesto al PVP
   AADD(aData,{"MOV_TOTAL" ,"Monto;Total"           ,"999,999,999,999.99",0,155,"",.T.})
   AADD(aData,{"MOV_TOTDIV","Total;Divisa"          ,"9,999,999,999.99"  ,0,160,"",.T.})

   FOR I=1 TO LEN(aData)

      aData[I,5]:=STRZERO(I,2) // 16/08/2023

      IF oMovInv:FieldPos(aData[I,1])>0 .AND. oMovInv:Fieldtype(aData[I,1])="N" .AND. !Empty(aData[I,3])
         aData[I,3]:=FIELDPICTURE("DPMOVINV",aData[I,1],.T.)
      ENDIF

      cWhere:="CAM_TABLE"+GetWhere("=","DPMOVINV")+" AND CAM_NAME"+GetWhere("=",aData[I,1])
      // ? SQLGET("DPCAMPOS","CAM_DESCRI",cWhere)

      SQLUPDATE("DPCAMPOS","CAM_DESCRI",aData[I,2],cWhere)

      oDp:cDescri:=SQLGET("DPCAMPOS","CAM_DESCRI",cWhere)

      IF !Empty(oDp:cDescri)
        aData[I,2]:=oDp:cDescri
      ENDIF

// FIELDLABEL("DPMOVINV",aData[I,1],.T.)
//      aData[I,2]:=STRTRAN(aData[I,2],CRLF,";")

      oTable:=OpenTable("SELECT * FROM DPTIPDOCCLICOL WHERE CTD_TIPDOC"+GetWhere("=",cTipDoc)+" AND CTD_FIELD"+GetWhere("=",aData[I,1]),.T.)

      IF oTable:RecCount()=0

         oTable:AppendBlank() 
         oTable:cWhere:=""
         aData[I,5]:=I

         oTable:Replace("CTD_TIPDOC",cTipDoc   )
         oTable:Replace("CTD_FIELD" ,aData[I,1])
         oTable:Replace("CTD_NUMPOS",aData[I,5])
         oTable:Replace("CTD_SIZE"  ,aData[I,4])
         oTable:Replace("CTD_AFTER" ,aData[I,6])
         oTable:Replace("CTD_TITLE" ,aData[I,2])
         oTable:Replace("CTD_PICTUR",aData[I,3])
         oTable:Replace("CTD_ACTIVO",aData[I,7])

      ELSE

        oTable:Replace("CTD_NUMPOS",aData[I,5])

        aData[I,4]:=oTable:CTD_SIZE

      ENDIF

      oTable:Commit(oTable:cWhere)

      oTable:End()

    
   NEXT I

   oMovInv:End()

RETURN .T. 
// EOF
