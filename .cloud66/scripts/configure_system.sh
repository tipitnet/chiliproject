#!/bin/bash
set -e

# load default data
cd $STACK_PATH 
bundle exec rake redmine:load_default_data

# configure file system write permissions
cd $STACK_PATH 
mkdir -p tmp public/plugin_assets
sudo chown -R nginx:app_writers files log tmp public/plugin_assets
sudo chmod -R 755 files log tmp public/plugin_assets
sudo chmod a+x extra/mail_handler/rdm-mailhandler.rb

# configure posfix
alias=`cat $STACK_PATH/.cloud66/scripts/incoming_mail_configuration.txt`
eval echo "$alias" >> /etc/aliases
newaliases
