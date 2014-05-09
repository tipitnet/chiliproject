#!/bin/bash
set -e

# install postfix
sudo debconf-set-selections <<< "postfix postfix/mailname string $SERVER_NAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix

#echo "${HOST_NAME}    ignored" >> /etc/postfix/virtual
#echo "${INCOMING_EMAIL_ADDRESS}    chiliproject" >> /etc/postfix/virtual
#postmap /etc/postfix/virtual