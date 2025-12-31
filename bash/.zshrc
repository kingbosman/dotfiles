export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=$(go env GOPATH)/bin:$PATH

if [ -f ~/.config/bash/.bash_aliases ]; then
    . ~/.config/bash/.bash_aliases
fi

bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward

# Docker
# dockerboot is running twice because I had issues that some services were skipped in the first command
# running it twice fixes the issue
alias dockerboot='docker restart $(docker ps -a -q) && docker restart $(docker ps -a -q)'

# Start multiple tmux sessions for work
alias startdev='bash $HOME/.config/scripts/work_tmux.sh'

alias sqlflufflint='~/.local/share/nvim/mason/bin/sqlfluff lint'

## SQL connections (DEV ONLY) ##
# Work
alias felixdb='usql mysql://root:root@127.0.0.1:13306/felixworks'
alias einsteindb='usql mysql://root:root@127.0.0.1:23306/mreinstein'
alias authserverdb='usql mysql://root:root@127.0.0.1:33306/authserver'
alias planworksdb='usql mysql://root:root@127.0.0.1:43306/planworks'
