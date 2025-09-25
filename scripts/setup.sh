#!/bin/bash

# Onfly n8n Challenge - Setup Script
# Este script automatiza a configuração inicial do projeto

set -e

echo "🚀 Iniciando setup do projeto Onfly n8n Challenge..."

# Verificar se Node.js 22 está instalado
echo "📋 Verificando pré-requisitos..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 22 (LTS)"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo "❌ Node.js versão $NODE_VERSION encontrada. É necessário Node.js 22 ou superior"
    exit 1
fi

echo "✅ Node.js $(node -v) encontrado"

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Por favor, instale Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não encontrado. Por favor, instale Docker Compose"
    exit 1
fi

echo "✅ Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1) encontrado"
echo "✅ Docker Compose $(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1) encontrado"

# Instalar dependências
echo "📦 Instalando dependências..."
npm ci

# Build do projeto
echo "🔨 Fazendo build do projeto..."
npm run build

# Criar pasta de custom nodes
echo "📁 Configurando pasta de custom nodes..."
mkdir -p custom-nodes

# Copiar arquivos para pasta de custom nodes
echo "📋 Copiando arquivos para pasta de custom nodes..."
cp -r dist/* custom-nodes/
cp package.json custom-nodes/

# Verificar se os arquivos foram copiados corretamente
if [ ! -f "custom-nodes/package.json" ]; then
    echo "❌ Erro ao copiar arquivos para pasta de custom nodes"
    exit 1
fi

echo "✅ Arquivos copiados com sucesso"

# Executar testes
echo "🧪 Executando testes..."
npm test

echo "🎉 Setup concluído com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "1. Execute: docker-compose up -d"
echo "2. Acesse: http://localhost:5678"
echo "3. Use as credenciais: admin / admin123"
echo "4. Procure pelo node 'Random' na lista de nodes"
echo ""
echo "📚 Para mais informações, consulte o README.md"
