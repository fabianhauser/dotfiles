#!/bin/bash

# Add GPG compatibility setting (currently used by claws-mail)
GNUPGHOME=${HOME}/.gnupg
GPG_AGENT_INFO=${GNUPGHOME}/S.gpg-agent:0:1
export GPG_AGENT_INFO
