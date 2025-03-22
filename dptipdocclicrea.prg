// Programa   : DPTIPDOCCLICREA
// Fecha/Hora : 07/12/2012 01:22:10
// Propósito  : Crear Registro DPTIPDOCCLI     
// Creado Por : Juan Navas
// Llamado por: BRW_PRESUPDET
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc,cDescri,cCxC,cPicture)
   LOCAL oTable

   DEFAULT cCxC:="D",;
           cPicture:=REPLI("9",10)

   IF cTipDoc=NIL .OR. ISSQLFIND("DPTIPDOCCLI","TDC_TIPO"+GetWhere("=",cTipDoc))
      RETURN .F.
   ENDIF

   EJECUTAR("DPCTAINDEF") // Crear Cuenta Indefinida

   oTable:=OpenTable("SELECT * FROM DPTIPDOCCLI",.F.)
   oTable:AppendBlank()
   oTable:lAuditar:=.F.
   oTable:Replace("TDC_TIPO"  ,cTipDoc      )
   oTable:Replace("TDC_DESCRI",cDescri      )
   oTable:Replace("TDC_CODCTA",oDp:cCtaIndef)
   oTable:Replace("TDC_CXC"   ,cCxC         )
   oTable:Replace("TDC_PICTUR",cPicture     )
   oTable:Replace("TDC_ACTIVO",.T.          )
   oTable:Replace("TDC_MONETA",.T.          )

   IF cCxC="D" .OR. cCxC="C"
     oTable:Replace("TDC_PAGOS",.T.          )
   ENDIF
   
// oTable:Replace("TDC_ACTIVO",.F.          )
   oTable:Commit()
   oTable:End(.t.)

RETURN .T.
// EOF
