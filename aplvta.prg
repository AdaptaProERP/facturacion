// Programa   : APLVTA
// Fecha/Hora : 30/06/2003 13:43:04
// PropÑsito  : Iniciar AplicaciÑn de Ventas y Cuentas por Pagar
// Creado Por : Juan Navas
// Llamado por: Men+ Principal
// AplicaciÑn : Todas
// Tabla      : DPMENU

#INCLUDE "DPXBASE.CH"
PROCE MAIN()

   CursorWait()

   oDp:cModulo:="03"                     // Aplicación 03 
   oDp:cAplica:="Facturación y Clientes" // Nombre de la AplicaciÑn
  // oDp:cAplica:="Ventas y Cuentas Por Cobrar" // Nombre de la AplicaciÑn


   BuildMenu()                                // Presenta las Opciones del Men+
   EJECUTAR("BOTBARCHANGE")                   // Cambia los Botones


   // Este programa se ejecuta luego de DPLOADCNF 
   IF COUNT("DPTIPDOCCLI")=0
     // Importar Tipo de documento del Cliente
     EJECUTAR("DPTIPDOCCLIADD")
     EJECUTAR("DPUPDATECATALOG",.F.,"DPTIPDOCCLI")
   ENDIF

   IF COUNT("DPDOCCLI")>0 .AND. COUNT("DPCLISLD")=0
      EJECUTAR("DPCLISLDCREAR")
   ENDIF

   // Crear la Serie Fiscal
   IF COUNT("DPSERIEFISCAL")=0
      EJECUTAR("DPSERIEFISCALCREA")
   ENDIF

   oDp:nInvLotes:=COUNT("DPINV","INV_METCOS"+GetWhere("=","L")+" OR INV_METCOS"+GetWhere("=","C"))

   EJECUTAR("DPCLIENTECEROCREAR")
   EJECUTAR("DPCREATERCEROS")

   EJECUTAR("DPVENDEDOR_INDEF")  // Vendedor Indefinido
   EJECUTAR("DPTIPDOCCLIVALMNU") // Indefinidos
   EJECUTAR("DPTIPDOCCLILOAD")                // Documentos de Clientes
   EJECUTAR("DPINVTRANCREAFAVCOM")

   IF COUNT("DPCLISLD")=0 .AND. COUNT("DPDOCCLI")>0
     EJECUTAR("DPCLISLDCREAR")
   ENDIF

/*
   EJECUTAR("DPPRIVVTALEE","FAV",.F.,.F.) 

   COMPILA("VTACLINOMBRE")
   COMPILA("DPFACTURAV,DPPRIVVTALEE,DPDOCCLIPAR,DPDOCCLIVALCLI,DOCTOTAL,DPDOCCLIEDO")
   COMPILA("VTAGRIDCODINV,VTAGRIDEXISTE,VTAGRIDPRECIO,VTAGRIDCOSTO,INVGETCXUND,VTAGRIDLOAD,VTAGRIDPOSSAV")
   COMPILA("VTAGRIDVALALM,VTAGRIDVALCOD,VTAGRIDVALTEX,VTAGRIDVALUND,VTAGRIDVALDES,VTAGRIDVALPRE,VTAGRIDVALTOT")
// COMPILA("DPRECIBOSCLI")
*/

   // Activacion del Modo Fiscal
   ISRUNDOCFISCAL()

   CursorWait()

RETURN .T.
// EOF
