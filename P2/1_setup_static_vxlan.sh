#!/bin/bash

# Get the list of running Docker container IDs
running_containers=$(docker ps -q)

if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    echo "Container ID: $container_id"
    echo "Hostname: $hostname"

    # Check the hostname and execute the respective commands
    case $hostname in
      host_*)
        # Get network interfaces and their MAC addresses
        docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
        # Assign IP address based on hostname
        if [[ $hostname == "host_1" ]]; then
          docker exec $container_id sh -c "ip addr add 30.1.1.1/24 dev eth1"
        elif [[ $hostname == "host_2" ]]; then
          docker exec $container_id sh -c "ip addr add 30.1.1.2/24 dev eth1"
        fi
        ;;
      router_*)
        # Get network interfaces and their MAC addresses
        docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
        # Assign IP address based on hostname
        if [[ $hostname == "router_1" ]]; then
          docker exec $container_id sh -c "ip addr add 10.1.1.1/24 dev eth0"
          docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 local 10.1.1.1 remote 10.1.1.2 dstport 4789 dev eth0"
          docker exec $container_id sh -c "ip link set dev vxlan10 up"
          docker exec $container_id sh -c "ip link add br0 type bridge"
          docker exec $container_id sh -c "ip link set dev br0 up"
          docker exec $container_id sh -c "brctl addif br0 eth1"
          docker exec $container_id sh -c "brctl addif br0 vxlan10"
        elif [[ $hostname == "router_2" ]]; then
          docker exec $container_id sh -c "ip addr add 10.1.1.2/24 dev eth0"
          docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 local 10.1.1.2 remote 10.1.1.1 dstport 4789 dev eth0"
          docker exec $container_id sh -c "ip link set dev vxlan10 up"
          docker exec $container_id sh -c "ip link add br0 type bridge"
          docker exec $container_id sh -c "ip link set dev br0 up"
          docker exec $container_id sh -c "brctl addif br0 eth1"
          docker exec $container_id sh -c "brctl addif br0 vxlan10"
        fi
        ;;
      *)
        echo "Unknown container hostname pattern"
        ;;
    esac
    echo "---------------------------"
  done
  exit 0
else
  echo "No running containers"
  exit 1
fi
