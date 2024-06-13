#!/bin/bash

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


echo "Building host_${login}..."
cd host
if docker build -t host_${login} .; then
    echo "Host image built successfully."
else
    echo "Error: Failed to build host_${login}."
    exit 1
fi

echo "Building router_${login}..."
cd ../router
if docker build -t router_${login} .; then
    echo "Router image built successfully."
else
    echo "Error: Failed to build router_${login}."
    exit 1
fi

echo "Both Host and Router images are built for gns3 to run them."
