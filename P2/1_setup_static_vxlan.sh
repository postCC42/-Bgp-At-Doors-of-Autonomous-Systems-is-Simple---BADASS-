#!/bin/bash

# to be executed after having imported the P2.gns3project into gns3 and activated the network with play button (this creates the container on VM)


GREEN='\033[1;92m'
YELLOW='\033[1;93m'
NC='\033[0m' # No Color

# Get the list of running Docker container IDs
running_containers=$(docker ps -q)

if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    echo "Container ID: $container_id"
    echo -e "${YELLOW}Hostname: $hostname${NC}"

    # Check the hostname and execute the respective commands
    case $hostname in
      host_mpagani-*)
        # Get network interfaces and their MAC addresses
        echo "Configuring host $hostname:"
        docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
        # Assign IP address based on hostname
        if [[ $hostname == "host_mpagani-1" ]]; then
          echo "Attempting to assign IP address 30.1.1.1/24 to eth1..."
          docker exec $container_id sh -c "ip addr add 30.1.1.1/24 dev eth1" && echo -e "${GREEN}Success: Assigned IP address 30.1.1.1/24 to eth1${NC}" || echo "Error: Failed to assign IP address 30.1.1.1/24 to eth1"
        elif [[ $hostname == "host_mpagani-2" ]]; then
          echo "Attempting to assign IP address 30.1.1.2/24 to eth1..."
          docker exec $container_id sh -c "ip addr add 30.1.1.2/24 dev eth1" && echo -e "${GREEN}Success: Assigned IP address 30.1.1.2/24 to eth1${NC}" || echo "Error: Failed to assign IP address 30.1.1.2/24 to eth1"
        fi
        ;;
      router_mpagani-*)
        # Get network interfaces and their MAC addresses
        echo "Configuring router $hostname:"
        docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
        # Assign IP address based on hostname
        if [[ $hostname == "router_mpagani-1" ]]; then
          echo "Attempting to assign IP address 10.1.1.1/24 to eth0..."
          docker exec $container_id sh -c "ip addr add 10.1.1.1/24 dev eth0" && echo -e "${GREEN}Success: Assigned IP address 10.1.1.1/24 to eth0${NC}" || echo "Error: Failed to assign IP address 10.1.1.1/24 to eth0"
          
          echo "Attempting to create VXLAN interface vxlan10..."
          docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 local 10.1.1.1 remote 10.1.1.2 dstport 4789 dev eth0" && echo -e "${GREEN}Success: Created VXLAN vxlan10${NC}" || echo "Error: Failed to create VXLAN vxlan10"
          
          echo "Attempting to set VXLAN interface vxlan10 up..."
          docker exec $container_id sh -c "ip link set dev vxlan10 up" && echo -e "${GREEN}Success: Activated VXLAN vxlan10${NC}" || echo "Error: Failed to activate VXLAN vxlan10"
          
          echo "Attempting to create bridge br0..."
          docker exec $container_id sh -c "ip link add br0 type bridge" && echo -e "${GREEN}Success: Created bridge br0${NC}" || echo "Error: Failed to create bridge br0"
          
          echo "Attempting to set bridge br0 up..."
          docker exec $container_id sh -c "ip link set dev br0 up" && echo -e "${GREEN}Success: Activated bridge br0${NC}" || echo "Error: Failed to activate bridge br0"
          
          echo "Attempting to add eth1 to bridge br0..."
          docker exec $container_id sh -c "brctl addif br0 eth1" && echo -e "${GREEN}Success: Added eth1 to bridge br0${NC}" || echo "Error: Failed to add eth1 to bridge br0"
          
          echo "Attempting to add vxlan10 to bridge br0..."
          docker exec $container_id sh -c "brctl addif br0 vxlan10" && echo -e "${GREEN}Success: Added vxlan10 to bridge br0${NC}" || echo "Error: Failed to add vxlan10 to bridge br0"
        elif [[ $hostname == "router_mpagani-2" ]]; then
          echo "Attempting to assign IP address 10.1.1.2/24 to eth0..."
          docker exec $container_id sh -c "ip addr add 10.1.1.2/24 dev eth0" && echo -e "${GREEN}Success: Assigned IP address 10.1.1.2/24 to eth0${NC}" || echo "Error: Failed to assign IP address 10.1.1.2/24 to eth0"
          
          echo "Attempting to create VXLAN interface vxlan10..."
          docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 local 10.1.1.2 remote 10.1.1.1 dstport 4789 dev eth0" && echo -e "${GREEN}Success: Created VXLAN vxlan10" || echo "Error: Failed to create VXLAN vxlan10"
          
          echo "Attempting to set VXLAN interface vxlan10 up..."
          docker exec $container_id sh -c "ip link set dev vxlan10 up" && echo -e "${GREEN}Success: Activated VXLAN vxlan10${NC}" || echo "Error: Failed to activate VXLAN vxlan10"
          
          echo "Attempting to create bridge br0..."
          docker exec $container_id sh -c "ip link add br0 type bridge" && echo -e "${GREEN}Success: Created bridge br0${NC}" || echo "Error: Failed to create bridge br0"
          
          echo "Attempting to set bridge br0 up..."
          docker exec $container_id sh -c "ip link set dev br0 up" && echo -e "${GREEN}Success: Activated bridge br0${NC}" || echo "Error: Failed to activate bridge br0"
          
          echo "Attempting to add eth1 to bridge br0..."
          docker exec $container_id sh -c "brctl addif br0 eth1" && echo -e "${GREEN}Success: Added eth1 to bridge br0${NC}" || echo "Error: Failed to add eth1 to bridge br0"
          
          echo "Attempting to add vxlan10 to bridge br0..."
          docker exec $container_id sh -c "brctl addif br0 vxlan10" && echo -e "${GREEN}Success: Added vxlan10 to bridge br0${NC}" || echo "Error: Failed to add vxlan10 to bridge br0"
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
