#!/bin/bash

# Script para build e deploy do custom node

set -e

echo "🔨 Fazendo build do custom node..."

# Limpar build anterior
rm -rf dist/
rm -rf custom-nodes/

# Build do TypeScript
npm run build

# Criar pasta de custom nodes
mkdir -p custom-nodes

# Copiar arquivos
cp -r dist/* custom-nodes/
cp package.json custom-nodes/

echo "✅ Build concluído!"

# Verificar se o n8n está rodando
if docker-compose ps | grep -q "n8n.*Up"; then
    echo "🔄 Reiniciando n8n para carregar o custom node..."
    docker-compose restart n8n
    
    echo "⏳ Aguardando n8n inicializar..."
    sleep 10
    
    echo "✅ n8n reiniciado com sucesso!"
    echo "🌐 Acesse: http://localhost:5678"
else
    echo "⚠️  n8n não está rodando. Execute: docker-compose up -d"
fi
