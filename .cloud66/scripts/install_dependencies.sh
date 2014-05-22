#!/bin/bash
set -e


if [[ "$HOST_NAME" == "" ]]
	then export HOST_NAME=${SERVER_NAME,,}.${BOX_NAME}.c66.me
fi

export HOST_NAME=${SERVER_NAME,,}.${BOX_NAME}.c66.me
export INCOMING_EMAIL_ADDRESS=chiliproject@${HOST_NAME}

# install postfix
sudo debconf-set-selections <<< "postfix postfix/mailname string ${HOST_NAME}"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix