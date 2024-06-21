#!/bin/bash

# Check if Docker and GNS3 are installed
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
    sudo usermod -aG ubridge $USER
    sudo usermod -aG libvirt $USER
    sudo usermod -aG wireshark $USER
    newgrp ubridge
    newgrp libvirt
    newgrp wireshark
else
    echo "GNS3 is already installed."
fi

if ! command_exists docker; then
    echo "Installing Docker..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    newgrp docker # Apply the new group membership without logging out
    echo "Docker installed."
else
    echo "Docker is already installed."
fi
