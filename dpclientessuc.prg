// Programa   : DPCLIENTESSUC
// Fecha/Hora : 19/05/2007 11:18:13
// Propósito  : Incluir/Modificar DPCLIENTESSUC
// Creado Por : DpXbase
// Llamado por: DPCLIENTESSUC.LBX
// Aplicación : Ventas y Cuentas Por Cobrar             
// Tabla      : DPCLIENTESSUC

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCLIENTESSUC(nOption,cCodigo,cCodCli)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oDpLbx
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Sucursales del Cliente",;
        aItems1:={},;
        aItems2:={},;
        aItems3:={}

  aItems1:=ASQL("SELECT ESTADO FROM DPESTADOS WHERE PAIS "+GetWhere("=",oDp:cPais))

  IF Empty(aItems1) 
     EJECUTAR("CREA_REGION")
     aItems1:=ASQL("SELECT ESTADO FROM DPESTADOS WHERE PAIS "+GetWhere("=",oDp:cPais))
  ENDIF

  AEVAL(aItems1,{|a,n| aItems1[n]:=a[1] })

  IF Empty(aItems1)
     AADD(aItems1,"Ninguno")
  ENDIF

  oDpLbx:=GetDpLbx(oDp:nNumLbx)

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)<>"A"
     oDpLbx:aCargo:=oDp:aCargo
  ENDIF

  IF ValType(oDpLbx)="O" .AND. ValType(oDpLbx:aCargo)="A"

     cCodCli:=oDpLbx:aCargo[2] // 2Cliente
     cTitle :=oDpLbx:cTitle+" "

  ENDIF

  DEFAULT cCodigo:="1234",nOption:=1,;
          cCodCli:=STRZERO(1,10)

  DEFAULT cTitle:=oDp:xDPCLIENTESSUC           

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  cSql     :="SELECT * FROM DPCLIENTESSUC WHERE SDC_CODCLI"+GetWhere("=",cCodCli)+" AND "+;
             "SDC_CODIGO"+GetWhere("=",cCodigo)


  IF nOption=1 // Incluir
    cTitle   :=" Incluir "+cTitle
  ELSE // Modificar o Consultar
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+cTitle 
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPCLIENTESSUC]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="SDC_CODIGO" // Clave de Validación de Registro

  oCLIENTESSUC:=DPEDIT():New(cTitle,"DPCLIENTESSUC.edt","oCLIENTESSUC" , .F. )

  oCLIENTESSUC:nOption  :=nOption
  oCLIENTESSUC:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCLIENTESSUC
  oCLIENTESSUC:SetScript()        // Asigna Funciones DpXbase como Metodos de oCLIENTESSUC
  oCLIENTESSUC:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCLIENTESSUC:nClrPane:=oDp:nGris
  oCLIENTESSUC:cCodCli:=cCodCli

  oCLIENTESSUC:SDC_CODCLI:=cCodCli

  IF oCLIENTESSUC:nOption=1 // Incluir en caso de ser Incremental
     // oCLIENTESSUC:RepeatGet(NIL,"SDC_CODIGO") // Repetir Valores
     oCLIENTESSUC:SDC_CODIGO:=SQLINCREMENTAL("DPCLIENTESSUC","SDC_CODIGO","SDC_CODCLI"+GetWhere("=",cCodCli))
  ENDIF

  //Tablas Relacionadas con los Controles del Formulario

  oCLIENTESSUC:SDC_ESTADO:=IIF( Empty(oCLIENTESSUC:SDC_ESTADO) .AND. !Empty(aItems1) , aItems1[1] , oCLIENTESSUC:SDC_ESTADO)

  aItems2:=oCLIENTESSUC:GETMUNICIPIO(oCLIENTESSUC:SDC_ESTADO)

  oCLIENTESSUC:SDC_MUNICI:=IIF( Empty(oCLIENTESSUC:SDC_MUNICI) .AND. !Empty(aItems2) , aItems2[1] , oCLIENTESSUC:SDC_MUNICI)

  aItems3:=oCLIENTESSUC:GETPARROQUIA(oCLIENTESSUC:SDC_ESTADO,oCLIENTESSUC:SDC_MUNICI)

  oCLIENTESSUC:CreateWindow()       // Presenta la Ventana


  // Opciones del Formulario

  
  //
  // Campo : SDC_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oCLIENTESSUC:oSDC_CODIGO  VAR oCLIENTESSUC:SDC_CODIGO  VALID CERO(oCLIENTESSUC:SDC_CODIGO);
                    WHEN (AccessField("DPCLIENTESSUC","SDC_CODIGO",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oCLIENTESSUC:oSDC_CODIGO:cMsg    :="Código"
    oCLIENTESSUC:oSDC_CODIGO:cToolTip:="Código"

  @ oCLIENTESSUC:oSDC_CODIGO:nTop-08,oCLIENTESSUC:oSDC_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SDC_NOMBRE
  // Uso   : Nombre                                  
  //
  @ 2.8, 1.0 GET oCLIENTESSUC:oSDC_NOMBRE  VAR oCLIENTESSUC:SDC_NOMBRE  VALID CERO(oCLIENTESSUC:SDC_NOMBRE);
                    WHEN (AccessField("DPCLIENTESSUC","SDC_NOMBRE",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 200,10

    oCLIENTESSUC:oSDC_NOMBRE:cMsg    :="Nombre"
    oCLIENTESSUC:oSDC_NOMBRE:cToolTip:="Nombre"

  @ oCLIENTESSUC:oSDC_NOMBRE:nTop-08,oCLIENTESSUC:oSDC_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ .9,06 BMPGET oCLIENTESSUC:oSDC_CODVEN VAR oCLIENTESSUC:SDC_CODVEN;
                 VALID CERO(oCLIENTESSUC:SDC_CODVEN,NIL,.T.) .AND. oCLIENTESSUC:VALCODVEN();
                 NAME "BITMAPS\VENDEDORES2.BMP";
                 ACTION (oDpLbx:=DpLbx("DPVENDEDOR",NIL,"VEN_SITUAC='A'",NIL,NIL,NIL,NIL,NIL,NIL,oCLIENTESSUC:oSDC_CODVEN,oCLIENTESSUC:oWnd),;
                        oDpLbx:GetValue("VEN_CODIGO",oCLIENTESSUC:oSDC_CODVEN));
                 WHEN (AccessField("DPDOCCLI","SDC_CODVEN",oCLIENTESSUC:nOption);
                      .AND. oCLIENTESSUC:nOption!=0 );
                 SIZE 28,10

  //
  // Campo : SDC_DIR1  
  // Uso   : Dirección 1                             
  //
  @ 8.5, 1.0 GET oCLIENTESSUC:oSDC_DIR1    VAR oCLIENTESSUC:SDC_DIR1   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_DIR1",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCLIENTESSUC:oSDC_DIR1  :cMsg    :="Dirección"
    oCLIENTESSUC:oSDC_DIR1  :cToolTip:="Dirección"

  @ oCLIENTESSUC:oSDC_DIR1  :nTop-08,oCLIENTESSUC:oSDC_DIR1  :nLeft SAY "Dirección" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SDC_DIR2  
  // Uso   : Dirección 2                             
  //
  @ 1.0,15.0 GET oCLIENTESSUC:oSDC_DIR2    VAR oCLIENTESSUC:SDC_DIR2   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_DIR2",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCLIENTESSUC:oSDC_DIR2  :cMsg    :=" "
    oCLIENTESSUC:oSDC_DIR2  :cToolTip:=" "

/*
  @ oCLIENTESSUC:oSDC_DIR2  :nTop-08,oCLIENTESSUC:oSDC_DIR2  :nLeft SAY " " PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

*/

  //
  // Campo : SDC_DIR3  
  // Uso   : Dirección 3                             
  //
  @ 2.8,15.0 GET oCLIENTESSUC:oSDC_DIR3    VAR oCLIENTESSUC:SDC_DIR3   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_DIR3",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

/*
    oCLIENTESSUC:oSDC_DIR3  :cMsg    :=" "
    oCLIENTESSUC:oSDC_DIR3  :cToolTip:=" "

  @ oCLIENTESSUC:oSDC_DIR3  :nTop-08,oCLIENTESSUC:oSDC_DIR3  :nLeft SAY " " PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris
*/

  //
  // Campo : SDC_AREA  
  // Uso   : Cód. Area                               
  //
  @ 4.6,15.0 GET oCLIENTESSUC:oSDC_AREA    VAR oCLIENTESSUC:SDC_AREA   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_AREA",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oCLIENTESSUC:oSDC_AREA  :cMsg    :="Cód. Area"
    oCLIENTESSUC:oSDC_AREA  :cToolTip:="Cód. Area"

  @ oCLIENTESSUC:oSDC_AREA  :nTop-08,oCLIENTESSUC:oSDC_AREA  :nLeft SAY "Cód."+CRLF+"Area" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  
  // Campo : SDC_TEL2  
  // Uso   : Teléfono 2                              
  //
  @ 6.4,15.0 GET oCLIENTESSUC:oSDC_TEL2    VAR oCLIENTESSUC:SDC_TEL2   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_TEL2",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

    oCLIENTESSUC:oSDC_TEL2  :cMsg    :="Teléfonos"
    oCLIENTESSUC:oSDC_TEL2  :cToolTip:="Teléfonos"

  @ oCLIENTESSUC:oSDC_TEL2  :nTop-08,oCLIENTESSUC:oSDC_TEL2  :nLeft SAY "Teléfonos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SDC_TEL1  
  // Uso   : Teléfono 1                              
  //
  @ 8.2,15.0 GET oCLIENTESSUC:oSDC_TEL1    VAR oCLIENTESSUC:SDC_TEL1   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_TEL1",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

    oCLIENTESSUC:oSDC_TEL1  :cMsg    :=" "
    oCLIENTESSUC:oSDC_TEL1  :cToolTip:=" "

  @ oCLIENTESSUC:oSDC_TEL1  :nTop-08,oCLIENTESSUC:oSDC_TEL1  :nLeft SAY " " PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  // Campo : SDC_VIATIC
  // Uso   : Viaticos del Cliente
   
      @ 9.8,15.0 GET oCLIENTESSUC:oSDC_VIATIC    VAR oCLIENTESSUC:SDC_VIATIC   ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_VIATIC",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

                   oCLIENTESSUC:oSDC_VIATIC  :cMsg    :="Viaticos"
                   oCLIENTESSUC:oSDC_VIATIC  :cToolTip:="Viaticos"

     @ oCLIENTESSUC:oSDC_VIATIC  :nTop-08,oCLIENTESSUC:oSDC_VIATIC  :nLeft SAY "Viaticos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : SDC_REPRES
  // Uso   : Representante                           
  //
  @ 10.0,15.0 GET oCLIENTESSUC:oSDC_REPRES  VAR oCLIENTESSUC:SDC_REPRES ;
                    WHEN (AccessField("DPCLIENTESSUC","SDC_REPRES",oCLIENTESSUC:nOption);
                    .AND. oCLIENTESSUC:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCLIENTESSUC:oSDC_REPRES:cMsg    :="Representante"
    oCLIENTESSUC:oSDC_REPRES:cToolTip:="Representante"

  @ oCLIENTESSUC:oSDC_REPRES:nTop-08,oCLIENTESSUC:oSDC_REPRES:nLeft SAY "Representante" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


//
  // Campo : SDC_ESTADO
  // Uso   : Estado                                  
  //
  @ 4.1, 1.0 COMBOBOX oCLIENTESSUC:oSDC_ESTADO VAR oCLIENTESSUC:SDC_ESTADO ITEMS aItems1;
                      WHEN (AccessField("DPCLIENTESSUC","SDC_ESTADO",oCLIENTESSUC:nOption);
                     .AND. oCLIENTESSUC:nOption!=0) .AND. LEN(oCLIENTESSUC:oSDC_ESTADO:aItems)>1;
                      ON CHANGE oCLIENTESSUC:GETMUNICIPIO(oCLIENTESSUC:SDC_ESTADO,oCLIENTESSUC:oSDC_MUNICI);
                      FONT oFontG


 ComboIni(oCLIENTESSUC:oSDC_ESTADO)


    oCLIENTESSUC:oSDC_ESTADO:cMsg    :=oDP:xDPESTADOS
    oCLIENTESSUC:oSDC_ESTADO:cToolTip:=oDP:xDPESTADOS


  @ oCLIENTESSUC:oSDC_ESTADO:nTop-08,oCLIENTESSUC:oSDC_ESTADO:nLeft SAY oDP:xDPESTADOS PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SDC_MUNICI
  // Uso   : Municipio                               
  //
  @ 5.4, 1.0 COMBOBOX oCLIENTESSUC:oSDC_MUNICI VAR oCLIENTESSUC:SDC_MUNICI ITEMS aItems2;
                      WHEN (AccessField("DPCLIENTESSUC","SDC_MUNICI",oCLIENTESSUC:nOption);
                     .AND. oCLIENTESSUC:nOption!=0) .AND. LEN(oCLIENTESSUC:oSDC_MUNICI:aItems)>1;
                      FONT oFontG;
                      ON CHANGE oCLIENTESSUC:GETPARROQUIA(oCLIENTESSUC:SDC_ESTADO,oCLIENTESSUC:SDC_MUNICI,oCLIENTESSUC:oSDC_PARROQ)


 ComboIni(oCLIENTESSUC:oSDC_MUNICI)


    oCLIENTESSUC:oSDC_MUNICI:cMsg    :=oDp:XDPMUNICIPIOS
    oCLIENTESSUC:oSDC_MUNICI:cToolTip:=oDp:XDPMUNICIPIOS

  @ 0,0 SAY oDp:XDPMUNICIPIOS PIXEL;
            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SDC_PARROQ
  // Uso   : Parroquia                               
  //
  @ 6.7, 1.0 COMBOBOX oCLIENTESSUC:oSDC_PARROQ VAR oCLIENTESSUC:SDC_PARROQ ITEMS aItems3;
                      WHEN (AccessField("DPCLIENTESSUC","SDC_PARROQ",oCLIENTESSUC:nOption);
                      .AND. oCLIENTESSUC:nOption!=0) .AND. LEN(oCLIENTESSUC:oSDC_PARROQ:aItems)>1 ;
                      FONT oFontG


 ComboIni(oCLIENTESSUC:oSDC_PARROQ)


    oCLIENTESSUC:oSDC_PARROQ:cMsg    :=oDp:XDPPARROQUIAS  
    oCLIENTESSUC:oSDC_PARROQ:cToolTip:=oDp:XDPPARROQUIAS  

  @ 0,0 SAY oDp:XDPPARROQUIAS PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 20,0 SAY oDp:XDPVENDEDOR PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 25,0 SAY oCLIENTESSUC:oSayVendedor;
         PROMPT SQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oCLIENTESSUC:SDC_CODVEN));
         PIXEL;
         SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris




/*
  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCLIENTESSUC:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oCLIENTESSUC:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oCLIENTESSUC:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF
*/

  oCLIENTESSUC:Activate({|| oCLIENTESSUC:INICIO() })

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCLIENTESSUC


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oCLIENTESSUC:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   IF oCLIENTESSUC:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oCLIENTESSUC:Save())

     oBtn:cToolTip:="Guardar"

     oCLIENTESSUC:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oCLIENTESSUC:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oCLIENTESSUC:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


 
RETURN .T.




/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCLIENTESSUC:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  // Condiciones para no Repetir el Registro

  oCLIENTESSUC:SDC_CODCLI:=oCLIENTESSUC:cCodCli


RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

FUNCTION GETMUNICIPIO(cEstado,oMunici)

   LOCAL aMuni:=ASQL(" SELECT MUNICIPIO FROM DPMUNICIPIOS WHERE "+;
                     " PAIS  "+GetWhere("=",oDp:cPais) + " AND "+;
                     " ESTADO"+GetWhere("=",cEstado  ))

   
//   ? ValType(aMuni),CLPCOPY(oDp:cSql)

   AEVAL(aMuni , { |a,n| aMuni[n]:= a[1] } )

   IF Empty(aMuni)
      aMuni:={}
      AADD(aMuni, "Indefinido")
   ENDIF

   IF ValType(oMunici)="O"
      oMunici:SetItems(aMuni)
      COMBOINI(oMunici)
      oMunici:ForWhen()
  ENDIF
   
RETURN aMuni 

FUNCTION GETPARROQUIA(cEstado,cMunici,oParro)

   LOCAL aParro:=ASQL("SELECT PARROQUIA FROM DPPARROQUIAS WHERE "+;
                      " PAIS  "   +GetWhere("=",oDp:cPais)+" AND "+;
                      " ESTADO"   +GetWhere("=",cEstado  )+" AND "+;
                      " MUNICIPIO"+GetWhere("=",cMunici  ))


   AEVAL(aParro , { |a,n| aParro[n]:= a[1] } )

   IF Empty(aParro)
      aParro:={}
      AADD(aParro, "Indefinido")
   ENDIF

   IF ValType(oParro)="O"
      oParro:SetItems(aParro)
      COMBOINI(oParro)
      oParro:ForWhen()
   ENDIF

RETURN aParro

FUNCTION VALCODVEN()

  IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oCLIENTESSUC:SDC_CODVEN))
     oCLIENTESSUC:oSDC_CODVEN:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  oCLIENTESSUC:oSayVendedor:Refresh(.F.)

RETURN .T.

// EOF



/*
<LISTA:SDC_CODIGO:N:GET:N:N:Y:Código,SDC_NOMBRE:N:GET:N:N:Y:Nombre,SDC_ESTADO:N:COMBO:N:N:Y:Estado,SDC_MUNICI:N:COMBO:N:N:Y:Municipio
,SDC_PARROQ:N:COMBO:N:N:Y:Parroquia,SDC_DIR1:N:GET:N:N:Y:Dirección 1,SDC_DIR2:N:GET:N:N:Y:Dirección 2,SDC_DIR3:N:GET:N:N:Y:Dirección 3
,SDC_AREA:N:GET:N:N:Y:Cód. Area,SDC_TEL2:N:GET:N:N:Y:Teléfono 2,SDC_TEL1:N:GET:N:N:Y:Teléfono 1,SDC_REPRES:N:GET:N:N:Y:Representante
,SDC_VIATIC:N:GET:N:N:Y:Viaticos
>
*/
