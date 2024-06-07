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
- exit and log back in for the changes to take effects

## Docker image with busybox
    ## Busybox
    -

    ## Steps
    - we create a Dockerfile with a light distro (Alpine)
    - we install busybox
    - we build the image: `docker build -t alpine-busybox .`

## Docker image with Quagga, Busybox, services BGPD, OSFPD and IS-IS active 
    ## Quagga
    - Quagga is a network routing software suite providing implementations of Open Shortest Path First (OSPF), Routing Information Protocol (RIP), Border Gateway Protocol (BGP) and IS-IS for Unix-like platforms.
    - It has been created as a fork of Zebra (discontinued in 2005)
    - The Quagga architecture consists of a core daemon (zebra) which is an abstraction layer to the underlying Unix kernel and presents the Zserv API over a Unix-domain socket or TCP socket to Quagga clients. The Zserv clients typically implement a routing protocol and communicate routing updates to the zebra daemon.
    - curiosity: quagga is the name of an extinct sub-species of the African zebra.
    - [ref](https://www.openmaniak.com/fr/quagga.php)
    - [tuto](https://www.nongnu.org/quagga/docs/quagga.html)

    ## Steps 
    - we create a Dockerfile that install Quagga and busybox
    - we give the instruction to activate the services daemons modifying the /etc/quagga/daemons
    - we create a basic quagga conf:
        - host basic conf [ref](https://www.nongnu.org/quagga/docs/docs-multi/Sample-Config-File.html) 
        - BGP(IPv4): [ref](https://www.jamieweb.net/blog/bgp-routing-security-part-1-bgp-peering-with-quagga/#configuring-bgp-ipv4) 
        - OSPF [ref](https://www.nongnu.org/quagga/docs/docs-multi/OSPF-Configuration-Examples.html)
        - ISIS [ref](https://www.nongnu.org/quagga/docs/docs-multi/ISIS-Configuration-Examples.html)
    - we add the instructions in the Dockerfile to copy the conf within the image for it to be parsed

    # Services
    ## OSPF 
    - it is typically used within an Autonomous System (AS) to manage routing inside the network. It is an interior gateway protocol (IGP) and is very efficient for handling internal network routing.
    ## BGP
    - is used to route between different Autonomous Systems. It is an exterior gateway protocol (EGP) and is primarily used for managing how packets are routed across the internet and between large networks.

