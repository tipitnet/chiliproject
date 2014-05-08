#!/bin/bash
set -e

# install postfix
sudo debconf-set-selections <<< "postfix postfix/mailname string $SERVER_NAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix

# configure posfix
alias=`cat $STACK_PATH/.cloud66/scripts/incoming_mail_configuration.txt`
sudo eval echo "$alias" >> /etc/alias
sudo newaliases
