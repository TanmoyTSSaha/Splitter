# Splitr monorepo — essential commands.
# Unix/macOS/WSL: make help
# Windows without GNU Make: .\make.ps1 help

MOBILE_DIR := apps/mobile
WEB_DIR := apps/web

.DEFAULT_GOAL := help

.PHONY: help check check-web mobile-get mobile-analyze mobile-test mobile-build-aab mobile-brand-assets mobile-run web-install web-dev web-build web-dev-npm web-build-npm web-lint-npm supabase-deploy-preview-invite

help:
	@echo "Splitr monorepo commands:"
	@echo "  make mobile-get         - flutter pub get (apps/mobile)"
	@echo "  make mobile-analyze     - flutter analyze (apps/mobile)"
	@echo "  make mobile-test        - flutter test (apps/mobile)"
	@echo "  make mobile-build-aab   - Play Store release AAB (prod env, obfuscate, signed)"
	@echo "  make mobile-brand-assets - regenerate launcher icons + native splash"
	@echo "  make mobile-run         - flutter run (picker) or DEVICE=<id> make mobile-run"
	@echo "  make web-install        - pnpm install (repo root)"
	@echo "  make web-dev            - pnpm --filter web dev"
	@echo "  make web-build          - pnpm --filter web build"
	@echo "  make web-dev-npm        - npm run dev (apps/web)"
	@echo "  make web-build-npm      - npm run build (apps/web)"
	@echo "  make web-lint-npm       - npm run lint (apps/web)"
	@echo "  make check              - mobile-analyze + mobile-test + web-build"
	@echo "  make check-web          - npm lint + build (apps/web)"
	@echo "  make supabase-deploy-preview-invite - deploy preview-invite edge function"

mobile-get:
	cd $(MOBILE_DIR) && flutter pub get

mobile-analyze:
	cd $(MOBILE_DIR) && flutter analyze

mobile-test:
	cd $(MOBILE_DIR) && flutter test

mobile-brand-assets:
	cd $(MOBILE_DIR) && dart run flutter_launcher_icons && dart run flutter_native_splash:create

ifeq ($(OS),Windows_NT)
mobile-build-aab:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/mobile-build-aab.ps1
else
mobile-build-aab:
	bash scripts/mobile-build-aab.sh
endif

ifeq ($(OS),Windows_NT)
mobile-run:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/mobile-run.ps1 "$(DEVICE)"
else
mobile-run:
	bash scripts/mobile-run.sh "$(DEVICE)"
endif

web-install:
	pnpm install

web-dev:
	pnpm --filter web dev

web-build:
	pnpm --filter web build

web-dev-npm:
	cd $(WEB_DIR) && npm run dev

web-build-npm:
	cd $(WEB_DIR) && npm run build

web-lint-npm:
	cd $(WEB_DIR) && npm run lint

check: mobile-analyze mobile-test web-build

check-web:
	cd $(WEB_DIR) && npm run lint && npm run build

supabase-deploy-preview-invite:
	npm run supabase:deploy-preview-invite
