// Programa   : DPDOCCLIIMP
// Fecha/Hora : 12/08/2005 15:29:42
// Prop�sito  : Determinar el IVA por cada Documento
// Creado Por : Juan Navas
// Llamado por: DOCTOTAL
// Aplicaci�n : Ventas
// Tabla      : DPDOCCLIIVA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodCli,cNumero,lSave,nDesc,nRecarg,nDocOtros,cAplOrg,nIvaReb,cDocOrg,nAct)

? "AQUI ES DPDOCCLIIMP, CALCULA IMPUESTOS"
RETURN DPDOCCLIIMP(cCodSuc,cTipDoc,cCodCli,cNumero,lSave,nDesc,nRecarg,nDocOtros,cAplOrg,nIvaReb,cDocOrg,nAct)
// EOF
