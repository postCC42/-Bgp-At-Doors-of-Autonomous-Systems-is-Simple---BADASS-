#!/bin/bash

# check if Docker and GNS3 are installed
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists gns3; then
    echo "Installing GNS3..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-pyqt5 qemu-kvm qemu-utils libvirt-clients libvirt-daemon-system virtinst bridge-utils
    sudo add-apt-repository ppa:gns3/ppa
    sudo apt-get update
    sudo apt-get install -y gns3-gui gns3-server
else
    echo "GNS3 is already installed."
fi

if ! command_exists docker; then
    echo "Installing Docker..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo "Docker installed. Please log out and log back in for the changes to take effect."
else
    echo "Docker is already installed."
fi

# build and run the images
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
