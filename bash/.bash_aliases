## Common ##
alias ls='eza -aol --header --group-directories-first'
alias myip="ip -f inet address | grep inet | grep -v 'lo$' | cut -d ' ' -f 6,13 && curl ifconfig.me && echo ' external ip'"
alias e="xdg-open"

## GIT: Keep forgetting this ##
gcb() {
 if [ -z "$1" ] || [ -z "$2" ]
        then
                echo 'New branch name is required {{new_branch}} and: {{from_branch} as second argument'
        else
                echo 'Creating new branch with name ' $1
                git checkout -b $1 $2
  git push --set-upstream origin $1
        fi
}

## Code ##
alias v="nvim"
alias vim="nvim"
alias sail='./vendor/bin/sail'
alias sa='./vendor/bin/sail artisan'
alias a='php artisan'

# easy cd
alias cdd='cd ~/Downloads'
alias cdp='cd ~/projects'
