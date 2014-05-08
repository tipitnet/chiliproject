#!/bin/bash
set -e
debconf-set-selections <<< "postfix postfix/mailname string $SERVER_NAME"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix
