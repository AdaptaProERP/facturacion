// Programa   : DPFACTURAV_SETBANCOS 
// Fecha/Hora : 18/03/2025 05:23:23
// Propósito  : Asignar Bancos en Pagos
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oBrw)
   LOCAL aLine:=oBrw:aArrayData[oBrw:nArrayAt]
   LOCAL oCol :=oBrw:aCols[15]
   LOCAL oDoc :=oBrw:oLbx

//  oDp:oFrameDp:SetText(oBrw:Classname()+lstr(seconds())+" "+lstr(len(oDp:aCuentaBco)))
//   oDp:oFrameDp:SetText(LSTR(LEN(aLine))+" VALTYPE ALINE[8]"+ValType(aLine[8]))
//   IF aLine[08]="BCO" .AND. oDoc:nMtoDoc>0 .AND. aLine[oDoc:nColSelP] .AND. LEN(oDp:aCuentaBco)>0

   IF aLine[08]="BCO" 
//.AND. oDoc:nMtoDoc>0 .AND. aLine[oDoc:nColSelP] .AND. LEN(oDp:aCuentaBco)>0

      oCol:nEditType     :=EDIT_LISTBOX
      oCol:aEditListTxt  :=ACLONE(oDp:aNombreBco)
      oCol:aEditListBound:=ACLONE(oDp:aNombreBco)
      oCol:bOnPostEdit   :={|oCol,uValue|oBrw:PUTBANCO(oCol,uValue,15)} // Debe seleccionar las cuentas bancarias
      oBrw:DrawLine(.T.)
      
   ELSE

      oCol:nEditType    :=0
      oCol:bOnPostEdit  :=NIL

   ENDIF

RETURN .T.



RETURN .T.
// EOF
