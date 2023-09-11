// Programa   : DPCLIENTESDPJ26
// Fecha/Hora : 13/11/2019 17:41:39
// Propósito  : Calcular Fecha de Cierre Fiscal
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable:=OpenTable("SELECT CLI_RIF,CLI_FCHCIE,CLI_CODIGO FROM DPCLIENTES WHERE CLI_RIF"+GetWhere("<>",""),.T.)
  LOCAL aData:={},nAt,cRif:="",nAt,nRif,dFecha,I

  AADD(aData,{0,5,"31/01/2020","","31/01/2019",""})
  AADD(aData,{6,9,"28/02/2020","","28/02/2019",""})
  AADD(aData,{3,7,"08/03/2020","","08/03/2019",""})
  AADD(aData,{4,8,"14/03/2020","","14/03/2019",""})
  AADD(aData,{1,2,"21/03/2020","","21/03/2019",""})
  
  AEVAL(aData,{|a,n| aData[n,3]:=CTOD(a[3]),;
                     aData[n,5]:=CTOD(a[5])})

  FOR I=1 TO LEN(aData)

      dFecha:=aData[I,3]

      WHILE (DOW(dFecha)=7 .OR. DOW(dFecha)=1)
         dFecha++
      ENDDO

      aData[I,3]:=dFecha
      aData[I,4]:=CSEMANA(dFecha)
      aData[I,6]:=CSEMANA(aData[I,5])

  NEXT I

// ViewArray(aData)
// RETURN 
 
   WHILE !oTable:Eof() 
//.AND. oTable:RecNo()<3

      cRif   :=ALLTRIM(oTable:CLI_RIF)
      nRif   :=VAL(RIGHT(cRif,1))
     nAt  :=ASCAN(aData,{|a| (a[1]=nRif .OR. a[2]=nRif)})
      dFecha:=aData[nAt,3]

      SQLUPDATE("DPCLIENTES","CLI_FCHCIE",dFecha,"CLI_CODIGO"+GetWhere("=",oTable:CLI_CODIGO))

// ? cRif,nRif,nAt,dFecha,oDp:cSql,DOW(dFecha),CSEMANA(dFecha)
      oTable:DbSkip()
   ENDDO

//   oTable:Browse()
   oTable:End()
 
RETURN NIL
// EOF

