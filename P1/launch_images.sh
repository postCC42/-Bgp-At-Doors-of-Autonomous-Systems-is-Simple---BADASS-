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


echo "Building and running host_${login}..."
cd host
docker build -t host_${login} .
docker run -d --name host -d host_${login}

echo "Building and running router_${login}..."
cd ../router
docker build -t router_${login} .
docker run --name router -d --rm router_${login}

echo "Both Host and Router containers are up and running."
