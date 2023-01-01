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

link: ## make symlinks
	./link.sh
