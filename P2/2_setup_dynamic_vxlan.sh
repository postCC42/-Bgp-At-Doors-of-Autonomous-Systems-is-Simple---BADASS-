#!/bin/bash

#NB
# to be executed after having executed the script that set the static vxlan
# Get the list of running Docker container IDs

#!/bin/bash

#NB
# to be executed after having executed the script that set the static vxlan
# Get the list of running Docker container IDs

GREEN='\033[1;92m'
YELLOW='\033[1;93m'
NC='\033[0m' # No Color

running_containers=$(docker ps -q)

if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    echo "Container ID: $container_id"
    echo -e "${YELLOW}Hostname: $hostname${NC}"

    # Check if it's a router
    if [[ $hostname == router_* ]]; then
      echo "Configuring router $hostname:"

      # Remove the static VXLAN setup if exists
      echo -n "Attempting to remove existing VXLAN setup... "
      docker exec $container_id sh -c 'if ip link show vxlan10 &> /dev/null; then ip link del vxlan10 && echo -e "${GREEN}Success: Existing VXLAN removed${NC}"; else echo "No existing VXLAN setup"; fi'

      # Create dynamic multicast VXLAN
      echo -n "Attempting to create dynamic multicast VXLAN... "
      docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789" && echo -e "${GREEN}Success: Created VXLAN vxlan10${NC}"
      docker exec $container_id sh -c "ip link set dev vxlan10 up" && echo -e "${GREEN}Success: Activated VXLAN vxlan10${NC}"
      docker exec $container_id sh -c "ip link add br0 type bridge" && echo -e "${GREEN}Success: Created bridge br0${NC}"
      docker exec $container_id sh -c "ip link set dev br0 up" && echo -e "${GREEN}Success: Activated bridge br0${NC}"
      docker exec $container_id sh -c "brctl addif br0 eth1" && echo -e "${GREEN}Success: Added eth1 to bridge br0${NC}"
      docker exec $container_id sh -c "brctl addif br0 vxlan10" && echo -e "${GREEN}Success: Added vxlan10 to bridge br0${NC}"

      echo "Router configuration completed."
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
