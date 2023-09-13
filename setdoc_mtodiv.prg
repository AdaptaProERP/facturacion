// Programa   : SETDOC_MTODIV
// Fecha/Hora : 26/04/2023 05:37:49
// Propósito  : Asignar Monto de DOC_MTODIV
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cSql,oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL cCodigo,cDescri,cSql,lRun:=.T.

  EJECUTAR("DPTRIGGERSDELA")

  oDb:EXECUTE(" UPDATE dpdoccli    SET DOC_BASNET=0,DOC_MTOEXE=DOC_NETO WHERE DOC_BASNET>0 AND DOC_MTOIVA=0")
  oDb:EXECUTE(" UPDATE dpdoccli    SET DOC_MTOEXE=DOC_NETO              WHERE DOC_MTOIVA=0")

  oDb:Execute(" UPDATE dpdocprocta SET CCD_TOTAL=CCD_MONTO+(CCD_MONTO*(CCD_PORIVA/100)) WHERE CCD_TOTAL=0")
  oDb:Execute(" UPDATE dpdocclicta SET CCD_TOTAL=CCD_MONTO+(CCD_MONTO*(CCD_PORIVA/100)) WHERE CCD_TOTAL=0")

  EJECUTAR("DPCAMPOSADD","DPDOCCLI"    ,"DOC_MTODIV","N",019,2,"Monto en Divisa") 
  EJECUTAR("DPCAMPOSADD","DPDOCCLI"    ,"DOC_DIVISA","L",001,0,"En Divisa",NIL,.T.,.F.,[.F.])
  EJECUTAR("DPCAMPOSADD","DPDOCCLI_HIS","DOC_DIVISA","L",001,0,"En Divisa",NIL,.T.,.F.,[.F.])

  EJECUTAR("SETFIELDLONG","DPDOCCLI","DOC_MTODIV" ,19,2)

  cSql:=" ALTER TABLE `dpdoccli` CHANGE COLUMN `DOC_MTODIV` `DOC_MTODIV` DECIMAL(19,2)"
  oDb:EXECUTE(cSql)

//  cSql:=[ UPDATE dpdoccli SET DOC_MTODIV=ROUND(DOC_NETO/DOC_VALCAM,2) WHERE DOC_TIPTRA="D" AND (DOC_MTODIV>DOC_NETO OR DOC_MTODIV IS NULL OR DOC_MTODIV=0)]
//  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCCLI SET DOC_VALCAM=IF(DOC_VALCAM=0,1,DOC_VALCAM),DOC_MTODIV=IF(DOC_DIVISA,DOC_NETO,ROUND(DOC_NETO/DOC_VALCAM,2)) WHERE DOC_TIPTRA="D" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCPRO SET DOC_VALCAM=IF(DOC_VALCAM=0,1,DOC_VALCAM),DOC_MTODIV=ROUND(DOC_NETO/DOC_VALCAM,2) WHERE DOC_TIPTRA="D" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCCLI SET DOC_VALCAM=IF(DOC_VALCAM=0,1,DOC_VALCAM),DOC_MTODIV=IF(DOC_DIVISA=1,DOC_NETO,ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2)) WHERE DOC_TIPTRA="P" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCPRO SET DOC_VALCAM=IF(DOC_VALCAM=0,1,DOC_VALCAM),DOC_MTODIV=ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2) WHERE DOC_TIPTRA="P" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCPRO SET DOC_MTOCOM=0 WHERE DOC_MTOCOM IS NULL ]
  oDb:EXECUTE(cSql)

  EJECUTAR("DPCAMPOSADD" ,"DPDOCPRO","DOC_MTODIV","N",019,2,"Monto en Divisa")  
  EJECUTAR("DPCAMPOSADD" ,"DPDOCPRO","DOC_MTOCOM","N",019,2,"Monto Revalorización")
  EJECUTAR("SETFIELDLONG","DPDOCPRO","DOC_MTODIV" ,19,2)

  cSql:=" ALTER TABLE `dpdocpro` CHANGE COLUMN `DOC_MTODIV` `DOC_MTODIV` DECIMAL(19,2) "
  oDb:EXECUTE(cSql)


  cSql:=[UPDATE DPDOCPRO SET DOC_MTODIV=ROUND(DOC_NETO/DOC_VALCAM,2) WHERE DOC_TIPTRA="D" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE DPDOCPRO SET DOC_MTODIV=ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2) WHERE DOC_TIPTRA="P" AND DOC_VALCAM<>1 ]
  oDb:EXECUTE(cSql)


  cCodigo:="DOCCLICXCDIV"
  cDescri:="CXC en Divisas por Documento de Cliente"
  lRun   :=.T.

  cSql   :=[ SELECT DOC_CODSUC AS CXD_CODSUC,DOC_TIPDOC AS CXD_TIPDOC,DOC_NUMERO AS CXD_NUMERO, ]+CRLF+;
           [ DOC_CODIGO AS CXD_CODIGO, ]+CRLF+;       
           [ MAX(DOC_FCHVEN) AS CXD_FCHMAX,]+CRLF+;                                                       
           [ MIN(DOC_FECHA)  AS CXD_FECHA, ]+CRLF+;            
           [ SUM(ROUND((DOC_NETO+IF(DOC_TIPTRA="D",DOC_MTOCOM,0))/DOC_VALCAM,2)*DOC_CXC) AS CXD_CXCDIV, ]+CRLF+;
           [ SUM(IF(DOC_TIPTRA="D",DOC_NETO,0)) AS CXD_MTODOC,]+CRLF+;       
           [ SUM(DOC_NETO*DOC_CXC) AS CXD_NETO,]+CRLF+;                                                                         
           [ SUM(IF(DOC_TIPTRA="P",DOC_NETO,0)) AS CXD_MTOPAG, ]+CRLF+;     
           [ SUM(IF(DOC_TIPTRA="P",ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2),0)) AS CXD_PAGDIV, ]+CRLF+;
           [ COUNT(*) AS CXD_CANDOC, ]+CRLF+;
           [ SUM(DOC_NETO*DOC_CXC) AS CXD_SALDO ]+CRLF+;  
           [ FROM dpdoccli ]+CRLF+;        
           [ WHERE DOC_CXC<>0 AND DOC_ACT=1 AND DOC_VALCAM>1 ]+CRLF+;        
           [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]+CRLF+;        
           [ HAVING CXD_CXCDIV<>0 ]+;
           [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cCodigo:="DOCCLICXC"
  cDescri:="CXC en por Documento de Cliente"
  lRun   :=.T.

  cSql   :=[ SELECT DOC_CODSUC AS CXD_CODSUC,DOC_TIPDOC AS CXD_TIPDOC,DOC_NUMERO AS CXD_NUMERO, ]+CRLF+;
           [ DOC_CODIGO AS CXD_CODIGO, ]+CRLF+;       
           [ MAX(DOC_FCHVEN) AS CXD_FCHMAX,]+CRLF+;                                                       
           [ MIN(DOC_FECHA)  AS CXD_FECHA, ]+CRLF+;            
           [ SUM(ROUND((DOC_NETO+IF(DOC_TIPTRA="D",DOC_MTOCOM,0))/DOC_VALCAM,2)*DOC_CXC) AS CXD_CXCDIV, ]+CRLF+;
           [ SUM(IF(DOC_TIPTRA="D",DOC_NETO,0)) AS CXD_MTODOC,]+CRLF+;       
           [ SUM(DOC_NETO*DOC_CXC) AS CXD_NETO,]+CRLF+;                                                                         
           [ SUM(IF(DOC_TIPTRA="P",DOC_NETO,0)) AS CXD_MTOPAG, ]+CRLF+;     
           [ SUM(IF(DOC_TIPTRA="P",ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2),0)) AS CXD_PAGDIV, ]+CRLF+;
           [ SUM(DOC_NETO*DOC_CXC) AS CXD_SALDO ]+CRLF+;  
           [ FROM dpdoccli ]+CRLF+;        
           [ WHERE DOC_CXC<>0 AND DOC_ACT=1 AND DOC_VALCAM>1 ]+CRLF+;        
           [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]+CRLF+;        
           [ HAVING SUM(DOC_NETO*DOC_CXC)<>0 ]+CRLF+;       
           [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)


  cCodigo:="DOCPROCXPDIV"
  cDescri:="CXP en Divisas por Documento de Proveedor"
  lRun   :=.T.

  // 08/05/2023 Resuelve residuos de CxP en Divisas
  cSql:=[ SELECT  ]+CRLF+;
        [ DOC_CODSUC AS CXD_CODSUC, ]+CRLF+;
        [ DOC_TIPDOC AS CXD_TIPDOC, ]+CRLF+;
        [ DOC_NUMERO AS CXD_NUMERO, ]+CRLF+;
        [ DOC_CODIGO AS CXD_CODIGO, ]+CRLF+;
        [ MAX(DOC_FCHVEN) AS CXD_FCHMAX,]+CRLF+;
        [ MIN(DOC_FECHA)  AS CXD_FECHA, ]+CRLF+;
        [ SUM(ROUND((DOC_NETO+IF(DOC_TIPTRA="D",DOC_MTOCOM,0))/DOC_VALCAM,2)*DOC_CXP) AS CXD_CXPDIV, ]+CRLF+;
        [ SUM(IF(DOC_TIPTRA="D",DOC_NETO,0)) AS CXD_MTODOC,]+CRLF+;        
        [ SUM(DOC_NETO*DOC_CXP) AS CXD_NETO, ]+CRLF+;
        [ SUM(IF(DOC_TIPTRA="P",DOC_NETO,0)) AS CXD_MTOPAG,]+CRLF+;
        [ SUM(IF(DOC_TIPTRA="P",ROUND((DOC_NETO+DOC_MTOCOM)/DOC_VALCAM,2),0)) AS CXD_PAGDIV ]+CRLF+;
        [ FROM dpdocpro ]+CRLF+;
        [ WHERE DOC_CXP<>0 AND DOC_ACT=1 AND DOC_VALCAM>1 ]+CRLF+; 
        [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO  ]+CRLF+;
        [ HAVING CXD_CXPDIV<>0 ]+;
        [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cSql:=[ SELECT ]+CRLF+;                                       
        [ DOC_CODSUC AS PAG_CODSUC, ]+CRLF+;                                     
        [ DOC_TIPDOC AS PAG_TIPDOC, ]+CRLF+;                                     
        [ DOC_CODIGO AS PAG_CODIGO, ]+CRLF+;                                     
        [ DOC_FECHA  AS PAG_FECHA , ]+CRLF+;                                     
        [ CLI_NOMBRE AS PAG_NOMBRE, ]+CRLF+;                                     
        [ DOC_NUMERO AS PAG_NUMERO, ]+CRLF+;                                 
        [ DOC_CXC    AS PAG_CXC,    ]+CRLF+;                          
        [ IF(DOC_TIPTRA="D","P","D") AS PAG_TIPTRA,]+CRLF+;                                        
        [ DOC_NETO   AS PAG_NETO,  ]+CRLF+;                             
        [ DOC_BASNET AS PAG_BASNET,]+CRLF+;                               
        [ DOC_MTOIVA AS PAG_MTOIVA,]+CRLF+;                          
        [ DOC_RECNUM AS PAG_RECNUM,]+CRLF+;                    
        [ DOC_FCHDEC AS PAG_FCHDEC,]+CRLF+; 
        [ DOC_VALCAM AS PAG_VALCAM,]+CRLF+;  
        [ ROUND(DOC_NETO/DOC_VALCAM,2) AS PAG_PAGDIV,]+CRLF+;       
        [ DOC_MTOCOM AS PAG_MTODIF,]+CRLF+;              
        [ DOC_ACT    AS PAG_ACT,   ]+CRLF+;    
        [ REC_ACT    AS REC_ACT    ]+CRLF+;                                         
        [ FROM DPDOCCLI ]+CRLF+;                      
        [ INNER JOIN DPCLIENTES   ON CLI_CODIGO = DOC_CODIGO   ]+CRLF+;
        [ INNER JOIN DPRECIBOSCLI ON DOC_CODSUC = REC_CODSUC AND DOC_RECNUM=REC_NUMERO ]+CRLF+;                                     
        [ INNER JOIN DPTIPDOCCLI  ON TDC_TIPO   = DOC_TIPDOC   ]+CRLF+;                                 
        [ WHERE DOC_TIPTRA="P" AND DOC_CXC<>0 AND TDC_PAGOS=1 ]+CRLF+;               
        [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO  ]


  cCodigo:="DPDOCCLIPAG"
  cDescri:="Documentos pagado del Cliente"
  lRun   :=.T.

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cSql:=[ SELECT  ]+CRLF+;
        [ DOC_CODSUC AS CXD_CODSUC,]+CRLF+;
        [ DOC_TIPDOC AS CXD_TIPDOC,]+CRLF+;                                                
        [ DOC_NUMERO AS CXD_NUMERO,]+CRLF+;                                               
        [ DOC_CODIGO AS CXD_CODIGO,]+CRLF+;                                    
        [ MAX(DOC_FCHVEN) AS CXD_FCHMAX,]+CRLF+;                                    
        [ DOC_FECHA       AS CXD_FECHA, ]+CRLF+;                                 
        [ SUM(DOC_NETO*DOC_CXP) AS CXD_NETO,]+CRLF+;                
        [ SUM(IF(DOC_TIPTRA="D",DOC_NETO,0)) AS CXD_MTODOC,]+CRLF+;                                                
        [ SUM(IF(DOC_TIPTRA="P",DOC_NETO,0)) AS CXD_MTOPAG,]+CRLF+;  
        [ SUM(ROUND((DOC_NETO+IF(DOC_TIPTRA="D",DOC_MTOCOM,0))/DOC_VALCAM,2)*DOC_CXP) AS CXD_CXPDIV, ]+CRLF+;
        [ SUM(DOC_NETO*DOC_CXP) AS CXD_SALDO ]+CRLF+;          
        [ FROM DPDOCPRO ]+CRLF+;                                                
        [ WHERE DOC_CXP<>0 AND DOC_ACT=1 ]+CRLF+;                                               
        [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO ]+CRLF+;                                      
        [ HAVING SUM(DOC_NETO*DOC_CXP)<>0 ]+CRLF+;                                               
        [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO ]


  cCodigo:="DOCPROCXP"
  cDescri:="CXP por Documento del Proveedor"
  lRun   :=.T.
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  cSql   :=[ SELECT ]+;
           [ DOC_CODSUC      AS PAG_CODSUC,]+CRLF+;                                   
           [ DOC_TIPDOC      AS PAG_TIPDOC,]+CRLF+;                                    
           [ DOC_NUMERO      AS PAG_NUMERO,]+CRLF+;                                    
           [ SUM(DOC_NETO)   AS PAG_NETO, ]+CRLF+;                
           [ SUM(DOC_MTOCOM) AS PAG_MTODIF,]+CRLF+;               
           [ SUM(DOC_NETO/IF(DOC_VALCAM>=1,DOC_VALCAM,0)) AS PAG_MTODIV, ]+CRLF+;                              
           [ COUNT(*)        AS PAG_CUANTOS, ]+CRLF+;                        
           [ DOC_RECNUM      AS PAG_RECNUM,  ]+CRLF+;                    
           [ DOC_CBTNUM      AS PAG_CBTNUM,  ]+CRLF+;                  
           [ DOC_FECHA       AS PAG_FECHA ,  ]+CRLF+;            
           [ AVG(DOC_VALCAM) AS PAG_VALCAM ]+CRLF+;           
           [ FROM DPDOCCLI  ]+CRLF+;                                  
           [ WHERE DOC_TIPTRA="P" AND DOC_ACT=1 ]+CRLF+;                                    
           [ GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]+CRLF+;                                   
           [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

  cCodigo:="DOCCLIPAG"
  cDescri:="Pagos del Documento del Cliente  "
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cSql:=[ UPDATE DPDOCCLI ]+;
        [ INNER JOIN VIEW_DOCCLIDESORG ON DOR_CODSUC=DOC_CODSUC AND DOR_TIPORG=DOC_TIPDOC AND DOR_DOCORG=DOC_NUMERO AND DOC_TIPTRA="P" ]+;      
        [ INNER JOIN VIEW_DOCCLICXCDIV ON DOR_CODSUC=CXD_CODSUC AND DOR_TIPORG=CXD_TIPDOC AND DOR_DOCORG=CXD_NUMERO ]+;
        [ INNER JOIN view_DPDOCCLIpag  ON DOR_CODSUC=PAG_CODSUC AND DOR_TIPORG=PAG_TIPDOC AND DOR_DOCORG=PAG_NUMERO ]+;
        [ SET DOC_MTOCOM=0 ]+;
        [ WHERE PAG_VALCAM IS NOT NULL AND DOR_VALCAM=PAG_VALCAM AND DOR_NETO=PAG_NETO AND PAG_MTODIF<>0 ]

  oDb:EXECUTE(cSql)


   cSql:=[ UPDATE  DPDOCCLI ]+;
         [ INNER JOIN VIEW_DOCCLIDESORG ON DOR_CODSUC=DOC_CODSUC AND DOR_TIPORG=DOC_TIPDOC AND DOR_DOCORG=DOC_NUMERO AND DOC_TIPTRA="P" ]+;
         [ INNER JOIN VIEW_DOCCLICXCDIV ON DOR_CODSUC=CXD_CODSUC AND DOR_TIPORG=CXD_TIPDOC AND DOR_DOCORG=CXD_NUMERO ]+;
         [ INNER JOIN view_DPDOCCLIpag  ON DOR_CODSUC=PAG_CODSUC AND DOR_TIPORG=PAG_TIPDOC AND DOR_DOCORG=PAG_NUMERO ]+;
         [ SET DOC_VALCAM=DOR_VALCAM ]+;
         [ WHERE DOR_NETO=PAG_NETO AND ABS(CXD_CXCDIV)<=1 AND ABS(CXD_CXCDIV)<>0 ]
 
  oDb:EXECUTE(cSql)

  // 21/07/2023

  SQLUPDATE("DPRECIBOSCLI","REC_ESTADO","Nulo","REC_ACT=0")

  cSql:=[ UPDATE DPDOCCLI ]+;
        [ INNER JOIN DPRECIBOSCLI ON REC_CODSUC=DOC_CODSUC AND REC_NUMERO=DOC_RECNUM  ]+;
        [ SET DOC_ACT=REC_ACT WHERE DOC_TIPDOC="IGT" AND REC_ACT<>DOC_ACT ]

  oDb:Execute(cSql)
  
  SQLUPDATE("DPDOCCLI","DOC_ESTADO","N","DOC_ACT=0")

  oDb:Execute(cSql)

  cSql:=[ SELECT CXD_CODIGO AS CXC_CODIGO,SUM(CXD_NETO) AS CXC_SALDO,COUNT(*) AS CXC_CANDOC  ]+;
        [ FROM VIEW_DOCCLICXC ]+;
        [ GROUP BY CXD_CODIGO ]+;
        [ ORDER BY CXD_CODIGO ]

  cCodigo:="CLICXC"
  cDescri:="Cuenta por Cobrar (Deuda) Cliente  "
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)


RETURN .T.
// EOF

