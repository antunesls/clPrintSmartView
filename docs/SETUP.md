# Guia de Instalação e Configuração

## Índice
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Configuração do SmartView](#configuração-do-smartview)
- [Configuração no Protheus](#configuração-no-protheus)
- [Primeiros Passos](#primeiros-passos)
- [Configurações Avançadas](#configurações-avançadas)

---

## Requisitos

### Servidor SmartView
- **Versão mínima:** SmartView Server 2.0
- **Sistema operacional:** Windows Server 2012 R2 ou superior
- **Portas:** 7017 (HTTP) ou 7018 (HTTPS)
- **Memória RAM:** Mínimo 4GB (recomendado 8GB)
- **Disco:** 10GB livres para relatórios e logs

### Protheus
- **Versão mínima:** Protheus 12.1.25 ou superior
- **Build:** 20190828 ou superior
- **Compilação:** Suporte a TLPP (não AdvPL puro)
- **Libs:** Protheus Framework atualizado

### Rede
- Conectividade TCP/IP entre servidor Protheus e SmartView
- Portas liberadas no firewall
- DNS configurado (se usar nome de host)

---

## Instalação

### Passo 1: Copiar Arquivos

1. Copie a estrutura de pastas para o diretório do seu projeto:

```
<seu_projeto>/
├── src/
│   └── clPrintSmartView.tlpp
├── examples/
│   ├── PSVEX001.prw
│   ├── PSVEX002.prw
│   ├── PSVEX003.prw
│   └── PSVEX004.prw
└── docs/
```

### Passo 2: Compilar a Classe

1. Abra o **AppServer Compilation Tools** ou **TDS**
2. Compile o arquivo `src/clPrintSmartView.tlpp`
3. Verifique se não há erros de compilação
4. O RPO deve conter o namespace `PrintSmartView`

**Via linha de comando:**
```bash
# Windows
Protheus_Compiler.exe -i clPrintSmartView.tlpp -o clPrintSmartView.apo

# Copiar para RPO
copy clPrintSmartView.apo C:\totvs\protheus\apo\
```

### Passo 3: Verificar Instalação

Execute um programa simples para verificar a instalação:

```advpl
User Function TesteInst()
    Local oReport As Object
    
    oReport := PrintSmartView.clPrintSmartView():New()
    
    If oReport != Nil
        MsgInfo("Classe instalada com sucesso!", "Teste")
    Else
        MsgAlert("Erro na instalação!", "Teste")
    EndIf
Return
```

---

## Configuração do SmartView

### Verificar Instalação do SmartView

1. Acesse o servidor SmartView via navegador:
   ```
   http://servidor:7017
   ```

2. Faça login com as credenciais de administrador

3. Verifique o menu **Administração** > **Sobre** para confirmar a versão

### Criar Usuário de Integração

É recomendado criar um usuário específico para a integração:

1. Acesse **Administração** > **Usuários**
2. Clique em **Novo Usuário**
3. Preencha os dados:
   - **Login:** `protheus_integration`
   - **Nome:** Integração Protheus
   - **Senha:** *(senha forte)*
   - **Tipo:** API
   - **Perfil:** Geração de Relatórios

4. Salve o usuário

### Configurar Relatórios

1. Acesse **Relatórios** > **Meus Relatórios**
2. Selecione o relatório que deseja disponibilizar
3. Clique em **Configurações** (⚙️)
4. Na aba **API**, anote o **Report ID** (UUID)
5. Configure os **Parâmetros** que serão enviados via API
6. Salve as alterações

**Exemplo de Report ID:**
```
8505ddf2-dcea-4e25-83c7-7c9d8304b37d
```

### Testar API do SmartView

Use o Postman ou curl para testar:

```bash
# 1. Autenticar
curl -X POST http://servidor:7017/api/security/token \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $(echo -n 'usuario:senha' | base64)" \
  -d '{}'

# 2. Gerar relatório
curl -X POST http://servidor:7017/api/reports/v2/generate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "reportId": "8505ddf2-dcea-4e25-83c7-7c9d8304b37d",
    "parameters": {},
    "formats": ["pdf"]
  }'
```

---

## Configuração no Protheus

### Criar Parâmetros do Sistema

Crie os seguintes parâmetros no Configurador:

| Parâmetro | Tipo | Conteúdo | Descrição |
|-----------|------|----------|-----------|
| `MV_PSVURL` | C | `http://servidor:7017` | URL base do SmartView |
| `MV_PSVUSER` | C | `protheus_integration` | Usuário da API |
| `MV_PSVPASS` | C | `senha123` | Senha do usuário |
| `MV_PSVTIME` | N | `180` | Timeout em segundos |
| `MV_PSVPATH` | C | `C:\temp\reports\` | Pasta para relatórios |

**Criar via fonte:**

```advpl
User Function CriaPar()
    PutMV("MV_PSVURL" , "http://localhost:7017")
    PutMV("MV_PSVUSER", "admin")
    PutMV("MV_PSVPASS", "admin")
    PutMV("MV_PSVTIME", 180)
    PutMV("MV_PSVPATH", GetTempPath())
    
    MsgInfo("Parâmetros criados!", "Sucesso")
Return
```

### Configurar Permissões de Pasta

Garanta que o AppServer tenha permissão de escrita na pasta temporária:

**Windows:**
```cmd
icacls C:\temp\reports /grant "NETWORK SERVICE:(OI)(CI)F"
```

**Linux:**
```bash
chmod 777 /tmp/reports
chown protheus:protheus /tmp/reports
```

---

## Primeiros Passos

### Exemplo Básico

Crie um programa de teste:

```advpl
#Include "totvs.ch"

User Function PrimTest()
    Local oReport As Object
    Local cFile As Character
    
    // 1. Criar instância
    oReport := PrintSmartView.clPrintSmartView():New()
    
    // 2. Configurar
    oReport:SetUrl(GetMV("MV_PSVURL"))
    oReport:SetCredentials(GetMV("MV_PSVUSER"), GetMV("MV_PSVPASS"))
    
    // 3. Autenticar
    If !oReport:Authenticate(.T.)
        MsgAlert("Erro: " + oReport:GetLastError(), "Autenticação")
        Return
    EndIf
    
    // 4. Gerar relatório
    oReport:SetEndpoint("/api/reports/v2/generate")
    oReport:SetReportId("seu-report-id-aqui")
    
    cFile := oReport:GenerateReport({}, {"pdf"}, .T., "teste.pdf")
    
    // 5. Verificar resultado
    If !Empty(cFile) .And. File(cFile)
        MsgInfo("Relatório gerado: " + cFile, "Sucesso")
    Else
        MsgAlert("Erro: " + oReport:GetLastError(), "Geração")
    EndIf
Return
```

### Executar Exemplos

Os exemplos fornecidos estão prontos para uso:

1. **PSVEX001.prw** - Uso básico com token pré-configurado
2. **PSVEX002.prw** - Com autenticação automática
3. **PSVEX003.prw** - Execução via job/schedule
4. **PSVEX004.prw** - Integração com e-mail

Compile e execute:
```advpl
U_PSVEX001() // Executar exemplo 1
```

---

## Configurações Avançadas

### HTTPS / SSL

Para usar HTTPS, configure o certificado no SmartView e altere a URL:

```advpl
oReport:SetUrl("https://servidor:7018")
```

**Configurar certificado no Protheus:**

1. Copie o certificado para a pasta `\bin\appserver\`
2. Configure no `appserver.ini`:
   ```ini
   [ONSTART]
   JOBS=HTTP
   HTTPSRVC=ON
   HTTPSPORT=7018
   HTTPSCERT=certificado.pem
   ```

### Proxy

Se houver proxy entre Protheus e SmartView:

```advpl
oReport:AddHeader("Proxy-Authorization", "Basic " + Encode64("proxy_user:proxy_pass"))
```

### Logs Detalhados

Ative logs para debug:

```advpl
Static Function LogDebug(cMsg)
    ConOut("[PSV-DEBUG] " + DtoC(Date()) + " " + Time() + " - " + cMsg)
    
    // Opcional: gravar em arquivo
    Local nHandle := FOpen("C:\temp\psv_debug.log", 2) // Append
    If nHandle >= 0
        FSeek(nHandle, 0, 2) // Fim do arquivo
        FWrite(nHandle, DtoC(Date()) + " " + Time() + " - " + cMsg + CRLF)
        FClose(nHandle)
    EndIf
Return
```

### Múltiplas Instâncias

Para trabalhar com múltiplos servidores SmartView:

```advpl
Local oReportProd := PrintSmartView.clPrintSmartView():New()
Local oReportHomol := PrintSmartView.clPrintSmartView():New()

oReportProd:SetUrl("http://prod-server:7017")
oReportHomol:SetUrl("http://homol-server:7017")

// Cada instância mantém seu próprio token e estado
```

### Performance

Para melhorar a performance:

1. **Reutilizar tokens:**
   ```advpl
   // Autenticar uma vez
   oReport:Authenticate(.F.)
   cToken := oReport:cToken
   
   // Salvar token em cache (memória, banco, arquivo)
   
   // Próximas execuções
   oReport:SetToken(cToken)
   ```

2. **Timeout ajustado:**
   ```advpl
   // Relatórios rápidos
   oReport:SetTimeout(30)
   
   // Relatórios pesados
   oReport:SetTimeout(300)
   ```

3. **Processar em lote:**
   ```advpl
   For nI := 1 To Len(aRelatorios)
       oReport:SetReportId(aRelatorios[nI])
       oReport:GenerateReport(...)
   Next
   ```

---

## Verificação Final

Execute a checklist:

- [ ] SmartView rodando e acessível
- [ ] Usuário de API criado
- [ ] Report ID obtido
- [ ] Parâmetros MV_PSV* criados
- [ ] Classe compilada sem erros
- [ ] Exemplo básico executado com sucesso
- [ ] Logs sem erros

Se todos os itens estiverem OK, a instalação está completa!

---

## Suporte

Para problemas na instalação, consulte o arquivo [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
