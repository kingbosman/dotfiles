## Common ##
alias ls='eza -aol --header --group-directories-first'
alias myip="ip -f inet address | grep inet | grep -v 'lo$' | cut -d ' ' -f 6,13 && curl ifconfig.me && echo ' external ip'"
alias e="xdg-open"

## Code ##
alias v="nvim"
alias vim="nvim"
alias sail='./vendor/bin/sail'
alias sa='./vendor/bin/sail artisan'
alias a='php artisan'

# easy cd
alias cdd='cd ~/Downloads'
alias cdp='cd ~/projects'
alias cdw='cd ~/projects/github.com/Brendan-MacKenzie'
alias cdk='cd ~/projects/github.com/kingbosman/'
alias ..="cd .."

# GIT
alias lg='lazygit'

# Docker
# dockerboot is running twice because I had issues that some services were skipped in the first command
# running it twice fixes the issue
alias dockerboot='docker restart $(docker ps -a -q) && docker restart $(docker ps -a -q)'

alias sqlflufflint='~/.local/share/nvim/mason/bin/sqlfluff lint'
