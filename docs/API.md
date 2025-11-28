# API Reference - clPrintSmartView

## Índice
- [Construtor](#construtor)
- [Métodos de Configuração](#métodos-de-configuração)
- [Métodos de Autenticação](#métodos-de-autenticação)
- [Métodos de Relatório](#métodos-de-relatório)
- [Métodos HTTP](#métodos-http)
- [Métodos Utilitários](#métodos-utilitários)

---

## Construtor

### New()
Cria uma nova instância da classe clPrintSmartView.

**Sintaxe:**
```advpl
oReport := PrintSmartView.clPrintSmartView():New()
```

**Retorno:**
- `Object` - Instância da classe clPrintSmartView

**Exemplo:**
```advpl
Local oReport As Object
oReport := PrintSmartView.clPrintSmartView():New()
```

---

## Métodos de Configuração

### SetUrl(cUrl)
Define a URL base do servidor SmartView.

**Parâmetros:**
- `cUrl` (Character) - URL base do servidor (ex: "http://localhost:7017")

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetUrl("http://smartview.empresa.com.br:7017")
```

---

### GetUrl()
Retorna a URL base configurada.

**Retorno:**
- `Character` - URL base do servidor

**Exemplo:**
```advpl
Local cUrl := oReport:GetUrl()
ConOut("URL configurada: " + cUrl)
```

---

### SetEndpoint(cEndpoint)
Define o endpoint específico da API.

**Parâmetros:**
- `cEndpoint` (Character) - Endpoint da API (ex: "/api/reports/v2/generate")

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetEndpoint("/api/reports/v2/generate")
```

---

### AddHeader(cKey, cValue)
Adiciona um cabeçalho HTTP à requisição.

**Parâmetros:**
- `cKey` (Character) - Nome do cabeçalho
- `cValue` (Character) - Valor do cabeçalho

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:AddHeader("Content-Type", "application/json")
oReport:AddHeader("X-Custom-Header", "valor")
```

---

### SetTimeout(nSeconds)
Define o tempo limite para requisições HTTP.

**Parâmetros:**
- `nSeconds` (Numeric) - Tempo em segundos (padrão: 120)

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetTimeout(180) // 3 minutos
```

---

### SetCredentials(cUser, cPass)
Define as credenciais para autenticação.

**Parâmetros:**
- `cUser` (Character) - Nome de usuário
- `cPass` (Character) - Senha do usuário

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetCredentials("admin", "senha123")
```

---

### GetUsername()
Retorna o nome de usuário configurado.

**Retorno:**
- `Character` - Nome de usuário

**Exemplo:**
```advpl
Local cUser := oReport:GetUsername()
ConOut("Usuário: " + cUser)
```

**Nota:** Por segurança, não existe um método GetPassword().

---

## Métodos de Autenticação

### Authenticate(lShowMsg)
Realiza a autenticação no SmartView e obtém o token JWT.

**Parâmetros:**
- `lShowMsg` (Logical, opcional) - Se .T., exibe mensagens de sucesso/erro (padrão: .T.)

**Retorno:**
- `Logical` - .T. se autenticação bem-sucedida, .F. caso contrário

**Exemplo:**
```advpl
If oReport:Authenticate(.T.)
    ConOut("Autenticação realizada com sucesso")
Else
    ConOut("Erro: " + oReport:GetLastError())
EndIf
```

**Observações:**
- Requer que SetUrl() e SetCredentials() tenham sido chamados previamente
- O token é armazenado automaticamente na propriedade cToken
- O token é válido por tempo determinado pelo servidor

---

### SetToken(cToken)
Define manualmente o token de autenticação.

**Parâmetros:**
- `cToken` (Character) - Token JWT

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
Local cToken := GetTokenFromConfig()
oReport:SetToken(cToken)
```

**Uso recomendado:** Quando você já possui um token válido e deseja evitar nova autenticação.

---

## Métodos de Relatório

### SetReportId(cReportId)
Define o ID do relatório a ser gerado.

**Parâmetros:**
- `cReportId` (Character) - UUID do relatório no SmartView

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetReportId("8505ddf2-dcea-4e25-83c7-7c9d8304b37d")
```

---

### SetGenerationId(cGenerationId)
Define o ID de uma geração específica para download.

**Parâmetros:**
- `cGenerationId` (Character) - UUID da geração

**Retorno:**
- `Nil`

**Exemplo:**
```advpl
oReport:SetGenerationId("f47ac10b-58cc-4372-a567-0e02b2c3d479")
```

---

### GenerateReport(aParams, aFormats, lSaveFile, cFileName)
Gera um relatório no SmartView.

**Parâmetros:**
- `aParams` (Array, opcional) - Array de parâmetros do relatório. Cada elemento é um array {cNome, xValor}
- `aFormats` (Array, opcional) - Array de formatos desejados ("pdf", "xlsx", etc.)
- `lSaveFile` (Logical, opcional) - Se .T., salva o arquivo no disco (padrão: .T.)
- `cFileName` (Character, opcional) - Nome do arquivo a ser salvo

**Retorno:**
- `Character` - Se lSaveFile = .T., retorna o caminho completo do arquivo. Se lSaveFile = .F., retorna o conteúdo em base64

**Exemplo 1 - Salvar em arquivo:**
```advpl
Local aParams := {}
Local cFile As Character

aAdd(aParams, {"dataInicio", "20240101"})
aAdd(aParams, {"dataFim", "20241231"})

cFile := oReport:GenerateReport(aParams, {"pdf"}, .T., "relatorio.pdf")

If !Empty(cFile)
    ConOut("Relatório salvo em: " + cFile)
EndIf
```

**Exemplo 2 - Retornar base64:**
```advpl
Local cBase64 := oReport:GenerateReport(aParams, {"pdf"}, .F.)

If !Empty(cBase64)
    // Enviar por e-mail, API, etc.
EndIf
```

**Observações:**
- Requer autenticação prévia
- O formato padrão é "pdf"
- Múltiplos formatos podem ser solicitados, mas apenas o primeiro será retornado

---

### DownloadReport(cFormat, lSaveFile, cFileName)
Baixa um relatório previamente gerado.

**Parâmetros:**
- `cFormat` (Character, opcional) - Formato do arquivo ("pdf", "xlsx", etc.) - padrão: "pdf"
- `lSaveFile` (Logical, opcional) - Se .T., salva o arquivo no disco (padrão: .T.)
- `cFileName` (Character, opcional) - Nome do arquivo a ser salvo

**Retorno:**
- `Character` - Se lSaveFile = .T., retorna o caminho completo do arquivo. Se lSaveFile = .F., retorna o conteúdo em base64

**Exemplo:**
```advpl
oReport:SetGenerationId("f47ac10b-58cc-4372-a567-0e02b2c3d479")

Local cFile := oReport:DownloadReport("pdf", .T., "meu_relatorio.pdf")

If !Empty(cFile) .And. File(cFile)
    ConOut("Download concluído: " + cFile)
EndIf
```

**Observações:**
- Requer que SetGenerationId() tenha sido chamado previamente
- O ID de geração é obtido através do GenerateReport()

---

## Métodos HTTP

### GetRequest(cCustomEndpoint)
Executa uma requisição HTTP GET.

**Parâmetros:**
- `cCustomEndpoint` (Character, opcional) - Endpoint customizado. Se não fornecido, usa o definido em SetEndpoint()

**Retorno:**
- `Character` - Resposta do servidor

**Exemplo:**
```advpl
oReport:SetEndpoint("/api/reports/list")
Local cResponse := oReport:GetRequest()

If !Empty(cResponse)
    Local oJson := JsonObject():New()
    oJson:FromJson(cResponse)
    // Processar resposta
EndIf
```

---

### PostRequest(cBody, cCustomEndpoint)
Executa uma requisição HTTP POST.

**Parâmetros:**
- `cBody` (Character) - Corpo da requisição (geralmente JSON)
- `cCustomEndpoint` (Character, opcional) - Endpoint customizado

**Retorno:**
- `Character` - Resposta do servidor

**Exemplo:**
```advpl
Local cJson := '{"reportId":"123","format":"pdf"}'
Local cResponse := oReport:PostRequest(cJson, "/api/custom/endpoint")
```

---

## Métodos Utilitários

### GetLastError()
Retorna a última mensagem de erro.

**Retorno:**
- `Character` - Mensagem de erro

**Exemplo:**
```advpl
If !oReport:Authenticate(.F.)
    ConOut("Erro: " + oReport:GetLastError())
EndIf
```

---

### SaveToTemp(cContent, cFileName)
Salva conteúdo em um arquivo na pasta temporária.

**Parâmetros:**
- `cContent` (Character) - Conteúdo a ser salvo
- `cFileName` (Character) - Nome do arquivo

**Retorno:**
- `Character` - Caminho completo do arquivo salvo, ou vazio em caso de erro

**Exemplo:**
```advpl
Local cContent := "Conteúdo do arquivo"
Local cFile := oReport:SaveToTemp(cContent, "teste.txt")

If !Empty(cFile)
    ConOut("Arquivo salvo: " + cFile)
EndIf
```

---

### ConvertToBase64(cContent)
Converte uma string para base64.

**Parâmetros:**
- `cContent` (Character) - Conteúdo a ser convertido

**Retorno:**
- `Character` - String em base64

**Exemplo:**
```advpl
Local cBase64 := oReport:ConvertToBase64("Texto para codificar")
ConOut(cBase64)
```

---

### FileToBase64(cFilePath)
Converte o conteúdo de um arquivo para base64.

**Parâmetros:**
- `cFilePath` (Character) - Caminho completo do arquivo

**Retorno:**
- `Character` - Conteúdo do arquivo em base64, ou vazio em caso de erro

**Exemplo:**
```advpl
Local cBase64 := oReport:FileToBase64("C:\temp\relatorio.pdf")

If !Empty(cBase64)
    // Enviar por e-mail, salvar em banco, etc.
EndIf
```

---

### SendFileAsBase64(cFilePath)
Envia o conteúdo de um arquivo como base64 via POST.

**Parâmetros:**
- `cFilePath` (Character) - Caminho completo do arquivo

**Retorno:**
- `Character` - Resposta do servidor

**Exemplo:**
```advpl
Local cResponse := oReport:SendFileAsBase64("C:\temp\arquivo.pdf")

If !Empty(cResponse)
    ConOut("Arquivo enviado com sucesso")
EndIf
```

**Observações:**
- O arquivo é convertido para base64 automaticamente
- O corpo da requisição terá o formato: {"file":"<base64>"}

---

## Propriedades Públicas

### cEndpoint
Endpoint da API atualmente configurado.

**Tipo:** Character

---

### aHeaders
Array de cabeçalhos HTTP.

**Tipo:** Array

**Estrutura:** Cada elemento é um array {cKey, cValue}

---

### cLastError
Última mensagem de erro.

**Tipo:** Character

---

### cTempPath
Caminho da pasta temporária do sistema.

**Tipo:** Character

---

### nTimeout
Tempo limite para requisições HTTP (em segundos).

**Tipo:** Numeric

---

### cToken
Token JWT de autenticação.

**Tipo:** Character

---

### cReportId
ID do relatório.

**Tipo:** Character

---

### cGenerationId
ID da geração do relatório.

**Tipo:** Character

---

## Códigos de Erro Comuns

| Erro | Descrição | Solução |
|------|-----------|---------|
| URL não configurada | SetUrl() não foi chamado | Chamar SetUrl() antes de fazer requisições |
| Credenciais não configuradas | SetCredentials() não foi chamado | Chamar SetCredentials() antes de Authenticate() |
| Erro de autenticação | Credenciais inválidas ou servidor indisponível | Verificar usuário/senha e conectividade |
| Report ID não configurado | SetReportId() não foi chamado | Chamar SetReportId() antes de GenerateReport() |
| Generation ID não configurado | SetGenerationId() não foi chamado | Chamar SetGenerationId() antes de DownloadReport() |
| Timeout | Tempo limite excedido | Aumentar timeout com SetTimeout() |
| Arquivo não encontrado | Caminho inválido em FileToBase64() | Verificar se o arquivo existe |

---

## Fluxo de Trabalho Típico

```advpl
// 1. Criar instância
oReport := PrintSmartView.clPrintSmartView():New()

// 2. Configurar
oReport:SetUrl("http://servidor:7017")
oReport:SetCredentials("usuario", "senha")
oReport:SetTimeout(180)

// 3. Autenticar
oReport:Authenticate(.T.)

// 4. Configurar relatório
oReport:SetEndpoint("/api/reports/v2/generate")
oReport:SetReportId("uuid-do-relatorio")

// 5. Gerar relatório
Local aParams := {{"param1", "valor1"}}
Local cFile := oReport:GenerateReport(aParams, {"pdf"}, .T., "rel.pdf")

// 6. Processar resultado
If !Empty(cFile)
    // Sucesso
Else
    ConOut(oReport:GetLastError())
EndIf
```
