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
	Local cToken As Character
	
	ConOut("[PSVEX001] Iniciando exemplo básico")
	
	// Token JWT (em produção, busque de forma segura)
	cToken := GetTokenFromConfig()
	
	// Cria instância da classe
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetUrl("http://localhost:7017")
	oReport:SetToken(cToken)
	oReport:SetEndpoint("/api/reports/v2/generate")
	oReport:SetReportId("dae9a9a2-a6d8-43ef-ba95-3af02b7623e9")
	oReport:AddHeader("Content-Type", "application/json")
	
	// Define parâmetros do relatório conforme API SmartView
	aParams := {}
	aAdd(aParams, {"SV_MULTBRANCH", "[]"})
	aAdd(aParams, {"MV_PAR01", "   "})
	aAdd(aParams, {"MV_PAR02", "ZZZ"})
	aAdd(aParams, {"MV_PAR03", 1})
	aAdd(aParams, {"MV_PAR04", 1})
	
	// Gera relatório e salva em arquivo
	ConOut("[PSVEX001] Gerando relatório...")
	cResult := oReport:GenerateReport(aParams, {"pdf"}, .T., "relatorio_exemplo.pdf")
	
	If !Empty(cResult)
		ConOut("[PSVEX001] Sucesso! Arquivo: " + cResult)
		MsgInfo("Relatório gerado com sucesso!" + CRLF + cResult, "Exemplo 001")
	Else
		ConOut("[PSVEX001] Erro: " + oReport:GetLastError())
		MsgStop("Erro ao gerar relatório: " + CRLF + oReport:GetLastError(), "Exemplo 001")
	EndIf
	
Return

//-------------------------------------------------------------------
Static Function GetTokenFromConfig()
	Local cToken As Character
	
	// Em produção, busque de configuração segura
	// Exemplo: arquivo .ini, banco de dados criptografado, etc
	cToken := SuperGetMV("MV_PSVTOKN", .F., "")
	
	If Empty(cToken)
		// Token de exemplo (use apenas em desenvolvimento)
		cToken := "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
	EndIf
	
Return cToken
