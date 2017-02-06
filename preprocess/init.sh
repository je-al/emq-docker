#!/bin/sh
WD=$( cd "$(dirname "$0")" ; pwd -P )
find /opt/emqttd/etc/plugins -type f -name 'emq_*.conf' | xargs -I {} sh -c "<{} ${WD}/process.py > {}.tpl"
