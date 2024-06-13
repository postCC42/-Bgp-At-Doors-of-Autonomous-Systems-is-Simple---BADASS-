#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

login="mpagani"

# Check any existing Docker containers and remove
if [ "$(docker ps -aq)" ]; then
  echo "Stopping and removing all Docker containers..."
  docker stop $(docker ps -aq)
  docker rm $(docker ps -aq)
else
  echo "No Docker containers to remove."
fi

# Check any existing Docker images and remove
if [ "$(docker images -q)" ]; then
  echo "Removing all Docker images..."
  docker rmi $(docker images -q) -f
else
  echo "No Docker images to remove."
fi


function image_exists() {
    if [[ "$(docker images -q "$1" 2> /dev/null)" != "" ]]; then
        return 0
    else
        return 1
    fi
}

echo "Checking if host_${login} image exists..."
if image_exists "host_${login}"; then
    echo -e "${GREEN}Host image already exists.${NC}\n"
else
    echo "Building host_${login}..."
    cd host
    if docker build -t host_${login} .; then
        echo -e "${GREEN}Host image built successfully.${NC}\n"
    else
        echo "Error: Failed to build host_${login}.\n"
        exit 1
    fi
    cd ..
fi

echo "Checking if router_${login} image exists..."
if image_exists "router_${login}"; then
    echo -e "${GREEN}Router image already exists.${NC}\n"
else
    echo "Building router_${login}..."
    cd router
    if docker build -t router_${login} .; then
        echo -e "${GREEN}Router image built successfully.${NC}\n"
    else
        echo "Error: Failed to build router_${login}.\n"
        exit 1
    fi
    cd ..
fi
echo -e "\n${YELLOW}###########################################"
echo -e "#                                         #"
echo -e "#  Both Host and Router images are built  #"
echo -e "#  for GNS3 to run them.                  #"
echo -e "#                                         #"
echo -e "###########################################${NC}\n"