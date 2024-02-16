// Programa   : XLSLEEPEDIDO
// Fecha/Hora : 17/02/2024 05:51:26
// Propósito  : Leer pedidos desde Excel, compararlo con la Lista de Precios
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFileXls)
   LOCAL aData  :={},aHead:={},aLine:={},aPaquete:={}
   LOCAL aFields:={},I,oExcel,nLin,nCol,cValue,uData,U,nContar:=0

   DEFAULT cFileXls:=oDp:cBin+"\EJEMPLO\PEDIDO.XLSX"
  
   IF !FILE(cFileXls)
     MsgMemo(cFileXls,"Archivo no Existe")
     RETURN {}
   ENDIF

   /*
   // Encabezado
   */

   AADD(aFields,{"CLI_RIF"   ,"F9" ,"",0,0,""})
   AADD(aFields,{"CLI_NOMBRE","D7" ,"",0,0,""})
   AADD(aFields,{"CLI_DIR"   ,"C8" ,"",0,0,""})
   AADD(aFields,{"CLI_CODVEN","C11","",0,0,""})
   AADD(aFields,{"CLI_EMAIL" ,"J10","",0,0,""})
   AADD(aFields,{"CLI_TEL1"  ,"B9" ,"",0,0,""})
   AADD(aFields,{"DOC_FECHA" ,"J9" ,"",0,0,""})
   AADD(aFields,{"PDC_PERSON","D10","",0,0,""})

   // ASORT(aFields,,, { |x, y| x[2] < y[2] })

   oExcel := TExcelScript():New()
   oExcel:Open( cFileXls )

   FOR I=1 TO LEN(aFields)

     cValue:=SPACE(1024)
     nLin  :=VAL(SUBS(aFields[I,2],2,4))
     nCol  :=(ASC(LEFT(aFields[I,2],1))-64)
     uData :=oExcel:Get( nLin , nCol ,@cValue )

     aFields[I,4]:=nLin
     aFields[I,5]:=nCol
     aFields[I,3]:=uData
     aFields[I,6]:=VALTYPE(uData)

   NEXT I

   aHead:=ACLONE(aFields)

   /*
   // Cuerpo del Documento
   */
   aFields:={}
   AADD(aFields,{"MOV_CANTID","A14","",0,0,""})
   AADD(aFields,{"MOV_CODIGO","B14","",0,0,""})
   AADD(aFields,{"MOV_PREDIV","J14","",0,0,""})
   AADD(aFields,{"MOV_DESCUE","K14","",0,0,""})
   AADD(aFields,{"MOV_TOTDIV","L14","",0,0,""})

   FOR I=1 TO LEN(aFields)

      cValue:=SPACE(1024)
      nLin  :=VAL(SUBS(aFields[I,2],2,4))
      nCol  :=(ASC(LEFT(aFields[I,2],1))-64)
      uData :=oExcel:Get( nLin , nCol ,@cValue )

      aFields[I,4]:=nLin
      aFields[I,5]:=nCol
      aFields[I,3]:=uData
      aFields[I,6]:=VALTYPE(uData)

   NEXT I

   // leer hasta que se Agote
   aLine:={}
   aData:={}
   AEVAL(aFields,{|a,n| AADD(aLine,a[3])})
   AADD(aData,ACLONE(aLine))

   nLin:=aFields[1,4] 

   WHILE .T.
      nLin++
      aLine:={}

      FOR U=1 TO LEN(aFields)
          cValue:=SPACE(1024)
          nCol  :=aFields[U,5]
          uData :=oExcel:Get( nLin , nCol ,@cValue )
          AADD(aLine,uData)
      NEXT U

      // lee vacio
      IF Empty(aLine[1])
        EXIT
      ENDIF

      IF ValType(aLine[1])<>ValType(aData[1,1])
        EXIT
      ENDIF

      AADD(aData,ACLONE(aLine))

   ENDDO

   oExcel:End(.F.)

   AEVAL(aFields,{|a,n| aFields[n]:=a[1]})

ViewArray(aHead)
ViewArray(aFields)
ViewArray(aData)

   aPaquete:={ACLONE(aHead),ACLONE(aFields),ACLONE(aData)}
  
   oDp:aPaquete:=ACLONE(aPaquete)

RETURN aPaquete
// EOF
