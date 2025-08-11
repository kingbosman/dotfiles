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
alias ..="cd .."

# GIT
alias lg='lazygit'
alias gs="git status"
alias gp="git pull"
alias gb="git branch"
alias gd="git diff"
alias gc="git checkout"
gcb() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "🚨 Usage: gcb {{new_branch}} {{from_branch}}"
        return 1
    fi

    if git rev-parse --verify "$1" >/dev/null 2>&1; then
        echo "🔄 Branch '$1' already exists. Switching to it... 🚀"
        git switch "$1"
    else
        echo "🌱 Creating new branch '$1' from '$2'... ✨"
        git checkout -b "$1" "$2"
        git push --set-upstream origin "$1"
        echo "✅ Branch '$1' created and pushed! 🌍"
    fi
}
gcp() {
    git remote update
    STATUS_OUTPUT=$(git status -uno)

    # Check if the branch is behind or has diverged
    if echo "$STATUS_OUTPUT" | grep -q "Your branch is behind"; then
        echo "❌ Your branch is behind. Please pull before pushing."
        return 1
    elif echo "$STATUS_OUTPUT" | grep -q "have diverged"; then
        echo "❌ Your branch has diverged from the remote branch. Please pull and resolve conflicts first."
        return 1
    fi

    # Ensure a commit message is provided
    COMMIT_MSG=$(echo "$1" | xargs) # Trim spaces
    if [ -z "$COMMIT_MSG" ]; then
        echo "⚠️ Commit message is required. Use: gcp \"commit message\""
        return 1
    fi

    echo "🚀 Adding files and preparing to push..."
    git add .
    git commit -m "$COMMIT_MSG"
    
    echo "🌀 Pushing to repository, please wait..."
    if git push; then
        echo "✅ Push successful!"
    else
        echo "❌ Push failed! Please check your Git settings or network connection."
        return 1
    fi
}

# Docker
# dockerboot is running twice because I had issues that some services were skipped in the first command
# running it twice fixes the issue
alias dockerboot='docker restart $(docker ps -a -q) && docker restart $(docker ps -a -q)'
alias sqlflufflint='~/.local/share/nvim/mason/bin/sqlfluff lint'
