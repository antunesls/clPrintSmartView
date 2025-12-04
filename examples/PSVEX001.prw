#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PSVEX001
Exemplo básico de uso da classe clPrintSmartView
Gera um relatório PDF usando token JWT pré-configurado
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
/*/
//-------------------------------------------------------------------
User Function PSVEX001()
	Local oReport As Object
	Local cResult As Character
	Local aParams As Array
	
	ConOut("[PSVEX001] Exemplo básico com configurações automáticas")
	
	// Cria instância - carrega automaticamente dos parâmetros ou usa padrões
	// URL: MV_PSVURL (padrão: http://localhost:7017)
	// Credenciais: MV_PSVUSER/MV_PSVPASS (padrão: admin/admin)
	// Cache de token habilitado automaticamente
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetReportId("dae9a9a2-a6d8-43ef-ba95-3af02b7623e9")
	
	// Define parâmetros do relatório conforme API SmartView
	aParams := {}
	aAdd(aParams, {"SV_MULTBRANCH", "[]"})
	aAdd(aParams, {"MV_PAR01", "   "})
	aAdd(aParams, {"MV_PAR02", "ZZZ"})
	aAdd(aParams, {"MV_PAR03", 1})
	aAdd(aParams, {"MV_PAR04", 1})
	
	// Gera relatório - autentica automaticamente e aguarda processamento
	ConOut("[PSVEX001] Gerando relatório (aguarda até 50s se necessário)...")
	cResult := oReport:GenerateReport(aParams, {"pdf"}, .T., "relatorio_exemplo.pdf")
	
	If !Empty(cResult)
		ConOut("[PSVEX001] Sucesso! Arquivo: " + cResult)
		MsgInfo("Relatório gerado com sucesso!" + CRLF + cResult, "Exemplo 001")
	Else
		ConOut("[PSVEX001] Erro: " + oReport:GetLastError())
		MsgStop("Erro ao gerar relatório: " + CRLF + oReport:GetLastError(), "Exemplo 001")
	EndIf
	
Return
