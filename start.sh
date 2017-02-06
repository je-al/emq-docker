#!/bin/sh
## EMQ docker image start script
# Huang Rui <vowstar@gmail.com>

## EMQ Base settings
sed -i -e "s/^#*\s*node.name\s*=\s*.*@.*/node.name = ${EMQ_NODE_NAME}/g" /opt/emqttd/etc/emq.conf

if [ -n "${EMQ_NODE_COOKIE}" ]
then
  export NODE__COOKIE="${EMQ_NODE_COOKIE}"
fi

if [ -n "${EMQ_PROCESS_LIMIT}" ]
then
  export NODE__PROCESS_LIMIT="${EMQ_PROCESS_LIMIT}"
fi

if [ -n "${EMQ_MAX_PORTS}" ]
then
  export NODE__MAX_PORTS="${EMQ_MAX_PORTS}"
fi

if [ -n "${EMQ_LOG_CONSOLE}" ]
then
  export LOG__CONSOLE="${EMQ_LOG_CONSOLE}"
fi

if [ -n "${EMQ_LOG_LEVEL}" ]
then
  export LOG__CONSOLE__LEVEL="${EMQ_LOG_LEVEL}"
fi

if [ -n "${EMQ_ALLOW_ANONYMOUS}" ]
then
  export MQTT__ALLOW_ANONYMOUS="${EMQ_ALLOW_ANONYMOUS}"
fi

if [ -n "${EMQ_TCP_PORT}" ]
then
  export MQTT__LISTENER__TCP="${EMQ_TCP_PORT}"
fi

if [ -n "${EMQ_TCP_ACCEPTORS}" ]
then
  export MQTT__LISTENER__TCP__ACCEPTORS="${EMQ_TCP_ACCEPTORS}"
fi

if [ -n "${EMQ_TCP_MAX_CLIENTS}" ]
then
  export MQTT__LISTENER__TCP__MAX_CLIENTS="${EMQ_TCP_MAX_CLIENTS}"
fi

if [ -n "${EMQ_SSL_PORT}" ]
then
  export MQTT__LISTENER__SSL="${EMQ_SSL_PORT}"
fi

if [ -n "${EMQ_SSL_ACCEPTORS}" ]
then
  export MQTT__LISTENER__SSL__ACCEPTORS="${EMQ_SSL_ACCEPTORS}"
fi

if [ -n "${EMQ_SSL_MAX_CLIENTS}" ]
then
  export MQTT__LISTENER__SSL__MAX_CLIENTS="${EMQ_SSL_MAX_CLIENTS}"
fi

if [ -n "${EMQ_HTTP_PORT}" ]
then
  export MQTT__LISTENER__HTTP="${EMQ_HTTP_PORT}"
fi

if [ -n "${EMQ_HTTP_ACCEPTORS}" ]
then
  export MQTT__LISTENER__HTTP__ACCEPTORS="${EMQ_HTTP_ACCEPTORS}"
fi

if [ -n "${EMQ_HTTP_MAX_CLIENTS}" ]
then
  export MQTT__LISTENER__HTTP__MAX_CLIENTS="${EMQ_HTTP_MAX_CLIENTS}"
fi

if [ -n "${EMQ_HTTPS_PORT}" ]
then
  export MQTT__LISTENER__HTTPS="${EMQ_HTTPS_PORT}"
fi

if [ -n "${EMQ_HTTPS_ACCEPTORS}" ]
then
  export MQTT__LISTENER__HTTPS__ACCEPTORS="${EMQ_HTTPS_ACCEPTORS}"
fi

if [ -n "${EMQ_HTTPS_MAX_CLIENTS}" ]
then
  export MQTT__LISTENER__HTTPS__MAX_CLIENTS="${EMQ_HTTPS_MAX_CLIENTS}"
fi

if [ -n "${EMQ_MAX_PACKET_SIZE}" ]
then
  export MQTT__MAX_PACKET_SIZE="${EMQ_MAX_PACKET_SIZE}"
fi

## EMQ Plugin load settings
# Plugins loaded by default

if [ x"${EMQ_LOADED_PLUGINS}" = x ]
then
EMQ_LOADED_PLUGINS="emq_recon,emq_dashboard,emq_mod_presence,emq_mod_retainer,emq_mod_subscription"
echo "EMQ_LOADED_PLUGINS=${EMQ_LOADED_PLUGINS}"
fi
# First, remove special char at header
# Next, replace special char to ".\n" to fit emq loaded_plugins format
echo $(echo "${EMQ_LOADED_PLUGINS}."|sed -e "s/^[^A-Za-z0-9_]\{1,\}//g"|sed -e "s/[^A-Za-z0-9_]\{1,\}/\.\n/g") > /opt/emqttd/data/loaded_plugins

## EMQ Plugins setting
for INFILE in $(find /opt/emqttd/etc -name '*.tpl')
do
  OUTFILE="$(dirname ${INFILE})/$(basename ${INFILE} .tpl)"
  gucci ${INFILE} > ${OUTFILE} || exit 1
done

## EMQ Main script
# Start and run emqttd
trap 'emqttd_ctl cluster leave; kill -TERM $PID' TERM INT
emqttd foreground &
PID=$!
wait $PID
trap - TERM INT
wait $PID
exit $?
