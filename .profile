#!/bin/bash

if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
	eval $(dbus-launch --sh-syntax --exit-with-session)
	export $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
fi

export	LANG=en_US.UTF-8 \
	GNUPGHOME=$HOME/.gnupg \
	SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
	GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent \
	LANG=de_CH.UTF-8 \
	LC_MESSAGES=en_US.UTF-8 \
	LC_TIME=C \
	EDITOR=vim \
	PAGER=less

