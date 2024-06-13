#!/bin/bash

# Get the list of running Docker container IDs
running_containers=$(docker ps -q)

if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    echo "Container ID: $container_id"
    echo "Hostname: $hostname"
    
    # Retrieve network interfaces and MAC addresses
    docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
    echo "---------------------------"
  done
  exit 0
else
  echo "No running containers"
  exit 1
fi