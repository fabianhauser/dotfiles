# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User defined Bin paths
PATH=$PATH:$HOME/bin/aptana_studio_3/:$HOME/bin/Viridian-1.2/

# User specific aliases and functions
alias l='ls -lah'
alias mpg123='mpg123 -C'
