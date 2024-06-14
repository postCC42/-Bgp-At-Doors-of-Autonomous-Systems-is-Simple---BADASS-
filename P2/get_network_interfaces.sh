#!/bin/bash

GREEN='\033[1;92m'
YELLOW='\033[1;93m'
NC='\033[0m' # No Color

# Get the list of running Docker container IDs
running_containers=$(docker ps -q)

# Check if there are any running containers
if [[ ! -z $running_containers ]]; then
  for container_id in ${running_containers[@]}; do
    # Get the hostname of the container
    hostname=$(docker exec $container_id hostname)
    
    echo "Container ID: $container_id"
    echo -e "${YELLOW}Hostname: $hostname${NC}"
    echo "Network Interfaces and IP Addresses:"
    
    # Display the full output of `ip a` for the container
    docker exec $container_id ip a
    
    echo "---------------------------"
  done
  exit 0
else
  echo "No running containers"
  exit 1
fi
