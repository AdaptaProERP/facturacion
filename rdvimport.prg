// Programa   : RDVIMPORT
// Fecha/Hora : 02/09/2024 02:23:29
// Propósito  : Importar RDV Resumen diario de ventas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,cLetra,cDir)
  LOCAL cFileZip,oFontG,oFontC 
  LOCAL cTitle :="Importar Resumen diario de Ventas"

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cDir   :=oDp:cBin+"diarioventas\"

  lMkDir(cDir)

  cFileZip:=cDir+"rdv_"+cCodSuc+".zip"

  DEFINE FONT oFontG  NAME "Tahoma"   SIZE 0, -10 BOLD

  DEFINE FONT oFontC  NAME "Courier New"   SIZE 0, -14 BOLD

  DpMdi(cTitle,"oDRV","RDVIMPORT.EDT")

  oDRV:Windows(0,0,oDp:aCoors[3]-160,MIN(600,oDp:aCoors[4]-10),.T.) // Maximizado

  oDRV:cFileZip     :=cFileZip
  oDRV:cDir         :=cDir
  oDRV:cWhere       :=cWhere
  oDRV:cCodSuc      :=cCodSuc
  oDRV:cSucDescri   :=SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",cCodSuc))
  oDRV:cMemo        :=""

  @ 8,06 GET oDRV:oMemo VAR oDRV:cMemo MULTI READONLY OF oDRV:oWnd FONT oFontC

  oDRV:oWnd:oClient := oDRV:oMemo

  oDRV:Activate({||oDRV:INICIO()})

RETURN NIL


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,oFontG
   LOCAL oDlg:=oDRV:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 58,60 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Ejecutar"; 
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          WHEN FILE(oDRV:cFilezip);
          ACTION oDRV:RDVIMPORTAR()

   oBtn:cToolTip:="Iniciar"

   oDRV:oBtnRun:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\DOWNLOAD.BMP";
          TOP PROMPT "Descargar"; 
          ACTION oDRV:RDVDESCARGAR() CANCEL

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION oDRV:CLOSE() CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

   oBar:SetSize(NIL,95,.T.)

   @ 1,220 SAY " "+oDRV:cCodSuc+" "+oDRV:cSucDescri OF oBar SIZE 320,20 PIXEL BORDER;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

   @ 65,15 SAY " Carpeta " OF oBar PIXEL BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow;
           FONT oFont SIZE 080,20

   @ 65,100 BMPGET oDRV:oFileZip;
               VAR oDRV:cFilezip   ;
              NAME "BITMAPS\FIND.BMP";
             VALID oDRV:VALFILEZIP(oDRV:cFilezip);
            ACTION (cFile:=cGetFile32("Fichero(*.zip) |*.zip|Ficheros (*.zip) |*.zip",;
                   "Seleccionar Archivo (*.zip)",1,cFilePath(oDRV:cFilezip),.f.,.t.),;
                   cFile:=STRTRAN(cFile,"/","/"),;
                   oDRV:cFilezip:=IIF(!EMPTY(cFile),cFile,oDRV:cFilezip),;
                   oDRV:oFilezip:KeyBoard(13));
                   FONT oFont;
                   SIZE 400,20 OF oBar PIXEL

  oDRV:oFileZip:bKeyDown  := {|nkey| IIF(nKey=13,oDRV:VALFILEZIP(oDRV:cFilezip) ,NIL) }
   
  @ 22,220 SAY oDRV:oSay PROMPT " Proceso " SIZE 220,20 ;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont PIXEL BORDER OF oBar

  oDRV:nMeter:=0

  @ 42,220 METER oDRV:oMeter VAR oDRV:nMeter SIZE 220,20 ;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont PIXEL OF oBar

  BMPGETBTN(oBar)

RETURN .T.

FUNCTION VALFILEZIP(cFile)

   oDRV:oBtnRun:ForWhen(.T.)

   IF !FILE(cFile)
     oDRV:oFileZip:MsgErr("Archivo "+cFile+" no Existe")
     RETURN .F.
   ENDIF

RETURN .T.

FUNCTION RDVDESCARGAR()
  LOCAL aFiles:={},aTablas:={},lOk:=.F.
  LOCAL cWhere,cFile:=cFileNoPath(oDRV:cFileZip)

  FERASE(cFile)

  cWhere:="DIR_FILE"+GetWhere("=",UPPER(cFile))

  oDRV:oMemo:Append("Descargando Archivo "+cFile+" desde AdaptaPro Server "+CRLF)

  lOk:=DPAPTGETPERSONALIZA(cWhere,.F.)

  oDRV:oBtnRun:ForWhen(.T.)

  IF FILE(oDRV:cFileZip)
    oDRV:oMemo:Append("Descarga Exitosa"+CRLF)
    oDRV:oMemo:Append("Importación Iniciada "+oDRV:cFileZip+CRLF)
    oDRV:RDVIMPORTAR()
  ENDIF

RETURN .T. 

FUNCTION RDVIMPORTAR()
  LOCAL aFiles:=DIRECTORY(oDRV:cDir+"*.*"),I,cFile,aTablas:={}
  LOCAL oNew,cTable,cWhere,cKey,aKey,aFields:={},nT1
  LOCAL dDesde  :=CTOD("")
  LOCAL dHasta  :=CTOD("")
  LOCAL nPeriodo:=oDp:nIndefinida
  LOCAL nContar :=0
  LOCAL oDb     :=OpenOdbc(oDp:cDsnData)

  IF !oDRV:VALFILEZIP(oDRV:cFileZip)
      RETURN .T.
  ENDIF

  ADEPURA(aFiles,{|a,n| UPPER(cFileExt(a[1]))="ZIP" })

  FOR I=1 TO LEN(aFiles)
     cFile:=oDRV:cDir+aFiles[I,1]
  NEXT I

  oDRV:oMemo:Append("Descomprimiendo "+oDRV:cFileZip+CRLF)

  oDRV:oMemo:Append("Carpeta "+oDRV:cDir+CRLF)
  oDRV:oMemo:Append("-------------------- "+CRLF)

  HB_UNZIPFILE( oDRV:cFileZip , {|| nil }, .t., NIL, oDRV:cDir , NIL )

  aFiles:=DIRECTORY(oDRV:cDir+"*.*")
  ADEPURA(aFiles,{|a,n| UPPER(cFileExt(a[1]))="ZIP" })

  FOR I=1 TO LEN(aFiles)
     cFile:=oDRV:cDir+aFiles[I,1]
     oDRV:oMemo:Append(space(02)+lower(cFileNoPath(cFile))+" "+lstr(aFiles[I,2])+"kb"+CRLF)
  NEXT I

  /*
  // Proceso de actualización
  */
  AADD(aTablas,{"DPCLIENTES"   ,"CLI_CODIGO"})
  AADD(aTablas,{"DPDOCCLI"     ,"DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_RECNUM,DOC_TIPTRA"})
  AADD(aTablas,{"DPMOVINV"     ,"MOV_CODSUC,MOV_TIPDOC,MOV_DOCUME,MOV_ITEM  ,MOV_APLORG"})
  AADD(aTablas,{"DPRECIBOSCLI" ,"REC_CODSUC,REC_NUMERO"})
  AADD(aTablas,{"DPCTABANCOMOV","MOB_CODSUC,MOB_CUENTA,MOB_NUMTRA"})
  AADD(aTablas,{"DPCAJAMOV"    ,"CAJ_CODSUC,CAJ_CODCAJ,CAJ_NUMTRA"})

  oDRV:oMemo:Append("Importando Registros "+CRLF)
  oDRV:oMemo:Append("-------------------- "+CRLF)

  CLOSE ALL

  oDp:lSaveSqlFile:=.T.

  oDb:EXECUTE("SET FOREIGN_KEY_CHECKS = 0")

  nT1:=SECONDS()

  FOR I=1 TO LEN(aTablas)

     cTable:=aTablas[I,1]
     cKey  :=aTablas[I,2]
     aKey  :=_VECTOR(cKey)
     cFile :=oDRV:cDir+cTable+".dbf"
     
     IF FILE(cFile)

       // oNew:=OpenTable("SELECT * FROM "+cTable,.F.)
       oNew:=INSERTINTO(cTable,NIL,100) // Inserta más Rápido
       // oNew:SetForeignkeyOff()

       SELECT A
       USE (cFile) 

       aFields:=A->(DBSTRUCT())

       oDRV:oSay:SetText(cTable+" "+LSTR(I)+"/"+LSTR(LEN(aTablas)))

       oDRV:oMeter:SetTotal(RECCOUNT())

       oDRV:oMemo:Append(cTable+" Rec:"+LSTR(RECCOUNT())+CRLF)

// BROWSE()

       WHILE !A->(EOF()) 

         nContar++

         IF RECNO()%30=0
            SysRefresh(.T.)
            oDRV:oMeter:Set(RECNO())
            CursorWait()
         ENDIF

         // Obtenemos el Rango de la Fecha
         IF cTable="DPDOCCLI"

            IF Empty(dDesde)
               dDesde:=DOC_FECHA
            ENDIF

            dDesde:=MIN(dDesde,DOC_FECHA)
            dHasta:=MAX(dHasta,DOC_FECHA)

         ENDIF

         cWhere:=""
         AEVAL(aKey,{|a,n,nField| nField:=FIELDPOS(a),;
                                  cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+a+GetWhere("=",FIELDGET(nField))})

         // Solo importa registros que no existe. podemos utilizar INSERT IGNORE INTO ... IF NOT EXIST <CONDICION>
         IF !ISSQLFIND(cTable,cWhere)
            oNew:AppendBlank()
            AEVAL(aFields,{|a,n| oNew:Replace(a[1],a->(FieldGet(n)))})
            oNew:Commit("")
         ENDIF

         SKIP

       ENDDO
       
       SysRefresh(.T.)

       CLOSE ALL

       oNew:End()

     ENDIF

  NEXT I

  oDb:EXECUTE("SET FOREIGN_KEY_CHECKS = 1")

  oDRV:oMemo:Append("-------------------- "+CRLF)

  IF nContar=0
    oDRV:oMemo:Append("Ningún Registro Importado "+CRLF)
  ELSE
    oDRV:oMemo:Append(LSTR(nContar)+" Registros Importados en "+LSTR(SECONDS()-nT1)+" Segundos"+CRLF)
  ENDIF

  oDRV:oMemo:Append("Proceso Concluido "+CRLF)

  cWhere:=NIL

  IF !Empty(dDesde)
    EJECUTAR("BRRDVDIARIO",cWhere,oDRV:cCodSuc,nPeriodo,dDesde,dHasta) // ,cTitle)
  ENDIF
  
RETURN .T.
// EOF
