# If not running interactively, don't do anything 
[[ $- != *i* ]] && return 

stty -ixon # Disables ctrl-s and ctrl-q (Used To Pause Term) 
# System
alias shd="shutdown -h now"
alias rb="reboot"
# Aliases
alias ..='cd ..' 
alias ...='cd ../..' 
alias install='sudo apt install'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias uplist='apt list --upgradable'
alias remove='sudo apt autoremove'
alias l='exa -ll --color=always --group-directories-first'
alias ls='exa -al --header --icons --group-directories-first'
alias myip="ip -f inet address | grep inet | grep -v 'lo$' | cut -d ' ' -f 6,13 && curl ifconfig.me && echo ' external ip'"
# Dotfiles & Files
alias g.="cd ~/.config"
alias gd="cd ~/Downloads"
# Git aliases
alias gc="git commit -m"
alias gp="git push"
alias ga="git add ."
alias gs="git status"
alias gb="git branch"

PATH="$PATH:$HOME/.config/composer/vendor/bin" #load composer

#Im too stupid to understand networks so hacked this function
changenetwork() {
	if [ ! -f /etc/network/$1 ]; then
    		echo "Network config not found!";
	else
		sudo cp /etc/network/$1 /etc/network/interfaces
		sudo ifdown wlp3s0
		sudo ifup wlp3s0
	fi

}

phpstorm () {
    if [ -f /home/robin/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm2024.2/.lock ]; then
        rm -r /home/robin/.var/app/com.jetbrains.PhpStorm/config/JetBrains/PhpStorm2024.2/.lock
        echo "Lock file removed"
    fi
    flatpak run com.jetbrains.PhpStorm "$1" > /dev/null 2>&1 &
}
alias v="vim"
alias sail='sudo ./vendor/bin/sail'
alias sa='sudo ./vendor/bin/sail artisan'
alias a='php artisan'

# Add Color
alias egrep='grep --color=auto' 

export PATH="~/scripts:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
 export VISUAL=nvim;
 export EDITOR=nvim;
# PS1 Customization
#PS1="\[\e[32m\]\h\[\e[m\]\[\e[36m\]@\[\e[m\]\[\e[34m\]\u\[\e[m\] \W \$ " 
# Colour codes
RED="\\[\\e[1;31m\\]"
GREEN="\\[\\e[1;32m\\]"
YELLOW="\\[\\e[1;33m\\]"
BLUE="\\[\\e[1;34m\\]"
MAGENTA="\\[\\e[1;35m\\]"
CYAN="\\[\\e[1;36m\\]"
WHITE="\\[\\e[1;37m\\]"
ENDC="\\[\\e[0m\\]"

# Set a two-line prompt. If accessing via ssh include 'ssh-session' message.
if [[ -n "$SSH_CLIENT" ]]; then ssh_message="-ssh_session"; fi
PS1="${MAGENTA}\t ${GREEN}\u ${WHITE}at ${YELLOW}\h${RED}${ssh_message} ${WHITE}in ${BLUE}\w \n${CYAN}\$${ENDC} "


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
