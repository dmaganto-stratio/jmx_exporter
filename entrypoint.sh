#!/bin/bash

## $PORT0 local port
## $REMOTE_JMX_HOST remote jmx host
## $REMOTE_JMX_PORT remote jmx port


source ./kms_utils.sh

STRING_VAULT_HOST=${STRING_VAULT_HOST:=vault.service.eos.saas.stratio.com}
VAULT_PORT=${VAULT_PORT:=8200}

CLUSTER="${CLUSTER:=userland}"
INSTANCE="${INSTANCE:=stratiokafka-sec}"
SECRET="${SECRET:=jmx}"
CERTPATH="/tmp"
APP="${APP:=kafka}"
AUTH="${AUTH:=false}"

IFS_OLD=$IFS
IFS=',' read -r -a VAULT_HOSTS <<< "$STRING_VAULT_HOST"


if [[ ${VAULT_ROLE_ID} ]] && [[ ${VAULT_SECRET_ID} ]];
then
  # Login to Vault to get VAULT_TOKEN using dynamic authentication
  login
fi

getPass ${CLUSTER} ${INSTANCE} ${SECRET}

INSTANCE=${INSTANCE//-/_}
USER=${INSTANCE^^}_JMX_USER 
PASS=${INSTANCE^^}_JMX_PASS

#echo $USER
#echo $PASS

JAVA_OPTS=${JAVA_OPTS:="-Xmx256m"}

cat <<EOF > /config.yml
---
hostPort: $REMOTE_JMX_HOST:$REMOTE_JMX_PORT
username: ${!USER}
password: ${!PASS}
EOF

cat /${APP}.yml >> /config.yml


echo LOCAL_PORT: $PORT0
echo REMOTE_JMX_HOST: $REMOTE_JMX_HOST
echo REMOTE_JMX_PORT: $REMOTE_JMX_PORT

cat /config.yml

java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=$AUTH -jar jmx_exporter.jar $PORT0 /config.yml
