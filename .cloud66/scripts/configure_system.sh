#!/bin/bash
set -e

# load default data
cd $STACK_PATH 
bundle exec rake db:migrate:plugins
bundle exec rake redmine:load_default_data

# configure file system write permissions
cd $STACK_PATH 
mkdir -p tmp public/plugin_assets
sudo touch log/received_emails.log
sudo chown -R nginx:app_writers files log tmp public/plugin_assets
sudo chmod -R 755 files log tmp public/plugin_assets

# configure mail handler scripts
cd /etc/postfix
sudo mkdir chili-handler
cp $STACK_PATH/extra/mail_handler/* /etc/postfix/chili-handler 
sudo chmod a+x /etc/postfix/chili-handler/rdm-mailhandler.rb

# create chiliproject user
sudo useradd -m -s /bin/bash chiliproject

./configure_postfix.sh