#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PSVEX004
Exemplo de geração e envio por email em base64
Gera relatório e envia anexado em email
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
/*/
//-------------------------------------------------------------------
User Function PSVEX004()
	Local oReport As Object
	Local cBase64 As Character
	Local aParams As Array
	Local lSent As Logical
	
	ConOut("[PSVEX004] Iniciando exemplo email")
	
	// Cria e autentica
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetUrl(SuperGetMV("MV_PSVURL", .F., "http://localhost:7017"))
	oReport:SetCredentials("admin", "admin")
	
	If !oReport:Authenticate(.F.)
		MsgStop("Falha na autenticação", "Exemplo 004")
		Return
	EndIf
	
	// Configura relatório
	oReport:SetEndpoint("/api/reports/v2/generate")
	oReport:SetReportId("8505ddf2-dcea-4e25-83c7-7c9d8304b37d")
	oReport:AddHeader("Content-Type", "application/json")
	
	// Parâmetros
	aParams := {}
	aAdd(aParams, {"destinatario", "cliente@email.com"})
	aAdd(aParams, {"periodo", "Mensal"})
	
	// Gera relatório em base64 (não salva arquivo)
	ConOut("[PSVEX004] Gerando relatório em base64...")
	cBase64 := oReport:GenerateReport(aParams, {"pdf"}, .F.)
	
	If !Empty(cBase64)
		ConOut("[PSVEX004] Relatório gerado, tamanho: " + cValToChar(Len(cBase64)))
		
		// Envia por email
		lSent := SendEmailWithAttachment(cBase64, "relatorio.pdf")
		
		If lSent
			MsgInfo("Relatório enviado por email com sucesso!", "Exemplo 004")
		Else
			MsgStop("Erro ao enviar email", "Exemplo 004")
		EndIf
	Else
		MsgStop("Erro ao gerar: " + CRLF + oReport:GetLastError(), "Exemplo 004")
	EndIf
	
Return

//-------------------------------------------------------------------
Static Function SendEmailWithAttachment(cBase64 As Character, cFileName As Character)
	Local lSuccess As Logical
	Local cServer As Character
	Local cFrom As Character
	Local cTo As Character
	Local cSubject As Character
	Local cBody As Character
	
	lSuccess := .F.
	
	// Configurações de email
	cServer := SuperGetMV("MV_RELSERV", .F., "smtp.servidor.com")
	cFrom := SuperGetMV("MV_RELFROM", .F., "sistema@empresa.com")
	cTo := "destinatario@empresa.com"
	cSubject := "Relatório SmartView - " + DtoC(Date())
	cBody := "Segue relatório em anexo."
	
	ConOut("[PSVEX004] Enviando email...")
	
	// Aqui você implementaria o envio usando sua função de email
	// Exemplo com TMailMessage (adapte conforme sua implementação)
	/*
	oEmail := TMailMessage():New()
	oEmail:Clear()
	oEmail:cFrom := cFrom
	oEmail:cTo := cTo
	oEmail:cSubject := cSubject
	oEmail:cBody := cBody
	oEmail:AttachFileBase64(cBase64, cFileName)
	lSuccess := oEmail:Send()
	*/
	
	// Simulação para exemplo
	ConOut("[PSVEX004] Email enviado para: " + cTo)
	ConOut("[PSVEX004] Anexo: " + cFileName)
	lSuccess := .T.
	
Return lSuccess
