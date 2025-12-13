# signing commits
# https://gist.github.com/repodevs/a18c7bb42b2ab293155aca889d447f1b
export GPG_TTY=$(tty)

# starship
eval "$(starship init zsh)"

# ghq
export GHQ_ROOT="$HOME/src"

repo() {
    local action="${1:-list}"
    
    case "$action" in
        "list"|"l")
            # List all repositories with fzf selection
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                echo "Selected: $selected_repo"
                echo "Path: $(ghq root)/$selected_repo"
            fi
            ;;
        "cd"|"c")
            # Change directory to selected repository
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                cd "$(ghq root)/$selected_repo" || return 1
            fi
            ;;
        "remove"|"rm"|"r")
            # Remove selected repository
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap --prompt="Select repository to remove: ")
            if [[ -n "$selected_repo" ]]; then
                echo "Are you sure you want to remove $selected_repo? [y/N]"
                read -r confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    rm -rf "$(ghq root)/$selected_repo"
                    echo "Removed: $selected_repo"
                else
                    echo "Cancelled"
                fi
            fi
            ;;
        "get"|"g")
            # Clone/get a new repository
            if [[ -z "$2" ]]; then
                # Interactive mode: show remote repositories via gh + fzf
                local selected_repo
                selected_repo=$(gh repo list --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | fzf --height=50% --border --preview="gh repo view {} --json description,url,pushedAt --template '{{.description}}\n{{.url}}\nLast updated: {{.pushedAt}}'" --preview-window=down:5:wrap --prompt="Select repository to clone: ")
                if [[ -n "$selected_repo" ]]; then
                    ghq get "github.com/$selected_repo"
                fi
            else
                ghq get "$2"
            fi
            ;;
        "create"|"new"|"n")
            # Create a new repository directory
            if [[ -z "$2" ]]; then
                echo "Usage: repo create <repository_path>"
                echo "Example: repo create github.com/user/new-repo"
                return 1
            fi
            local repo_path="$(ghq root)/$2"
            mkdir -p "$repo_path"
            cd "$repo_path" || return 1
            git init
            echo "Created and initialized: $2"
            ;;
        "open"|"o")
            # Open repository in editor (default: code)
            local editor="${2:-code}"
            local selected_repo
            selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
            if [[ -n "$selected_repo" ]]; then
                local repo_path="$(ghq root)/$selected_repo"
                if command -v "$editor" > /dev/null; then
                    "$editor" "$repo_path"
                else
                    echo "Editor '$editor' not found. Trying fallback editors..."
                    if command -v code > /dev/null; then
                        code "$repo_path"
                    elif command -v vim > /dev/null; then
                        vim "$repo_path"
                    else
                        echo "No suitable editor found (code, vim)"
                    fi
                fi
            fi
            ;;
        "help"|"h"|*)
            # Show help
            cat << 'EOF'
Repository management with ghq and fzf

Usage: repo <command> [args]

Commands:
  list, l         List repositories with fzf selection
  cd, c           Change directory to selected repository
  remove, rm, r   Remove selected repository (with confirmation)
  get, g [url]    Clone repository (interactive if no url)
  create, new, n  Create and initialize a new repository
  open, o [editor] Open repository in editor (default: code)
  help, h         Show this help message

Examples:
  repo                    # List repositories
  repo cd                 # Change to selected repository
  repo get                # Interactive repository selection
  repo get github.com/user/repo
  repo create github.com/user/new-repo
  repo remove             # Remove selected repository
  repo open               # Open repository in code (default)
  repo open vim           # Open repository in vim
  repo open nvim          # Open repository in neovim

Requirements: ghq, fzf, git, gh (for interactive get)
EOF
            ;;
    esac
}


#
# alias
#
alias ..="cd .."
alias cd..="cd .."

alias rm='rm -i -v'
alias mv='mv -i -v'
alias cp='cp -i -v'
alias jump="z"

## terraform
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfs='terraform show'
alias tfd='terraform destroy'
alias gtf='export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token) | terraform'

## kubernetes
alias k='kubectl'

## zenn
alias zenn='npx zenn'

## difit
alias difit="npx difit"

gifit() {
  local from_commit to_commit from_hash to_hash

  from_commit=$(git log --oneline --decorate -100 --color=always | \
    fzf \
      --ansi \
      --header "> difit \$TO \$FROM~1" \
      --prompt "Select \$FROM>" \
      --preview 'git log --oneline --decorate --color=always -1 {1}' \
      --preview-window=top:3:wrap
  ) || return
  from_hash="${from_commit%% *}"

  to_commit=$(git log --oneline --decorate -100 --color=always $from_hash~1.. | \
    fzf \
      --ansi \
      --header "> difit \$TO $from_hash~1" \
      --prompt "Select \$TO>" \
      --preview 'git log --oneline --decorate --color=always -1 {1}' \
      --preview-window=top:3:wrap
  ) || return
  to_hash="${to_commit%% *}"

  difit "$to_hash" "$from_hash~1"
}

# git
# https://gist.github.com/juno/5546198
fpath=($(brew --prefix)/share/zsh-completions $fpath)
autoload -U compinit
compinit -u
# 補完候補に色つける
autoload -U colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"
# 単語の入力途中でもTab補完を有効化
setopt complete_in_word
# 補完候補をハイライト
zstyle ':completion:*:default' menu select=1
# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true
# 大文字、小文字を区別せず補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完リストの表示間隔を狭くする
setopt list_packed
# コマンドの打ち間違いを指摘してくれる
setopt correct
SPROMPT="correct: $RED%R$DEFAULT -> $GREEN%r$DEFAULT ? [Yes/No/Abort/Edit] => "

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# ghq + fzf
alias g='REPO=$(ghq list | sort -u | fzf);for GHQ_ROOT in $(ghq root -all);do [ -d $GHQ_ROOT/$REPO ] && cd $GHQ_ROOT/$REPO;done'

# z
. `brew --prefix`/etc/profile.d/z.sh

# Golang
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# uv
. "$HOME/.local/bin/env"

# mise
eval "$(`brew --prefix`/bin/mise activate zsh)"
mise completion zsh > $(brew --prefix)/share/zsh/site-functions/_mise