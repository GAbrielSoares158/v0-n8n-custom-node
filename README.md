# Onfly n8n Challenge - Random Number Generator Custom Node

Este projeto implementa um conector personalizado (custom node) para a plataforma n8n que gera números aleatórios verdadeiros usando a API do Random.org.

## Descrição do Desafio

Desenvolver um conector personalizado para n8n que:
- Recebe inputs de mínimo e máximo (números inteiros)
- Retorna um número aleatório verdadeiro usando a API do Random.org
- Segue as melhores práticas de desenvolvimento do n8n

## Funcionalidades

- **Conector "Random"** com operação "True Random Number Generator"
- **Validação de entrada**: Aceita apenas números inteiros
- **Integração com Random.org**: Usa a API oficial para gerar números verdadeiramente aleatórios
- **Tratamento de erros**: Gerencia timeouts, indisponibilidade da API e respostas inválidas
- **Interface amigável**: Nomes descritivos e ícone personalizado
- **Testes unitários**: Cobertura completa das funcionalidades

## Estrutura do Projeto

\`\`\`
onfly-n8n-challenge/
├── src/
│   ├── nodes/
│   │   └── Random/
│   │       ├── Random.node.ts      # Implementação do custom node
│   │       └── icon.jpg            # Ícone do node
│   ├── utils/
│   │   └── RandomOrgClient.ts      # Cliente para API do Random.org
│   ├── types/
│   │   └── RandomTypes.ts          # Definições de tipos TypeScript
│   ├── __tests__/
│   │   └── RandomOrgClient.test.ts # Testes unitários
│   └── index.ts                    # Ponto de entrada
├── custom-nodes/                   # Pasta para nodes customizados do n8n
├── docker-compose.yml              # Configuração do Docker
├── Dockerfile                      # Build do custom node
├── package.json                    # Dependências e scripts
├── tsconfig.json                   # Configuração TypeScript
├── jest.config.js                  # Configuração dos testes
└── README.md                       # Este arquivo
\`\`\`

## Pré-requisitos

- **Node.js 22 (LTS)** ou superior
- **Docker** e **Docker Compose**
- **npm** (incluído com Node.js)

## Instalação e Configuração

### 1. Clone o repositório

\`\`\`bash
git clone https://github.com/gabrielsoaresreis2004/onfly-n8n-challenge.git
cd onfly-n8n-challenge
\`\`\`

### 2. Instale as dependências

\`\`\`bash
npm install
\`\`\`

### 3. Build do custom node

\`\`\`bash
npm run build
\`\`\`

### 4. Prepare a pasta de custom nodes

\`\`\`bash
mkdir -p custom-nodes
cp -r dist/* custom-nodes/
cp package.json custom-nodes/
\`\`\`

## Executando o Projeto

### 1. Inicie os serviços com Docker Compose

\`\`\`bash
docker-compose up -d
\`\`\`

Este comando irá:
- Iniciar uma instância PostgreSQL para o n8n
- Iniciar o n8n na versão 1.85.4
- Montar a pasta `custom-nodes` no diretório correto do n8n

### 2. Acesse o n8n

Abra seu navegador e acesse: `http://localhost:5678`

**Credenciais de acesso:**
- Usuário: `admin`
- Senha: `admin123`

### 3. Usando o Custom Node

1. Crie um novo workflow no n8n
2. Procure pelo node "Random" na lista de nodes disponíveis
3. Adicione o node ao seu workflow
4. Configure os parâmetros:
   - **Minimum Value**: Valor mínimo (inclusive)
   - **Maximum Value**: Valor máximo (inclusive)
5. Execute o workflow

## Configuração do Ambiente

### Variáveis de Ambiente

O projeto usa as seguintes variáveis de ambiente (já configuradas no docker-compose.yml):

\`\`\`env
# Banco de dados PostgreSQL
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=n8n

# Autenticação básica do n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin123

# Configurações gerais
WEBHOOK_URL=http://localhost:5678/
GENERIC_TIMEZONE=America/Sao_Paulo
\`\`\`

### Estrutura de Pastas do n8n

O custom node é instalado em:
\`\`\`
/home/node/.n8n/custom/
├── nodes/
│   └── Random/
│       ├── Random.node.js
│       └── icon.jpg
├── types/
├── utils/
├── index.js
└── package.json
\`\`\`

## Executando os Testes

### Testes unitários

\`\`\`bash
npm test
\`\`\`

### Testes com cobertura

\`\`\`bash
npm run test -- --coverage
\`\`\`

### Modo watch (desenvolvimento)

\`\`\`bash
npm run test -- --watch
\`\`\`

## Scripts Disponíveis

\`\`\`bash
# Build do projeto
npm run build

# Desenvolvimento com watch
npm run dev

# Executar testes
npm test

# Linting
npm run lint

# Correção automática de lint
npm run lintfix

# Formatação de código
npm run format

# Cópia de ícones
npm run copy-icons
\`\`\`

## API do Random.org

O custom node utiliza a API pública do Random.org:

**Endpoint:** `https://www.random.org/integers/`

**Parâmetros:**
- `num=1`: Quantidade de números (sempre 1)
- `min`: Valor mínimo (configurável)
- `max`: Valor máximo (configurável)
- `col=1`: Uma coluna
- `base=10`: Base decimal
- `format=plain`: Formato texto simples
- `rnd=new`: Novo número aleatório

**Exemplo de requisição:**
\`\`\`
https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new
\`\`\`

## Tratamento de Erros

O custom node implementa tratamento robusto de erros:

- **Validação de entrada**: Verifica se min ≤ max e se são números inteiros
- **Timeout**: Requisições com timeout de 10 segundos
- **API indisponível**: Detecta status 503 e informa ao usuário
- **Respostas inválidas**: Valida se a resposta é um número válido
- **Erros de rede**: Trata problemas de conectividade

## Exemplo de Uso

### Input
\`\`\`json
{
  "min": 1,
  "max": 100
}
\`\`\`

### Output
\`\`\`json
{
  "randomNumber": 42,
  "min": 1,
  "max": 100,
  "timestamp": "2024-09-24T12:00:00.000Z",
  "source": "Random.org"
}
\`\`\`

## Desenvolvimento

### Adicionando novas funcionalidades

1. Modifique o arquivo `src/nodes/Random/Random.node.ts`
2. Execute `npm run build`
3. Copie os arquivos para `custom-nodes/`
4. Reinicie o n8n: `docker-compose restart n8n`

### Debugging

Para debug, você pode:
1. Verificar logs do n8n: `docker-compose logs n8n`
2. Verificar logs do PostgreSQL: `docker-compose logs postgres`
3. Usar o console do navegador para erros de frontend

## Troubleshooting

### Problema: Custom node não aparece na lista

**Solução:**
1. Verifique se os arquivos estão em `custom-nodes/`
2. Reinicie o n8n: `docker-compose restart n8n`
3. Verifique os logs: `docker-compose logs n8n`

### Problema: Erro "Random.org API timeout"

**Solução:**
1. Verifique sua conexão com a internet
2. Tente novamente após alguns segundos
3. A API do Random.org pode estar temporariamente indisponível

### Problema: Erro de build do TypeScript

**Solução:**
1. Verifique se o Node.js 22 está instalado: `node --version`
2. Limpe e reinstale dependências: `rm -rf node_modules package-lock.json && npm install`
3. Execute o build novamente: `npm run build`

## Tecnologias Utilizadas

- **Node.js 22** - Runtime JavaScript
- **TypeScript** - Linguagem tipada
- **n8n** - Plataforma de automação
- **Docker** - Containerização
- **PostgreSQL** - Banco de dados
- **Jest** - Framework de testes
- **Axios** - Cliente HTTP
- **ESLint** - Linting
- **Prettier** - Formatação de código

## Autor

**Gabriel Soares**
- Email: gabrielsoaresreis2004@gmail.com
- GitHub: [@gabrielsoaresreis2004](https://github.com/gabrielsoaresreis2004)

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Agradecimentos

- Equipe Onfly pelo desafio técnico
- Comunidade n8n pela documentação
- Random.org pela API gratuita de números aleatórios
