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
export INCOMING_EMAIL_ADDRESS=chiliproject@${SERVER_NAME}.${BOX_NAME}.c66.me
export SERVER_URL=http://${SERVER_NAME}.${BOX_NAME}.c66.me

alias=`cat $STACK_PATH/.cloud66/scripts/incoming_mail_configuration.txt`
eval echo "$alias" >> /etc/aliases
newaliases

sudo useradd -m -s /bin/bash chiliproject
