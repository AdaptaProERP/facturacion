// Programa   : DPDOCCLIPOSGRA
// Fecha/Hora : 09/10/2005 12:48:53
// Prop¢sito  : Post-Grabar en DPDOCCLI
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicaci¢n : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPosDocCli)
   LOCAL cSerie,cWhere,nOption,lAutImp:=.F.,nAt,lIslr:=.F.,cKey
   LOCAL lExpTot:=.F.,cDocDes:=""  // 28/09/2023 Exportar Total

/*
   IF oPosDocCli:DOC_CODIGO=STRZERO(0,10)
      EJECUTAR("DPCLICEROGRAB",oPosDocCli,oPosDocCli:nOption=1)
   ENDIF
*/
   IF ValType(oPosDocCli:bPostRun)="C"
      MACROEJE(oPosDocCli:bPostRun)
   ENDIF

   cKey:=oPosDocCli:DOC_CODSUC+","+;
         oPosDocCli:DOC_TIPDOC+","+;
         ALLTRIM(oPosDocCli:DOC_NUMERO)+",D"

//   DEFAULT oPosDocCli:lRunPrint:=.F.

   AUDITAR( IF(oPosDocCli:nOption=1,"DINC","DMOD"), .F.,"DPDOCCLI" , cKey , "DPAUDITOR", oPosDocCli )

   IF oPosDocCli:nOption=3

      //
      // Documentos Asociados
      //
      cWhere:="DOC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
              "DOC_TIPAFE"+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
              "DOC_FACAFE"+GetWhere("=",oPosDocCli:DOC_CODIGO_)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oPosDocCli:DOC_NUMERO_)

      SQLUPDATE("DPDOCCLI","DOC_FACAFE",oPosDocCli:DOC_NUMERO,cWhere)

      cWhere:="MOV_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
              "MOV_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
              "MOV_CODCTA"+GetWhere("=",oPosDocCli:DOC_CODIGO_)+" AND "+;
              "MOV_DOCUME"+GetWhere("=",oPosDocCli:DOC_NUMERO_)+" AND MOV_INVACT=1 AND MOV_APLORG='V' "

      SQLUPDATE("DPMOVINV","MOV_FECHA",oPosDocCli:DOC_FECHA,cWhere)

      // 27/09/2012
          
      cWhere:="RTI_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
              "RTI_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
              "RTI_NUMERO"+GetWhere("=",oPosDocCli:DOC_NUMERO_)


      SQLUPDATE("DPDOCCLIRTI","RTI_NUMERO",oPosDocCli:DOC_NUMERO,cWhere)

      cWhere:="RXC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
              "RXC_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
              "RXC_NUMDOC"+GetWhere("=",oPosDocCli:DOC_NUMERO_)

      SQLUPDATE("DPDOCCLIISLR","RXC_DOCNUM",oPosDocCli:DOC_NUMERO,cWhere)


      cWhere:="RXC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
              "RXC_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
              "RXC_NUMDOC"+GetWhere("=",oPosDocCli:DOC_NUMERO_)


      lIslr :=COUNT("DPDOCCLIISLR",cWhere)>0

      IF lIslr

        EJECUTAR("DPDOCISLR",oPosDocCli:DOC_CODSUC,;
                             oPosDocCli:DOC_TIPDOC,;
                             oPosDocCli:DOC_CODIGO,;
                             oPosDocCli:DOC_NUMERO,;
                             NIL , "V" , 0 , NIL)


        oDoc:LoadData(3)
        oGrid:Open() 
        oGrid:BtnSave()
        oGrid:Open()   

      ENDIF

   ENDIF

   // Tarea Automatica Requiere Referencia
   IF !Empty(oPosDocCli:cNumTar)

      cWhere:="DOC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oPosDocCli:DOC_NUMERO)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D")

      SQLUPDATE("DPTAREASXEJEC",{"TXE_TABLA","TXE_TABWER"},;
                                {"DPDOCCLI" ,cWhere      },;
                                "TXE_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                "TXE_NUMERO"+GetWhere("=",oPosDocCli:cNumTar))

   ENDIF
  
   oPosDocCli:oFocus:=oPosDocCli:oDOC_CODIGO
   nOption       :=oPosDocCli:nOption

   // Asigna el Codigo del Vendedor 
   // 19/04/2020 
   oPosDocCli:DOC_CODVEN:=RIGHT(oPosDocCli:DOC_CODVEN,6) // no puede pasar de 6 digitos
   IF ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oPosDocCli:DOC_CODVEN))
     SQLUPDATE("DPCLIENTES","CLI_CODVEN",oPosDocCli:DOC_CODVEN,"CLI_CODIGO"+GetWhere("=",oPosDocCli:DOC_CODIGO))
   ENDIF

//  EJECUTAR("DPFACTURAVMNU" , oPosDocCli:DOC_CODSUC , oPosDocCli:DOC_NUMERO , oPosDocCli:DOC_CODIGO , oPosDocCli:cTitle , oDoc)
//  EJECUTAR("DPDOCCLI"+oPosDocCli:DOC_TIPDOC+"MNU",oPosDocCli:DOC_CODSUC , oPosDocCli:DOC_NUMERO , oPosDocCli:DOC_CODIGO , oPosDocCli:cTitle , oDoc)

   IF oPosDocCli:nOption<>1 .AND. !Empty(oPosDocCli:DOC_CBTNUM)

      SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",oPosDocCli:DOC_CBTNUM_)+" AND "+;
                             "MOC_FECHA "+GetWhere("=",oPosDocCli:DOC_FECHA_ )+" AND "+;
                             "MOC_TIPO  "+GetWhere("=",oPosDocCli:DOC_TIPDOC_)+" AND "+;
                             "MOC_DOCUME"+GetWhere("=",oPosDocCli:DOC_NUMERO_)+" AND "+;
                             "MOC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC_)+" AND "+;
                             "MOC_ACTUAL"+GetWhere("=","N"                )+" AND "+;       
                             "MOC_TIPTRA"+GetWhere("=","D"                )+" AND "+;
                             "MOC_ORIGEN"+GetWhere("=","VTA"              )) 
   ENDIF

// IF (oPosDocCli:lPar_ConAut .AND. oPosDocCli:nPar_CXC<>0) .OR. (oPosDocCli:nOption<>1 .AND. !Empty(oPosDocCli:DOC_CBTNUM))
   IF (oPosDocCli:lPar_ConAut .AND. oPosDocCli:nPar_InvCon<>0) .OR. (oPosDocCli:nOption<>1 .AND. !Empty(oPosDocCli:DOC_CBTNUM))


      MsgRun("Contabilizando Documento "+oPosDocCli:DOC_NUMERO ,"Por favor Espere",{||;
               EJECUTAR("DPDOCCONTAB", NIL,oPosDocCli:DOC_CODSUC,;
                                           oPosDocCli:DOC_TIPDOC,;
                                           oPosDocCli:DOC_CODIGO,;
                                           oPosDocCli:DOC_NUMERO,.T.,.F.) })

   ENDIF

   IF "DATAPRO"$UPPE(oDp:cEmpresa) .AND. FILE("DPXBASE\DPLICAUTOASIGNA.DXB")
      EJECUTAR("DPLICAUTOASIGNA",oPosDocCli:DOC_TIPDOC,oPosDocCli:DOC_NUMERO,oPosDocCli:DOC_CODIGO,oPosDocCli:DOC_FECHA,oPosDocCli:DOC_HORA)
   ENDIF

   // Transacción InteEmpresa
   //
   IF oPosDocCli:DOC_TIPDOC="FAV" .AND. oDp:lInvConsol .AND. !Empty(oDp:cWhereExi)


      MsgRun("Generando Documentos Inter"+GetFromVar("{oDp:xDPSUCURSAL}"),"Por Favor Espere",;
            {||EJECUTAR("DPDOCINTERSUC",oPosDocCli:DOC_CODSUC, oPosDocCli:DOC_TIPDOC , oPosDocCli:DOC_CODIGO , oPosDocCli:DOC_NUMERO)})

   ENDIF

   DEFAULT oPosDocCli:lLimite:=.F.,;
           oPosDocCli:lMoneta:=.T.

   // JN, Depende de los permisos del usuario
   IF oPosDocCli:lLimite .AND. oPosDocCli:lMoneta .AND. .F.
      oPosDocCli:RECIBO()
      RETURN .T.
   ENDIF

   // PROFORMA ->FACTURA
/*
   // 7/2/2025 Optimizado desde DPFACTURAV
   lExpTot:=SQLGET("DPTIPDOCCLI","TDC_IMPTOT,TDC_DOCDES","TDC_TIPO"+GetWhere("=",oPosDocCli:DOC_TIPDOC))
   cDocDes:=DPSQLROW(2)
   cDocDes:=IF("NINGUN"$UPPER(cDocDes),"",cDocDes)
*/
   lExpTot:=oDocCli:lExpTot 
   cDocDes:=oDocCli:cDocDes 

// ? lExpTot,"<-lExpTot",cDocDes,"<-cDocDes, DOCCLIPOSTGRA"

   IF lExpTot .AND. !Empty(cDocDes)
     // SQLGET("DPTIPDOCCLI","TDC_IMPTOT,TDC_DOCDES","TDC_TIPO"+GetWhere("=",oPosDocCli:DOC_TIPDOC))
     // Exporta Automaticamente hacia la factura
     // cDocDes:=DPSQLROW(2)

     // Exportar de Ticket hacia devolución y debe realizarlo desde MENU 7/8/2024
     IF !oPosDocCli:DOC_TIPDOC="TIK"
        EJECUTAR("DPDOCCLIEXPMNU",oPosDocCli:DOC_CODSUC,oPosDocCli:DOC_TIPDOC,oPosDocCli:DOC_NUMERO,DPSQLROW(2))
     ENDIF

     RETURN .T.

   ELSE

     // ? oPosDocCli:lPar_MnuFin,"oPosDocCli:lPar_MnuFin"
     // 06/06/2024 Menú al Finalizar
     IF oPosDocCli:lPar_MnuFin
       EJECUTAR("DPDOCCLIMNU",oPosDocCli:DOC_CODSUC , oPosDocCli:DOC_NUMERO , oPosDocCli:DOC_CODIGO , oPosDocCli:cTitle , oPosDocCli:DOC_TIPDOC , oDoc  )
     ENDIF

   ENDIF

   
   // Se inactivo para volver a imprimir con EPSON  de antes TJ
   /*
   cSerie :=MYSQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF,TDC_AUTIMP","TDC_TIPO"+GetWhere("=",oPosDocCli:DOC_TIPDOC))

   IF "EPSON"$cSerie

      cWhere:="DOC_CODSUC"+GetWhere("=",oPosDocCli:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oPosDocCli:DOC_TIPDOC)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oPosDocCli:DOC_NUMERO)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D")
              
      EJECUTAR("FMTRUN","DPDOCCLI","DPDOCCLI"+oPosDocCli:DOC_TIPDOC,oPosDocCli:cTitle+" "+oPosDocCli:DOC_TIPDOC+" "+oPosDocCli:DOC_NUMERO,cWhere)

      nAt:=ASCAN(oFmt:oFormato:aItems,{|a,n| "EPSON"$UPPE(a) })
    
      IF nAt>0
         oFmt:oFormato:Select(nAt)
      ENDIF

      nAt:=ASCAN(oFmt:oLpt:aItems,{|a,n| "EPSON"$UPPE(a) })
    
      IF nAt>0
         oFmt:oLpt:Select(nAt)
      ENDIF

      cSerie :=SQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF,TDC_AUTIMP","TDC_TIPO"+GetWhere("=",oPosDocCli:DOC_TIPDOC))
      lAutImp:=IF(Empty(oDp:aRow),.T.,oDp:aRow[2])

      IF lAutImp
        EVAL(oFmt:oBtnRun:bAction)
      ENDIF    

   ENDIF
   */

   IF oPosDocCli:lPar_AutoImp  .AND. oPosDocCli:nOption=1 
 
     oPosDocCli:PRINTER() // 7/2/2025 Envia hacia la impresión

/*
     cSerie :=SQLGET("DPTIPDOCCLI"  ,"TDC_SERIEF,TDC_AUTIMP","TDC_TIPO"+GetWhere("=",oPosDocCli:DOC_TIPDOC))
     lAutImp:=IF(Empty(oDp:aRow),.T.,oDp:aRow[2])
*/
// ? "solo debe llamarlo una vez",oPosDocCli:cSerie,oPosDocCli:cLetra,oPosDocCli:lPar_AutoImp

   
/*
7/2/2025, reemplazado por DPDOCCLI_PRINT, evita ejecuta este formulario dos veces

     // 10-10-2008 Marlon Ramos (Agregar la Samsung) IF !(ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie))
     // 27-01-2009 Marlon Ramos (Agregar la Aclas y Okidata)   IF !(ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie) .OR. "SAMSUNG"$UPPER(cSerie))
     IF !(ALLTRIM(cSerie)="BMC" .OR. "EPSON"=LEFT(cSerie,5) .OR. "BEMATECH"=ALLTRIM(cSerie) .OR. "SAMSUNG"$UPPER(cSerie) .OR. "ACLAS"$UPPER(cSerie) .OR. "OKIDATA"$UPPER(cSerie) .OR. "STAR"$UPPER(cSerie))

        IF lAutImp //
.AND. !oPosDocCli:lRunPrint

? oPosDocCli:lRunPrint,"oPosDocCli:lRunPrint",oPosDocCli:nOption,"oPosDocCli:"


           oPosDocCli:PRINTER()
    
           // Se AutoEjecuta si es Salida por Impresora

           IF (oDp:oGenRep:oRun:nOut=2 .OR. oDp:oGenRep:oRun:nOut=9)

              oDp:oGenRep:Run()
              oFrmRun:Close()
              oDp:oGenRep:End()

            ENDIF

         ENDIF

      ENDIF
*/

   ENDIF

   // Cliente Activo
   IF oPosDocCli:nPar_CXC<>0
      SQLUPDATE("DPCLIENTES","CLI_SITUAC","A","CLI_CODIGO"+GetWhere("=",oPosDocCli:DOC_CODIGO))
   ENDIF

   // Aqui le Indicamos que inicie un Nuevo Documento
   // 14-11-2008 Marlon Ramos (Evitar error en consecutivos de la serie seleccionada) oPosDocCli:nOption:=nOption
   oPosDocCli:nOption:=0
   // Fin 14-11-2008 

   IF oPosDocCli:nOption=1
      Eval(oPosDocCli:aBtn[1,1]:bAction)
   ENDIF

RETURN .T.
// EOF
