#!/bin/bash

portIsReachable() {
  # Params: $1 -> host $2 -> port
  if [ -f /usr/bin/nc ]; then
    nc -z "${1}" "${2}" # alpine image
  else
    # shellcheck disable=SC2006,SC2086,SC3025,SC2034
    temp=$( (echo >/dev/tcp/${1}/${2}) >/dev/null 2>&1) # centos image
  fi
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then echo 1; else echo 0; fi
}


checkVmMaxMapCount(){
    ## constants 
    local c1=262144 # p1 -> vm.max_map_count

    local p1=$(sysctl "vm.max_map_count" | cut -d " " -f 3)
    if [[ ! $p1 -lt $c1 ]]; then
        echo "vm.max_map_count is adequate ($p1)"
    else
        echo "ERROR - vm.max_map_count is NOT adequate ($p1)"
        return 1
    fi
}

checkVmMaxMapCount || exit 106

onInterrupt(){
	echo "Interrupted! Shutting down Cloud Agent"

  cd "${TARGETDIR}" || exit 105
  ./ArisCloudagent10 stop
	exit 0 # managed expected exit
}

trap "onInterrupt" SIGINT SIGTERM

if [ ! -f "${TARGETDIR}/install.log" ]; then
  echo "Not yet installed, installing now"
  cd /tmp || exit 101

  echo "installing cloud agent..."
  rpm -i cloud-agent.rpm
  RESULT_cloud_agent=$?
  if [ ! $RESULT_cloud_agent ]; then
    echo "cloud agent installation failed"
    exit 103
  else
    touch "${TARGETDIR}/install.log"
  fi

  echo "installing acc..."
  rpm -i acct.rpm
  RESULT_acc=$?
  if [ ! $RESULT_acc ]; then
    echo "acc installation failed"
    exit 104
  else
    touch "${TARGETDIR}/install.log"
  fi

fi

echo "starting cloud agent..."
cd "${TARGETDIR}" || exit 104
./ArisCloudagent10 start

while ! portIsReachable localhost 14000; do
  echo "Waiting for port 14000 to be open on localhost"
  sleep 5
done

if [ ! -f "${TARGETDIR}/setup.done.txt" ]; then
  echo "Setting up node..."
  cd "${TARGETDIR}" || exit 107
  # ./acc10.sh -c /mnt/scripts/aris-playground-minimal.acc.env
  echo "Finished setting up node"
fi


ARIS_CA_PID=$(ps auxww | grep "com.aris" | grep -v grep | tr -s ' ' | cut -d' ' -f2)

echo "Aris cloud agent java process PID=$ARIS_CA_PID"

# wait "$ARIS_CA_PID"
# wait requires the PID to be a child of this shell, which is not the case here...
tail --pid="${ARIS_CA_PID}" -f /dev/null

echo "Cloud agent finished"

#echo "stopping for debug <server box>"
#tail -f /dev/null
