# clPrintSmartView - Biblioteca TLPP para SmartView

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![TLPP](https://img.shields.io/badge/TLPP-Compatible-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📋 Descrição

Classe TLPP para geração e download de relatórios SmartView de forma automatizada, sem interface gráfica com gerenciamento automático de autenticação e cache de token. Ideal para:

- ✅ Jobs programados
- ✅ Schedules
- ✅ Envio automático para impressoras
- ✅ Processamentos em background
- ✅ Integração com APIs

## 🏗️ Estrutura do Projeto

```
print_smartview/
├── src/
│   └── clPrintSmartView.tlpp          # Classe principal
├── includes_tlpp/
│   ├── tlpp-core.th                   # Include core TLPP
│   ├── tlpp-rest.th                   # Include REST TLPP
│   ├── tlpp-doc.th                    # Include documentação
│   ├── tlpp-i18n.th                   # Include internacionalização
│   ├── tlpp-object.th                 # Include orientação a objetos
│   └── tlpp-probat.th                 # Include ProBat
├── examples/
│   ├── PSVEX001.prw                   # Exemplo básico de uso
│   ├── PSVEX002.prw                   # Exemplo com autenticação
│   ├── PSVEX003.prw                   # Exemplo em job
│   └── PSVEX004.prw                   # Exemplo envio email
├── docs/
│   ├── API.md                         # Documentação da API
│   ├── SETUP.md                       # Guia de instalação
│   └── TROUBLESHOOTING.md            # Solução de problemas
└── README.md                          # Este arquivo
```

## 🚀 Instalação

1. Copie o arquivo `src/clPrintSmartView.tlpp` para o diretório de fontes do seu projeto
2. Copie a pasta `includes_tlpp/` com todos os arquivos `.th` para o diretório de includes do seu projeto
3. Compile o fonte no ambiente Protheus
4. Configure os parâmetros de produção (opcional):

### Parâmetros de Configuração

A classe carrega automaticamente as configurações dos seguintes parâmetros (crie via Configurador - SIGACFG):

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-----------|--------|
| `MV_PSVURL` | C | http://localhost:7017 | URL do servidor SmartView |
| `MV_PSVUSER` | C | admin | Usuário para autenticação |
| `MV_PSVPASS` | C | admin | Senha para autenticação |
| `MV_PSVTOKN` | C | (vazio) | Cache de token JWT (gerenciado automaticamente) |

**Nota:** Os parâmetros são opcionais. Se não existirem, a classe usará os valores padrão. Você pode sobrescrever via `SetUrl()` e `SetCredentials()` se necessário.

## 📖 Uso Rápido

### Modo Simples (Configurações Automáticas)

```advpl
#Include "totvs.ch"

User Function MyReport()
    Local oReport As Object
    Local cResult As Character
    Local aParams As Array
    
    // Cria instância - carrega automaticamente dos parâmetros
    // MV_PSVURL, MV_PSVUSER, MV_PSVPASS (ou usa padrões)
    oReport := PrintSmartView.clPrintSmartView():New()
    
    // Configura relatório
    oReport:SetReportId("uuid-do-relatorio")
    
    // Define parâmetros do relatório
    aParams := {}
    aAdd(aParams, {"parameter1", "valor1"})
    aAdd(aParams, {"parameter2", "valor2"})
    
    // Gera relatório (autentica automaticamente se necessário)
    cResult := oReport:GenerateReport(aParams, {"pdf"}, .T., "meu_relatorio.pdf")
    
    If !Empty(cResult)
        ConOut("Relatório gerado: " + cResult)
    Else
        ConOut("Erro: " + oReport:GetLastError())
    EndIf
    
Return
```

### Modo Personalizado (Sobrescrevendo Padrões)

```advpl
User Function MyCustomReport()
    Local oReport As Object
    Local cResult As Character
    
    oReport := PrintSmartView.clPrintSmartView():New()
    
    // Sobrescreve configurações padrão se necessário
    oReport:SetUrl("http://outro-servidor:8080")
    oReport:SetCredentials("outro_usuario", "outra_senha")
    oReport:EnableTokenCache(.F.) // Desabilita cache (usa apenas memória)
    oReport:SetEndpoint("/api/custom/endpoint") // Endpoint customizado
    
    oReport:SetReportId("uuid-do-relatorio")
    cResult := oReport:GenerateReport({}, {"pdf"}, .T.)
    
Return
```

## 🔑 Principais Métodos

### Construção
- `New()` - Cria instância carregando automaticamente:
  - URL de MV_PSVURL (padrão: http://localhost:7017)
  - Credenciais de MV_PSVUSER e MV_PSVPASS (padrão: admin/admin)
  - Endpoint: /api/reports/v2/generate
  - Header: Content-Type: application/json
  - Cache de token habilitado em MV_PSVTOKN

### Configuração (Opcionais)
- `SetUrl(cUrl)` - Sobrescreve URL base do SmartView
- `SetCredentials(cUsername, cPassword)` - Sobrescreve credenciais
- `SetEndpoint(cEndpoint)` - Sobrescreve endpoint (padrão: /api/reports/v2/generate)
- `SetTimeout(nSeconds)` - Define timeout (padrão: 120s)
- `AddHeader(cKey, cValue)` - Adiciona header customizado
- `EnableTokenCache(lEnable)` - Controla cache (.T.=parâmetro MV_PSVTOKN, .F.=memória)

### Autenticação (Automática)
- `EnsureAuthenticated()` - Garante autenticação (chamado automaticamente)
- `Authenticate(lRememberUser)` - Autentica manualmente e obtém token JWT

### Geração de Relatórios
- `SetReportId(cReportId)` - Define UUID do relatório (obrigatório)
- `GenerateReport(aParameters, aFormats, lSaveFile, cFileName)` - Gera relatório

### Download de Relatórios
- `SetGenerationId(cGenerationId)` - Define UUID de geração
- `DownloadReport(cFormat, lSaveFile, cFileName)` - Baixa relatório gerado

### Utilitários
- `GetLastError()` - Retorna último erro ocorrido
- `ConvertToBase64(cContent)` - Converte conteúdo para base64
- `FileToBase64(cFilePath)` - Lê arquivo e converte para base64

## 📚 Exemplos

Veja exemplos completos na pasta `examples/`:

- **PSVEX001** - Uso básico com token manual
- **PSVEX002** - Autenticação automática
- **PSVEX003** - Execução em job agendado
- **PSVEX004** - Geração e envio por email

## 📋 Requisitos

- Protheus 12.1.33 ou superior
- TLPP habilitado
- SmartView configurado e rodando
- Acesso HTTP ao servidor SmartView

## 🔧 Configuração do SmartView

1. Certifique-se que o SmartView está rodando
2. Obtenha a URL base (ex: `http://localhost:7017`)
3. Crie credenciais de acesso (usuário/senha)
4. Obtenha o UUID do relatório desejado

## 🐛 Troubleshooting

### Erro de autenticação
- Verifique se a URL está correta
- Confirme usuário e senha
- Verifique se o SmartView está acessível

### Relatório não é gerado
- Valide se o Report ID está correto
- Verifique os parâmetros obrigatórios
- Confira timeout (relatórios grandes precisam de mais tempo)

### Arquivo não é salvo
- Verifique permissões da pasta temporária
- Confirme espaço em disco disponível

Consulte `docs/TROUBLESHOOTING.md` para mais detalhes.

## 📄 Licença

MIT License - Copyright (c) 2025 Lucas Souza - Insider Consulting

## 👤 Autor

**Lucas Souza**
- Empresa: Insider Consulting
- Email: contato@insiderconsulting.com.br

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Changelog

### [1.0.0] - 2025-11-28
- Versão inicial
- Suporte completo a autenticação JWT
- Geração de relatórios com múltiplos formatos
- Download de relatórios por generation ID
- Conversão para base64
- Exemplos incluídos
