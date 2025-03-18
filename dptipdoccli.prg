// Programa   : DPTIPDOCCLI
// Fecha/Hora : 11/08/2005 22:42:07
// Prop¢sito  : Incluir/Modificar DPTIPDOCCLI
// Creado Por : DpXbase
// Llamado por: DPTIPDOCCLI.LBX
// Aplicaci¢n : Ventas y Cuentas Por Cobrar             
// Tabla      : DPTIPDOCCLI

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPTIPDOCCLI(nOption,cCodigo,lRunDoc,cCodSuc,cLetra)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:="",cNumero:=REPLI("0",10),cSerie:=" ",cNumFis:=SPACE(10)
  LOCAL nClrText,nAt,oData
  LOCAL cTitle :="Documentos de Cliente"
  LOCAL aItems1:=GETOPTIONS("DPTIPDOCCLI","TDC_CXC")
  LOCAL aSeries:={} // ASQL("SELECT SFI_MODELO FROM DPSERIEFISCAL WHERE SFI_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND SFI_ACTIVO=1")
  LOCAL aTipDoc:={},cDocDes:=SPACE(3),nAt
  LOCAL aDocs  :=ASQL("SELECT TDC_TIPO,TDC_DESCRI FROM DPTIPDOCCLI WHERE TDC_PRODUC=1 ORDER BY TDC_TIPO")
  LOCAL aExi   :={},nAt,cWhere

  AADD(aDocs,{cDocDes,"Ninguno"})

  DEFAULT lRunDoc:=.F.

  AEVAL(aDocs, {|a,n|AADD(aTipDoc,ALLTRIM(a[1])),aDocs[n]:=a[2]+a[1]})

//  AADD(aSeries,{"Ninguno"})
//  AEVAL(aSeries,{|a,n|aSeries[n]:=a[1]})

  cExcluye:=""

  DEFAULT cCodigo:="CUO",;
          nOption:=3,;
          cCodSuc:=oDp:cSucursal,;
          cLetra :=""

  IF COUNT("DPSERIEFISCAL","SFI_CODSUC"+GetWhere("=",cCodSuc)+[ AND SFI_ACTIVO=1 AND SFI_LETRA<>" "])=0 
     MsgMemo("Requiere Serie fiscal")
     DPLBX("DPSERIEFISCAL.LBX")
     RETURN .T.
  ENDIF

//  IF COUNT("DPSERIEFISCAL","SFI_CODSUC"+GetWhere("=",cCodSuc)+[ AND SFI_ACTIVO=1 AND SFI_LETRA<>" "])
//   
//  ENDIF


  aSeries:=ASQL("SELECT SFI_MODELO FROM DPSERIEFISCAL WHERE SFI_CODSUC"+GetWhere("=",cCodSuc)+" AND SFI_ACTIVO=1")
  //AADD(aSeries,{"Ninguno"}) Sustituido por NO-FISCAL
  AEVAL(aSeries,{|a,n|aSeries[n]:=a[1]})

  cCodigo:=ALLTRIM(cCodigo)

/*
  IF !EJECUTAR("ISFIELDMYSQL",NIL,"DPTIPDOCCLI","TDC_IMPTOT")
     EJECUTAR("DPCAMPOSADD","DPTIPDOCCLI"    ,"TDC_IMPTOT","L",01,0,"Exportación Total"    ,NIL,.T.,.F.,".F."  ) // Importación Total desde Documento Origen
  ENDIF
*/
  cNumero:=IIF(Empty(cNumero),STRZERO(0,10),cNumero)
  cSerie :=IIF(Empty(cSerie )," "          ,cSerie )
  cNumFis:=IIF(Empty(cNumFis),STRZERO(0,10),cNumFis)

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -08 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO]+GetWhere("=",cCodigo)
    cTitle   :=" Incluir {oDp:DPTIPDOCCLI}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO]+GetWhere("=",cCodigo)
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Documentos de Cliente                   "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPTIPDOCCLI}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPTIPDOCCLI]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="TDC_TIPO" // Clave de Validaci¢n de Registro

//  oTable:Browse()

  oTIPDOCCLI:=DPEDIT():New(cTitle,"DPTIPDOCCLI.edt","oTIPDOCCLI" , .F. )

  oTIPDOCCLI:nOption  :=nOption
  oTIPDOCCLI:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oTIPDOCCLI
  oTIPDOCCLI:SetScript()        // Asigna Funciones DpXbase como Metodos de oTIPDOCCLI
  oTIPDOCCLI:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oTIPDOCCLI:nClrPane:=oDp:nGris
  oTIPDOCCLI:aCxC    :={1,-1,0}
  oTIPDOCCLI:cNumero :=cNumero
  oTIPDOCCLI:cSerie  :=cSerie
  oTIPDOCCLI:cNumFis :=cNumFis
  oTIPDOCCLI:cInvAct :=IIF(oTIPDOCCLI:TDC_INVACT=1,"Suma","Resta")
  oTIPDOCCLI:aSeries :=ACLONE(aSeries)
  oTIPDOCCLI:cTipDoc :=oTIPDOCCLI:TDC_TIPO
  oTIPDOCCLI:SetMemo("TDC_NUMMEM")                     // Campo para el Valor Memo
  oTIPDOCCLI:lEditFiscal:=SQLGET("DPSERIEFISCAL","SFI_EDITAB","SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))
  oTIPDOCCLI:lRunDoc    :=lRunDoc
  oTIPDOCCLI:cCodSuc    :=cCodSuc
  oTIPDOCCLI:oEXI       :=NIL
  oTIPDOCCLI:cLetra :=cLetra

  oTIPDOCCLI:aLbx    :={}
  oTIPDOCCLI:aLbxName:={}

  AADD(oTIPDOCCLI:aLbxName,"Productos con Precios,Grupo, Marca y Utilización")
  AADD(oTIPDOCCLI:aLbx    ,"DPINV.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Precios en Divisas")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVDIVISA.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Equivalentes")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEQUIV.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Existencia Contable")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEXICON.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Existencia Fisica")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEXIFIS.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Existencia Lógica")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEXILOG.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Existencia Contable,Física y Lógica")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEXICONFISLOG.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos Año,Modelo,Marca y Grupo")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVREPUESTOS.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Existencia y Ubicación Fisica")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEXIFISUBI.LBX")

  AADD(oTIPDOCCLI:aLbxName,"Productos con Equivalentes y observaciones")
  AADD(oTIPDOCCLI:aLbx    ,"DPINVEQUIVOBS.LBX")



  cDocDes:=IF(nOption=1,cDocDes,oTIPDOCCLI:TDC_DOCDES)

  IF nOption=1 .OR. Empty(oTIPDOCCLI:TDC_DOCDES)
     nAt:=LEN(aTipDoc)
  ELSE
     nAt:=MAX(ASCAN(aTipDoc,cDocDes),1)
  ENDIF

  oTIPDOCCLI:cNomDoc :=aDocs[nAt]
  oTIPDOCCLI:aTipDoc :=ACLONE(aTipDoc)

  oTIPDOCCLI:cNumero :=IF(oTIPDOCCLI:TDC_TIPO="RTI" , LEFT(oTIPDOCCLI:cNumero,8),oTIPDOCCLI:cNumero)

  IF oTIPDOCCLI:nOption=1 // Incluir en caso de ser Incremental

     oTIPDOCCLI:TDC_SERIEF:="Libre" // ATAIL(aSeries)
     oTIPDOCCLI:cNumero:=REPLI("0",10)
     oTIPDOCCLI:cNumFis:=REPLI("0",10)
     oTIPDOCCLI:TDC_ACTIVO:=.T.
     oTIPDOCCLI:TDC_MONETA:=.T.

     oTIPDOCCLI:TDC_XY    :=.F.
     oTIPDOCCLI:TDC_XYZ   :=.F.

     oTIPDOCCLI:TDC_PICTUR:=REPLI("9",10)
     oTIPDOCCLI:TDC_PICFIS:=REPLI("9",10)

     // AutoIncremental 
  ELSE

     //  Busca los Valores por Sucursal

     IF Empty(cLetra)
        cLetra:=SQLGET("DPSERIEFISCAL","SFI_LETRA","SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))
     ENDIF

     cWhere :="TDN_CODSUC"+GetWhere("=",oTIPDOCCLI:cCodSuc )+" AND "+;
              "TDN_TIPDOC"+GetWhere("=",oTIPDOCCLI:TDC_TIPO)

     oData  :=OpenTable("SELECT * FROM dptipdocclinum WHERE "+cWhere)

     oTIPDOCCLI:cNumero   :=oData:TDN_NUMERO
     oTIPDOCCLI:TDC_SERIEF:=SQLGET("DPSERIEFISCAL","SFI_MODELO","SFI_LETRA"+GetWhere("=",oData:TDN_SERFIS))
     oTIPDOCCLI:TDC_PICTUR:=oData:TDN_PICTUR

//   oData:Browse()
     oData:End()

     oTIPDOCCLI:TDC_PICFIS:=SQLGET("DPSERIEFISCAL","SFI_PICTUR,SFI_NUMERO,SFI_ITEMXP","SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))
     oTIPDOCCLI:cNumFis   :=DPSQLROW(2)
     oTIPDOCCLI:TDC_NITEMS:=DPSQLROW(3)
     oTIPDOCCLI:TDC_PICFIS:=IF(Empty(oTIPDOCCLI:TDC_PICFIS),"9999999999",oTIPDOCCLI:TDC_PICFIS)


/* 
     oData  :=DATASET("SUC_V"+cCodSuc,"ALL")
     oTIPDOCCLI:cNumero   :=oData:Get(oTIPDOCCLI:cTipDoc+"Numero",STRZERO(0,10))
     oTIPDOCCLI:TDC_SERIEF:=oData:Get(oTIPDOCCLI:cTipDoc+"Serie" ,"Libre" )
     oTIPDOCCLI:cNumFis   :=oData:Get(oTIPDOCCLI:cTipDoc+"NumFis",STRZERO(0,10))
     oTIPDOCCLI:TDC_PICTUR:=oData:Get(oTIPDOCCLI:cTipDoc+"Pictur",REPLI("9",10) )
     oTIPDOCCLI:TDC_PICFIS:=oData:Get(oTIPDOCCLI:cTipDoc+"PicFis",REPLI("9",10) )
     
*/

     oData:End(.F.)

     // Si Calcula IVA, será monetario
     IF oTIPDOCCLI:TDC_IVA
       oTIPDOCCLI:TDC_MONETA:=.T.
     ENDIF

     IF lRunDoc
      oTIPDOCCLI:TDC_ACTIVO:=.T.
     ENDIF

    

  ENDIF

  oTIPDOCCLI:TDC_CODCTA:=EJECUTAR("DPGETCTAMOD","DPTIPDOCCLI_CTA",oTIPDOCCLI:TDC_TIPO,"","CODCTA")


  nAt:=MAX(1,ASCAN(oTIPDOCCLI:aLbx,ALLTRIM(oTIPDOCCLI:TDC_INVLBX)))

  oTIPDOCCLI:TDC_INVLBX:=oTIPDOCCLI:aLbxName[nAt]

  aExi:=oTIPDOCCLI:GETVALEXI() // oTIPDOCCLI:oTDC_EXIVAL)

  //Tablas Relacionadas con los Controles del Formulario

//   oTIPDOCCLI:SetScroll(1,80,0,0)

  oTIPDOCCLI:CreateWindow()       // Presenta la Ventana

  
  oTIPDOCCLI:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","TDC_CODCTA")

  @ 6.4, 1.0 GROUP oTIPDOCCLI:oGroup TO 11.4,6 PROMPT "Impuestos";
                   FONT oFontG

  @ 2.8,15.0 GROUP oTIPDOCCLI:oGroup TO 7.8,20 PROMPT "Inventario";
                      FONT oFontG

  @ 8.2,15.0 GROUP oTIPDOCCLI:oGroup TO 13.2,20 PROMPT "Cuentas por Cobrar";
                      FONT oFontG

  @ 11.8,15.0 GROUP oTIPDOCCLI:oGroup TO 16.8,20 PROMPT "Relación Contable";
                      FONT oFontG

  @ 11.8,15.0 GROUP oTIPDOCCLI:oGroup TO 16.8,20 PROMPT "Sucursal ["+cCodSuc+"]";
                      FONT oFontG

  @ 11.8,15.0 GROUP oTIPDOCCLI:oGroup TO 16.8,20 PROMPT " Control Fiscal Sucursal ["+cCodSuc+"]";
                      FONT oFontG

  @ 1,1 GROUP oTIPDOCCLI:oGroup TO 16.8,20 PROMPT " Tipo de Documento ";
                      FONT oFontG

  //
  // Campo : TDC_TIPO  
  // Uso   : Tipo                                    
  //
  @ 1.0, 1.0 GET oTIPDOCCLI:oTDC_TIPO    VAR oTIPDOCCLI:TDC_TIPO    VALID oTIPDOCCLI:ValUnique(oTIPDOCCLI:TDC_TIPO  );
                   .AND. !VACIO(oTIPDOCCLI:TDC_TIPO,NIL);
                    WHEN (AccessField("DPTIPDOCCLI","TDC_TIPO",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Tipo de CxC"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Tipo de CxC"

  @ 1,1 SAY "Tipo" PIXEL;
        SIZE NIL,7 


  //
  // Campo : TDC_DESCRI
  // Uso   : Descripci¢n                             
  //
  @ 2.8, 1.0 GET oTIPDOCCLI:oTDC_DESCRI  VAR oTIPDOCCLI:TDC_DESCRI  VALID  !VACIO(oTIPDOCCLI:TDC_DESCRI,NIL);
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DESCRI",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                    FONT oFontG;
                    SIZE 120,10

  oTIPDOCCLI:oTDC_DESCRI:cMsg    :="Descripción"
  oTIPDOCCLI:oTDC_DESCRI:cToolTip:="Descripción"

  @ 1,1 SAY "Descripción" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : TDC_RETIVA
  // Uso   : Retenciones de IVA                      
  //
  @ 6.4, 1.0 CHECKBOX oTIPDOCCLI:oTDC_RETIVA  VAR oTIPDOCCLI:TDC_RETIVA  PROMPT ANSITOOEM("Retenciones de IVA");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_RETIVA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F. );
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_RETIVA:cMsg    :="Retenciones de IVA"
    oTIPDOCCLI:oTDC_RETIVA:cToolTip:="Retenciones de IVA"


  //
  // Campo : TDC_RETISR
  // Uso   : Retenciones de ISLR                     
  //
  @ 8.2, 1.0 CHECKBOX oTIPDOCCLI:oTDC_RETISR  VAR oTIPDOCCLI:TDC_RETISR  PROMPT ANSITOOEM("Retenciones de ISLR");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_RETISR",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F.);
                     FONT oFont COLOR nClrText,NIL SIZE 154,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_RETISR:cMsg    :="Retenciones de ISLR"
    oTIPDOCCLI:oTDC_RETISR:cToolTip:="Retenciones de ISLR"

  //
  // Campo : TDC_IVA   
  // Uso   : Calcula I.V.A.                          
  //
  @ 10.0, 1.0 CHECKBOX oTIPDOCCLI:oTDC_IVA     VAR oTIPDOCCLI:TDC_IVA     PROMPT ANSITOOEM("Calcula I.V.A.");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_IVA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. !ISDOCFISCAL(oTIPDOCCLI:TDC_TIPO));
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_IVA   :cMsg    :="Calcula I.V.A."
    oTIPDOCCLI:oTDC_IVA   :cToolTip:="Calcula I.V.A."


  //
  // Campo : TDC_LIBVTA
  // Uso   : Libro de Venta                          
  //
  @ 1.0,15.0 CHECKBOX oTIPDOCCLI:oTDC_LIBVTA  VAR oTIPDOCCLI:TDC_LIBVTA  PROMPT ANSITOOEM("Libro de Venta");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_LIBVTA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F. );
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_LIBVTA:cMsg    :="Libro de Venta"
    oTIPDOCCLI:oTDC_LIBVTA:cToolTip:="Libro de Venta"



  //
  // Campo : TDC_INVLOG
  // Uso   : Inventario L¢gico                       
  //
  @ 2.8,15.0 CHECKBOX oTIPDOCCLI:oTDC_INVLOG  VAR oTIPDOCCLI:TDC_INVLOG  PROMPT ANSITOOEM("Lógico");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_INVLOG",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC );
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10;
                    ON CHANGE oTIPDOCCLI:GETVALEXI(oTIPDOCCLI:oTDC_EXIVAL)

  oTIPDOCCLI:oTDC_INVLOG:cMsg    :="Inventario L¢gico"
  oTIPDOCCLI:oTDC_INVLOG:cToolTip:="Inventario L¢gico"


  //
  // Campo : TDC_INVCON
  // Uso   : Inventario Contable                     
  //
  @ 4.6,15.0 CHECKBOX oTIPDOCCLI:oTDC_INVCON  VAR oTIPDOCCLI:TDC_INVCON  PROMPT ANSITOOEM("Contable");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_INVCON",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC .AND. .F. );
                     FONT oFont COLOR nClrText,NIL SIZE 88,10;
                    SIZE 4,10;
                    ON CHANGE oTIPDOCCLI:GETVALEXI(oTIPDOCCLI:oTDC_EXIVAL)


    oTIPDOCCLI:oTDC_INVCON:cMsg    :="Inventario Contable"
    oTIPDOCCLI:oTDC_INVCON:cToolTip:="Inventario Contable"


  //
  // Campo : TDC_INVFIS
  // Uso   : Inventario Físico                       
  //
  @ 6.4,15.0 CHECKBOX oTIPDOCCLI:oTDC_INVFIS  VAR oTIPDOCCLI:TDC_INVFIS  PROMPT ANSITOOEM("Físico");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_INVFIS",oTIPDOCCLI:nOption );
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC);
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10;
                    ON CHANGE oTIPDOCCLI:GETVALEXI(oTIPDOCCLI:oTDC_EXIVAL)

    oTIPDOCCLI:oTDC_INVFIS:cMsg    :="Inventario Físico"
    oTIPDOCCLI:oTDC_INVFIS:cToolTip:="Inventario Físico"


  //
  // Campo : TDC_ALMACE
  // Uso   : Multi-Almac‚n                           
  //
  @ 6.4,15.0 CHECKBOX oTIPDOCCLI:oTDC_ALMACE  VAR oTIPDOCCLI:TDC_ALMACE  PROMPT ANSITOOEM("Almacén");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_ALMACE",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC .AND. (oTIPDOCCLI:TDC_INVFIS .OR. oTIPDOCCLI:TDC_INVLOG .OR. oTIPDOCCLI:TDC_INVCON));
                    FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_INVFIS:cMsg    :="Multi-Almacén"
    oTIPDOCCLI:oTDC_INVFIS:cToolTip:="Multi-Almacén"

  //
  // Campo : TDC_INVEXI
  // Uso   : Existencia
  //
  @ 1,2 COMBOBOX oTIPDOCCLI:oEXI    VAR oTIPDOCCLI:cInvAct  ITEMS {"Suma","Resta","Ninguno"};
                 WHEN (.F. .AND. AccessField("DPTIPDOCCLI","TDC_INVACT",oTIPDOCCLI:nOption);
                       .AND. oTIPDOCCLI:TDC_PRODUC ;
                       .AND. oTIPDOCCLI:nOption!=0 .AND.  (oTIPDOCCLI:TDC_INVFIS .OR. oTIPDOCCLI:TDC_INVLOG .OR. oTIPDOCCLI:TDC_INVCON));
                       FONT oFontG

  //
  // Campo : TDC_MONEDA
  // Uso   : Moneda Extranjera                       
  //
  @ 10.0,15.0 CHECKBOX oTIPDOCCLI:oTDC_MONEDA  VAR oTIPDOCCLI:TDC_MONEDA  PROMPT ANSITOOEM("En Divisas");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_MONEDA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 142,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_MONEDA:cMsg    :="Moneda Extranjera"
    oTIPDOCCLI:oTDC_MONEDA:cToolTip:="Moneda Extranjera"

  //
  // Campo : TDC_REVALO
  // Uso   : Revalorizable                           
  //
  @ 8.2,15.0 CHECKBOX oTIPDOCCLI:oTDC_REVALO  VAR oTIPDOCCLI:TDC_REVALO  PROMPT ANSITOOEM("Revalorizable");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_REVALO",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 118,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_REVALO:cMsg    :="Revalorizable"
    oTIPDOCCLI:oTDC_REVALO:cToolTip:="Revalorizable"


  //
  // Campo : TDC_PAGOS 
  // Uso   : Acepta Pagos                            
  //
  @ 4.6, 1.0 CHECKBOX oTIPDOCCLI:oTDC_PAGOS   VAR oTIPDOCCLI:TDC_PAGOS   PROMPT ANSITOOEM("Acepta Pago/Anticipo");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_PAGOS",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F. );
                     FONT oFont COLOR nClrText,NIL SIZE 112,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_PAGOS :cMsg    :="Acepta Pagos"
    oTIPDOCCLI:oTDC_PAGOS :cToolTip:="Acepta Pagos"


  //
  // Campo : TDC_CXC   
  // Uso   : Cuentas por Cobrar
  //
  @ 6.1, 1.0 COMBOBOX oTIPDOCCLI:oCXC    VAR oTIPDOCCLI:TDC_CXC    ITEMS aItems1;
                      WHEN (AccessField("DPTIPDOCCLI","TDC_CXC",oTIPDOCCLI:nOption);
                     .AND. oTIPDOCCLI:nOption!=0 .AND. .F.);
                      FONT oFontG


  ComboIni(oTIPDOCCLI:oCXC   )

  oTIPDOCCLI:oCXC   :cMsg    :="Tipo de Cuenta"
  oTIPDOCCLI:oCXC   :cToolTip:="Tipo de Cuenta"

  @ 0,0 SAY "Tipo CxC:" PIXEL;
        SIZE NIL,7 FONT oFont

  //
  // Campo : TDC_CONTAB
  // Uso   : Asientos Contables                      
  //
  @ 11.8,15.0 CHECKBOX oTIPDOCCLI:oTDC_CONTAB  VAR oTIPDOCCLI:TDC_CONTAB  PROMPT ANSITOOEM("Asientos Contables");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_CONTAB",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0) .AND. .F.;
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_CONTAB:cMsg    :="Asientos Contables"
    oTIPDOCCLI:oTDC_CONTAB:cToolTip:="Asientos Contables"

  //
  // Campo : TDC_CODCTA
  // Uso   : Cuenta Contable                         
  //
  @ 1.0,29.0 BMPGET oTIPDOCCLI:oTDC_CODCTA  VAR oTIPDOCCLI:TDC_CODCTA ;
             VALID oTIPDOCCLI:oDPCTA:SeekTable("CTA_CODIGO",oTIPDOCCLI:oTDC_CODCTA,NIL,oTIPDOCCLI:oTIPDOCCLI_DESCRI);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPCTA",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oTIPDOCCLI:oTDC_CODCTA),;
                     oDpLbx:GetValue("CTA_CODIGO",oTIPDOCCLI:oTDC_CODCTA),;
                     EJECUTAR("DPCTALBXFIND",oTIPDOCCLI:TDC_CODCTA)); 
             WHEN (AccessField("DPTIPDOCCLI","TDC_CODCTA",oTIPDOCCLI:nOption);
                  .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_CONTAB);
             FONT oFontG;
             SIZE 80,10

    oTIPDOCCLI:oTDC_CODCTA:cMsg    :="Cuenta Contable"
    oTIPDOCCLI:oTDC_CODCTA:cToolTip:="Cuenta Contable"

  @ 0,0 SAY GETFROMVAR("{oDp:xDPCTA}")+" del Documento" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//oTIPDOCCLI:oDPCTA:cSingular
  @ oTIPDOCCLI:oTDC_CODCTA:nTop,oTIPDOCCLI:oTDC_CODCTA:nRight+5 SAY oTIPDOCCLI:oTIPDOCCLI_DESCRI;
                            PROMPT oTIPDOCCLI:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  // Campo : TDC_CONAUT
  // Uso   : Asientos Contables AutoMáticos                     
  //
  @ 11.8,15.0 CHECKBOX oTIPDOCCLI:oTDC_CONAUT  VAR oTIPDOCCLI:TDC_CONAUT  PROMPT ANSITOOEM("Automático");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_CONAUT",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_CONTAB);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_CONAUT:cMsg    :="Asientos Automáticos"
    oTIPDOCCLI:oTDC_CONAUT:cToolTip:="Asientos Automáticos"


  //
  // Campo : NUMERO
  // Uso   : N£mero del Documento
  //
  @ 1.0, 1.0 GET oTIPDOCCLI:oNumero      VAR oTIPDOCCLI:cNumero;  
                    VALID CERO(oTIPDOCCLI:cNumero);
                    PICTURE IF(oTIPDOCCLI:TDC_TIPO="RTI","99999999","X999999999");
                    WHEN (oTIPDOCCLI:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Número del Documento"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Número del Documento"

 @ 1,10 SAY "# Documento:"

  //
  // Campo : NUMERO
  // Uso   : Transacción Libro de ventas
  //
  @ 1.0, 1.0 GET oTIPDOCCLI:oTDC_LIBTRA  VAR oTIPDOCCLI:TDC_LIBTRA;
                    WHEN (oTIPDOCCLI:TDC_LIBVTA;
                    .AND. oTIPDOCCLI:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Transacción Indicada en el Libro de Ventas"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Transacción Indicada en el Libro de Ventas"


  //
  // Campo : TDC_NUMEDT
  // Uso   : EDITAR NUMERO
  //
  @ 6.4, 1.0 CHECKBOX oTIPDOCCLI:oTDC_NUMEDT  VAR oTIPDOCCLI:TDC_NUMEDT;
                      PROMPT ANSITOOEM("Número Editable");
                      WHEN (AccessField("TIPDOCCLI","TDC_NUMEDT",oTIPDOCCLI:nOption);
                           .AND. oTIPDOCCLI:nOption!=0);
                      FONT oFont COLOR nClrText,NIL SIZE 148,10;
                      SIZE 4,10

    oTIPDOCCLI:oTDC_NUMEDT:cMsg    :="Editar Número de Transacción"
    oTIPDOCCLI:oTDC_NUMEDT:cToolTip:="Editar Número de Transacción"


  //
  // Campo : TDC_DOCEDI
  // Uso   : EDITAR DESDE DOCUMENTO
  //
  @ 6.4, 1.0 CHECKBOX oTIPDOCCLI:oTDC_DOCEDI  VAR oTIPDOCCLI:TDC_DOCEDI;
                      PROMPT ANSITOOEM("Acceso desde Documentos");
                      WHEN (oTIPDOCCLI:oCXC:nAt<>3 .AND. AccessField("TIPDOCCLI","TDC_DOCEDI",oTIPDOCCLI:nOption);
                           .AND. oTIPDOCCLI:nOption!=0);
                      FONT oFont COLOR nClrText,NIL SIZE 148,10;
                      SIZE 4,10

    oTIPDOCCLI:oTDC_DOCEDI:cMsg    :="Editar Desde Documentos"
    oTIPDOCCLI:oTDC_DOCEDI:cToolTip:="Editar Desde Documentos"


  //
  // Campo : Modelo de Serie Fiscal
  //

  @ 0,1 COMBOBOX oTIPDOCCLI:oTDC_SERIEF VAR oTIPDOCCLI:TDC_SERIEF ITEMS aSeries;
        WHEN oTIPDOCCLI:TDC_LIBVTA .AND.;
             (AccessField("DPTIPDOCCLI","TDC_SERIEF",oTIPDOCCLI:nOption);
              .AND. oTIPDOCCLI:nOption!=0);
        ON CHANGE oTIPDOCCLI:GETEDITFISCAL()

  ComboIni(oTIPDOCCLI:oTDC_SERIEF)

  oTIPDOCCLI:oTDC_SERIEF:cMsg    :="Serie Fiscal"
  oTIPDOCCLI:oTDC_SERIEF:cToolTip:="Serie Fiscal"

  //
  // Campo : TDC_PRODUC
  // Uso   : Requiere Productos
  //

  @ 6.4, 1.0 CHECKBOX oTIPDOCCLI:oTDC_PRODUC  VAR oTIPDOCCLI:TDC_PRODUC  PROMPT ANSITOOEM("Productos");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_PRODUC",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_PRODUC:cMsg    :="Requiere Productos"
    oTIPDOCCLI:oTDC_PRODUC:cToolTip:="Requiere Productos"


  //
  // Campo : TDC_INVMON
  // Uso   : Productos en Moneda Extranjera                       
  //
  @ 6.4,15.0 CHECKBOX oTIPDOCCLI:oTDC_INVMON  VAR oTIPDOCCLI:TDC_INVMON  PROMPT ANSITOOEM("En Divisas");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_INVMON",oTIPDOCCLI:nOption );
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC) .AND.  oTIPDOCCLI:TDC_PRODUC;
                    .AND. LEFT(oTIPDOCCLI:TDC_CXC,1)="N";
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_INVMON:cMsg    :="Productos en Moneda Extranjera"
    oTIPDOCCLI:oTDC_INVMON:cToolTip:="Productos en Moneda Extranjera"


  //
  // Campo : NUMFIS
  // Uso   : N£mero Fiscal      
  //
  @ 1.0, 1.0 GET oTIPDOCCLI:oNumFis      VAR oTIPDOCCLI:cNumFis    VALID CERO(oTIPDOCCLI:cNumFis);
                    PICTURE "9999999999";
                    WHEN (oTIPDOCCLI:TDC_LIBVTA ;
                          .AND. (oTIPDOCCLI:nOption=1 .OR. oTIPDOCCLI:nOption=3));
                    FONT oFontG;
                    SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Número de Control Fiscal"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Número de Control Fiscal"



 @ 1,10 SAY "Serie:"
 @ 1,10 SAY "# Fiscal" RIGHT

  // Campo : TDC_FORTXT
  // Uso   :Impresión en Formato Plano                      
  //
  @ 16,15.0 CHECKBOX oTIPDOCCLI:oTDC_FORTXT  VAR oTIPDOCCLI:TDC_FORTXT  PROMPT ANSITOOEM("Impresión en Formato Plano");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_FORTXT",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 142,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_FORTXT:cMsg    :="Impresión en Formato Plano"
    oTIPDOCCLI:oTDC_FORTXT:cToolTip:="Impresión en Formato Plano"




  //
  // Campo : TDC_FILBMP
  // Uso   : Imagen en Bmp                           
  //
  @ 6.4, 1.0 BMPGET oTIPDOCCLI:oTDC_FILBMP  VAR oTIPDOCCLI:TDC_FILBMP ;
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (cFile:=cGetFile32("Bmp File (*.bmp) |*.bmp|Archivos BitMaps (*.bmp) |*.bmp",;
                    "Seleccionar Archivo BITMAP (BMP)",1,cFilePath(oTIPDOCCLI:TDC_FILBMP),.f.,.t.),;
                    cFile:=STRTRAN(cFile,"\","/"),;
                    oTIPDOCCLI:TDC_FILBMP:=IIF(!EMPTY(cFile),cFile,oTIPDOCCLI:TDC_FILBMP),;
                    oTIPDOCCLI:oTDC_FILBMP:Refresh(),;
                    oTIPDOCCLI:oImage1:LoadBmp(cFile));
                    WHEN (AccessField("DPTIPDOCCLI","TDC_FILBMP",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                    FONT oFontG;
                    SIZE 280,10

    oTIPDOCCLI:oTDC_FILBMP:cMsg    :="Imagen en Bmp"
    oTIPDOCCLI:oTDC_FILBMP:cToolTip:="Imagen en Bmp"

  @ 1,20 SAY "Imagen en Bmp" PIXEL;
          SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 1,1 BITMAP oTIPDOCCLI:oImage1 FILENAME oTIPDOCCLI:TDC_FILBMP PIXEL;
        SIZE 30,30 

// SCROLL ADJUST

  @ 1,20 SAY "Existencia" PIXEL;
         SIZE NIL,7 FONT oFont

  @ 1,10 SAY "Transacción:"


  //
  // Campo : TDC_MNUOTR   
  // Uso   : Menú Otros Documentos
  //
  @ 10.0, 1.0 CHECKBOX oTIPDOCCLI:oTDC_MNUOTR     VAR oTIPDOCCLI:TDC_MNUOTR     PROMPT ANSITOOEM("Menú Otros Definibles");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_MNUOTR",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_MNUOTR   :cMsg    :="Menú Otros Documentos"
    oTIPDOCCLI:oTDC_MNUOTR   :cToolTip:="Menú Otros Documentos"

//  @ 1,10 SAY "Serie:"

/*
  //
  // Campo : TDC_COMISI 
  // Comisiones de Venta
  //

  @ 12.0, 100 CHECKBOX oTIPDOCCLI:oTDC_COMISI     VAR oTIPDOCCLI:TDC_COMISI     PROMPT ANSITOOEM("Incide en Comisiones de Venta");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_COMISI",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_COMISI   :cMsg    :="Afecta Comisiones de Venta"
    oTIPDOCCLI:oTDC_COMISI   :cToolTip:="Afecta Comisiones de Venta"
*/

/*
  //
  // Campo : TDC_REGTAR
  // Uso   : Importación total desde el Documento de Origen
  //
  @ 19, 20 CHECKBOX oTIPDOCCLI:oTDC_REGTAR  VAR oTIPDOCCLI:TDC_REGTAR  PROMPT ANSITOOEM("Registro de Tara de Carga");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_REGTAR",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. "R"$oTIPDOCCLI:cInvAct .AND. oTIPDOCCLI:TDC_INVFIS);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

  oTIPDOCCLI:oTDC_REGTAR:cMsg    :="Registro de Taras de Carga"
  oTIPDOCCLI:oTDC_REGTAR:cToolTip:=oTIPDOCCLI:oTDC_REGTAR:cMsg

*/
  @ 15,1 COMBOBOX oTIPDOCCLI:oTDC_DOCDES VAR oTIPDOCCLI:cNomDoc ITEMS aDocs;
                  WHEN (AccessField("DPTIPDOCCLI","TDC_DOCDES",oTIPDOCCLI:nOption );
                        .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC .AND. DPVERSION()>4);
                        COLOR nClrText,NIL SIZE 76,10;
                        SIZE 4,10

  @ 13,1 SAY "Documento Destino"

  /*
  // Validación de Existencia 07/10/2016
  */

  @ 15,1 COMBOBOX oTIPDOCCLI:oTDC_EXIVAL VAR oTIPDOCCLI:TDC_EXIVAL ITEMS aExi;
                  WHEN (AccessField("DPTIPDOCCLI","TDC_EXIVAL",oTIPDOCCLI:nOption );
                        .AND. oTIPDOCCLI:nOption!=0 .AND. LEN(oTIPDOCCLI:oTDC_EXIVAL:aItems)>1);
                        FONT oFont COLOR nClrText,NIL SIZE 124,10;
                        SIZE 4,10

  oTIPDOCCLI:oTDC_EXIVAL:cMsg    :="Existencia para Validación de Cantidad Requerida"
  oTIPDOCCLI:oTDC_EXIVAL:cToolTip:=oTIPDOCCLI:oTDC_EXIVAL:cMsg

//  oTIPDOCCLI:oTDC_EXIVAL:SetFont(oFont)

  COMBOINI(oTIPDOCCLI:oTDC_EXIVAL)

  oTIPDOCCLI:TDC_EXIVALx:="Uno"

  //
  // Campo : TDC_AUTIMP
  // Uso   : Auto Impresión
  //

  @ 8.2,15.0 CHECKBOX oTIPDOCCLI:oTDC_AUTIMP  VAR oTIPDOCCLI:TDC_AUTIMP  PROMPT ANSITOOEM("Auto Impresión");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_AUTIMP",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 118,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_AUTIMP:cMsg    :="AutoImpresión"
    oTIPDOCCLI:oTDC_AUTIMP:cToolTip:="AutoImpresión"

/*
  //
  // Campo : TDC_DOCPRG
  // Uso   : Genera Documento Progresivo
  //
  @ 1.0,15.0 CHECKBOX oTIPDOCCLI:oTDC_DOCPRG  VAR oTIPDOCCLI:TDC_DOCPRG  PROMPT ANSITOOEM("Genera "+oDp:DPCLIENTEPROG);
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DOCPRG",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 );
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_DOCPRG:cMsg    :="Genera "+oDp:DPCLIENTEPROG
    oTIPDOCCLI:oTDC_DOCPRG:cToolTip:="Genera "+oDp:DPCLIENTEPROG
*/

  //
  // Campo : TDC_VALFCH
  // Uso   : Valida Fechas Restringidas
  //
  @ 1.0,15.0 CHECKBOX oTIPDOCCLI:oTDC_VALFCH  VAR oTIPDOCCLI:TDC_VALFCH  PROMPT ANSITOOEM("Valida Fechas Restringidas");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_VALFCH",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>=5);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_VALFCH:cMsg    :="Valida Fechas Restringidas"
    oTIPDOCCLI:oTDC_VALFCH:cToolTip:="Valida Fechas Restringidas"


  //
  // Campo : TDC_REQDIG
  // Uso   : Requiere Digitalización
  //
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_REQDIG  VAR oTIPDOCCLI:TDC_REQDIG  PROMPT ANSITOOEM("Requiere Digitalización");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_REQDIG",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>=5);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_REQDIG:cMsg    :="Requiere Digitalización"
    oTIPDOCCLI:oTDC_REQDIG:cToolTip:="Requiere Digitalización"

/*
  // Campo : TDC_REQSCA
  // Uso   : Requiere Scanear Documento al Finalizar
  //
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_REQSCA  VAR oTIPDOCCLI:TDC_REQSCA  PROMPT ANSITOOEM("Requiere Scanner al Finalizar");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_REQSCA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>=5);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_REQSCA:cMsg    :="Requiere Scanner al Finalizar"
    oTIPDOCCLI:oTDC_REQSCA:cToolTip:="Requiere Scanner al Finalizar"
*/

/*
  //
  // Campo : TDC_GENPRO
  // Uso   : Genera Proyecto
  //
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_GENPRO  VAR oTIPDOCCLI:TDC_GENPRO  PROMPT ANSITOOEM("Genera Proyecto");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_GENPRO",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F.);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_GENPRO:cMsg    :="Requiere Proyecto"
    oTIPDOCCLI:oTDC_GENPRO:cToolTip:="Requiere Proyecto"
*/

  //
  // Campo : TDC_CENCOS
  // Uso   : Genera Centro de Costo
  //
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_CENCOS  VAR oTIPDOCCLI:TDC_CENCOS  PROMPT ANSITOOEM("Genera Centro de Costo");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_CENCOS",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. ISRELEASE("18.11"));
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_CENCOS:cMsg    :="Genera Centro de Costo"
    oTIPDOCCLI:oTDC_CENCOS:cToolTip:="Genera Centro de Costo"

  //
  // Campo : TDC_NITEMS
  // Uso   : Cantidad de Items     
  //
  @ 1.0, 20 GET oTIPDOCCLI:oTDC_NITEMS VAR oTIPDOCCLI:TDC_NITEMS ;
                PICTURE "9999" RIGHT;
                SPINNER;
                WHEN (oTIPDOCCLI:TDC_LIBVTA .AND. oTIPDOCCLI:TDC_PRODUC .AND. ;
                      AccessField("DPTIPDOCCLI","TDC_NITEMS",oTIPDOCCLI:nOption) .AND. ;
                      oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>=5);
                FONT oFontG

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Cantidas de Items"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Cantidas de Items"

 @ 1,10 SAY "Items Max." RIGHT


  //
  // Campo : TDC_PICFIS
  // Uso   : PICTURE   
  //

  @ 11, 1.0 GET oTIPDOCCLI:oTDC_PICFIS      VAR oTIPDOCCLI:TDC_PICFIS;
            WHEN (oTIPDOCCLI:TDC_LIBVTA ;
                  .AND. (oTIPDOCCLI:nOption=1 .OR. oTIPDOCCLI:nOption=3));
            FONT oFontG;
            SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Formato de Datos Número de Control Fiscal"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Formato de Datos Número de Control Fiscal"


  //
  // Campo : NUMFIS
  // Uso   : PICTURE   
  //
  @ 10, 1.0 GET oTIPDOCCLI:oTDC_PICTUR      VAR oTIPDOCCLI:TDC_PICTUR;
                 WHEN (oTIPDOCCLI:nOption=1 .OR. oTIPDOCCLI:nOption=3);
                    FONT oFontG;
                    SIZE 16,10

    oTIPDOCCLI:oTDC_TIPO  :cMsg    :="Formato de Datos Número de Documento"
    oTIPDOCCLI:oTDC_TIPO  :cToolTip:="Formato de Datos Número de Documento"


  //
  // Campo : TDC_ACTIVO
  // Uso   : Campo Activo                     
  //
  @ 2, 10 CHECKBOX oTIPDOCCLI:oTDC_ACTIVO  VAR oTIPDOCCLI:TDC_ACTIVO  PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_ACTIVO",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_ACTIVO:cMsg    :="Activo"
    oTIPDOCCLI:oTDC_ACTIVO:cToolTip:="Activo"


 // Campo : TDC_LIBINV
  // Uso   : Libro de Inventario                     
  //
  @ 6.4, 1.0 CHECKBOX oTIPDOCCLI:oTDC_LIBINV  VAR oTIPDOCCLI:TDC_LIBINV  PROMPT ANSITOOEM("Libro de Inventario");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_LIBINV",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. .F.);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_LIBINV:cMsg    :="Libro de Inventario"
    oTIPDOCCLI:oTDC_LIBINV:cToolTip:="Libro de Inventario"



/*
  //
  // Campo : TDC_DIFPAG
  // Uso   : Acepta Diferencia de Pago                   
  //
  @ 2, 10 CHECKBOX oTIPDOCCLI:oTDC_DIFPAG  VAR oTIPDOCCLI:TDC_DIFPAG  PROMPT ANSITOOEM("Acepta Diferencia de Pago");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DIFPAG",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_CXC<>'N');
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_DIFPAG:cMsg    :="Acepta Diferencia de Pago"
    oTIPDOCCLI:oTDC_DIFPAG:cToolTip:="Acepta Diferencia de Pago"
*/

  //
  // Campo : TDC_DELETE
  // Uso   : Puede Eliminar Registro                 
  //
  @ 19, 20 CHECKBOX oTIPDOCCLI:oTDC_DELETE  VAR oTIPDOCCLI:TDC_DELETE  PROMPT ANSITOOEM("Eliminar Registro");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DELETE",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. !ISDOCFISCAL(oTIPDOCCLI:TDC_TIPO));
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_DELETE:cMsg    :="Eliminar Registro"
    oTIPDOCCLI:oTDC_DELETE:cToolTip:="Eliminar Registro"
/*
  //
  // Campo : TDC_MOVED
  // Uso   : Puede Mover Número 
  //
  @ 20, 20 CHECKBOX oTIPDOCCLI:oTDC_MOVED  VAR oTIPDOCCLI:TDC_MOVED  PROMPT ANSITOOEM("Mover Número Documento");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_MOVED",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. ISRELEASE("17.01"));
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_MOVED:cMsg    :="Mover Número Fiscal"
    oTIPDOCCLI:oTDC_MOVED:cToolTip:="Mover Número Fiscal"

  //
  // Campo : TDC_MOVEF
  // Uso   : Puede Mover Número Fiscal
  //
  @ 21, 20 CHECKBOX oTIPDOCCLI:oTDC_MOVEF  VAR oTIPDOCCLI:TDC_MOVEF  PROMPT ANSITOOEM("Mover Número Fiscal");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_MOVEF",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. ISRELEASE("17.01"));
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_MOVEF:cMsg    :="Mover Número Fiscal"
    oTIPDOCCLI:oTDC_MOVEF:cToolTip:="Mover Número Fiscal"

*/
  //
  // Campo : TDC_DEPURA
  // Uso   : Depuración de Registros
  //
  @ 22, 20 CHECKBOX oTIPDOCCLI:oTDC_DEPURA  VAR oTIPDOCCLI:TDC_DEPURA  PROMPT ANSITOOEM("Depurar Registros");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DEPURA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. !ISDOCFISCAL(oTIPDOCCLI:TDC_TIPO));
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_DEPURA:cMsg    :="Depurar Registros"
    oTIPDOCCLI:oTDC_DEPURA:cToolTip:="Depurar Registros"

// Aqui requiere diversos Formularios

  // Campo : TDC_LBXEXI
  // Uso   : Muestra y Valida Existencia en Formulario LBX
  //
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_LBXEXI  VAR oTIPDOCCLI:TDC_LBXEXI  PROMPT ANSITOOEM("Valida Existencia LBX");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_LBXEXI",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. ISRELEASE("18.08"));
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_LBXEXI:cMsg    :="Valida Existencia y Muestra en Formulario LBX"
    oTIPDOCCLI:oTDC_LBXEXI:cToolTip:="Valida Existencia y Muestra en Formulario LBX"


 // Campo : TDC_GUIATR
 // Uso   : Guia de Transporte
 //

   @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_GUIATR  VAR oTIPDOCCLI:TDC_GUIATR  PROMPT ANSITOOEM("Guia de Transporte");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_GUIATR",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_GUIATR:cMsg    :="Guia de Transporte"
    oTIPDOCCLI:oTDC_GUIATR:cToolTip:=oTIPDOCCLI:oTDC_GUIATR:cMsg
/*
esto lo define en la serie fiscal
  @ 15,15.0 CHECKBOX oTIPDOCCLI:oEditFiscal  VAR oTIPDOCCLI:lEditFiscal  PROMPT ANSITOOEM("Editar #Control Fiscal");
                     WHEN (oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_LIBVTA);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oEditFiscal:cMsg    :="Editar Número de Control Fiscal"
    oTIPDOCCLI:oEditFiscal:cToolTip:=oTIPDOCCLI:oEditFiscal:cMsg

*/

 // Campo : TDC_PRECIO
 // Uso   : Precio D 
 //

   @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_PRECIO  VAR oTIPDOCCLI:TDC_PRECIO  PROMPT ANSITOOEM("Precio Dinámico en Divisas");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_PRECIO",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. ISRELEASE("18.11"));
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_PRECIO:cMsg    :="Precio Dinámico en Divisas"
    oTIPDOCCLI:oTDC_PRECIO:cToolTip:=oTIPDOCCLI:oTDC_PRECIO:cMsg


 // Campo : TDC_MONETA
 // Uso   : Documento con Valor Monetario
 //

   @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_MONETA  VAR oTIPDOCCLI:TDC_MONETA  PROMPT ANSITOOEM("Con Valor Monetario");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_MONETA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_MONETA:cMsg    :="Genera Documentos con Valor Monetario"
    oTIPDOCCLI:oTDC_MONETA:cToolTip:=oTIPDOCCLI:oTDC_MONETA:cMsg


/*
   @ 15,15.0 CHECKBOX oTIPDOCCLI:oTDC_XY  VAR oTIPDOCCLI:TDC_XY  PROMPT ANSITOOEM("X*Y");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_XY",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>5.1);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_XY:cMsg    :="X*Y Calcular Medidas"
    oTIPDOCCLI:oTDC_XY:cToolTip:=oTIPDOCCLI:oTDC_XY:cMsg

  @ 16,15.0 CHECKBOX oTIPDOCCLI:oTDC_XYZ  VAR oTIPDOCCLI:TDC_XYZ  PROMPT ANSITOOEM("X*Y*Z");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_XYZ",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>5.1);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_XYZ:cMsg    :="X*Y*Z Calcular Volumen"
    oTIPDOCCLI:oTDC_XYZ:cToolTip:=oTIPDOCCLI:oTDC_XYZ:cMsg

*/
  @ 16,15.0 CHECKBOX oTIPDOCCLI:oTDC_REQAPR  VAR oTIPDOCCLI:TDC_REQAPR  PROMPT ANSITOOEM("Requiere Aprobación Exportar");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_REQAPR",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>=6.0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_REQAPR:cMsg    :="Requiere Aprobación Exportar hacia Otros Documentos"
    oTIPDOCCLI:oTDC_REQAPR:cToolTip:=oTIPDOCCLI:oTDC_REQAPR:cMsg


  @ 20,15.0 CHECKBOX oTIPDOCCLI:oTDC_CARGAP  VAR oTIPDOCCLI:TDC_CARGAP  PROMPT ANSITOOEM("Orden de Carga con Pesaje");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_CARGAP",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>5.1);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_CARGAP:cMsg    :="Al finalizar Crear Orden de Carga con Pesaje"
    oTIPDOCCLI:oTDC_CARGAP:cToolTip:=oTIPDOCCLI:oTDC_CARGAP:cMsg

//? "oTIPDOCCLI:oTDC_PRECIO:ClassName()"

/*
  //
  // Campo : TDC_DIFCAM
  // Uso   : Acepta Diferencia de Pago                   
  //
  @ 2, 10 CHECKBOX oTIPDOCCLI:oTDC_DIFCAM  VAR oTIPDOCCLI:TDC_DIFCAM  PROMPT ANSITOOEM("Para Diferencial de Cambiario");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_DIFCAM",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_CXC<>'N');
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_DIFCAM:cMsg    :="Para Diferencial de Cambiario"
    oTIPDOCCLI:oTDC_DIFCAM:cToolTip:="Para Diferencial de Cambiario"
*/

  //
  // Campo : TDC_ORGPLA
  // Uso   : Origen de Plantilla                          
  //
  @ 10,15.0 CHECKBOX oTIPDOCCLI:oTDC_ORGPLA  VAR oTIPDOCCLI:TDC_ORGPLA  PROMPT ANSITOOEM("Originado desde Plantilla");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_ORGPLA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 );
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_ORGPLA:cMsg    :="Originado desde Plantilla"
    oTIPDOCCLI:oTDC_ORGPLA:cToolTip:="Originado desde Plantilla"


  @ 10,1 SAY "Formato" RIGHT
  @ 11,1 SAY "Formato" RIGHT

  @ 11,1 SAY "Catálogo de Productos"


/*
  //
  // Campo : TDC_CROSSD
  // Uso   : Proceso de Cross-Docking
  //
  @ 19, 20 CHECKBOX oTIPDOCCLI:oTDC_CROSSD  VAR oTIPDOCCLI:TDC_CROSSD  PROMPT ANSITOOEM("Croos-Docking");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_CROSSD",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

    oTIPDOCCLI:oTDC_CROSSD:cMsg    :="Vinculo con Proceso Croos-Docking"
    oTIPDOCCLI:oTDC_CROSSD:cToolTip:="Vinculo con Proceso Croos-Docking"
*/
  //
  // Campo : TDC_IMPTOT
  // Uso   : Importación total desde el Documento de Origen
  //
  @ 19, 20 CHECKBOX oTIPDOCCLI:oTDC_IMPTOT  VAR oTIPDOCCLI:TDC_IMPTOT  PROMPT ANSITOOEM("Exportación Total");
                    WHEN (AccessField("DPTIPDOCCLI","TDC_IMPTOT",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. !"Ninguno"$oTIPDOCCLI:TDC_DOCDES);
                     FONT oFont COLOR nClrText,NIL SIZE 148,10;
                    SIZE 4,10

  oTIPDOCCLI:oTDC_IMPTOT:cMsg    :="Importación Total desde el Documento de Origen"
  oTIPDOCCLI:oTDC_IMPTOT:cToolTip:=oTIPDOCCLI:oTDC_IMPTOT:cMsg

/*
  @ 10,15.0 CHECKBOX oTIPDOCCLI:oTDC_CNTRES  VAR oTIPDOCCLI:TDC_CNTRES  PROMPT ANSITOOEM("Resumido por día");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_CNTRES",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_CONTAB .AND. !oTIPDOCCLI:TDC_CONAUT);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_CNTRES:cMsg    :="Generar Asientos Contables Resumidos"
    oTIPDOCCLI:oTDC_CNTRES:cToolTip:=oTIPDOCCLI:oTDC_CNTRES:cMsg
 
*/
  //
  // Campo : TDC_INVLBX
  // Uso   : Formulario LBX
  //

   @ 15,2 COMBOBOX oTIPDOCCLI:oTDC_INVLBX    VAR oTIPDOCCLI:TDC_INVLBX  ITEMS oTIPDOCCLI:aLbxName;
                   WHEN (AccessField("DPTIPDOCCLI","TDC_INVLBX",oTIPDOCCLI:nOption);
                        .AND. oTIPDOCCLI:nOption!=0 .AND. oTIPDOCCLI:TDC_PRODUC) .AND. ISRELEASE("18.11");
                   FONT oFontG

   oTIPDOCCLI:oTDC_INVLBX:cMsg    :="Formulario del Catálogo de Productos"
   oTIPDOCCLI:oTDC_INVLBX:cToolTip:=oTIPDOCCLI:oTDC_EXIVAL:cMsg

/*
   @ 20,15.0 CHECKBOX oTIPDOCCLI:oTDC_ESTVTA  VAR oTIPDOCCLI:TDC_ESTVTA  PROMPT ANSITOOEM("Estadística de Venta");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_ESTVTA",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>5.1);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_ESTVTA:cMsg    :="Estadística de Venta"
    oTIPDOCCLI:oTDC_ESTVTA:cToolTip:=oTIPDOCCLI:oTDC_ESTVTA:cMsg
*/


  @ 20,15.0 CHECKBOX oTIPDOCCLI:oTDC_IMPPAG  VAR oTIPDOCCLI:TDC_IMPPAG  PROMPT ANSITOOEM("Imprime solo Pagado");
                     WHEN (AccessField("DPTIPDOCCLI","TDC_IMPPAG",oTIPDOCCLI:nOption);
                    .AND. oTIPDOCCLI:nOption!=0 .AND. oDp:nVersion>5.1);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                     SIZE 4,10

    oTIPDOCCLI:oTDC_IMPPAG:cMsg    :="Imprimir solo si está pagado"
    oTIPDOCCLI:oTDC_IMPPAG:cToolTip:=oTIPDOCCLI:oTDC_IMPPAG:cMsg

   @ 18,1 BUTTON oTIPDOCCLI:oRunLbx PROMPT ">"  ACTION oTIPDOCCLI:RUNINVLBX()

   oTIPDOCCLI:oRunLbx:cMsg    :="Visualizar Formulario"
   oTIPDOCCLI:oRunLbx:cToolTip:=oTIPDOCCLI:oTDC_EXIVAL:cMsg

   @ 10,70 BMPGET oTIPDOCCLI:oTDC_DESDE  VAR oTIPDOCCLI:TDC_DESDE ;
            PICTURE oDp:cFormatoFecha;
            NAME "BITMAPS\Calendar.bmp";
            ACTION LbxDate(oTIPDOCCLI:oTDC_DESDE ,oTIPDOCCLI:TDC_DESDE);
            VALID .T.;
            WHEN (AccessField("DPTIPDOCCLI","TDC_DESDE",oTIPDOCCLI:nOption);
                .AND. oTIPDOCCLI:nOption!=0 .AND. !"Ninguno"$oTIPDOCCLI:TDC_INVLBX);
            SIZE 45,10


  @ 11,1 SAY "Desde"


  // Campo : TDC_ABREVI
  // Uso   : Descripci¢n                             
 
  @ 2.8, 14 GET oTIPDOCCLI:oTDC_ABREVI  VAR oTIPDOCCLI:TDC_ABREVI  VALID  !VACIO(oTIPDOCCLI:TDC_ABREVI,NIL);
                WHEN (AccessField("DPTIPDOCCLI","TDC_ABREVI",oTIPDOCCLI:nOption);
                     .AND. oTIPDOCCLI:nOption!=0);
                FONT oFontG;
                SIZE 120,10

  oTIPDOCCLI:oTDC_ABREVI:cMsg    :="Descripción Abreviada"
  oTIPDOCCLI:oTDC_ABREVI:cToolTip:="Descripción Abreviada"

  @ 1,1 SAY "Abrevidado" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



 @ 10,30 BMPGET oTIPDOCCLI:oTDC_CLRGRA VAR oTIPDOCCLI:TDC_CLRGRA;
          PICTURE "99999999";
          NAME "BITMAPS\COLORS.BMP";
          SIZE 50,10;
          VALID  (oTIPDOCCLI:SETCOLORGRA());
          ACTION (oTIPDOCCLI:oColor:SelColor(),;
                  oTIPDOCCLI:oTDC_CLRGRA:VarPut(oTIPDOCCLI:oColor:nClrPane,.T.),oTIPDOCCLI:SETCOLORGRA());
          WHEN (AccessField("DPTIPDOCCLI","TDC_DESCRI",oTIPDOCCLI:nOption);
                        .AND. oTIPDOCCLI:nOption!=0);
          FONT oFontG;
          SIZE 160,10 RIGHT



  @ 10,40 SAY oTIPDOCCLI:oColor PROMPT "Color Formulario" SIZE 100,10 COLOR oTIPDOCCLI:TDC_CLRGRA,oDp:nGris2


  //
 
  oTIPDOCCLI:Activate({||oTIPDOCCLI:BARINICIO()})
 
//  

  IF oTIPDOCCLI:nOption<>1
    oTIPDOCCLI:TDC_MONETA:=oTable:TDC_MONETA
    oTIPDOCCLI:oTDC_MONETA:Refresh(.T.)
  ENDIF

//?  oTIPDOCCLI:oColor:ClassName(),oTIPDOCCLI:TDC_CLRGRA,ValType(oTIPDOCCLI:TDC_CLRGRA)

  oTIPDOCCLI:oColor:SetColor(oTIPDOCCLI:TDC_CLRGRA,oDp:nGris2)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oTIPDOCCLI

FUNCTION BARINICIO()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oTIPDOCCLI:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52,60-2 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD


   IF oTIPDOCCLI:nOption=2 


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
            ACTION (oTIPDOCCLI:Close())

     oBtn:cToolTip:="Salir"

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            TOP PROMPT "Grabar"; 
            ACTION (oTIPDOCCLI:Save())

     oBtn:cToolTip:="Grabar"

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XMEMO.BMP";
            TOP PROMPT "Memo"; 
            ACTION (oTIPDOCCLI:CAMPOMEMO())

     oBtn:cToolTip:="Campo Memo para leyendas de Impresión"
     oBtn:cMsg    :=oBtn:cToolTip


     DEFINE BUTTON oBtn;
            OF oBar;
            FONT oFont;
            NOBORDER;
            FILENAME "BITMAPS\XCANCEL.BMP";
            TOP PROMPT "Cancelar"; 
            ACTION (oTIPDOCCLI:Cancel()) CANCEL

     oBtn:cToolTip:="Cancelar"

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   AEVAL(oTIPDOCCLI:oDlg:aControls,{|o| IF("COMBOBOX"$o:ClassName(),o:SetSize(NIL,140),NIL)})

   oTIPDOCCLI:oColor:SetColor(oTIPDOCCLI:oColor:nClrText,oTIPDOCCLI:TDC_CLRGRA)

   oTIPDOCCLI:GETVALEXI(oTIPDOCCLI:oTDC_EXIVAL)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

   @ 2,200 SAY " "+oDp:xDPSUCURSAL+" " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59+4,20

   @ 2,264 SAY " "+oTIPDOCCLI:cCodSuc OF oBar SIZE 60,20 BORDER PIXEL; 
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 100,20

   @23,200 SAY " Nombre " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59+4,20

   @23,264 SAY " "+SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",oTIPDOCCLI:cCodSuc)) OF oBar;
           SIZE 300,20 BORDER PIXEL;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 


/*
   @ 1,200 SAY oTIPDOCCLI:cCodSuc OF oBar SIZE 100,20 BORDER PIXEL FONT oFont

   @25,200 SAY SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",oTIPDOCCLI:cCodSuc)) OF oBar;
           SIZE 300,20 BORDER PIXEL FONT oFont
*/

/*
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 68,015 SAY " Serie " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59,20

  @ 68,310 SAY " Medio " OF oBar ;
           BORDER  PIXEL RIGHT;
           COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 59,20

  @ 68,015+60 SAY " "+oSELSERFISXTIP:cLetra+"-"+ALLTRIM(oSELSERFISXTIP:cSerieF)+" " OF oBar ;
           BORDER  PIXEL;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20

  @ 68,310+60 SAY " "+ALLTRIM(oSELSERFISXTIP:cImpFis)+" " OF oBar ;
           BORDER  PIXEL;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 200,20
*/





RETURN .T.

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oTIPDOCCLI:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecuci¢n PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  lResp      :=oTIPDOCCLI:ValUnique(oTIPDOCCLI:TDC_TIPO  )

  oTIPDOCCLI:TDC_INVACT:=IIF(LEFT(oTIPDOCCLI:cInvAct,1)="S",1,-1)
  oTIPDOCCLI:TDC_FECHA :=DPFECHA()
  oTIPDOCCLI:TDC_HORA  :=DPHORA()
  oTIPDOCCLI:TDC_ALTER :=.T.
  oTIPDOCCLI:TDC_DOCDES:=IF(oTIPDOCCLI:TDC_PRODUC,oTIPDOCCLI:aTipDoc[oTIPDOCCLI:oTDC_DOCDES:nAt],"")

  IF !(oTIPDOCCLI:nOption!=0 .AND.  (oTIPDOCCLI:TDC_INVFIS .OR. oTIPDOCCLI:TDC_INVLOG .OR. oTIPDOCCLI:TDC_INVCON))
    oTIPDOCCLI:TDC_ALMACE:=.F.
  ENDIF

  IF (!oTIPDOCCLI:TDC_INVLOG .AND. !oTIPDOCCLI:TDC_INVFIS .AND. !oTIPDOCCLI:TDC_INVCON)
    oTIPDOCCLI:TDC_INVACT:=0
  ENDIF

  IF !oTIPDOCCLI:TDC_LIBVTA

    oTIPDOCCLI:TDC_SERIEF:="NO-FISCAL" // ATAIL( oTIPDOCCLI:aSeries)

  ELSE

    IF "NO-FISCAL"$UPPER(oTIPDOCCLI:TDC_SERIEF)

       oTIPDOCCLI:oTDC_SERIEF:MsgErr("Tipo de Documento "+oTIPDOCCLI:TDC_TIPO+CRLF+;
                                     "está vinculado con el Libro de ventas."+CRLF+"Requiere su respectiva SERIE FISCAL")

      RETURN .F.

    ENDIF

  ENDIF

  IF !lResp
     MsgAlert("Registro "+CTOO(oTIPDOCCLI:TDC_TIPO),"Ya Existe")
  ENDIF

  IF EMPTY(oTIPDOCCLI:TDC_TIPO)
     MensajeErr("Tipo no Puede estar Vacio")
     RETURN .F.
  ENDIF

  IF Empty(oTIPDOCCLI:TDC_CODCTA)
    oTIPDOCCLI:TDC_CODCTA:=oDp:cCtaIndef
  ENDIF

  IF lResp
    oTIPDOCCLI:TDC_INVLBX:=oTIPDOCCLI:aLbx[oTIPDOCCLI:oTDC_INVLBX:nAt]
  ENDIF

  IF !oTIPDOCCLI:TDC_INVLOG .AND. !oTIPDOCCLI:TDC_INVFIS .AND. !oTIPDOCCLI:TDC_INVCON
     oTIPDOCCLI:TDC_EXIVAL:="Ninguno"
  ENDIF

RETURN lResp

/*
// Ejecuci¢n despues de Grabar
*/
FUNCTION POSTSAVE()
  LOCAL oData,cCodigo:=ALLTRIM(oTIPDOCCLI:TDC_TIPO)
  LOCAL cWhere,nLen  :=LEN(oTIPDOCCLI:cNumero)
  LOCAL cLetra:=SQLGET("DPSERIEFISCAL","SFI_LETRA","SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))

/*
  oData:=DATASET("SUC_V"+oTIPDOCCLI:cCodSuc,"ALL",NIL,NIL,NIL,NIL,.T.)
  oData:Set(cCodigo+"Numero",oTIPDOCCLI:cNumero)
  oData:Set(cCodigo+"Serie" ,oTIPDOCCLI:TDC_SERIEF)
  oData:Set(cCodigo+"NumFis",oTIPDOCCLI:cNumFis)
  oData:Set(cCodigo+"Pictur",oTIPDOCCLI:TDC_PICTUR)
  oData:Set(cCodigo+"PicFis",oTIPDOCCLI:TDC_PICFIS)

  oData:Save(.T.)
  oData:End()
*/

  SQLUPDATE("DPSERIEFISCAL",{"SFI_EDITAB"          ,"SFI_PICTUR"         ,"SFI_NUMERO"      ,"SFI_ITEMXP"           },;
                            {oTIPDOCCLI:lEditFiscal,oTIPDOCCLI:TDC_PICFIS,oTIPDOCCLI:cNumFis,oTIPDOCCLI:TDC_NITEMS},;
                            "SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))

  cWhere :="TDN_CODSUC"+GetWhere("=",oTIPDOCCLI:cCodSuc )+" AND "+;
           "TDN_TIPDOC"+GetWhere("=",oTIPDOCCLI:TDC_TIPO)+" AND "+;
           "TDN_SERFIS"+GetWhere("=",cLetra)

  EJECUTAR("CREATERECORD","dptipdocclinum",{"TDN_CODSUC"      ,"TDN_TIPDOC"       ,"TDN_SERFIS"          ,"TDN_LEN","TDN_PICTUR"         ,"TDN_EDITAR"         ,"TDN_ACTIVO"},;
                                           {oTIPDOCCLI:cCodSuc,oTIPDOCCLI:TDC_TIPO, cLetra               ,nLen     ,oTIPDOCCLI:TDC_PICTUR,oTIPDOCCLI:TDC_NUMEDT,.T.         },;
                                            NIL,.T.,cWhere)

// Registrar la Cuenta Contable
  EJECUTAR("SETCTAINTMOD","DPTIPDOCCLI_CTA",oTIPDOCCLI:TDC_TIPO,"","CODCTA",oTIPDOCCLI:TDC_CODCTA,.T.)

  IF oTIPDOCCLI:nOption=3

    EJECUTAR("DPTIPDOCCLILOAD")
//  Este Programa ahora es llamado desde DPTIPDOCCLIMNU
//  EJECUTAR("CXCFIX" , oTIPDOCCLI:TDC_TIPO )

    // Realiza Cambios en Tablas sin Integridad
    IF !(oTIPDOCCLI:cTipDoc=oTIPDOCCLI:TDC_TIPO)

      SQLUPDATE("DPMOVINV"    ,"MOV_TIPDOC",oTIPDOCCLI:TDC_TIPO,"MOV_TIPDOC"+GetWhere("=",oTIPDOCCLI:cTipDoc)+" AND MOV_APLORG='V'")
      SQLUPDATE("DPMOVINV"    ,"MOV_ASOTIP",oTIPDOCCLI:TDC_TIPO,"MOV_ASOTIP"+GetWhere("=",oTIPDOCCLI:cTipDoc)+" AND MOV_APLORG='V'")
      SQLUPDATE("DPASIENTOS"  ,"MOC_TIPO"  ,oTIPDOCCLI:TDC_TIPO,"MOC_TIPO"  +GetWhere("=",oTIPDOCCLI:cTipDoc)+" AND MOC_ORIGEN='VTA'")
      SQLUPDATE("DPDOCCLI"    ,"DOC_TIPAFE",oTIPDOCCLI:TDC_TIPO,"DOC_TIPAFE"+GetWhere("=",oTIPDOCCLI:cTipDoc))
      SQLUPDATE("DPTAREASAUTM","TAU_TIPDOC",oTIPDOCCLI:TDC_TIPO,"TAU_TIPDOC"+GetWhere("=",oTIPDOCCLI:cTipDoc))
   
    ENDIF

    IF !Empty(oTIPDOCCLI:TDC_CODCTA) .AND. oTIPDOCCLI:TDC_CODCTA<>oDp:cCtaIndef

      SQLUPDATE("DPASIENTOS","MOC_CUENTA",oTIPDOCCLI:TDC_CODCTA,"MOC_TIPO"+GetWhere("=",oTIPDOCCLI:TDC_TIPO)+" AND MOC_CUENTA"+GetWhere("=",oDp:cCtaIndef)+" AND MOC_ORIGEN"+GetWhere("=","VTA"))
      SQLUPDATE("DPDOCCLICTA","CCD_CODCTA",oTIPDOCCLI:TDC_CODCTA,"CCD_TIPDOC"+GetWhere("=",oTIPDOCCLI:TDC_TIPO)+" AND CCD_CODCTA"+GetWhere("=",oDp:cCtaIndef))

    ENDIF

    EJECUTAR("DPTIPDOCCLIMNU",oTIPDOCCLI:TDC_TIPO)

  ENDIF

  IF oTIPDOCCLI:TDC_REQSCA .AND. oDp:nVersion>=5
    EJECUTAR("DPTABXUSU",oTIPDOCCLI:TDC_TIPO,oTIPDOCCLI:TDC_DESCRI,"DPTIPDOCCLISCANNER","Usuarios con Scanner para el [Tipo de Documento "+oTIPDOCCLI:TDC_TIPO+" ]")
  ENDIF

  // Ubica; si es una Impresora Fiscal
  IF oTIPDOCCLI:TDC_LIBVTA
  //  EJECUTAR("DPEQUIPOSPOLBX",oTIPDOCCLI:TDC_TIPO,.F.)
  ENDIF

  IF (oTIPDOCCLI:TDC_INVFIS .OR. oTIPDOCCLI:TDC_INVCON .OR. oTIPDOCCLI:TDC_INVLOG) .AND. COUNT("DPINVUTILIZ"," LEFT JOIN DPTIPDOCCLIUTILIZ ON UTL_CODIGO=TDU_UTILIZ WHERE TDU_TIPDOC"+GetWhere("=",oTIPDOCCLI:TDC_TIPO))=0
    EJECUTAR("DPTIPDOCCLIUTILIZ",oTIPDOCCLI:TDC_TIPO)
  ENDIF

  cWhere :="CTD_TIPDOC"+GetWhere("=",oTIPDOCCLI:TDC_TIPO)+" AND CTD_FIELD"+GetWhere("=","MOV_TOTDIV")

  IF (oTIPDOCCLI:TDC_INVFIS .OR. oTIPDOCCLI:TDC_INVCON .OR. oTIPDOCCLI:TDC_INVLOG) .AND. COUNT("DPTIPDOCCLICOL",cWhere)=0
     EJECUTAR("BRTIPDOCCLICOL",NIL,NIL,NIL,NIL,NIL,NIL,oTIPDOCCLI:TDC_TIPO)
  ENDIF 

  SQLUPDATE("DPSERIEFISCAL","SFI_EDITAB",oTIPDOCCLI:lEditFiscal,"SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))

  IF oTIPDOCCLI:lRunDoc
     EJECUTAR("BRTIPDOCCLICOL",NIL,NIL,NIL,NIL,NIL,NIL,oTIPDOCCLI:TDC_TIPO)
//   EJECUTAR("DPFACTURAV",oTIPDOCCLI:TDC_TIPO)
  ENDIF

  oDp:cFavD_cToken :=""
  oDp:cFavD_cUrl   :=""
  oDp:cFavD_cPrg   :=""
  oDp:nImpFisEntPre:=0
  oDp:nImpFisEntCan:=0
  oDp:cModSerFis   :=""

  IF !Empty(oTIPDOCCLI:cLetra)
     EJECUTAR("BRSELSERFISXTIP",NIL,NIL,NIL,NIL,NIL,NIL,oTIPDOCCLI:cLetra)
  ENDIF

RETURN .T.

/*
// Genera Tipo de Existencia
*/
FUNCTION GETVALEXI(oCbx)
   LOCAL aExi:={}

   IF oTIPDOCCLI:TDC_INVFIS
      AADD(aExi,"Físico")
   ENDIF

   IF oTIPDOCCLI:TDC_INVLOG
      AADD(aExi,"Lógico")
   ENDIF

   IF oTIPDOCCLI:TDC_INVCON
      AADD(aExi,"Contable")
   ENDIF

   IF Empty(aExi)
      AADD(aExi,"Físico")
      AADD(aExi,"Lógico")
      AADD(aExi,"Contable")
      AADD(aExi,"Ninguno")
   ENDIF

   IF !oTIPDOCCLI:TDC_INVLOG .AND. !oTIPDOCCLI:TDC_INVFIS .AND. !oTIPDOCCLI:TDC_INVCON
     aExi:={}
     AADD(aExi,"Ninguno")
     oTIPDOCCLI:TDC_EXIVAL:="Ninguno"
     // COMBOINI(oTIPDOCCLI:oTDC_EXIVAL)
   ENDIF

   IF !oCbx=NIL

     oCbx:SetItems(aExi)
     // oCbx:Reset()
     oCbx:Select(1)
     COMBOINI(oCbx)

     IF Empty(oTIPDOCCLI:TDC_EXIVAL)
        oTIPDOCCLI:oTDC_EXIVAL:Select(1)
     ENDIF
 
     oTIPDOCCLI:oTDC_EXIVAL:ForWhen(.t.)

   ENDIF

   IF ValType(oTIPDOCCLI:oEXI)="O" .AND. (!oTIPDOCCLI:TDC_INVLOG .AND. !oTIPDOCCLI:TDC_INVFIS .AND. !oTIPDOCCLI:TDC_INVCON)
      oTIPDOCCLI:oEXI:Select(3)
   ENDIF


RETURN aExi

FUNCTION CAMPOMEMO()

    oTIPDOCCLI:aMemo[2]:="Texto Imprimir en formato Crystal Report "+ALLTRIM(oTIPDOCCLI:TDC_TIPO)

   _DPMEMOEDIT(oTIPDOCCLI,oTIPDOCCLI:oEditMemo)

RETURN .T.

FUNCTION RUNINVLBX()
   LOCAL cLbx:="FORMS\"+oTIPDOCCLI:aLbx[oTIPDOCCLI:oTDC_INVLBX:nAt]

   IF !FILE(cLbx)
      COPY FILE ("FORMS\DPINV.LBX") TO ("FORMS\"+cLbx)
   ENDIF

   DPLBX(cLbx)

RETURN .T.

FUNCTION GETEDITFISCAL()

//  LOCAL lEdit
//  lEdit:=SQLGET("DPSERIEFISCAL","SFI_EDITAB","SFI_MODELO"+GetWhere("=",cSerie))
//  oTIPDOCCLI:lEditFiscal:=SQLGET("DPSERIEFISCAL","SFI_EDITAB","SFI_MODELO"+GetWhere("=",oTIPDOCCLI:TDC_SERIEF))
//oTIPDOCCLI:oEditFiscal:Refresh(.T.) // 11/03/2025 NO SE PUEDE MODIFICAR EL NUMERO FISCAL 
// ? oTIPDOCCLI:lEditFiscal,oDp:cSql

RETURN .T.

FUNCTION SETCOLORGRA()
  oTIPDOCCLI:oColor:SetColor(oTIPDOCCLI:TDC_CLRGRA,oDp:nGris2)
  oTIPDOCCLI:oColor:Refresh(.T.)
RETURN .T.

/*
<LISTA:TDC_TIPO:Y:GET:N:N:N:Tipo,TDC_DESCRI:N:GET:N:N:N:Descripci¢n,TDC_PAGOS:N:CHECKBOX:N:N:Y:Acepta Pagos,@Grupo03:N:GET:N:N:N:Impuestos,TDC_RETIVA:N:CHECKBOX:N:N:Y:Retenciones de IVA,TDC_RETISR:N:CHECKBOX:N:N:Y:Retenciones de ISLR,TDC_IVA:N:CHECKBOX:N:N:Y:Calcula I.V.A.,TDC_LIBVTA:N:CHECKBOX:N:N:Y:Libro de Venta
,@Grupo01:N:GET:N:N:N:Inventario,TDC_INVLOG:N:CHECKBOX:N:N:Y:L¢gico,TDC_INVCON:N:CHECKBOX:N:N:Y:Contable,TDC_INVFIS:N:CHECKBOX:N:N:Y:F¡sico
,@Grupo02:N:GET:N:N:N:Moneda Extranjera,TDC_REVALO:N:CHECKBOX:N:N:Y:Revalorizable,TDC_MONEDA:N:CHECKBOX:N:N:Y:Moneda Extranjera,@Grupo04:N:GET:N:N:N:Relaci¢n Contable,TDC_CONTAB:N:CHECKBOX:N:N:Y:Asientos Contables,TDC_CODCTA:N:BMPGETL:N:N:Y:Cuenta Contable>
*/
