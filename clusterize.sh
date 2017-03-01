#!/bin/sh
export EMQ_SERVICE_NAME="${EMQ_SERVICE_NAME:-emq}"

until emqttd_ctl status
do
  sleep 1
done

while true
do

  NODES=$(dig +short "${EMQ_SERVICE_NAME}" | grep -v ${MY_IP})

  if [ -z "${NODES}" ]
  then
    >&2 echo 'no other nodes, breaking...'
    break
  fi

  echo "found the following peers: $(echo ${NODES} | tr '\n' ' ')"

  for NODE in ${NODES}
  do
    #TODO fragile when a node dies unexpectedly
    if emqttd_ctl cluster join "${EMQ_NAME}@${NODE}" | grep -E 'successfully|already_clustered'
    then
      echo 'joined cluster or already clustered...'
      break 2
    fi
  done

  echo 'trying again...'
  sleep 2
done

