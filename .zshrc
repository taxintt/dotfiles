# signing commits
# https://gist.github.com/repodevs/a18c7bb42b2ab293155aca889d447f1b
export GPG_TTY=$(tty)

# starship
eval "$(starship init zsh)"

# ghq
export GHQ_ROOT="$HOME/src"

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

# nodenv setting
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Golang
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# uv
. "$HOME/.local/bin/env"