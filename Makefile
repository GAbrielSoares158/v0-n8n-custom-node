# Makefile para automação de tarefas do projeto

.PHONY: help install build test lint format clean setup start stop restart logs deploy

# Variáveis
NODE_VERSION := 22
DOCKER_COMPOSE := docker-compose
NPM := npm

# Ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  install     - Instalar dependências"
	@echo "  build       - Build do projeto"
	@echo "  test        - Executar testes"
	@echo "  lint        - Executar linting"
	@echo "  format      - Formatar código"
	@echo "  clean       - Limpar arquivos de build"
	@echo "  setup       - Setup completo do projeto"
	@echo "  start       - Iniciar serviços Docker"
	@echo "  stop        - Parar serviços Docker"
	@echo "  restart     - Reiniciar serviços Docker"
	@echo "  logs        - Ver logs dos serviços"
	@echo "  deploy      - Build e deploy do custom node"

# Instalar dependências
install:
	@echo "📦 Instalando dependências..."
	$(NPM) ci

# Build do projeto
build:
	@echo "🔨 Fazendo build do projeto..."
	$(NPM) run build

# Executar testes
test:
	@echo "🧪 Executando testes..."
	$(NPM) test

# Executar testes com cobertura
test-coverage:
	@echo "🧪 Executando testes com cobertura..."
	$(NPM) test -- --coverage

# Linting
lint:
	@echo "🔍 Executando linting..."
	$(NPM) run lint

# Correção automática de lint
lint-fix:
	@echo "🔧 Corrigindo problemas de lint..."
	$(NPM) run lintfix

# Formatação de código
format:
	@echo "✨ Formatando código..."
	$(NPM) run format

# Limpar arquivos de build
clean:
	@echo "🧹 Limpando arquivos de build..."
	rm -rf dist/
	rm -rf custom-nodes/
	rm -rf coverage/
	rm -rf node_modules/

# Setup completo
setup: install build test
	@echo "📁 Configurando pasta de custom nodes..."
	mkdir -p custom-nodes
	cp -r dist/* custom-nodes/
	cp package.json custom-nodes/
	@echo "🎉 Setup concluído!"

# Iniciar serviços Docker
start:
	@echo "🚀 Iniciando serviços..."
	$(DOCKER_COMPOSE) up -d
	@echo "⏳ Aguardando serviços inicializarem..."
	sleep 10
	@echo "✅ Serviços iniciados!"
	@echo "🌐 n8n disponível em: http://localhost:5678"

# Parar serviços Docker
stop:
	@echo "🛑 Parando serviços..."
	$(DOCKER_COMPOSE) down

# Reiniciar serviços Docker
restart:
	@echo "🔄 Reiniciando serviços..."
	$(DOCKER_COMPOSE) restart

# Ver logs dos serviços
logs:
	@echo "📋 Logs dos serviços:"
	$(DOCKER_COMPOSE) logs -f

# Ver logs apenas do n8n
logs-n8n:
	@echo "📋 Logs do n8n:"
	$(DOCKER_COMPOSE) logs -f n8n

# Ver logs apenas do PostgreSQL
logs-postgres:
	@echo "📋 Logs do PostgreSQL:"
	$(DOCKER_COMPOSE) logs -f postgres

# Build e deploy do custom node
deploy: build
	@echo "📋 Fazendo deploy do custom node..."
	rm -rf custom-nodes/
	mkdir -p custom-nodes
	cp -r dist/* custom-nodes/
	cp package.json custom-nodes/
	@if $(DOCKER_COMPOSE) ps | grep -q "n8n.*Up"; then \
		echo "🔄 Reiniciando n8n..."; \
		$(DOCKER_COMPOSE) restart n8n; \
		echo "✅ Deploy concluído!"; \
	else \
		echo "⚠️  n8n não está rodando. Execute: make start"; \
	fi

# Verificar saúde dos serviços
health:
	@echo "🏥 Verificando saúde dos serviços..."
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "🌐 Testando n8n..."
	@curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:5678 || echo "❌ n8n não está respondendo"

# Backup dos dados
backup:
	@echo "💾 Fazendo backup dos dados..."
	@mkdir -p backups
	@$(DOCKER_COMPOSE) exec postgres pg_dump -U n8n n8n > backups/n8n_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup salvo em backups/"

# Restaurar backup
restore:
	@echo "📥 Para restaurar um backup, execute:"
	@echo "docker-compose exec -T postgres psql -U n8n -d n8n < backups/[arquivo_backup].sql"

# Desenvolvimento
dev: install
	@echo "🔧 Iniciando modo de desenvolvimento..."
	$(NPM) run dev

# CI/CD
ci: install lint test build
	@echo "✅ Pipeline CI passou!"

# Informações do projeto
info:
	@echo "📋 Informações do projeto:"
	@echo "Node.js: $(shell node --version)"
	@echo "npm: $(shell npm --version)"
	@echo "Docker: $(shell docker --version)"
	@echo "Docker Compose: $(shell docker-compose --version)"
	@echo "Projeto: $(shell cat package.json | grep '"name"' | cut -d'"' -f4)"
	@echo "Versão: $(shell cat package.json | grep '"version"' | cut -d'"' -f4)"
