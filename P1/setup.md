# P1

## Install GNS3 on VM (Ubuntu 22.04 in our case)
- install Depepndencies:
    ```
    sudo apt-get install -y python3 python3-pip python3-pyqt5 qemu-kvm qemu-utils libvirt-clients libvirt-daemon-system virtinst bridge-utils
    ```
- Add GNS3 Repo
    ```
    sudo add-apt-repository ppa:gns3/ppa
    sudo apt-get update
    ```
- Install GNS3
    `sudo apt-get install -y gns3-gui gns3-server`

## Install Docker
-   ```
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    ```
- log out and log back in for the changes to take effects
