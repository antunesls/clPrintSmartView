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
	
	ConOut("[PSVEX002] Iniciando exemplo com autenticação")
	
	// Busca configurações (em produção, use forma segura)
	cUrl := SuperGetMV("MV_PSVURL", .F., "http://localhost:7017")
	cUser := SuperGetMV("MV_PSVUSER", .F., "admin")
	cPass := SuperGetMV("MV_PSVPASS", .F., "admin")
	
	// Cria instância e configura
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetUrl(cUrl)
	oReport:SetCredentials(cUser, cPass)
	oReport:SetTimeout(180) // 3 minutos
	
	// Autentica
	ConOut("[PSVEX002] Autenticando...")
	If !oReport:Authenticate(.F.)
		ConOut("[PSVEX002] Falha na autenticação: " + oReport:GetLastError())
		MsgStop("Falha na autenticação: " + CRLF + oReport:GetLastError(), "Exemplo 002")
		Return
	EndIf
	
	ConOut("[PSVEX002] Autenticado com sucesso!")
	
	// Configura relatório
	oReport:SetEndpoint("/api/reports/v2/generate")
	oReport:SetReportId("8505ddf2-dcea-4e25-83c7-7c9d8304b37d")
	oReport:AddHeader("Content-Type", "application/json")
	
	// Parâmetros do relatório
	aParams := {}
	aAdd(aParams, {"filial", xFilial("SA1")})
	aAdd(aParams, {"cliente", "000001"})
	
	// Gera em múltiplos formatos
	ConOut("[PSVEX002] Gerando relatório...")
	cResult := oReport:GenerateReport(aParams, {"pdf", "xlsx"}, .T., "relatorio_auth.pdf")
	
	If !Empty(cResult)
		ConOut("[PSVEX002] Sucesso! Arquivo: " + cResult)
		MsgInfo("Relatório gerado!" + CRLF + cResult, "Exemplo 002")
	Else
		ConOut("[PSVEX002] Erro: " + oReport:GetLastError())
		MsgStop("Erro: " + CRLF + oReport:GetLastError(), "Exemplo 002")
	EndIf
	
Return
