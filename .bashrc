# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
elif [ -f /etc/bash.bashrc ]; then
	source /etc/bash.bashrc
fi;

if [ -f "${HOME}/.gpg-agent-info" ]; then
	source "${HOME}/.gpg-agent-info"
	export GPG_AGENT_INFO
	export SSH_AUTH_SOCK
fi

###########
# Locales
###########
unset LC_ALL
export LANG=de_CH.UTF-8
export LC_MESSAGES=C
export LC_TIME=C

############
# Aliases
############
# User specific aliases and functions
alias l='ls -lah'
alias mpg123='mpg123 -C'
alias pwgen='pwgen -c -n -s -N 30'
alias s='su -'
alias bc='bc --mathlib'

############
# Bash conf
############
# - if command not exists, cd into dir
# - Dont't exit directly when running jobs
# - Include .* files in * pattern
# - ** is recursive *
# - Append, not overwrite, history

shopt -s autocd checkjobs dotglob globstar histappend

