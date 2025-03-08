// Programa   : DOCCLIREPFAVCOPY
// Fecha/Hora : 15/11/2018 12:19:49
// Propósito  : Copiar Archivos *.DBF hacia CRYSTAL
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDes,cOrg)
  LOCAL aFiles:={},cFilOrg,cFilDes,I,aNew:={},cTipOrg

  DEFAULT cTipDes:="DEV",;
          cOrg   :="FAV" 

  CLOSE ALL

  cTipOrg:=cOrg

// ? cTipDes,cOrg,"destino","origen"

  // desde Devolucion pasa hacia Nota de Credito
  aFiles:=DIRECTORY("CRYSTAL\DOCCLICRE*.*")

  IF Empty(aFiles)
     aFiles:=DIRECTORY("CRYSTAL\DOCCLI"+cTipOrg+"*.*")
  ENDIF

// aFiles:=DIRECTORY("CRYSTAL\DOCCLI"+cTipDes+".dbf")
// ViewArray(aFiles)

  IF LEN(aFiles)>0

     FOR I=1 TO LEN(aFiles)

      cFilOrg:=LOWER("CRYSTAL\"+aFiles[I,1])
      cFilDes:=LOWER("CRYSTAL\"+STRTRAN(aFiles[I,1],"cre","dev"))

      IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) // .AND. !FILE(cFilDes)
        COPY FILE (cFilOrg) TO (cFilDes)
      ENDIF

     NEXT I

  ENDIF


  aFiles:={}

  AADD(aFiles,"docclifav.dbf")
  AADD(aFiles,"docclifav.fpt")
  AADD(aFiles,"docclifavant.dbf")
  AADD(aFiles,"docclifavcli.dbf")
  AADD(aFiles,"docclifavdet.dbf")
  AADD(aFiles,"docclifavdetcomp.dbf")
  AADD(aFiles,"docclifavdir.dbf")
  AADD(aFiles,"docclifaviva.dbf")
  AADD(aFiles,"docclifavser.dbf")
  AADD(aFiles,"docclifav_.dbf")
  AADD(aFiles,"dpdocclipagfav.dbf")
  AADD(aFiles,"dpdocclipagfav2.dbf")
  AADD(aFiles,"dptipdocclifav.dbf")
  AADD(aFiles,"docclifav.fpt")
  AADD(aFiles,"docclifavcli.fpt")
  AADD(aFiles,"docclifavdet.fpt")
  AADD(aFiles,"docclifavdetcomp.fpt")
  AADD(aFiles,"dptipdocclifav.fpt")

  FOR I=1 TO LEN(aFiles)
    AADD(aNew,STRTRAN(aFiles[I],"fav","cre"))
  NEXT 

  AEVAL(aNew,{|a,n| AADD(aFiles,a)})

// ViewArray(aFiles)

//ViewArray(aNew)

  FOR I=1 TO LEN(aFiles)

    cFilOrg:=LOWER("CRYSTAL\"+aFiles[I])

    IF !File(cFilOrg)
      cFilOrg:=STRTRAN(cFilOrg,"fav","dev")
    ENDIF

    cFilDes:=LOWER("CRYSTAL\"+STRTRAN(aFiles[I],LOWER(cOrg),LOWER(cTipDes)))

//  ? cFilOrg,"<-Origen",cFilDes,"<-Destino"

    IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) // .AND. !FILE(cFilDes)
       COPY FILE (cFilOrg) TO (cFilDes)
    ENDIF

    IF cFilOrg<>cFilDes .AND. FILE(cFilDes) // .AND. !FILE(cFilDes)
       COPY FILE (cFilDes) TO (cFilOrg)
    ENDIF


  NEXT I


  cFilOrg:=Lower("CRYSTAL\doccli"+cTipDes+"_.dbf")
  cFilDes:=Lower("CRYSTAL\docclifav_.dbf")

  IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) // .AND. !FILE(cFilDes)
     COPY FILE (cFilOrg) TO (cFilDes)
  ENDIF

  cFilOrg:=Lower("CRYSTAL\doccli"+cTipDes+"_.dbf")
  cFilDes:=Lower("CRYSTAL\docclidev_.dbf")

  IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) // .AND. !FILE(cFilDes)
     COPY FILE (cFilOrg) TO (cFilDes)
  ENDIF

  cFilOrg:=Lower("CRYSTAL\doccli"+cTipDes+".dbf")
  cFilDes:=Lower("CRYSTAL\docclifav.dbf")

  IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) 
     COPY FILE (cFilOrg) TO (cFilDes)
  ENDIF

  cFilOrg:=Lower("CRYSTAL\doccli"+cTipDes+".fpt")
  cFilDes:=Lower("CRYSTAL\docclifav.fpt")

  IF cFilOrg<>cFilDes .AND. FILE(cFilOrg) // .AND. !FILE(cFilDes)
     COPY FILE (cFilOrg) TO (cFilDes)
  ENDIF

/*
  cFilOrg:=Lower("CRYSTAL\docclicre_.dbf")
  cFilDes:=Lower("CRYSTAL\docclidev_.dbf")

  IF FILE(cFilOrg) // .AND. !FILE(cFilDes)
     COPY FILE (cFilOrg) TO (cFilDes)
  ENDIF
*/
RETURN .T.
// EOF
