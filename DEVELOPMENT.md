# Guia de Desenvolvimento

Este documento contém informações detalhadas para desenvolvedores que desejam contribuir ou modificar o custom node.

## Arquitetura do Projeto

### Estrutura de Classes

\`\`\`typescript
// Classe principal do custom node
class Random implements INodeType {
  description: INodeTypeDescription;
  execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]>;
}

// Cliente para API do Random.org
class RandomOrgClient {
  static generateRandomNumber(min: number, max: number): Promise<number>;
  private static validateParameters(min: number, max: number): void;
  private static parseResponse(data: string): number;
  private static handleApiError(error: any): Error;
}
\`\`\`

### Fluxo de Execução

1. **Validação de Parâmetros**: Verifica se min ≤ max e se são inteiros
2. **Chamada da API**: Faz requisição HTTP para Random.org
3. **Processamento da Resposta**: Converte string para número
4. **Retorno dos Dados**: Formata resposta no padrão n8n

### Padrões de Código

#### Nomenclatura
- **Classes**: PascalCase (`RandomOrgClient`)
- **Métodos**: camelCase (`generateRandomNumber`)
- **Constantes**: UPPER_SNAKE_CASE (`BASE_URL`)
- **Interfaces**: PascalCase com prefixo I (`INodeType`)

#### Estrutura de Arquivos
\`\`\`
src/
├── nodes/           # Implementações dos custom nodes
├── utils/           # Utilitários e clientes de API
├── types/           # Definições de tipos TypeScript
├── __tests__/       # Testes unitários
└── index.ts         # Ponto de entrada
\`\`\`

## Configuração do Ambiente de Desenvolvimento

### 1. Setup Inicial

\`\`\`bash
# Clone e instale dependências
git clone <repo-url>
cd onfly-n8n-challenge
npm install

# Configure o ambiente de desenvolvimento
npm run dev  # TypeScript em modo watch
\`\`\`

### 2. Desenvolvimento com Hot Reload

\`\`\`bash
# Terminal 1: Build contínuo
npm run dev

# Terminal 2: Copiar arquivos automaticamente
watch -n 2 'npm run build && cp -r dist/* custom-nodes/ && cp package.json custom-nodes/'

# Terminal 3: n8n
docker-compose up n8n
\`\`\`

### 3. Debugging

#### Logs do n8n
\`\`\`bash
docker-compose logs -f n8n
\`\`\`

#### Debug do Custom Node
Adicione logs no código:
\`\`\`typescript
console.log('[DEBUG] Random node executed with params:', { min, max });
\`\`\`

## Testes

### Estrutura de Testes

\`\`\`typescript
describe('RandomOrgClient', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should generate random number successfully', async () => {
    // Arrange
    const mockResponse = { data: '42\n' };
    mockedAxios.get.mockResolvedValue(mockResponse);

    // Act
    const result = await RandomOrgClient.generateRandomNumber(1, 100);

    // Assert
    expect(result).toBe(42);
  });
});
\`\`\`

### Executando Testes

\`\`\`bash
# Todos os testes
npm test

# Testes específicos
npm test -- RandomOrgClient

# Com cobertura
npm test -- --coverage

# Modo watch
npm test -- --watch
\`\`\`

### Cobertura de Testes

O projeto mantém cobertura mínima de:
- **Statements**: 90%
- **Branches**: 85%
- **Functions**: 90%
- **Lines**: 90%

## Integração com n8n

### Estrutura do Node Description

\`\`\`typescript
description: INodeTypeDescription = {
  displayName: 'Random',           // Nome exibido na UI
  name: 'random',                  // Nome interno (lowercase)
  icon: 'file:icon.jpg',          // Ícone do node
  group: ['utility'],             // Categoria
  version: 1,                     // Versão do node
  subtitle: '={{$parameter["operation"]}}', // Subtítulo dinâmico
  description: 'Generate true random numbers', // Descrição
  defaults: { name: 'Random' },   // Valores padrão
  inputs: ['main'],               // Tipos de entrada
  outputs: ['main'],              // Tipos de saída
  properties: [...]               // Propriedades configuráveis
};
\`\`\`

### Propriedades Configuráveis

\`\`\`typescript
properties: [
  {
    displayName: 'Operation',      // Nome exibido
    name: 'operation',             // Nome interno
    type: 'options',               // Tipo do campo
    options: [...],                // Opções disponíveis
    default: 'generateRandomNumber', // Valor padrão
    required: true,                // Campo obrigatório
    description: 'Operation to perform', // Descrição
    displayOptions: {              // Condições de exibição
      show: { operation: ['generateRandomNumber'] }
    }
  }
]
\`\`\`

### Método Execute

\`\`\`typescript
async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
  const items = this.getInputData();
  const returnData: INodeExecutionData[] = [];

  for (let i = 0; i < items.length; i++) {
    try {
      // Obter parâmetros
      const min = this.getNodeParameter('min', i) as number;
      const max = this.getNodeParameter('max', i) as number;

      // Processar
      const result = await processData(min, max);

      // Retornar dados
      returnData.push({
        json: result,
        pairedItem: { item: i }
      });
    } catch (error) {
      // Tratamento de erro
      if (this.continueOnFail()) {
        returnData.push({
          json: { error: error.message },
          pairedItem: { item: i }
        });
        continue;
      }
      throw new NodeOperationError(this.getNode(), error.message);
    }
  }

  return [returnData];
}
\`\`\`

## API do Random.org

### Documentação da API

**Base URL**: `https://www.random.org/integers/`

**Parâmetros obrigatórios**:
- `num`: Quantidade de números (1-10000)
- `min`: Valor mínimo (-1000000000 a 1000000000)
- `max`: Valor máximo (-1000000000 a 1000000000)
- `col`: Número de colunas (1-1000)
- `base`: Base numérica (2, 8, 10, 16)
- `format`: Formato da resposta (plain, html)
- `rnd`: Tipo de aleatoriedade (new, id.identifier)

### Limites da API

- **Quota diária**: 1.000.000 bits por IP
- **Rate limit**: Não especificado oficialmente
- **Timeout recomendado**: 10 segundos
- **User-Agent**: Recomendado para identificação

### Tratamento de Respostas

\`\`\`typescript
// Resposta de sucesso
"42\n"

// Resposta de erro (HTML)
"<html>Error: ...</html>"

// Status codes importantes
200: Sucesso
400: Parâmetros inválidos
503: Serviço indisponível
\`\`\`

## Deployment

### Build para Produção

\`\`\`bash
# Build otimizado
npm run build

# Verificar arquivos gerados
ls -la dist/

# Copiar para pasta de custom nodes
cp -r dist/* custom-nodes/
cp package.json custom-nodes/
\`\`\`

### Docker Build

\`\`\`bash
# Build da imagem
docker build -t n8n-random-node .

# Executar container
docker run -v $(pwd)/output:/output n8n-random-node
\`\`\`

### Publicação no npm

\`\`\`bash
# Preparar para publicação
npm run prepublishOnly

# Publicar (se for um pacote público)
npm publish
\`\`\`

## Troubleshooting de Desenvolvimento

### Problema: TypeScript não compila

\`\`\`bash
# Verificar versão do TypeScript
npx tsc --version

# Limpar cache
rm -rf dist/ node_modules/
npm install
npm run build
\`\`\`

### Problema: Custom node não carrega

1. Verificar estrutura de arquivos em `custom-nodes/`
2. Verificar logs do n8n
3. Verificar se o `package.json` está presente
4. Reiniciar o n8n

### Problema: Testes falhando

\`\`\`bash
# Limpar cache do Jest
npx jest --clearCache

# Executar testes em modo verbose
npm test -- --verbose

# Executar teste específico
npm test -- --testNamePattern="should generate random number"
\`\`\`

## Contribuindo

### Processo de Contribuição

1. **Fork** do repositório
2. **Branch** para feature: `git checkout -b feature/nova-funcionalidade`
3. **Commit** das mudanças: `git commit -m 'Add: nova funcionalidade'`
4. **Push** para branch: `git push origin feature/nova-funcionalidade`
5. **Pull Request** com descrição detalhada

### Padrões de Commit

\`\`\`
feat: adiciona nova funcionalidade
fix: corrige bug
docs: atualiza documentação
style: mudanças de formatação
refactor: refatoração de código
test: adiciona ou modifica testes
chore: tarefas de manutenção
\`\`\`

### Code Review

Todos os PRs devem:
- Passar nos testes automatizados
- Manter cobertura de testes > 85%
- Seguir padrões de código (ESLint)
- Incluir documentação atualizada
- Ser revisados por pelo menos 1 pessoa
