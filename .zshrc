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

# git
# https://gist.github.com/juno/5546198
# export PATH=/usr/local/bin/git:$PATH
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

## docker
# Select a docker container to start and attach to
function da() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker start "$cid" && docker attach "$cid"
}

# Select a running docker container to stop
function ds() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker stop "$cid"
}

# Select a docker container to remove
function drm() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker rm "$cid"
}

## gbr - checkout git branch
gbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

## gbrm - checkout git branch (including remote branches)
gbrm() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

## gshow - git commit browser
gshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

## fcd - find directory below current directory and cd
fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# z
. `brew --prefix`/etc/profile.d/z.sh

# starship
eval "$(starship init zsh)"

# added by golang
# export GOPATH=$HOME/go
# export GOROOT=/usr/local/opt/go/libexec
# export PATH=$PATH:$GOPATH/bin
# export PATH=$PATH:$GOROOT/bin

# Google Cloud SDK.
# if [ -f '/Users/nishikawatakushi/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nishikawatakushi/Downloads/google-cloud-sdk/path.zsh.inc'; fi
# if [ -f '/Users/nishikawatakushi/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nishikawatakushi/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
# export PATH="/usr/local/opt/helm@2/bin:$PATH"

# pyenv setting
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# nodenv setting
eval "$(nodenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Golang tools
export PATH="$HOME/go/bin:$PATH"
