#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_TESTPSV
Wrapper para chamar a função de teste U_PSVTEST
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
@obs Este fonte .prw chama a função U_PSVTEST do arquivo .tlpp
/*/
//-------------------------------------------------------------------
User Function TESTPSV()
	Local lResult As Logical

    RpcSetEnv( "99","01", "Administrador", "admin", "CTB", "CTBA102", , , , ,  )
	
	ConOut("[TESTPSV] Iniciando wrapper de teste")
	
	// Chama a função de teste da classe
	lResult := PrintSmartView.U_PSVTEST()
	
	If lResult
		ConOut("[TESTPSV] Teste concluído com sucesso")
	Else
		ConOut("[TESTPSV] Teste concluído com falhas")
	EndIf
	
Return lResult
