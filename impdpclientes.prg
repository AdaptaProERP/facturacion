// Programa   : IMPDPCLIENTES
// Fecha/Hora : 06/01/2011 01:54:25
// Propósito  : Importar Clientes
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cFile:="EJEMPLO\DPCLIENTES.DBF"
   LOCAL oTable

   IF !File(cFile)
     MensajeErr("Archivo  "+cFile+" no Existe")
     RETURN NIL
   ENDIF

   CLOSE ALL
   SELECT A
   USE (cFile)

   WHILE !A->(EOF())

      oTable:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",A->CLI_CODIGO),.T.)

      IF oTable:RecCount()=0
         oTable:AppendBlank()
         oTable:cWhere:=""
      ENDIF

      AEVAL(DBSTRUCT(),{|a,n| oTable:Replace(a[1],FieldGet(n)) })

      oTable:Commit(oTable:cWhere)

      SKIP

   ENDDO

   CLOSE ALL
   
   MensajeErr("Proceso Concluido")

   
RETURN
