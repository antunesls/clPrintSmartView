#Include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PSVEX003
Exemplo de uso em JOB agendado
Gera relatórios periodicamente sem interface gráfica
@type function
@author Lucas Souza - Insider Consulting
@since 28/11/2025
/*/
//-------------------------------------------------------------------
User Function PSVEX003()
	Local cEmpAnt As Character
	Local cFilAnt As Character
	
	// Parâmetros passados pelo schedule
	cEmpAnt := GetPvProfString("PSVJOB", "Empresa", "99", GetAdv97())
	cFilAnt := GetPvProfString("PSVJOB", "Filial", "01", GetAdv97())
	
	ConOut("[PSVEX003] Job iniciado - Empresa: " + cEmpAnt + " Filial: " + cFilAnt)
	
	// Prepara ambiente
	RpcSetType(3)
	RpcSetEnv(cEmpAnt, cFilAnt)
	
	// Executa processamento
	ProcessReport()
	
	// Finaliza ambiente
	RpcClearEnv()
	
	ConOut("[PSVEX003] Job finalizado")
	
Return

//-------------------------------------------------------------------
Static Function ProcessReport()
	Local oReport As Object
	Local cResult As Character
	Local aParams As Array
	Local cDataRef As Character
	Local lSuccess As Logical
	
	ConOut("[PSVEX003] Processando relatório...")
	
	lSuccess := .F.
	
	// Cria instância com cache em parâmetro (ideal para JOBs)
	oReport := PrintSmartView.clPrintSmartView():New()
	oReport:SetUrl(SuperGetMV("MV_PSVURL", .F., "http://localhost:7017"))
	oReport:SetCredentials(;
		SuperGetMV("MV_PSVUSER", .F., "admin"),;
		SuperGetMV("MV_PSVPASS", .F., "admin");
	)
	oReport:EnableTokenCache(.T.) // Cache em MV_PSVTOKN para reutilizar
	
	ConOut("[PSVEX003] Token será reutilizado do parâmetro MV_PSVTOKN")
	
	// Configura relatório
	oReport:SetEndpoint("/api/reports/v2/generate")
	oReport:SetReportId("dae9a9a2-a6d8-43ef-ba95-3af02b7623e9")
	oReport:AddHeader("Content-Type", "application/json")
	
	// Parâmetros do relatório conforme API SmartView
	aParams := {}
	aAdd(aParams, {"SV_MULTBRANCH", "[]"})
	aAdd(aParams, {"MV_PAR01", "   "})
	aAdd(aParams, {"MV_PAR02", "ZZZ"})
	aAdd(aParams, {"MV_PAR03", 1})
	aAdd(aParams, {"MV_PAR04", 1})
	
	// Gera relatório
	cResult := oReport:GenerateReport(aParams, {"pdf"}, .T., "relatorio_job_" + DtoS(Date()) + ".pdf")
	
	If !Empty(cResult)
		ConOut("[PSVEX003] Relatório gerado: " + cResult)
		
		// Envia por email (exemplo)
		SendReportByEmail(cResult)
		
		lSuccess := .T.
	Else
		ConOut("[PSVEX003] Erro ao gerar: " + oReport:GetLastError())
		
		// Log de erro
		LogError(oReport:GetLastError())
	EndIf
	
Return lSuccess

//-------------------------------------------------------------------
Static Function SendReportByEmail(cFilePath As Character)
	// Implemente envio de email aqui
	ConOut("[PSVEX003] Enviando relatório por email: " + cFilePath)
	// U_SendMail(cFilePath)
Return

//-------------------------------------------------------------------
Static Function LogError(cError As Character)
	Local nHandle As Numeric
	Local cLogFile As Character
	
	cLogFile := "\logs\psvjob_" + DtoS(Date()) + ".log"
	
	nHandle := FCreate(cLogFile, 0)
	If nHandle >= 0
		FWrite(nHandle, Time() + " - " + cError + CRLF)
		FClose(nHandle)
	EndIf
	
Return
