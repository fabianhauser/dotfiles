# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

############
# BASH Vars
############
PATH=$PATH:$HOME/bin/aptana_studio_3/:$HOME/bin/Viridian-1.2/

############
# Configuration
############

# currently nothing to see here :-)

############
# Aliases
############
# User specific aliases and functions
alias l='ls -lah'
alias mpg123='mpg123 -C'
#alias pwgen='pwgen -c -n -s -N 30'
alias aptana='/home/fabian/bin/aptana/AptanaStudio3'
alias nano='nano -A -L'
alias tailnew='tail -n0 -f'

## UberSpace specific aliases
alias us-services_status='svstat ~/service/*'
alias us-restart_php='killall -u fabianh php-cgi'

