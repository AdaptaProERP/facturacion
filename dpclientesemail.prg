// Programa   : DPCLIENTESEMAIL
// Fecha/Hora : 06/01/2008 22:01:53
// Propósito  : Solicitar eMail del Cliente
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli)
  LOCAL cEmail,oDlg,oGet,oFontG,oFontB,lOk:=.F.,cMail

  DEFAULT cCodCli:=STRZERO(1,10)

  DEFINE FONT oFontG  NAME "MS Sans Serif" SIZE 0, -14 BOLD
  DEFINE FONT oFontB  NAME "MS Sans Serif" SIZE 0, -12 BOLD

  cEmail:=MYSQLGET("DPCLIENTES","CLI_EMAIL,CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
  cMail :=ALLTRIM(cEmail)

  DEFINE DIALOG oDlg TITLE "Email del "+oDp:xDPCLIENTES+" "+cCodCli

  oDlg:lHelpIcon:=.F.

  @ 0,.2 SAY " "+oDp:aRow[2]+" " SIZE 157,10;
         COLOR CLR_WHITE,CLR_HBLUE FONT oFontB

  @ 0.8,.5 SAY "Cuenta de Correo:" FONT oFontB
  @ 1.8,.5 GET cEmail SIZE 150,12;
           FONT oFontG

  @ 3,14 BUTTON " Aceptar " ACTION (lOk:=.T.,oDlg:End());
         FONT oFontB;
         SIZE 32,13


  @ 3,20 BUTTON " Cerrar  " ACTION (lOk:=.F.,oDlg:End());
         FONT oFontB;
         SIZE 32,13

  ACTIVATE DIALOG oDlg CENTERED

  IF lOk
    cMail :=ALLTRIM(cEmail)
    SQLUPDATE("DPCLIENTES","CLI_EMAIL",cMail,"CLI_CODIGO"+GetWhere("=",cCodCli))
  ENDIF
  
RETURN cMail
// EOF
