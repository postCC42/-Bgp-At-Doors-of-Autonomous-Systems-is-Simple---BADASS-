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
    - BusyBox is a software suite commonly used in embedded systems and Unix-like operating systems. It provides several stripped-down Unix tools bundled into a single executable file, reducing the footprint and resource requirements of the system.

    ## Steps
    - we create a Dockerfile with a light distro (Alpine)
    - we install busybox
    - we build the image: `docker build -t alpine-busybox .`

## Docker image with FRR, Busybox, services BGPD, OSFPD and IS-IS active 

    # FRR
    FRR (Free Range Routing) is an open-source routing software suite providing a comprehensive suite of routing protocols. It is a fork of Quagga, developed to incorporate modern network requirements and features faster.
    
    # Services
    ## OSPF 
    - it is typically used within an Autonomous System (AS) to manage routing inside the network. It is an interior gateway protocol (IGP) and is very efficient for handling internal network routing.
    ## BGP
    - is used to route between different Autonomous Systems. It is an exterior gateway protocol (EGP) and is primarily used for managing how packets are routed across the internet and between large networks.
    ## IS-IS
    - ISIS (Intermediate System to Intermediate System) is a routing protocol used in computer networks, particularly within Internet Service Provider (ISP) networks. It is designed to route IP packets efficiently within a large and complex network, providing fast convergence and scalability

    # Why OSPF, BGP and IS-IS together in this project ?
    - Each protocol serves different functions in a network. OSPF is typically used for internal routing within an Autonomous System (AS), BGP is used for routing between different ASes, and ISIS can provide additional routing capabilities or act as an alternative to OSPF. Having all three protocols integrated allows for a comprehensive routing soluti


    ## Steps
    - Create a dockerfile that pull the frr image from [here](https://hub.docker.com/r/frrouting/frr/tags)
    - add instruction to install busybox
    - add instruction to replace in the daemon conf file the activation state of bgp ospf isis daemons with "yes"
    - `docker build -t router-mpagani .`
    - `docker run -d --name router router-mpagani`
    - to check if services are running within the container: `dokcer exec -it router bash`, then `ps aux` and `| grep` the services

    # Previous project version

    ## Quagga install (used at the beginning of the project and then replaced by frr)
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
    - build the docker image: `docker build -t quagga-routing .`