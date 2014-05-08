#!/bin/bash
set -e

# load default data
cd $STACK_PATH 
bundle exec rake redmine:load_default_data

# configure posfix
alias=`cat $STACK_PATH/.cloud66/scripts/incoming_mail_configuration.txt`
eval echo "$alias" >> /etc/alias
newaliases
