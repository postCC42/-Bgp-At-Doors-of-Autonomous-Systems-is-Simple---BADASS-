#!/bin/bash

# to be executed after having imported the P3.gns3project into gns3 and activated the network with play button (this creates the container on VM)

GREEN='\033[1;92m'
YELLOW='\033[1;93m'
NC='\033[0m' # No Color

CONFIG_FILE_ROUTER_1="router_1.conf"
CONFIG_FILE_ROUTER_2="router_2.conf"
CONFIG_FILE_ROUTER_3="router_3.conf"
CONFIG_FILE_ROUTER_4="router_4.conf"

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
                docker exec $container_id sh -c "ip addr add 20.1.1.1/24 dev eth1" && echo -e "${GREEN}Success: Assigned IP address 20.1.1.1/24 to eth1${NC}" || echo "Error: Failed to assign IP address 20.1.1.1/24 to eth1"
            elif [[ $hostname == "host_mpagani-2" ]]; then
                docker exec $container_id sh -c "ip addr add 20.1.1.2/24 dev eth0" && echo -e "${GREEN}Success: Assigned IP address 20.1.1.2/24 to eth0${NC}" || echo "Error: Failed to assign IP address 20.1.1.2/24 to eth0"
            elif [[ $hostname == "host_mpagani-3" ]]; then
                docker exec $container_id sh -c "ip addr add 20.1.1.3/24 dev eth0" && echo -e "${GREEN}Success: Assigned IP address 20.1.1.3/24 to eth0${NC}" || echo "Error: Failed to assign IP address 20.1.1.3/24 to eth0"
            fi
            ;;
        router_mpagani-*)
            # Get network interfaces and their MAC addresses
            echo "Configuring router $hostname:"
            docker exec $container_id sh -c "ip link show | awk '/^[0-9]+: / {iface=\$2} /ether/ {print iface, \$2}'"
            # Assign IP address based on hostname
            case $hostname in
                router_mpagani-1)
                    # Copy configuration file to the container
                    docker cp $CONFIG_FILE_ROUTER_1 $container_id:/tmp/router.conf
                    # Execute the configuration file
                    docker exec -it $container_id ash /tmp/router.conf && echo -e "${GREEN}Success: Configured router $hostname${NC}" || echo "Error: Failed to configure router $hostname"
                    ;;
                router_mpagani-2)
                    docker exec $container_id sh -c "
                        ip link add name vxlan10 type vxlan id 10 dev eth0 dstport 4789
                        ip link set dev vxlan10 up
                        ip link add name br0 type bridge
                        ip link set dev br0 up
                        brctl addif br0 eth1
                        brctl addif br0 vxlan10
                    "
                    echo -e "${GREEN}Success: Configured VXLAN and bridge for $hostname${NC}"
                    # Copy configuration file to the container
                    docker cp $CONFIG_FILE_ROUTER_2 $container_id:/tmp/router.conf
                    # Execute the configuration file
                    docker exec -it $container_id ash /tmp/router.conf && echo -e "${GREEN}Success: Configured router $hostname${NC}" || echo "Error: Failed to configure router $hostname"
                    ;;
                router_mpagani-3)
                    docker exec $container_id sh -c "
                        ip link add name vxlan10 type vxlan id 10 dev eth1 dstport 4789
                        ip link set dev vxlan10 up
                        ip link add name br0 type bridge
                        ip link set dev br0 up
                        brctl addif br0 eth0
                        brctl addif br0 vxlan10
                    "
                    echo -e "${GREEN}Success: Configured VXLAN and bridge for $hostname${NC}"
                    # Copy configuration file to the container
                    docker cp $CONFIG_FILE_ROUTER_3 $container_id:/tmp/router.conf
                    # Execute the configuration file
                    docker exec -it $container_id ash /tmp/router.conf && echo -e "${GREEN}Success: Configured router $hostname${NC}" || echo "Error: Failed to configure router $hostname"
                    ;;
                router_mpagani-4)
                    docker exec $container_id sh -c "
                        ip link add name vxlan10 type vxlan id 10 dev eth2 dstport 4789
                        ip link set dev vxlan10 up
                        ip link add name br0 type bridge
                        ip link set dev br0 up
                        brctl addif br0 eth0
                        brctl addif br0 vxlan10
                    "
                    echo -e "${GREEN}Success: Configured VXLAN and bridge for $hostname${NC}"
                    # Copy configuration file to the container
                    docker cp $CONFIG_FILE_ROUTER_4 $container_id:/tmp/router.conf
                    # Execute the configuration file
                    docker exec -it $container_id ash /tmp/router.conf && echo -e "${GREEN}Success: Configured router $hostname${NC}" || echo "Error: Failed to configure router $hostname"
                    ;;
            esac
            ;;
    esac
  done
else
  echo "No running Docker containers found."
fi
