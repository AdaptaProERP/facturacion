// Programa   : DPRECIBODIV_CAJBCO
// Fecha/Hora : 01/03/2023 06:10:40
// Propósito  : Lectura de Instrumentos de Caja/Bancos
//              Lectura del Estado de Cuenta Bancario
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(oRecDiv,cRif,nValCam,oBrw,nColIsMon,lCliente,cNumRec,cCodSuc,cTipDoc,nOption)
  LOCAL aData,cSql,aData1,nAt,nAt1
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL dFecha:=oDp:dFecha
  LOCAL cInner:="",cCuatro:=" 0 AS CUATRO ",cCinco:=" 0 AS CINCO "
  LOCAL cOnce :="0 ",cDoce:="0 ",cTrece:="0 ",cMarcaF,cRefere,cCtaBco,cJoinBco


  IF ValType(oBrw)="O"
     dFecha:=oRecDiv:dFecha
  ENDIF

  DEFAULT cCodSuc :=oDp:cSucursal,;
          lCliente:=.T.

  nColIsMon:=13

  EJECUTAR("DPRECIBOSDIVINST",lCliente)

  SQLUPDATE("DPTABMON",{"MON_RECING","MON_ACTIVO"},{.T.,.T.},GetWhereOr("MON_CODIGO",{"BSD"}))

  DEFAULT cTipDoc:=IF(lCliente,"REC","PAG"),;
          nOption:=1

  IF !Empty(cNumRec)

     cInner:=" LEFT JOIN DPCAJAMOV ON CAJ_CODSUC"+GetWhere("=",cCodSuc)+;
             " AND CAJ_ORIGEN"+GetWhere("=",cTipDoc)+;
             " AND CAJ_DOCASO"+GetWhere("=",cNumRec)+;
             " AND CAJ_ACT=1 "+;
             " AND ICJ_CODIGO=CAJ_TIPO "



    IF cTipDoc="TIK" .AND. (nOption=2 .OR. nOption=0)
       cInner:=STRTRAN(cInner," LEFT JOIN"," INNER JOIN")
    ENDIF

    cCuatro:=" CAJ_MTODIV AS CUATRO "
    cCinco :=" CAJ_MONTO  AS CINCO "

  ENDIF

  oDp:cMonedaNombre:=SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oDp:cMoneda))

  cSql:=[ SELECT MON_DESCRI,HMN_VALOR,0 AS TRES,]+cCuatro+[,]+cCinco+[,0 AS LOGICO,MON_CODIGO,"CAJ" AS TIPDOC,ICJ_CODIGO,ICJ_NOMBRE,ICJ_PORITF,0 AS MTOIGTF,ICJ_MONEDA,]+;
        [ SPACE(10) AS MARCAFIN,]+CRLF+;
        [ SPACE(10) AS BANCO ,]+CRLF+;
        [ SPACE(20) AS CUENTA,]+CRLF+;
        [ SPACE(10) AS REFER,0 AS LOGICO  ]+CRLF+;
        [ FROM DPTABMON ]+;
        [ INNER JOIN DPCAJAINST          ON MON_CODIGO=ICJ_CODMON AND ICJ_ACTIVO=1 AND ]+IF(lCliente,[ICJ_INGRES=1 ],[ICJ_EGRESO=1 ])+;
        +cInner+;
        [ LEFT  JOIN VIEW_NMHISMONMAXFCH ON MON_CODIGO=MAX_CODIGO ]+;
        [ LEFT  JOIN DPHISMON            ON MON_CODIGO=HMN_CODIGO AND HMN_FECHA]+GetWhere("=",dFecha)+;
        [ LEFT  JOIN VIEW_TABMONXCLI     ON MON_CODIGO=CLI_CODMON ]+;
        [ WHERE MON_ACTIVO=1 AND ]+IF(lCliente,[MON_RECING=1 ],[MON_CBTPAG=1 ])+;
        [ GROUP BY ICJ_CODIGO ]+;
        [ ORDER BY HMN_VALOR DESC ]

  aData:=ASQL(cSql)

  AEVAL(aData,{|a,n| aData[n,2]:=IF(a[2]=0 .OR. a[2]=1,EJECUTAR("DPGETVALCAM",a[7],dFecha),a[2])})

  cInner :=[]
  cCuatro:=" 0 AS CUATRO "
  cCinco :=" 0 AS CINCO "

  cMarcaF :=[ SPACE(25)  AS MARCAFIN,]
  cRefere :=[ SPACE(10)  AS REFER   ,]
  cCtaBco :=[ TDB_CTABCO AS CUENTA  ,]
  cJoinBco:=[ LEFT JOIN DPBANCOS    ON DPBANCOS.BAN_CODIGO=BCO_CODIGO ]

  IF !Empty(cNumRec) .AND. cTipDoc="TIK"

     cInner:=" INNER JOIN DPCTABANCOMOV ON MOB_CODSUC"+GetWhere("=",cCodSuc)+;
             " AND MOB_ORIGEN"+GetWhere("=",cTipDoc)+;
             " AND MOB_DOCASO"+GetWhere("=",cNumRec)+;
             " AND MOB_ACT=1 "+;
             " AND TDB_CODIGO=MOB_TIPO "

    cCuatro :=" MOB_MTODIV AS CUATRO "
    cCinco  :=" MOB_MONTO  AS CINCO "

    cMarcaF :=[ MOB_MARFIN AS MARCAFIN,]
    cCtaBco :=[ MOB_CUENTA AS CUENTA  ,]
    cRefere :=[ MOB_DOCUME AS REFER   ,]
    cJoinBco:=[ LEFT JOIN DPBANCOS    ON DPBANCOS.BAN_CODIGO=MOB_CODBCO ]


  ENDIF

  cSql  :=[ SELECT           ]+;
          [ MON_DESCRI     , ]+CRLF+;
          [ 1 AS DOS       , ]+CRLF+;
          [ 0 AS TRES      , ]+CRLF+;
          cCuatro       +[ , ]+CRLF+;
          cCinco        +[ , ]+CRLF+;
          [ 0 AS LOGICO    , ]+CRLF+;
          [ TDB_CODMON AS MONEDA, ]+CRLF+;
          [ "BCO" AS NUEVE  , ]+CRLF+;
          [ TDB_CODIGO      , ]+CRLF+;
          [ TDB_NOMBRE      , ]+CRLF+;
          cOnce +[ AS IGTF  , ]+CRLF+;
          cDoce +[ AS TIGTF , ]+CRLF+;
          cTrece+[ AS MONEDA, ]+CRLF+;
          [ SPACE(25)  AS MARCAFIN,]+CRLF+;
          [ BAN_NOMBRE AS BANCO ,]+CRLF+;
          cCtaBco+CRLF+;
          [ SPACE(10)  AS REFER ,0 AS LOGICO ]+CRLF+;
          [ FROM DPBANCOTIP  ]+CRLF+;
          [ LEFT JOIN DPTABMON    ON MON_CODIGO=TDB_CODMON ]+CRLF+;
          cInner+;
          [ LEFT JOIN DPCTABANCO  ON TDB_CTABCO=BCO_CTABAN ]+CRLF+;
          [ ]+cJoinBco+CRLF+;
          [ WHERE TDB_ACTIVO=1 AND ]+IF(lCliente,[TDB_INGRES=1 ],[TDB_PAGOS=1 ])+CRLF+;
          [ ORDER BY TDB_NOMBRE ]

// ? CLPCOPY(cSql)
 
  aData1:=ASQL(cSql)

  IF Empty(aData1) .AND. Empty(aData) .AND. (cTipDoc="TIK" .OR. cTipDoc="DEV")
     aData1:=EJECUTAR("SQLARRAYEMPTY",cSql)
  ENDIF

// ViewArray(aData1)

  AEVAL(aData1,{|a,n| aData1[n,02       ]:=IF(a[2]=0 .OR. a[2]=1,EJECUTAR("DPGETVALCAM",a[7],dFecha),a[2]),;
                      aData1[n,06       ]:=.F.,;
                      aData1[n,nColIsMon]:=.F.})

  AEVAL(aData1,{|a,n| AADD(aData,a)})

  AEVAL(aData,{|a,n| aData[n,6]:=(a[5]>0)})

  WHILE .T.

    nAt:=ASCAN(aData,{|a,n| "HTTP"$UPPER(a[1])})
    IF nAt=0
       EXIT
    ENDIF
    
    nAt1:=AT("HTTP",UPPER(aData[nAt,1]))
    aData[nAt,1]:=LEFT(aData[nAt,1],nAt1-1)

  ENDDO

  IF !Empty(cNumRec)
     // Posiciona primero los que tienen pago
     aData:=ASORT(aData,,, { |x, y| x[5] > y[5] })
  ENDIF

IF lCliente

  IF !oDp:lConEsp
    AEVAL(aData,{|a,n| aData[n,11]:=0  })
  ELSE
    AEVAL(aData,{|a,n| aData[n,11]:=IF(a[11]>0 .AND. a[7]<>oDp:cMoneda,3,0)})
  ENDIF

ENDIF

  nAt:=ASCAN(aData,{|a,n| a[7]="COP"})

  IF nAt>0
     // EJECUTAR("CALCOP")
     SET DECI TO 6
     aData[nAt,2]:=ROUND(oDp:nDivisa/oDp:nValCop,8)
     aData[nAt,1]:="COP "+LSTR(ROUND(oDp:nDivisa/oDp:nValCop,8),19,8)
     SET DECI TO 2
  ENDIF

  // AEVAL(aData,{|a,n| aData[n,2]:=ROUND(aData[n,2],2) }) // Redondeo de 2

//  ViewArray(aData)

  IF ValType(oBrw)="O"
     oBrw:aArrayData:=ACLONE(aData)
     oBrw:Refresh(.T.)
  ENDIF

RETURN aData
// EOF

