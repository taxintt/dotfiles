.DEFAULT_GOAL := help

help: ## show description
	@echo "Command list:"
	@echo ""
	@printf "\033[36m%-30s\033[0m %-50s\n" "[Command]" "[Description]" ""
	@grep -E '^[/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | perl -pe 's%^([/a-zA-Z_-]+):.*?(##)%$$1 $$2%' | awk -F " *?## *?" '{printf "\033[36m%-30s\033[0m %-50s %s\n", $$1, $$2, $$3}'

brew: ## install from homebrew
	@echo "started to install by using BrewFile ..."
	if ! which brew > /dev/null 3>&1; then \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi && \
	brew bundle install --no-upgrade;

brew-dump: ## dump to Brewfile
	brew bundle dump -f

brew-install: ## install by using Brewfile
	brew bundle

brew-list-independent-packages: ## list independent packages
	brew list | xargs -I{} sh -c 'brew uses --installed {} | wc -l | xargs printf "%20s is used by %2d formulae.\n" {}'

link: ## make symlinks
	./scripts/link.sh

agmsg-install: ## install agmsg (cross-agent messaging)
	npx -y agmsg

gitleaks-scan: ## scan gitleaks for all ghq repos (redacted reports, written outside the scanned repos)
	@report_dir="$${TMPDIR:-/tmp}/gitleaks-reports"; \
	mkdir -p "$$report_dir"; \
	echo "Scanning all ghq repositories. Reports: $$report_dir"; \
	leaked=""; failed=""; \
	for repo in $$(ghq list); do \
		echo "Scanning $$repo ..."; \
		gitleaks git --redact --no-banner \
			--report-path "$$report_dir/$$(echo "$$repo" | tr / _).json" \
			"$$(ghq root)/$$repo"; \
		rc=$$?; \
		if [ $$rc -eq 1 ]; then leaked="$$leaked $$repo"; \
		elif [ $$rc -ne 0 ]; then failed="$$failed $$repo"; fi; \
	done; \
	for repo in $$failed; do echo "SCAN ERROR: $$repo"; done; \
	if [ -n "$$leaked" ]; then \
		echo "Leaks detected in:"; \
		for repo in $$leaked; do echo "  $$repo"; done; \
		exit 1; \
	fi; \
	echo "No leaks found."