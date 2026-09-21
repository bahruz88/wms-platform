# WMS — Satınalma və Anbar İdarəetmə Platforması
#
#   make help            bütün target-lərin siyahısı
#
# Bu Makefile skriptlərin üstündə nazik qabıqdır: həqiqi məntiq `scripts/*.sh` və
# `deploy/docker-compose.yml`-dədir (docs/CONVENTIONS.md). Portlar və parollar
# `deploy/.env` faylından gəlir (`deploy/.env.example`-dən kopyalayın).
#
# .NET SDK lokal quraşdırılmayıbsa backend target-ləri avtomatik Docker-ə keçir.

SHELL := /bin/bash
.DEFAULT_GOAL := help

ROOT_DIR      := $(CURDIR)
BACKEND_DIR   := $(ROOT_DIR)/backend
FRONTEND_DIR  := $(ROOT_DIR)/frontend
CONTRACTS_DIR := $(ROOT_DIR)/contracts
COMPOSE_FILE  := deploy/docker-compose.yml

# --- toolchain detection ------------------------------------------------------------
# Lokal dotnet varsa birbaşa, yoxsa SDK konteynerində işlədirik. Konteynerdə NuGet keşi
# host-da saxlanılır ki, hər çağırışda yenidən endirilməsin.
DOTNET_LOCAL    := $(shell command -v dotnet 2>/dev/null)
DOTNET_SDK_IMAGE ?= mcr.microsoft.com/dotnet/sdk:10.0
DOTNET_DOCKER   := docker run --rm -t \
                     -v "$(BACKEND_DIR)":/src \
                     -v "$(HOME)/.nuget/packages":/root/.nuget/packages \
                     -w /src \
                     -e DOTNET_NOLOGO=1 -e DOTNET_CLI_TELEMETRY_OPTOUT=1 \
                     $(DOTNET_SDK_IMAGE) dotnet
ifeq ($(DOTNET_LOCAL),)
  DOTNET     := $(DOTNET_DOCKER)
  DOTNET_HOW := docker ($(DOTNET_SDK_IMAGE))
else
  DOTNET     := cd "$(BACKEND_DIR)" && dotnet
  DOTNET_HOW := local ($(DOTNET_LOCAL))
endif

FLUTTER ?= flutter
DART    ?= dart

REDOCLY_IMAGE ?= redocly/cli:latest
KUSTOMIZE_IMAGE ?= registry.k8s.io/kustomize/kustomize:v5.4.3

# Dev dart-define dəyərləri — deploy/.env-dəki portlarla uzlaşdırılıb.
API_BASE_URL     ?= http://localhost:5001
KEYCLOAK_ISSUER  ?= http://localhost:8180/realms/wms

# `make backend-run MODULES=inventory`
MODULES ?= *
# `make k8s-build OVERLAY=prod`
OVERLAY ?= dev

.PHONY: help up down logs migrate backend-build backend-test backend-run \
        frontend-get frontend-analyze frontend-test web-run mobile-run \
        gen-client lint-contracts k8s-build doctor

## help: bu siyahını göstər
help:
	@echo "WMS — make target-ləri"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed -E 's/^## ([a-z-]+): /\1\t/' \
	  | awk -F'\t' '{printf "  \033[1m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  .NET:    $(DOTNET_HOW)"
	@echo "  API:     $(API_BASE_URL)   Keycloak: $(KEYCLOAK_ISSUER)"
	@echo "  Portlar: deploy/.env (nümunə: deploy/.env.example)"

# =====================================================================================
# Dev infrastruktur
# =====================================================================================

## up: dev infrastrukturunu qaldır (mysql, redis, rabbitmq, minio, keycloak, seq)
up:
	scripts/dev-up.sh

## down: dev stack-i dayandır (data qalır; silmək üçün: scripts/dev-down.sh --volumes)
down:
	scripts/dev-down.sh

## logs: stack loglarını izlə (məs: make logs SERVICES="keycloak mysql")
logs:
	scripts/dev-logs.sh $(SERVICES)

## migrate: EF miqrasiyalarını işlət (ayrıca migrator konteyneri — startup-da YOX)
migrate:
	scripts/db-migrate.sh

# =====================================================================================
# Backend (.NET 10)
# =====================================================================================

## backend-build: solution-u build et (xəbərdarlıqlar xətadır)
backend-build:
	$(DOTNET) build Wms.slnx --configuration Release -warnaserror

## backend-test: unit + arxitektura + integration testləri (Testcontainers üçün Docker lazımdır)
backend-test:
	$(DOTNET) test Wms.slnx --configuration Release --logger "trx;LogFileName=tests.trx"

## backend-run: API host-u işlət — make backend-run MODULES=inventory (default: *)
backend-run:
ifeq ($(DOTNET_LOCAL),)
	@echo "Lokal .NET SDK yoxdur → API konteynerdə qalxır (Modules=$(MODULES))."
	@echo "Dev compose-da modul bölgüsü servis başına sabitdir (deploy/docker-compose.yml)."
	@svc=$$(case '$(MODULES)' in \
	    identity)              echo wms-identity ;; \
	    masterdata*|documents) echo wms-masterdata ;; \
	    inventory)             echo wms-inventory ;; \
	    procurement)           echo wms-procurement ;; \
	    reporting)             echo wms-reporting ;; \
	    notification|integration) echo wms-worker ;; \
	    '*')                   echo '' ;; \
	    *) echo "UNKNOWN" ;; \
	  esac); \
	if [ "$$svc" = "UNKNOWN" ]; then \
	  echo "Bilinməyən MODULES='$(MODULES)'. Dəyərlər: identity | masterdata | inventory |"; \
	  echo "procurement | reporting | notification | integration | *"; exit 2; \
	fi; \
	if [ -z "$$svc" ]; then \
	  echo "Modules=* → bütün 'app' servisləri (gateway + modullar + worker)."; \
	  docker compose --project-directory deploy -f $(COMPOSE_FILE) --profile app up --build; \
	else \
	  echo "→ compose servisi: $$svc"; \
	  docker compose --project-directory deploy -f $(COMPOSE_FILE) --profile app up --build gateway "$$svc"; \
	fi
else
	cd "$(BACKEND_DIR)/src/Host/Wms.Host.Api" && \
	  dotnet run --project Wms.Host.Api.csproj -- --Modules=$(MODULES)
endif

# =====================================================================================
# Frontend (Flutter 3.47 / Dart 3.13, pub workspace)
# =====================================================================================

## frontend-get: pub workspace asılılıqlarını bağla (kökdə bir dəfə)
frontend-get:
	cd "$(FRONTEND_DIR)" && $(FLUTTER) pub get

## frontend-analyze: bütün paketlər üzrə statik analiz
frontend-analyze:
	cd "$(FRONTEND_DIR)" && $(FLUTTER) analyze --no-pub

## frontend-test: test qovluğu olan hər paket/tətbiq üçün testlər (melos)
frontend-test:
	cd "$(FRONTEND_DIR)" && $(DART) run melos run test

## web-run: wms_web-i Chrome-da işlət (port 3001)
web-run:
	cd "$(FRONTEND_DIR)/apps/wms_web" && $(FLUTTER) run -d chrome --web-port 3001 \
	  --dart-define=API_BASE_URL=$(API_BASE_URL) \
	  --dart-define=KEYCLOAK_ISSUER=$(KEYCLOAK_ISSUER) \
	  --dart-define=KEYCLOAK_CLIENT_ID=wms-web

## mobile-run: wms_mobile-i qoşulmuş cihazda/emulyatorda işlət
mobile-run:
	cd "$(FRONTEND_DIR)/apps/wms_mobile" && $(FLUTTER) run \
	  --dart-define=API_BASE_URL=$(API_BASE_URL) \
	  --dart-define=KEYCLOAK_ISSUER=$(KEYCLOAK_ISSUER) \
	  --dart-define=KEYCLOAK_CLIENT_ID=wms-mobile

# =====================================================================================
# Kontraktlar və deployment
# =====================================================================================

## gen-client: OpenAPI → Dart (dart-dio) client generasiyası + build_runner
gen-client:
	scripts/gen-client.sh
	cd "$(FRONTEND_DIR)" && $(DART) run melos run gen

## lint-contracts: redocly lint + openapi-generator validate (hamısı Docker-də)
lint-contracts:
	docker run --rm -v "$(CONTRACTS_DIR)":/spec $(REDOCLY_IMAGE) lint \
	  --config /spec/redocly.yaml \
	  /spec/openapi/common.v1.yaml \
	  /spec/openapi/identity.v1.yaml \
	  /spec/openapi/masterdata.v1.yaml \
	  /spec/openapi/inventory.v1.yaml \
	  /spec/openapi/procurement.v1.yaml \
	  /spec/openapi/documents.v1.yaml \
	  /spec/openapi/notifications.v1.yaml \
	  /spec/openapi/reporting.v1.yaml
	@for m in identity masterdata inventory procurement documents notifications reporting; do \
	  echo "--- validate $$m"; \
	  docker run --rm -v "$(CONTRACTS_DIR)":/spec \
	    openapitools/openapi-generator-cli:latest validate -i /spec/openapi/$$m.v1.yaml || exit 1; \
	done

## k8s-build: kustomize overlay-i render et — make k8s-build OVERLAY=prod
k8s-build:
	docker run --rm -v "$(ROOT_DIR)/deploy/k8s":/k8s -w /k8s/overlays/$(OVERLAY) \
	  $(KUSTOMIZE_IMAGE) build .

## doctor: alətlərin mövcudluğunu yoxla
doctor:
	@echo "docker:   $$(docker --version 2>/dev/null || echo 'YOXDUR — məcburidir')"
	@echo "dotnet:   $(if $(DOTNET_LOCAL),$(shell dotnet --version 2>/dev/null) ($(DOTNET_LOCAL)),yoxdur → Docker SDK image: $(DOTNET_SDK_IMAGE))"
	@echo "flutter:  $$($(FLUTTER) --version 2>/dev/null | head -1 || echo 'YOXDUR')"
	@echo "dart:     $$($(DART) --version 2>&1 | head -1 || echo 'YOXDUR')"
	@echo "env:      $$([ -f deploy/.env ] && echo 'deploy/.env var' || echo 'deploy/.env YOXDUR — cp deploy/.env.example deploy/.env')"
