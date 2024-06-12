# P2

- we create a switch ethernet (8 ports by default, should we set 2 ?)
- we add 2 routers (update adapters to 2)
- we add 2 hosts

## setting up router and host to create a VXLAN in static broadcast
- hosts
    - launch the network (play button)
    - click on auxiliary console on the host
    - `ip a` allows us to check the network interfaces in the newly created machine.
        - `lo` : Loopback Interface
        The loopback interface is a special, virtual network interface that a computer uses to communicate with itself. It is primarily used for testing and network management purposes. 
        - `eth0` Ethernet Interface
        An Ethernet interface is a physical network interface used to connect a computer to a local area network (LAN). It is one of the most common types of network interfaces used in wired networking.
    - we change the name of the eth network interface to eth1 to match the exercise schema and assign the IP address 30.1.1.1 to the network interface eth1.
    - The /24 subnet mask indicates that the network portion of the IP address is 30.1.1, allowing for 256 addresses (from 30.1.1.0 to 30.1.1.255), where 30.1.1.0 is the network address and 30.1.1.255 is the broadcast address.

    ```
    ip link set eth0 down
    ip link set eth0 name eth1
    ip link set eth1 up
    ip addr add 30.1.1.1/24 dev eth1
    ```
    - we do the same for host_2, assigning the IP address 30.1.1.1/24
- routers
    - we assign toward the switch an ip address in the same network of the one set in the hosts to communicate to router (30.1.1.0/24), the same in both the routers: `ip addr add 30.1.1.3 dev eth1`
    - we assign toward the hosts an ip address in the network 10.1.1.1/24 for a distinct path  and a separation of traffic:
    - `ip addr add 10.1.1.1/24 dev eth0` in router 1 toward host 1 (eth0)
    - `ip addr add 10.1.1.2/24 dev eth0` in router 2 toward host 2 (eth0)
    NB: The 10.0.0.0/8 block is designated for private use (RFC 1918), which means any IP address in the range 10.0.0.0 to 10.255.255.255 can be used within a private network without conflicting with other networks