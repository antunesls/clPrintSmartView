# Guia de Solução de Problemas

## Índice
- [Erros de Autenticação](#erros-de-autenticação)
- [Erros de Geração](#erros-de-geração)
- [Erros de Download](#erros-de-download)
- [Erros de Arquivo](#erros-de-arquivo)
- [Erros de Rede](#erros-de-rede)
- [Erros de Performance](#erros-de-performance)
- [Diagnóstico](#diagnóstico)

---

## Erros de Autenticação

### Erro: "URL não configurada"

**Causa:** O método `SetUrl()` não foi chamado antes de fazer requisições.

**Solução:**
```advpl
oReport:SetUrl("http://servidor:7017")
```

---

### Erro: "Credenciais não configuradas"

**Causa:** O método `SetCredentials()` não foi chamado antes de `Authenticate()`.

**Solução:**
```advpl
oReport:SetCredentials("usuario", "senha")
oReport:Authenticate(.T.)
```

---

### Erro: "401 Unauthorized"

**Causas possíveis:**
1. Usuário ou senha incorretos
2. Usuário bloqueado no SmartView
3. Usuário sem permissão de API

**Soluções:**

**1. Verificar credenciais:**
```advpl
ConOut("Usuário: " + oReport:GetUsername())
ConOut("URL: " + oReport:GetUrl())
```

**2. Testar no navegador:**
- Acesse `http://servidor:7017` e faça login manualmente
- Se não conseguir, o problema é no SmartView

**3. Verificar permissões:**
- Acesse **Administração** > **Usuários** no SmartView
- Verifique se o usuário tem perfil com permissão "API"

**4. Resetar senha:**
```sql
-- No banco do SmartView
UPDATE users SET password_reset_required = 1 WHERE username = 'protheus_integration';
```

---

### Erro: "Token expirado"

**Causa:** O token JWT tem tempo de validade (geralmente 1 hora).

**Solução:**
```advpl
// Renovar token automaticamente
If !oReport:Authenticate(.F.)
    ConOut("Erro ao renovar token: " + oReport:GetLastError())
    Return
EndIf

// Ou guardar token com timestamp
Static Function GetValidToken(oReport)
    Static nLastAuth := 0
    Static cLastToken := ""
    
    // Renovar a cada 50 minutos
    If Seconds() - nLastAuth > 3000
        If oReport:Authenticate(.F.)
            nLastAuth := Seconds()
            cLastToken := oReport:cToken
        EndIf
    Else
        oReport:SetToken(cLastToken)
    EndIf
Return cLastToken
```

---

## Erros de Geração

### Erro: "Report ID não configurado"

**Causa:** `SetReportId()` não foi chamado.

**Solução:**
```advpl
oReport:SetReportId("8505ddf2-dcea-4e25-83c7-7c9d8304b37d")
```

**Como obter o Report ID:**
1. Acesse o SmartView via navegador
2. Vá em **Relatórios** > **Meus Relatórios**
3. Selecione o relatório
4. Clique em **Configurações** (⚙️) > **API**
5. Copie o UUID exibido

---

### Erro: "404 Not Found" ao gerar

**Causas possíveis:**
1. Report ID inválido
2. Relatório excluído
3. Endpoint incorreto

**Soluções:**

**1. Verificar Report ID:**
```advpl
ConOut("Report ID: " + oReport:cReportId)
```

**2. Testar via curl:**
```bash
curl -X POST http://servidor:7017/api/reports/v2/generate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"reportId":"<uuid>","parameters":{},"formats":["pdf"]}'
```

**3. Verificar endpoint:**
```advpl
// Correto
oReport:SetEndpoint("/api/reports/v2/generate")

// Errado
oReport:SetEndpoint("/generate") // Faltando /api/reports/v2
```

---

### Erro: "Parâmetro obrigatório não fornecido"

**Causa:** O relatório exige parâmetros que não foram enviados.

**Solução:**
```advpl
// Verificar quais parâmetros o relatório precisa no SmartView

Local aParams := {}
aAdd(aParams, {"dataInicio", "20240101"})
aAdd(aParams, {"dataFim", "20241231"})
aAdd(aParams, {"filial", "01"})

cFile := oReport:GenerateReport(aParams, {"pdf"}, .T.)
```

**Como descobrir os parâmetros:**
1. No SmartView, abra o relatório
2. Vá em **Configurações** > **Parâmetros**
3. Anote os nomes dos parâmetros obrigatórios

---

### Erro: "Timeout ao gerar relatório"

**Causa:** Relatório muito pesado ou servidor sobrecarregado.

**Soluções:**

**1. Aumentar timeout:**
```advpl
oReport:SetTimeout(300) // 5 minutos
```

**2. Otimizar relatório:**
- Reduza o período de dados
- Simplifique as consultas SQL
- Use índices no banco de dados

**3. Verificar recursos do servidor:**
```bash
# Windows - Verificar uso de CPU/Memória
taskmgr

# Linux
top
htop
```

**4. Processar em background:**
```advpl
// Gerar sem aguardar resposta imediata
StartJob("U_GeraRel", GetEnvServer(), .F., oReport:cReportId)
```

---

## Erros de Download

### Erro: "Generation ID não configurado"

**Causa:** `SetGenerationId()` não foi chamado antes de `DownloadReport()`.

**Solução:**
```advpl
// Obter Generation ID após gerar
cGenId := oReport:cGenerationId

// Usar em outra instância ou momento
oReport:SetGenerationId(cGenId)
cFile := oReport:DownloadReport("pdf", .T.)
```

---

### Erro: "Geração não encontrada"

**Causas possíveis:**
1. Generation ID inválido
2. Geração expirada (SmartView limpa após X dias)
3. Geração ainda processando

**Soluções:**

**1. Verificar se geração existe:**
```bash
curl -X GET http://servidor:7017/api/reports/v2/generate/<generation_id>/status \
  -H "Authorization: Bearer <token>"
```

**2. Aguardar processamento:**
```advpl
Static Function WaitForGeneration(oReport, cGenId, nMaxWait)
    Local nStart := Seconds()
    Local cStatus := ""
    
    While Seconds() - nStart < nMaxWait
        // Consultar status
        cStatus := oReport:GetRequest("/api/reports/v2/generate/" + cGenId + "/status")
        
        If "completed" $ Lower(cStatus)
            Return .T.
        ElseIf "failed" $ Lower(cStatus)
            Return .F.
        EndIf
        
        Sleep(5000) // Aguardar 5 segundos
    EndDo
    
Return .F. // Timeout
```

---

## Erros de Arquivo

### Erro: "Falha ao criar arquivo"

**Causas possíveis:**
1. Sem permissão de escrita na pasta
2. Disco cheio
3. Caminho inválido

**Soluções:**

**1. Verificar permissões:**
```powershell
# Windows
icacls C:\temp\reports
# Deve mostrar permissão de escrita para o usuário do AppServer
```

**2. Verificar espaço em disco:**
```powershell
# Windows
Get-PSDrive C | Select-Object Used,Free

# Linux
df -h /tmp
```

**3. Usar caminho válido:**
```advpl
// Usar sempre GetTempPath() ou pasta configurada
oReport:cTempPath := GetTempPath()

// Verificar se pasta existe
If !ExistDir(oReport:cTempPath)
    MakeDir(oReport:cTempPath)
EndIf
```

---

### Erro: "Arquivo vazio"

**Causas possíveis:**
1. Geração falhou no SmartView
2. Formato não suportado
3. Erro na conversão

**Soluções:**

**1. Verificar tamanho:**
```advpl
If File(cFile)
    Local nHandle := FOpen(cFile, 0)
    Local nSize := FSeek(nHandle, 0, 2)
    FClose(nHandle)
    
    ConOut("Tamanho do arquivo: " + cValToChar(nSize) + " bytes")
    
    If nSize == 0
        ConOut("ERRO: Arquivo vazio!")
    EndIf
EndIf
```

**2. Verificar formato:**
```advpl
// Formatos suportados: pdf, xlsx, docx, html
Local aFormatos := {"pdf", "xlsx", "docx", "html"}

If aScan(aFormatos, Lower(cFormato)) == 0
    ConOut("ERRO: Formato não suportado: " + cFormato)
EndIf
```

---

### Erro: "Falha ao converter para base64"

**Causa:** Arquivo muito grande ou corrompido.

**Soluções:**

**1. Verificar tamanho:**
```advpl
// Base64 aumenta o tamanho em ~33%
// Arquivo de 10MB vira ~13MB em base64

Local nSize := fSize(cFile)
Local nMaxSize := 10 * 1024 * 1024 // 10MB

If nSize > nMaxSize
    ConOut("AVISO: Arquivo muito grande para base64: " + cValToChar(nSize))
    // Considerar envio direto do arquivo ao invés de base64
EndIf
```

**2. Verificar integridade:**
```advpl
// Tentar abrir o arquivo
Local nHandle := FOpen(cFile, 0)

If nHandle < 0
    ConOut("ERRO: Não foi possível abrir o arquivo")
    ConOut("Código de erro: " + cValToChar(FError()))
Else
    FClose(nHandle)
EndIf
```

---

## Erros de Rede

### Erro: "Connection timeout"

**Causas possíveis:**
1. SmartView não está rodando
2. Firewall bloqueando
3. Problema de rede

**Soluções:**

**1. Testar conectividade:**
```powershell
# Windows
Test-NetConnection servidor -Port 7017

# Linux
telnet servidor 7017
nc -zv servidor 7017
```

**2. Verificar SmartView:**
```bash
# No servidor SmartView
netstat -an | findstr 7017

# Deve aparecer LISTENING na porta 7017
```

**3. Verificar firewall:**
```powershell
# Windows - Adicionar regra
New-NetFirewallRule -DisplayName "SmartView" -Direction Inbound -Protocol TCP -LocalPort 7017 -Action Allow
```

---

### Erro: "Connection refused"

**Causa:** Porta incorreta ou SmartView não iniciado.

**Solução:**
```advpl
// Verificar porta configurada no SmartView
// Arquivo: smartview.properties
// server.port=7017

oReport:SetUrl("http://servidor:7017") // Usar porta correta
```

---

### Erro: "SSL/TLS error"

**Causa:** Certificado inválido ou HTTPS mal configurado.

**Soluções:**

**1. Usar HTTP para testes:**
```advpl
oReport:SetUrl("http://servidor:7017") // Sem HTTPS
```

**2. Configurar certificado:**
```advpl
// No appserver.ini
[HTTP]
HTTPSSECURITY=1
HTTPSCERT=certificate.pem
```

---

## Erros de Performance

### Problema: "Geração muito lenta"

**Causas:**
1. Relatório com muitos dados
2. Servidor sobrecarregado
3. Consultas SQL não otimizadas

**Soluções:**

**1. Monitorar tempo:**
```advpl
Local nStart := Seconds()

cFile := oReport:GenerateReport(aParams, {"pdf"}, .T.)

Local nElapsed := Seconds() - nStart
ConOut("Tempo de geração: " + cValToChar(nElapsed) + " segundos")

If nElapsed > 60
    ConOut("AVISO: Geração muito lenta!")
EndIf
```

**2. Otimizar relatório:**
- Adicione filtros de data/filial
- Limite quantidade de registros
- Use índices nas tabelas
- Cache de dados quando possível

**3. Processar em paralelo:**
```advpl
// Gerar múltiplos relatórios simultaneamente
Local aThreads := {}

For nI := 1 To Len(aRelatorios)
    aAdd(aThreads, StartJob("U_GeraRel", GetEnvServer(), .F., aRelatorios[nI]))
Next
```

---

### Problema: "Memória insuficiente"

**Causa:** Arquivos muito grandes sendo processados.

**Soluções:**

**1. Não carregar tudo em memória:**
```advpl
// Evitar
cBase64 := FileToBase64(cArquivoGrande)

// Preferir
// Processar em chunks ou enviar arquivo direto
```

**2. Liberar memória:**
```advpl
cBase64 := oReport:FileToBase64(cFile)

// Usar base64
EnviarEmail(cBase64)

// Liberar
cBase64 := Nil
FreeObj(cBase64)
```

---

## Diagnóstico

### Script de Diagnóstico Completo

```advpl
User Function PSVDiag()
    Local oReport As Object
    Local cLog := ""
    
    cLog += Replicate("=", 60) + CRLF
    cLog += "DIAGNÓSTICO PRINTSMARTVIEW" + CRLF
    cLog += Replicate("=", 60) + CRLF
    
    // 1. Verificar classe
    cLog += "1. Verificando classe..." + CRLF
    oReport := PrintSmartView.clPrintSmartView():New()
    If oReport != Nil
        cLog += "   OK - Classe carregada" + CRLF
    Else
        cLog += "   ERRO - Classe não encontrada" + CRLF
        MemoWrite("C:\temp\psv_diag.txt", cLog)
        Return
    EndIf
    
    // 2. Verificar parâmetros
    cLog += "2. Verificando parâmetros..." + CRLF
    cLog += "   MV_PSVURL.: " + GetMV("MV_PSVURL", "NÃO CONFIGURADO") + CRLF
    cLog += "   MV_PSVUSER: " + GetMV("MV_PSVUSER", "NÃO CONFIGURADO") + CRLF
    cLog += "   MV_PSVTIME: " + cValToChar(GetMV("MV_PSVTIME", 0)) + CRLF
    
    // 3. Configurar
    cLog += "3. Configurando conexão..." + CRLF
    oReport:SetUrl(GetMV("MV_PSVURL"))
    oReport:SetCredentials(GetMV("MV_PSVUSER"), GetMV("MV_PSVPASS"))
    cLog += "   OK" + CRLF
    
    // 4. Testar conectividade
    cLog += "4. Testando conectividade..." + CRLF
    Local cResp := HttpGet(oReport:GetUrl() + "/api/ping")
    If !Empty(cResp)
        cLog += "   OK - Servidor respondeu" + CRLF
    Else
        cLog += "   ERRO - Servidor não responde" + CRLF
    EndIf
    
    // 5. Testar autenticação
    cLog += "5. Testando autenticação..." + CRLF
    If oReport:Authenticate(.F.)
        cLog += "   OK - Autenticação bem-sucedida" + CRLF
        cLog += "   Token: " + Left(oReport:cToken, 50) + "..." + CRLF
    Else
        cLog += "   ERRO - " + oReport:GetLastError() + CRLF
    EndIf
    
    // 6. Verificar pasta temp
    cLog += "6. Verificando pasta temporária..." + CRLF
    cLog += "   Pasta: " + oReport:cTempPath + CRLF
    If ExistDir(oReport:cTempPath)
        cLog += "   OK - Pasta existe" + CRLF
        
        // Testar escrita
        Local cTestFile := oReport:cTempPath + "test_write.txt"
        Local nHandle := FCreate(cTestFile)
        If nHandle >= 0
            FWrite(nHandle, "teste")
            FClose(nHandle)
            FErase(cTestFile)
            cLog += "   OK - Permissão de escrita" + CRLF
        Else
            cLog += "   ERRO - Sem permissão de escrita" + CRLF
        EndIf
    Else
        cLog += "   ERRO - Pasta não existe" + CRLF
    EndIf
    
    cLog += Replicate("=", 60) + CRLF
    cLog += "Diagnóstico concluído em: " + DtoC(Date()) + " " + Time() + CRLF
    
    // Salvar log
    MemoWrite("C:\temp\psv_diag.txt", cLog)
    
    // Exibir
    MsgInfo("Diagnóstico salvo em: C:\temp\psv_diag.txt", "Diagnóstico")
    
    // Abrir arquivo
    ShellExecute("open", "C:\temp\psv_diag.txt", "", "", 1)
Return
```

### Habilitar Logs Detalhados

```advpl
// Na classe clPrintSmartView, adicione em cada método:

Method Authenticate(lShowMsg) Class clPrintSmartView
    Local lSuccess := .F.
    
    LogDebug("Authenticate() - Iniciando...")
    LogDebug("URL: " + ::cUrl)
    LogDebug("Usuario: " + ::cUsername)
    
    // ... código existente ...
    
    If lSuccess
        LogDebug("Authenticate() - Sucesso")
    Else
        LogDebug("Authenticate() - Falha: " + ::cLastError)
    EndIf
    
Return lSuccess

Static Function LogDebug(cMsg)
    Local cFile := "C:\temp\psv_debug_" + DtoS(Date()) + ".log"
    Local nHandle := FOpen(cFile, 2) // Append
    
    If nHandle < 0
        nHandle := FCreate(cFile)
    EndIf
    
    If nHandle >= 0
        FSeek(nHandle, 0, 2)
        FWrite(nHandle, Time() + " | " + cMsg + CRLF)
        FClose(nHandle)
    EndIf
Return
```

---

## Suporte

Se o problema persistir após seguir este guia:

1. Colete o log de diagnóstico (`U_PSVDiag()`)
2. Verifique os logs do SmartView (`smartview/logs/`)
3. Verifique os logs do AppServer (`protheus_error.log`)
4. Entre em contato com o suporte técnico

**Informações úteis para o suporte:**
- Versão do Protheus
- Build do AppServer
- Versão do SmartView
- Sistema operacional (servidor)
- Mensagem de erro completa
- Log de diagnóstico
