export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=$(go env GOPATH)/bin:$PATH

if [ -f ~/.config/bash/.bash_aliases ]; then
    . ~/.config/bash/.bash_aliases
fi
