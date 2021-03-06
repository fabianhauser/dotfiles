#!/bin/bash

if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
	eval $(dbus-launch --sh-syntax --exit-with-session)
	export $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
fi

export	LANG=en_US.UTF-8 \
	GNUPGHOME=$HOME/.gnupg \
	SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
	GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1 \
	LANG=de_CH.UTF-8 \
	LC_MESSAGES=en_US.UTF-8 \
	LC_TIME=en_DK.UTF-8 \
	EDITOR=vim \
	PAGER=less \
    XKB_DEFAULT_LAYOUT=ch

# Update GPG tty
gpg-connect-agent updatestartuptty /bye > /dev/null
export GPG_TTY=$(tty)

export PATH="$HOME/.cargo/bin:$PATH" \
    RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
