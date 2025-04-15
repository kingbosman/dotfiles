## Common ##
alias ls='eza -aol --header --group-directories-first'
alias myip="ip -f inet address | grep inet | grep -v 'lo$' | cut -d ' ' -f 6,13 && curl ifconfig.me && echo ' external ip'"
alias e="xdg-open"

## GIT ##
alias gs="git status"
alias gp="git pull"
alias gb="git branch"
alias gd="git diff"
alias gc="git checkout"
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
gcp() {
 if [ -z "$1" ] 
 then
  echo 'Commit message is required use gcp {{message}}'
 else 
  echo 'trying to add files and push with commit message ' $1
  git add .
  git commit -m $1
  git push
 fi
}

## Code ##
alias v="nvim"
alias sail='./vendor/bin/sail'
alias sa='./vendor/bin/sail artisan'
alias a='php artisan'

# easy cd
alias cdd='cd ~/Downloads'
alias cdp='cd ~/projects'
