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
    
    # Output the MAC address table if the bridge br0 exists
    if docker exec $container_id sh -c "brctl showmacs br0" &> /dev/null; then
      echo "MAC address table for br0:"
      docker exec $container_id sh -c "brctl showmacs br0"
    else
      echo "No bridge br0 found in this container"
    fi
    
    echo "---------------------------"
  done
  exit 0
else
  echo "No running containers"
  exit 1
fi
