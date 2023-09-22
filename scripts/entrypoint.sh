#!/bin/bash

if [ ! -f /mnt/aris/install.log ]; then
  echo "Not yet installed, installing now"
  cd /tmp || exit 101

  echo "installing acc..."
  rpm -i acc.rpm
  RESULT_acc=$?
  if [ ! $RESULT_acc ]; then
    echo "acc installation failed: $RESULT_acc"
    exit 102
  fi

  echo "installing cloud agent..."
  rpm -i cloud-agent.rpm
  RESULT_cloud_agent=$?
  if [ ! $RESULT_cloud_agent ]; then
    echo "cloud agent installation failed"
    exit 103
  fi

fi

echo "starting cloud agent..."
cd /mnt/aris || exit 104
./ArisCloudagent10 start

C_AGENT_PID=$!

echo "stopping for debug (C_AGENT_PID=$C_AGENT_PID)"
tail -f /dev/null

