# .bashrc

if [ -f $HOME/.profile ]; then
	source $HOME/.profile
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
elif [ -f /etc/bash.bashrc ]; then
	source /etc/bash.bashrc
fi

############
# Aliases
############
# User specific aliases and functions
alias l='ls -lah'
alias mpg123='mpg123 -C'
alias pwgen='pwgen -c -n -s -N 30'
alias s='su -'
alias bc='bc --mathlib'
alias cal='cal -m'
alias git-fetch-pr="git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'"

function o(){
#	for i in $@; do
		xdg-open "$*" >/dev/null 2>&1 &
#	done
}

############
# Bash conf
############
# - if command not exists, cd into dir
# - Dont't exit directly when running jobs
# - Include .* files in * pattern
# - ** is recursive *
# - Append, not overwrite, history

shopt -s autocd checkjobs dotglob globstar histappend

