#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_PRODPSV
Wrapper para chamar a função de produção U_PSVPROD
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
@obs Este fonte .prw chama a função U_PSVPROD do arquivo .tlpp
/*/
//-------------------------------------------------------------------
User Function PRODPSV()
	Local lResult As Logical
	
	ConOut("[PRODPSV] Iniciando wrapper de produção")
	
	// Chama a função de produção da classe
	lResult := U_PSVPROD()
	
	If lResult
		ConOut("[PRODPSV] Execução concluída com sucesso")
	Else
		ConOut("[PRODPSV] Execução concluída com falhas")
	EndIf
	
Return lResult
