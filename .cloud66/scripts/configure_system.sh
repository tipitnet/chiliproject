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

cd /etc/postfix
sudo mkdir chili-handler
cp $STACK_PATH/extra/mail_handler/* /etc/postfix/chili-handler 
sudo chmod a+x /etc/postfix/chili-handler/rdm-mailhandler.rb

# configure posfix
export INCOMING_EMAIL_ADDRESS=chiliproject@${SERVER_NAME}.${BOX_NAME}.c66.me
export SERVER_URL=http://${SERVER_NAME}.${BOX_NAME}.c66.me

alias=`cat $STACK_PATH/.cloud66/resources/aliases`
eval echo "$alias" > /etc/aliases
newaliases

sudo useradd -m -s /bin/bash chiliproject

cd /etc/postfix
echo "virtual_alias_domains = ${SERVER_NAME}.${BOX_NAME}.c66.me" >> /etc/postfix/main.cf
echo "virtual_alias_maps = hash:/etc/postfix/virtual" >> /etc/postfix/main.cf
sed "s/mydestination =/mydestination = $SERVER_NAME.$BOX_NAME.c66.me, /g" <main.cf >new.main.cf
mv new.main.cf main.cf

sudo postfix reload