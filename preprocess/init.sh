#!/bin/sh
WD=$( cd "$(dirname "$0")" ; pwd -P )
find /opt/emqttd/etc -type f -name 'emq*.conf' | xargs -I {} sh -c "<{} ${WD}/process.py > {}.tpl"
