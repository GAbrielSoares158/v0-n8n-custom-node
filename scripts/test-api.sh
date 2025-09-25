#!/bin/bash

# Script para testar a API do Random.org

echo "🧪 Testando API do Random.org..."

# Teste básico
echo "📋 Teste 1: Número entre 1 e 100"
RESPONSE=$(curl -s "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new")
echo "Resposta: $RESPONSE"

if [[ "$RESPONSE" =~ ^[0-9]+$ ]] && [ "$RESPONSE" -ge 1 ] && [ "$RESPONSE" -le 100 ]; then
    echo "✅ Teste 1 passou"
else
    echo "❌ Teste 1 falhou"
    exit 1
fi

# Teste com números negativos
echo "📋 Teste 2: Número entre -50 e 50"
RESPONSE=$(curl -s "https://www.random.org/integers/?num=1&min=-50&max=50&col=1&base=10&format=plain&rnd=new")
echo "Resposta: $RESPONSE"

if [[ "$RESPONSE" =~ ^-?[0-9]+$ ]] && [ "$RESPONSE" -ge -50 ] && [ "$RESPONSE" -le 50 ]; then
    echo "✅ Teste 2 passou"
else
    echo "❌ Teste 2 falhou"
    exit 1
fi

# Teste com números grandes
echo "📋 Teste 3: Número entre 1000000 e 2000000"
RESPONSE=$(curl -s "https://www.random.org/integers/?num=1&min=1000000&max=2000000&col=1&base=10&format=plain&rnd=new")
echo "Resposta: $RESPONSE"

if [[ "$RESPONSE" =~ ^[0-9]+$ ]] && [ "$RESPONSE" -ge 1000000 ] && [ "$RESPONSE" -le 2000000 ]; then
    echo "✅ Teste 3 passou"
else
    echo "❌ Teste 3 falhou"
    exit 1
fi

echo "🎉 Todos os testes da API passaram!"
