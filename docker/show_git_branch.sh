# show github branches
# https://stackoverflow.com/questions/17333531/how-can-i-display-the-current-branch-and-folder-path-in-terminal
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\xE2\x80\xA6\n(\1)/'
}
export PS1="\[\033[1;31m\]\u@\h:\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
