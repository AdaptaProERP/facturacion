// Programa   : DPSERIEFISCAL_DOCCLI
// Fecha/Hora : 26/02/2025 23:25:20
// Propósito  : Serie fiscal Integridad Referencial
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cLetra,cModelo,cCodSuc)
   LOCAL cWhere:="",I
   LOCAL aSerie:=ATABLE("SELECT DOC_SERFIS FROM dpdoccli LEFT JOIN dpseriefiscal ON DOC_SERFIS=SFI_LETRA WHERE SFI_MODELO IS NULL GROUP BY DOC_SERFIS")

   DEFAULT cLetra :=SPACE(1),;
           cModelo:="NO-FISCAL",;
           cCodSuc:=oDp:cSucursal

   cWhere:="SFI_LETRA"+GetWhere("=",cLetra)

   EJECUTAR("CREATERECORD","DPSERIEFISCAL",{"SFI_CODSUC","SFI_MODELO","SFI_LETRA","SFI_ACTIVO","SFI_IMPFIS","SFI_PUERTO"},;
                                           {cCodSuc     ,cModelo   , cLetra    ,.T.           ,"NO-FISCAL" ,"NING"},;
                                           NIL,.T.,cWhere)

   FOR I=1 TO LEN(aSerie)

     cLetra :=aSerie[I]
     cModelo:="Indef-"+cLetra
  
     cWhere:="SFI_LETRA"+GetWhere("=",cLetra)

     EJECUTAR("CREATERECORD","DPSERIEFISCAL",{"SFI_CODSUC","SFI_MODELO","SFI_LETRA","SFI_ACTIVO","SFI_IMPFIS","SFI_PUERTO"},;
                                             {cCodSuc     ,cModelo   , cLetra    ,.T.           ,"Indefinda" ,"NING"},;
                                             NIL,.T.,cWhere)

   NEXT I

RETURN .T.
/*
C001=SFI_MODELO          ,'C',015,0,'PRIMARY KEY NOT NULL','Modelo',0,''
 C002=SFI_ACTIVO          ,'L',001,0,'','Activo',0,''
 C003=SFI_ANCHO           ,'N',002,0,'','Ancho Impresora Fiscal',0,''
 C004=SFI_AUTDET          ,'L',001,0,'','Auto-Detectar',0,''
 C005=SFI_AUTOMA          ,'L',001,0,'','Automático',0,''
 C006=SFI_CANDEC          ,'N',001,0,'','Decimales en Cantidad',0,''
 C007=SFI_CANENT          ,'N',002,0,'','Enteros en Cantidad',0,''
 C008=SFI_CODSUC          ,'C',006,0,'','Sucursal',1,'&oDp:cSucursal'
 C009=SFI_COMEN1          ,'C',250,0,'','Comentario 1',0,''
 C010=SFI_COMEN2          ,'C',250,0,'','Comentario 2',0,''
 C011=SFI_COMEN3          ,'C',250,0,'','Comentario 3',0,''
 C012=SFI_DECPRE          ,'N',001,0,'','Cant. Decimales',0,''
 C013=SFI_EDITAB          ,'L',001,0,'','Editable',0,''
 C014=SFI_ENTPRE          ,'N',002,0,'','Longitud del Precio',0,''
 C015=SFI_FCHMAN          ,'D',010,0,'','Fecha para Mantenimiento',0,''
 C016=SFI_IMPFIS          ,'C',020,0,'','Impresora Fiscal',0,''
 C017=SFI_IP_PC           ,'C',010,0,'','PC Vinculado',0,''
 C018=SFI_ITEMXP          ,'N',003,0,'','Items por Página',0,''
 C019=SFI_JSONDV          ,'M',010,0,'','Devolución',0,''
 C020=SFI_JSONEV          ,'M',010,0,'','Enviar Correo',0,''
 C021=SFI_JSONFV          ,'M',010,0,'','Factura',0,''
*/
// EOF
