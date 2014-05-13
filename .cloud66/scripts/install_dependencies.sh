#!/bin/bash
set -e

export HOST_NAME=${SERVER_NAME,,}.${BOX_NAME}.c66.me
export INCOMING_EMAIL_ADDRESS=chiliproject@${SERVER_NAME,,}.${BOX_NAME}.c66.me

# install postfix
sudo debconf-set-selections <<< "postfix postfix/mailname string ${SERVER_NAME,,}"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix


echo "${HOST_NAME}    ignored" >> /etc/postfix/virtual
echo "${INCOMING_EMAIL_ADDRESS}    chiliproject" >> /etc/postfix/virtual
postmap /etc/postfix/virtual