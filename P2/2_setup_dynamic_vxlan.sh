#!/bin/bash

#NB
# to be executed after having executed the script that set the static vxlan
# Get the list of running Docker container IDs
running_containers=$(docker ps -q)

if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    echo "Container ID: $container_id"
    echo "Hostname: $hostname"

    # Check if it's a router
    if [[ $hostname == router_* ]]; then
      # Remove the static VXLAN setup if exists
      docker exec $container_id sh -c 'if ip link show vxlan10 &> /dev/null; then ip link del vxlan10; fi'

      # Create dynamic multicast VXLAN
      docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789"
      docker exec $container_id sh -c "ip link set dev vxlan10 up"
      docker exec $container_id sh -c "ip link add br0 type bridge"
      docker exec $container_id sh -c "ip link set dev br0 up"
      docker exec $container_id sh -c "brctl addif br0 eth1"
      docker exec $container_id sh -c "brctl addif br0 vxlan10"

      echo "Dynamic multicast VXLAN created."
    else
      echo "Not a router, skipping."
    fi

    echo "---------------------------"
  done
  exit 0
else
  echo "No running containers"
  exit 1
fi