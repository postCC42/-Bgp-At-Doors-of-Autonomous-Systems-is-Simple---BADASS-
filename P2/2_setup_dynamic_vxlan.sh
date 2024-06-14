#!/bin/bash

GREEN='\033[1;92m'
YELLOW='\033[1;93m'
NC='\033[0m' # No Color

# Array to store container IDs of routers
router_container_ids=()

# Get the list of running Docker container IDs
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

      # Remove existing VXLAN setup if exists
      echo -n "Attempting to remove existing VXLAN setup... "
      docker exec $container_id sh -c 'if ip link show vxlan10 &> /dev/null; then ip link del vxlan10 && echo -e "${GREEN}Success: Existing VXLAN removed${NC}"; else echo "No existing VXLAN setup"; fi'

      # Remove existing bridge if exists
      echo -n "Attempting to remove existing bridge setup... "
      docker exec $container_id sh -c 'if ip link show br0 &> /dev/null; then brctl delif br0 vxlan10 && echo -e "${GREEN}Success: Removed vxlan10 from bridge br0${NC}"; brctl delif br0 eth1 && echo -e "${GREEN}Success: Removed eth1 from bridge br0${NC}"; ip link set dev br0 down && echo -e "${GREEN}Success: Deactivated bridge br0${NC}"; ip link del br0 && echo -e "${GREEN}Success: Deleted bridge br0${NC}"; else echo "No existing bridge setup"; fi'

      # Create dynamic multicast VXLAN
      echo -n "Attempting to create dynamic multicast VXLAN... "
      docker exec $container_id sh -c "ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789" && echo -e "${GREEN}Success: Created VXLAN vxlan10${NC}"
      docker exec $container_id sh -c "ip link set dev vxlan10 up" && echo -e "${GREEN}Success: Activated VXLAN vxlan10${NC}"

      # Create bridge and add interfaces to it
      echo -n "Attempting to create bridge br0... "
      docker exec $container_id sh -c "ip link add br0 type bridge" && echo -e "${GREEN}Success: Created bridge br0${NC}"
      docker exec $container_id sh -c "ip link set dev br0 up" && echo -e "${GREEN}Success: Activated bridge br0${NC}"
      docker exec $container_id sh -c "brctl addif br0 eth1" && echo -e "${GREEN}Success: Added eth1 to bridge br0${NC}"
      docker exec $container_id sh -c "brctl addif br0 vxlan10" && echo -e "${GREEN}Success: Added vxlan10 to bridge br0${NC}"

      # Add container ID to array for later ip maddr show execution
      router_container_ids+=("$container_id")

      echo "Router configuration completed."
    else
      echo "Not a router, skipping."
    fi

    echo "---------------------------"
  done

      echo -e "\n###########################################"
      echo -e "#                                         #"
      echo -e "#  VXLAN vxlan10 encapsulates Ethernet    #"
      echo -e "#  frames and sends them over eth0.       #"
      echo -e "#                                         #"
      echo -e "#  eth0 joins 239.1.1.1 to receive VXLAN  #"
      echo -e "#  encapsulated frames from other VXLAN   #"
      echo -e "#  endpoints that use the same multicast  #"
      echo -e "#  group for BUM traffic                  #"
      echo -e "#                                         #"
      echo -e "###########################################\n"

      read -p $'\n'"Do you want to know what BUM traffic is? (y/n): " choice
      if [[ $choice == "y" ]]; then
        echo -e "\nBUM traffic refers to three types of network traffic:"
        echo -e "${YELLOW}Broadcast${NC}: Messages sent to all devices on a network segment."
        echo -e "${YELLOW}Unknown unicast${NC}: Packets addressed to a specific MAC address not in the switch's MAC address table."
        echo -e "${YELLOW}Multicast${NC}: Data sent from one source to multiple destinations using IP multicast addresses."
        echo -e "\nIn VXLAN networks, BUM traffic encapsulated within VXLAN frames is crucial for ensuring efficient communication among virtual machines across different subnets or physical networks."
      fi

  for router_id in "${!router_container_ids[@]}"; do
    container_id="${router_container_ids[$router_id]}"
    hostname=$(docker exec $container_id hostname)
    read -p $'\n'"Do you want to check the multicast group memberships in $hostname? (y/n): " choice

    if [[ $choice == "y" ]]; then
      echo -e "As a confirmation that eth0 successfully joined the 239.1.1.1 group to receive VXLAN encapsulated frames from other VXLAN endpoints,"
      echo "executing the command 'ip maddr show' for router $hostname:"
      docker exec $container_id sh -c "ip maddr show"
      echo -e "\n${GREEN}Command executed.${NC}"
    fi
  done
  echo "\n"
  read -p "Type 'info' to learn more about multicast addresses: " choice
    if [[ $choice == "info" ]]; then
      echo -e "\n###########################################"
      echo -e "#                                         #"
      echo -e "#  Multicast addresses deliver data to a  #"
      echo -e "#  group of devices simultaneously,       #"
      echo -e "#  enabling efficient distribution        #"
      echo -e "#  without multiple unicast transmissions,#"
      echo -e "#  used for multimedia streaming and      #"
      echo -e "#  protocols like VXLAN.                  #"
      echo -e "#                                         #"
      echo -e "###########################################\n"
      echo -e "\nBoth ${YELLOW}239.1.1.1${NC} and ${YELLOW}224.0.0.1${NC} have standardized uses in networking"
      echo -e "\n${YELLOW}239.1.1.1${NC}: used specifically within VXLAN deployments for multicast group communication."
      echo -e "It's used to send VXLAN encapsulated traffic between VXLAN tunnel endpoints (VTEPs)"
      echo -e "\n${YELLOW}224.0.0.1${NC}:  well-known IPv4 multicast address designated for all systems on a subnet to receive control-plane information"
      echo -e "It's used for protocols like ICMP and is part of the reserved range of multicast addresses defined by IANA (Internet Assigned Numbers Authority)."
    fi
  exit 0
else
  echo "No running containers"
  exit 1
fi
