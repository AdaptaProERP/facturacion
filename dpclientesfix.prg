// Programa   : DPCLIENTESFIX
// Fecha/Hora : 15/12/2006 11:40:13
// Propósito  : Asociar Movimientos con Clientes
// Creado Por : Juan Navas
// Llamado por: 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc)

  LOCAL lEnd:=.T.

  MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
             DPCLIFIX(oDlg,oText,oMeter,@lEnd,"Asociando Transacciones","Movimiento de Productos","TEST")  },;
            "Procesando", "Asociando Transacciones" )

RETURN .T.

FUNCTION DPCLIFIX(oDlg,oText,oMeter,lEnd,cTitle,cSubTitle,cFileXls)
   LOCAL oDocCli,cSql,nIva:=0,nContar:=0

   oDocCli:=OpenTable("SELECT DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,DOC_DCTO,DOC_RECARG,DOC_OTROS FROM DPDOCCLI WHERE DOC_TIPTRA='D'"+;
            IIF(Empty(cTipDoc),""," AND DOC_TIPDOC"+GetWhere("=",cTipDoc)),.T.)

   oMeter:SetTotal(oDocCli:RecCount())

   WHILE !oDocCli:Eof()

      oText:SetText("Registro: "+LSTR(oDocCli:RecCount())+" / "+LSTR(oDocCli:RecNo())) 

      SQLUPDATE("DPMOVINV","MOV_CODCTA",oDocCli:DOC_CODIGO,;
                "MOV_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                "MOV_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                "MOV_DOCUME"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
                "MOV_APLORG='V'")

      // Se calcula, el Monto del IVA
      EJECUTAR("DPDOCCLIIMP",oDocCli:DOC_CODSUC,oDocCli:DOC_TIPDOC,oDocCli:DOC_CODIGO,oDocCli:DOC_NUMERO,.F.,oDocCli:DOC_DCTO,oDocCli:DOC_RECARG,oDocCli:DOC_OTROS,"V")

     IF oDp:nBruto>0

          SQLUPDATE("DPDOCCLI",{"DOC_MTOIVA","DOC_BASNET" ,"DOC_NETO" },;
                               { oDp:nIva   , oDp:nBaseNet,oDp:nNeto  },;
                    "DOC_CODSUC"+GetWhere("=",oDocCli:DOC_CODSUC)+" AND "+;
                    "DOC_TIPDOC"+GetWhere("=",oDocCli:DOC_TIPDOC)+" AND "+;
                    "DOC_NUMERO"+GetWhere("=",oDocCli:DOC_NUMERO)+" AND "+;
                    "DOC_TIPTRA='D'")

      ENDIF
   
      oMeter:Set(oDocCli:RecNo())

      IF ++nContar>100
        SysRefresh(.T.)
        nContar:=0
      ENDIF

      oDocCli:DbSkip()

   ENDDO

   oDocCli:End()

RETURN .T.
// EOF

