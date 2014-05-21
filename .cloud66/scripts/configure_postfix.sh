#!/bin/bash
set -e

# configure posfix
if [[ "$HOST_NAME" == "" ]]
	then export HOST_NAME=${SERVER_NAME,,}.${BOX_NAME}.c66.me
fi

export HOST_NAME=${SERVER_NAME,,}.${BOX_NAME}.c66.me
export INCOMING_EMAIL_ADDRESS=chiliproject@${HOST_NAME}
export SERVER_URL=http://${HOST_NAME}

alias=`cat $STACK_PATH/.cloud66/resources/aliases`
eval echo "$alias" > /etc/aliases
newaliases

sudo useradd -m -s /bin/bash chiliproject

cd /etc/postfix

echo "${HOST_NAME}    ignored" >> /etc/postfix/virtual
echo "${INCOMING_EMAIL_ADDRESS}    chiliproject" >> /etc/postfix/virtual
postmap /etc/postfix/virtual

echo "virtual_alias_domains = ${HOST_NAME}" >> /etc/postfix/main.cf
echo "virtual_alias_maps = hash:/etc/postfix/virtual" >> /etc/postfix/main.cf
sed "s/mydestination =/mydestination = ${HOST_NAME}, /g" <main.cf >new.main.cf
mv new.main.cf main.cf

sudo postfix reload