# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

############
# Configuration
############

# fabian-laptop binary paths
if [ `hostname` = "nbfabian" ]; then
	export PATH=$PATH:$HOME/bin/aptana_studio_3/:$HOME/bin/Viridian-1.2/:$HOME/bin/timelapsepy:$HOME/bin/icaclient:$HOME/bin/nodejs/bin
	export ICAROOT="$HOME/bin/icaclient"
	export TERMINAL=terminal
	# remove flash-cookies
	rm -rf $HOME/.adobe $HOME/.macromedia
	# load node autocompletion
	. <(npm completion)
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

## UberSpace specific aliases
alias us-services_status='svstat ~/service/*'
alias us-restart_php="killall -u $USER php-cgi"

## Fabian shortcuts
alias wol-fabian-test='wol f0:7d:68:c1:ed:9e'
alias wol-fabian-laptop='wol f0:de:f1:5f:1d:44'
alias wol-nas='00:08:9b:c0:d5:ed'
