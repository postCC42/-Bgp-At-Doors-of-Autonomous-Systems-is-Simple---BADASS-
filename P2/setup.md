# P2

- we create a switch ethernet (8 ports by default)
- we add 2 routers (update adapters to 2)
- we add 2 hosts

[tuto](https://www.youtube.com/watch?v=u1ka-S6F9UI)

## setting up router and host to create a VXLAN in static broadcast
before going further let's summarize the state of the network created until now:
- Even if each host is connected to a different router the eth1 interfaces of each host belong to the same LAN segment and IP subnet (30.1.1.0/24).
- The hosts are on the same LAN segment. They can communicate directly without the need for routing
- hosts
    - launch the network (play button)
    - click on auxiliary console on the host
    - `ip a` allows us to check the network interfaces in the newly created machine.
        - `lo` : Loopback Interface
        The loopback interface is a special, virtual network interface that a computer uses to communicate with itself. It is primarily used for testing and network management purposes. 
        - `eth0` Ethernet Interface
        An Ethernet interface is a physical network interface used to connect a computer to a local area network (LAN). It is one of the most common types of network interfaces used in wired networking.
    - we assign the IP address 30.1.1.1 to the network interface eth0.
    - The /24 subnet mask indicates that the network portion of the IP address is 30.1.1, allowing for 256 addresses (from 30.1.1.0 to 30.1.1.255), where 30.1.1.0 is the network address and 30.1.1.255 is the broadcast address.

    ```
    ip addr add 30.1.1.1/24 dev eth0
    ```
    - we do the same for host_2, assigning the IP address 30.1.1.2/24
- routers
    - we assign toward the switch an ip address in the same network of the one set in the hosts to communicate to router (30.1.1.0/24), : `ip addr add 30.1.1.3/24 dev eth1` in router 1 and `ip addr add 30.1.1.4/24 dev eth1` in router 2
    - we assign toward the hosts an ip address in the network 10.1.1.1/24 for a distinct path  and a separation of traffic:
    - `ip addr add 10.1.1.1/24 dev eth0` in router 1 toward host 1 (eth0)
    - `ip addr add 10.1.1.2/24 dev eth0` in router 2 toward host 2 (eth0)
    NB: The 10.0.0.0/8 block is designated for private use (RFC 1918), which means any IP address in the range 10.0.0.0 to 10.255.255.255 can be used within a private network without conflicting with other networks
- vxlan tunnel between the 2 routers
    - we `ip link add vxlan10 type vxlan id 10 remote 10.1.1.2 (or 10.1.1.1)dstport 4789 dev eth0`:
        - `ip link add vxlan10`: This creates a new network interface named vxlan10.
        - `type vxlan`: Specifies that the interface is of type VXLAN.
        - `id 10`: The VXLAN Network Identifier (VNI), which is a unique identifier for the VXLAN segment, as the exercise requests
        - `remote 10.1.1.2` or `remote 10.1.1.1`: This is the IP address of the remote VXLAN endpoint, which is the IP address of the opposite router eth0 interface.
        - `dstport 4789`: This specifies the UDP port used for VXLAN communication, with 4789 being the IANA-assigned default port for VXLAN.
        - `dev eth0`: This specifies the local network interface to be used for the VXLAN tunnel. We tell router 1 to use its own eth0 interface (with IP 10.1.1.1/24) to send VXLAN packets towards the remote endpoint at 10.1.1.2.
    - then we activate the vxlan: `ip link set vxlan10 up`
    - and we assign vxlan the same ip adress of the eth1 network interface, that point towards the switch : `ip addr add 30.1.1.3/24 dev vxlan10` => By using the same IP address for both interfaces, we can integrate the VXLAN overlay network with the existing network infrastructure
    - then we need to set a bridge:
    ```
    ip link add name br0 type bridge
    ip link set br0 up
    ip link set vxlan10 master br0
    ip link set eth1 master br0
    ```


Key Points about VXLAN
Encapsulation:

VXLAN encapsulates Ethernet frames in UDP packets, allowing Layer 2 traffic to be tunneled over a Layer 3 network (e.g., the Internet or an IP-based LAN).
VXLAN Tunnel Endpoints (VTEPs):

VXLAN requires VXLAN Tunnel Endpoints (VTEPs) to encapsulate and decapsulate the Ethernet frames.
Each VTEP is typically a network device (like a router or switch) that terminates VXLAN tunnels.
Layer 2 Over Layer 3:

The primary purpose of VXLAN is to extend Layer 2 networks over a Layer 3 infrastructure.
This means that devices in different IP subnets can appear to be on the same Ethernet broadcast domain.