.DEFAULT_GOAL := help

## ------------------ VARIÁVEIS DE CONFIGURAÇÃO ------------------

# Para 'assets'
ASSETS_DIR := assets
OUTPUT_FILE := lib/shared/generated/assets.dart

# Para 'module' (o nome é passado via comando, ex: make module n=home)
MODULE_NAME=${n}

# Para 'build' (pode ser sobrescrito, ex: make build env=prd)
env ?= dev

# Para 'setup' (ex: make setup bundle=com.meuapp.legal name="Meu App Legal")
bundle ?=
name ?=

# -------------------------------------------------------------------
#  !! CONFIGURAÇÃO DO TEMPLATE !!
# O Makefile irá LER e ATUALIZAR o arquivo 'template.config'
# -------------------------------------------------------------------
CONFIG_FILE := template.config

# Tenta incluir a configuração; se não existir, usa os padrões abaixo
-include $(CONFIG_FILE)

# Define os padrões INICIAIS se 'template.config' não existir
OLD_PROJECT_NAME     ?= template_app
OLD_PACKAGE          ?= com.example.template_app
OLD_IOS_BUNDLE       ?= com.example.templateApp
OLD_DISPLAY_NAME     ?= Template App
OLD_IOS_DISPLAY_NAME ?= App
# -------------------------------------------------------------------


## ------------------ COMANDOS DO PROJETO ------------------

.PHONY: clean assets module watch build bundle setup help

.PHONY: setup
setup:
	# 1. Validar inputs
	@if [ -z "$(bundle)" ]; then \
		echo "❌ Erro: 'bundle' (identificador) é obrigatório."; \
		echo "   Exemplo: make setup bundle=com.meuapp.legal name=\"Meu App Legal\""; \
		exit 1; \
	fi
	@if [ -z "$(name)" ]; then \
		echo "❌ Erro: 'name' (nome de exibição) é obrigatório."; \
		echo "   Exemplo: make setup bundle=com.meuapp.legal name=\"Meu App Legal\""; \
		exit 1; \
	fi
	
	# --- 2. Definir Variáveis Antigas (lidas da config ou padrões) ---
	$(eval OLD_ANDROID_PATH_DIR := android/app/src/main/kotlin/$(shell echo $(OLD_PACKAGE) | sed 's/\./\//g'))
	$(eval OLD_ANDROID_FILE_PATH := $(OLD_ANDROID_PATH_DIR)/MainActivity.kt)
	$(eval OLD_DISPLAY_NAME_PRD := $(OLD_DISPLAY_NAME))
	$(eval OLD_DISPLAY_NAME_HOM := $(OLD_DISPLAY_NAME) - Homologação)
	$(eval OLD_DISPLAY_NAME_DEV := $(OLD_DISPLAY_NAME) - Desenvolvimento)

	# --- 3. Definir Novas Variáveis (calculadas a partir dos inputs) ---
	$(eval NEW_BUNDLE := $(bundle))
	$(eval NEW_DISPLAY_NAME := $(name))
	$(eval NEW_PROJECT_NAME := $(shell echo $(NEW_BUNDLE) | awk -F '.' '{print $$NF}'))
	$(eval NEW_ANDROID_PATH_DIR := android/app/src/main/kotlin/$(shell echo $(NEW_BUNDLE) | sed 's/\./\//g'))
	$(eval NEW_ANDROID_FILE_PATH := $(NEW_ANDROID_PATH_DIR)/MainActivity.kt)
	$(eval NEW_DISPLAY_NAME_PRD := $(NEW_DISPLAY_NAME))
	$(eval NEW_DISPLAY_NAME_HOM := $(NEW_DISPLAY_NAME) - Homologação)
	$(eval NEW_DISPLAY_NAME_DEV := $(NEW_DISPLAY_NAME) - Desenvolvimento)
	$(eval NEW_IOS_BUNDLE := $(shell echo "$(NEW_BUNDLE)" | awk -F '_' '{printf "%s", $$1; for(i=2;i<=NF;i++) printf "%s", toupper(substr($$i,1,1)) substr($$i,2)}'))


	@echo "🚀 Iniciando configuração do projeto..."
	@echo "   Lendo de '$(CONFIG_FILE)'..."
	@echo "   De (Nome):   $(OLD_PROJECT_NAME)"
	@echo "   Para (Nome): $(NEW_PROJECT_NAME)"
	@echo "---"
	@echo "   De (Android):   $(OLD_PACKAGE)"
	@echo "   Para (Android): $(NEW_BUNDLE)"
	@echo "---"
	@echo "   De (iOS):   $(OLD_IOS_BUNDLE)"
	@echo "   Para (iOS): $(NEW_IOS_BUNDLE)"
	@echo "---"
	@echo "   De (Display Genérico):   '$(OLD_DISPLAY_NAME)'"
	@echo "   De (Display iOS):        '$(OLD_IOS_DISPLAY_NAME)'"
	@echo "   Para (Display):          '$(NEW_DISPLAY_NAME)'"
	@echo "---"

	# 4. Renomear no pubspec.yaml
	@sed -i '' "s/name: $(OLD_PROJECT_NAME)/name: $(NEW_PROJECT_NAME)/g" pubspec.yaml
	@echo "✅ pubspec.yaml atualizado."

	# 5. Renomear no README.md
	@sed -i '' "s/# $(OLD_PROJECT_NAME)/# $(NEW_PROJECT_NAME)/g" README.md
	@echo "✅ README.md atualizado."

	# 6. Renomear no build.gradle.kts
	@sed -i '' "s/$(OLD_PACKAGE)/$(NEW_BUNDLE)/g" android/app/build.gradle.kts
	@sed -i '' "s#resValue(\"string\", \"app_name\", \"$(OLD_DISPLAY_NAME_PRD)\")#resValue(\"string\", \"app_name\", \"$(NEW_DISPLAY_NAME_PRD)\")#g" android/app/build.gradle.kts
	@sed -i '' "s#resValue(\"string\", \"app_name\", \"$(OLD_DISPLAY_NAME_HOM)\")#resValue(\"string\", \"app_name\", \"$(NEW_DISPLAY_NAME_HOM)\")#g" android/app/build.gradle.kts
	@sed -i '' "s#resValue(\"string\", \"app_name\", \"$(OLD_DISPLAY_NAME_DEV)\")#resValue(\"string\", \"app_name\", \"$(NEW_DISPLAY_NAME_DEV)\")#g" android/app/build.gradle.kts
	@echo "✅ android/app/build.gradle.kts atualizado."

	# 7. Renomear no Info.plist
	@sed -i '' "s#<string>$(OLD_PROJECT_NAME)</string>#<string>$(NEW_PROJECT_NAME)</string>#g" ios/Runner/Info.plist
	@sed -i '' "s#<string>$(OLD_IOS_DISPLAY_NAME)</string>#<string>$(NEW_DISPLAY_NAME)</string>#g" ios/Runner/Info.plist
	@echo "✅ ios/Runner/Info.plist atualizado."

	# 8. Renomear title no UiConfig.dart
	@sed -i '' "s/static String get title => '$(OLD_DISPLAY_NAME)';/static String get title => '$(NEW_DISPLAY_NAME)';/g" lib/shared/ui/ui_config.dart
	@echo "✅ lib/shared/ui/ui_config.dart atualizado."

	# 9. Renomear pacote no MainActivity.kt
	@sed -i '' "s/package $(OLD_PACKAGE)/package $(NEW_BUNDLE)/g" $(OLD_ANDROID_FILE_PATH)
	@echo "✅ Conteúdo do MainActivity.kt atualizado."

	# 10. Mover diretório do MainActivity
	@echo "   Movendo MainActivity..."
	@mkdir -p $(NEW_ANDROID_PATH_DIR)
	@mv $(OLD_ANDROID_FILE_PATH) $(NEW_ANDROID_FILE_PATH)
	@rmdir -p $(OLD_ANDROID_PATH_DIR) 2>/dev/null || true
	@echo "✅ Diretório Android movido para $(NEW_ANDROID_PATH_DIR)."

	# 11. Renomear Bundle ID no projeto iOS
	@sed -i '' "s/$(OLD_IOS_BUNDLE)/$(NEW_IOS_BUNDLE)/g" ios/Runner.xcodeproj/project.pbxproj
	@echo "✅ ios/Runner.xcodeproj/project.pbxproj atualizado."
	
	# --- PASSO FINAL: Atualizar o arquivo de configuração ---
	@echo "   Atualizando arquivo de configuração '$(CONFIG_FILE)'..."
	@echo "# ATENÇÃO: Arquivo gerado automaticamente. NÃO EDITE MANUALMENTE." > $(CONFIG_FILE)
	@echo "# Este arquivo armazena o estado atual do template para o 'make setup'." >> $(CONFIG_FILE)
	@echo "OLD_PROJECT_NAME     := $(NEW_PROJECT_NAME)" >> $(CONFIG_FILE)
	@echo "OLD_PACKAGE          := $(NEW_BUNDLE)" >> $(CONFIG_FILE)
	@echo "OLD_IOS_BUNDLE       := $(NEW_IOS_BUNDLE)" >> $(CONFIG_FILE)
	@echo "OLD_DISPLAY_NAME     := $(NEW_DISPLAY_NAME)" >> $(CONFIG_FILE)
	@echo "OLD_IOS_DISPLAY_NAME := $(NEW_DISPLAY_NAME)" >> $(CONFIG_FILE)
	@echo "✅ Arquivo de configuração salvo."
	
	@echo ""
	@echo "🎉 Setup concluído! O script está pronto para ser executado novamente se necessário."

clean:
	@echo "🧹 Limpando o projeto e buscando dependências..."
	@flutter clean && flutter pub get
	@echo "✅ Limpeza concluída."

.PHONY: assets
assets:
	@echo "🔍 Buscando assets em '$(ASSETS_DIR)' (ignorando a pasta 'fonts')..."
	@rm -f $(OUTPUT_FILE)
	@mkdir -p $(dir $(OUTPUT_FILE))
	@echo "// ATENÇÃO: Este arquivo é gerado automaticamente. Não edite manualmente." > $(OUTPUT_FILE)
	@echo "// Para atualizar, execute: make assets" >> $(OUTPUT_FILE)
	@echo "" >> $(OUTPUT_FILE)
	@echo "class AppAssets {" >> $(OUTPUT_FILE)
	@find $(ASSETS_DIR) -type f -not -path "*/fonts/*" | sort | while read file; do \
		var_name=$$(echo "$$file" | sed -e 's|^$(ASSETS_DIR)/||' -e 's/\.[^.]*$$//' | awk 'BEGIN{FS="[/_-]"} {printf "%s", $$1; for(i=2;i<=NF;i++) printf "%s", toupper(substr($$i,1,1)) substr($$i,2)}'); \
		echo "  static const String $$var_name = '$$file';" >> $(OUTPUT_FILE); \
	done
	@echo "}" >> $(OUTPUT_FILE)
	@echo "✅ Arquivo de assets gerado com sucesso em '$(OUTPUT_FILE)'!"

.PHONY: module
module:
	@if [ -z "$(MODULE_NAME)" ]; then \
		echo "❌ Erro: Você precisa informar o nome do módulo."; \
		echo "   Exemplo: make module n=auth_login"; \
		exit 1; \
	fi
	
	@echo "🛠️  Criando módulo '$(MODULE_NAME)'..."
	
	$(eval MODULE_DIR := lib/modules/$(MODULE_NAME))
	$(eval CAPITAL_CAMEL_CASE := $(shell echo $(MODULE_NAME) | awk -F '_' '{for(i=1;i<=NF;i++){printf toupper(substr($$i,1,1)) tolower(substr($$i,2))}}'))
	$(eval LOWER_CAMEL_CASE := $(shell echo $(MODULE_NAME) | awk -F '_' '{printf tolower(substr($$1,1,1)) tolower(substr($$1,2)); for(i=2;i<=NF;i++){printf toupper(substr($$i,1,1)) tolower(substr($$i,2))}}'))

	@mkdir -p $(MODULE_DIR)/{controllers,repositories,widgets,mixins,dtos}
	
	@# Arquivo principal do módulo (barrel file)
	@echo "export 'controllers/controllers.dart';\nexport 'repositories/repositories.dart';\nexport 'mixins/mixins.dart';\nexport 'widgets/widgets.dart';\nexport 'dtos/dtos.dart';\nexport '$(MODULE_NAME)_page.dart';\nexport '$(MODULE_NAME)_module.dart';" > $(MODULE_DIR)/$(MODULE_NAME).dart

	@# Arquivos de barrel internos
	@echo "export '$(MODULE_NAME)_controller.dart';" > $(MODULE_DIR)/controllers/controllers.dart
	@echo "export '$(MODULE_NAME)_repository.dart';" > $(MODULE_DIR)/repositories/repositories.dart
	@echo "export '$(MODULE_NAME)_repository_impl.dart';" >> $(MODULE_DIR)/repositories/repositories.dart
	@echo "export '$(MODULE_NAME)_variables.dart';" > $(MODULE_DIR)/mixins/mixins.dart
	@touch $(MODULE_DIR)/widgets/widgets.dart
	@touch $(MODULE_DIR)/dtos/dtos.dart

	@# Arquivo de Mixin
	@echo "mixin $(CAPITAL_CAMEL_CASE)Variables {}" > $(MODULE_DIR)/mixins/$(MODULE_NAME)_variables.dart

	@# Arquivo do Controller
	@echo "import '../../../core/core.dart';\nimport '../$(MODULE_NAME).dart';\n\nclass $(CAPITAL_CAMEL_CASE)Controller with $(CAPITAL_CAMEL_CASE)Variables {\n  final $(CAPITAL_CAMEL_CASE)Repository _$(LOWER_CAMEL_CASE)Repository;\n\n  $(CAPITAL_CAMEL_CASE)Controller({\n    required $(CAPITAL_CAMEL_CASE)Repository $(LOWER_CAMEL_CASE)Repository,\n  }) : _$(LOWER_CAMEL_CASE)Repository = $(LOWER_CAMEL_CASE)Repository;\n}" > $(MODULE_DIR)/controllers/$(MODULE_NAME)_controller.dart

	@# Arquivo do Repository
	@echo "import '../../../core/core.dart';\nimport '../../$(MODULE_NAME)/$(MODULE_NAME).dart';\n\nabstract class $(CAPITAL_CAMEL_CASE)Repository {\n  \n}" > $(MODULE_DIR)/repositories/$(MODULE_NAME)_repository.dart

	@# Arquivo do Repository Impl
	@echo "import '../../../core/core.dart';\nimport '../../$(MODULE_NAME)/$(MODULE_NAME).dart';\n\nclass $(CAPITAL_CAMEL_CASE)RepositoryImpl extends RepositoryLifeCycle implements $(CAPITAL_CAMEL_CASE)Repository {\n  \n}" > $(MODULE_DIR)/repositories/$(MODULE_NAME)_repository_impl.dart

	@# Arquivo da Page
	@echo "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\n\nimport '../../core/core.dart';\nimport '$(MODULE_NAME).dart';\n\n class $(CAPITAL_CAMEL_CASE)Page extends StatelessWidget {\n  const $(CAPITAL_CAMEL_CASE)Page({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    final controller = context.read<$(CAPITAL_CAMEL_CASE)Controller>();\n    return const Scaffold(\n      body: Center(\n        child: Text('$(CAPITAL_CAMEL_CASE) Page'),\n      ),\n    );\n  }\n}" > $(MODULE_DIR)/$(MODULE_NAME)_page.dart

	@# NOVO: Arquivo do Module (ProviderModule)
	@echo "import 'package:provider/provider.dart';\n\
\n\
import '../../core/core.dart';\n\
import '$(MODULE_NAME).dart';\n\
\n\
class $(CAPITAL_CAMEL_CASE)Module extends ProviderModule {\n\
  static const String path = '/$(MODULE_NAME)'; // TODO: Se necessário, ajuste a rota.\n\
  $(CAPITAL_CAMEL_CASE)Module()\n\
    : super(\n\
        path: path,\n\
        page: const $(CAPITAL_CAMEL_CASE)Page(),\n\
        bindings: (_) => [\n\
          Provider(\n\
            create: (context) => $(CAPITAL_CAMEL_CASE)Controller(\n\
              $(LOWER_CAMEL_CASE)Repository: $(CAPITAL_CAMEL_CASE)RepositoryImpl(),\n\
              // TODO: Adicione outras dependências aqui, como o UserStore.\n\
              // userStore: context.read<UserStore>(),\n\
            ),\n\
          ),\n\
        ],\n\
      );\n\
}" > $(MODULE_DIR)/$(MODULE_NAME)_module.dart
	
	@# Adiciona a exportação no barrel principal de módulos
	@echo "export '$(MODULE_NAME)/$(MODULE_NAME).dart';" >> lib/modules/modules.dart
	
	@echo "✅ Módulo '$(MODULE_NAME)' criado com sucesso!"
	@git add .

.PHONY: watch
watch:
	@echo "🏃‍♂️ Iniciando o build_runner no modo watch (use Ctrl+C para parar)..."
	@fvm flutter pub run build_runner watch -d

.PHONY: build
build:
	@if [ "$(env)" != "dev" ] && [ "$(env)" != "hom" ] && [ "$(env)" != "prd" ]; then \
		echo "❌ Erro: O ambiente (env) deve ser 'dev', 'hom' ou 'prd'."; \
		echo "   Exemplo: make build env=prd"; \
		exit 1; \
	fi
	@echo "📦 Compilando APK para o ambiente: $(env)..."
	fvm flutter build apk --release --flavor $(env) --target lib/main_$(env).dart
	@echo "✅ Build para $(env) concluído!"

.PHONY: bundle
bundle:
	@echo "📦 Compilando App Bundle (AAB) para o ambiente de produção (prd)..."
	@fvm flutter build appbundle --release --flavor prd --target lib/main.dart
	@echo "✅ App Bundle para prd concluído!"

.PHONY: help
help:
	@echo "--------------------------------------------------"
	@echo "  Comandos disponíveis para o projeto:"
	@echo "--------------------------------------------------"
	@echo "  make setup bundle=<id> name=\"<nome>\"   Configura o projeto com um novo bundle id e nome."
	@echo "                                   Ex: make setup bundle=com.meuapp.legal name=\"Meu App Legal\""
	@echo "  make clean                         Limpa o projeto e busca as dependências."
	@echo "  make assets                        Gera o arquivo 'assets.dart' com base na pasta de assets."
	@echo "  make module n=<nome>               Cria a estrutura completa de um novo módulo."
	@echo "                                   Exemplo: make module n=auth_login"
	@echo "  make watch                         Inicia o build_runner em modo 'watch' para gerar arquivos."
	@echo "  make build [env=<env>]             Compila o APK para um ambiente (dev, hom, prd)."
	@echo "                                   Padrão: dev. Exemplo: make build env=prd"
	@echo "  make bundle                        Compila o App Bundle (AAB) para o ambiente de produção (prd)."
	@echo "--------------------------------------------------"
