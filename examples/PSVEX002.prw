#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PSVEX002
Exemplo com autenticação automática
Autentica no SmartView e gera relatório
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
/*/
//-------------------------------------------------------------------
User Function PSVEX002()
	Local oReport As Object
	Local cResult As Character
	Local aParams As Array
	Local cUrl As Character
	Local cUser As Character
	Local cPass As Character
	
	ConOut("[PSVEX002] Exemplo com múltiplos formatos")
	
	// Cria instância - carrega configurações automaticamente
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetTimeout(180) // 3 minutos (opcional)
	
	ConOut("[PSVEX002] Configurações carregadas dos parâmetros ou padrões")
	
	// Configura relatório
	oReport:SetReportId("dae9a9a2-a6d8-43ef-ba95-3af02b7623e9")
	
	// Parâmetros do relatório conforme API SmartView
	aParams := {}
	aAdd(aParams, {"SV_MULTBRANCH", "[]"})
	aAdd(aParams, {"MV_PAR01", "   "})
	aAdd(aParams, {"MV_PAR02", "ZZZ"})
	aAdd(aParams, {"MV_PAR03", 1})
	aAdd(aParams, {"MV_PAR04", 1})
	
	// Gera em múltiplos formatos (autenticação e aguardo automáticos)
	ConOut("[PSVEX002] Gerando relatório em PDF e XLSX...")
	cResult := oReport:GenerateReport(aParams, {"pdf", "xlsx"}, .T., "relatorio_multiformat.pdf")
	
	If !Empty(cResult)
		ConOut("[PSVEX002] Sucesso! Arquivo: " + cResult)
		MsgInfo("Relatório gerado!" + CRLF + cResult, "Exemplo 002")
	Else
		ConOut("[PSVEX002] Erro: " + oReport:GetLastError())
		MsgStop("Erro: " + CRLF + oReport:GetLastError(), "Exemplo 002")
	EndIf
	
Return
