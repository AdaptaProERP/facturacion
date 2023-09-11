// Programa   : DPCLIENTESPERFX
// Fecha/Hora : 19/02/2015 07:00:28
// Propósito  : Crear Clientes sin Integridad
// Creado Por : Juan Navas
// Llamado por: 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable,I
  LOCAL aCodigos:=ASQL(" SELECT PDC_CODIGO,PDC_PERSON,PDC_TIPO FROM DPCLIENTESPER "+;
                       " LEFT JOIN DPCLIENTES ON PDC_CODIGO=CLI_CODIGO  "+;
                       " WHERE CLI_CODIGO IS NULL "+;
                       " GROUP BY PDC_CODIGO ")

  oTable:=OpenTable("SELECT * FROM DPCLIENTES ",.F.)

  FOR I=1 TO LEN(aCodigos)
    
    oTable:AppendBlank()
    oTable:Replace("CLI_CODIGO",aCodigos[I,1])
    oTable:Replace("CLI_CODCLA",SQLGET("DPCLICLA","CLC_CODIGO"))
    oTable:Replace("CLI_LISTA" ,SQLGET("DPPRECIOTIP","TPP_CODIGO"))
    oTable:Replace("CLI_ACTIVI",SQLGET("DPACTIVIDAD_E","ACT_CODIGO"))
    oTable:Replace("CLI_NOMBRE","Recuperado DPCLIENTESPER "+aCodigos[I,2]+"-"+aCodigos[I,3])

    IF oDp:nVersion<6
      oTable:Replace("CLI_CUENTA",oDp:cCtaIndef)
    ENDIF

    oTable:Commit()

  NEXT I

  oTable:End()

//  ViewArray(aCodigos)

RETURN NIL
// EOF


