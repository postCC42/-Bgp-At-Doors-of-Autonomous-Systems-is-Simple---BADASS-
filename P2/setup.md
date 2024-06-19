# P2

## Content tree
```
├── P2
│   ├── 1_setup_static_vxlan.sh
│   ├── 2_setup_dynamic_vxlan.sh
│   ├── get_mac_address.sh
│   ├── P2.gns3project
│   └── setup.md

```
- we create a switch ethernet (8 ports by default)
- we add 2 routers (update adapters to 2)
- we add 2 hosts (2 adapters to work with eth1 as requested)

[tuto](https://www.youtube.com/watch?v=u1ka-S6F9UI)

## setting up router and host to create a VXLAN in static broadcast
before going further let's summarize the state of the network created until now:
- we have a VLAN (a switch connected to 2 routers - eth0/eth0 and eth1/eth0, each of one having an host on eth1/eth1)
- VLAN  operate at layer 2 (data link access-ethernet frames) and allows commyuunication btw devices using their MAC addresses. It has some limits of scalability (12-bit VLAN ID (4096 VLANs), which can be restrictive in large-scale environments such as data centers)
- Routing between VLANs (inter-VLAN routing) typically requires Layer 3 routing devices (routers or Layer 3 switches, that use ip addresses).
- Devices in different VLANs can communicate through routers that route traffic between VLANs based on their IP addresses and MAC addresses(based on MAC address tables).
- we need VXLAN, that create a virtual layer 2 and incapsulate layer 2 frame into layer 3 packets on a large scale thanks to its 24 bit VNI that allow up to 16 million VXLAN segments, keeping the isolation of each vxlan
Focus on why we need a bridge:
- VXLAN is designed to extend Layer 2 networks over a Layer 3 infrastructure. Each router (or more specifically, each VXLAN Tunnel Endpoint - VTEP) acts as a bridge to encapsulate and decapsulate Ethernet frames into VXLAN packets. This encapsulation allows traditional Layer 2 Ethernet frames to be transported across an IP network.

- VXLAN Tunneling: 
The bridge functionality in VTEPs enables the creation of VXLAN tunnels. These tunnels are used to transport Layer 2 traffic over a Layer 3 network. The VTEP bridges the gap between the local Layer 2 domain and the VXLAN tunnel, allowing devices in different Layer 2 domains to communicate as if they were on the same local network.

- MAC Address Learning and Management: 
Bridges in VTEPs are responsible for MAC address learning and management. They maintain a MAC address table that maps MAC addresses to VXLAN tunnels, allowing them to forward traffic to the correct destination VTEP. This is similar to traditional Ethernet bridging but adapted to handle the encapsulated VXLAN traffic.

## set up hosts
- launch the network (play button)
- click on auxiliary console on the host
- `ip a` allows us to check the network interfaces in the newly created machine.
    - `lo` : Loopback Interface
    The loopback interface is a special, virtual network interface that a computer uses to communicate with itself. It is primarily used for testing and network management purposes. 
    - `eth0` Ethernet Interface
    - `eth1` Ethernet Interface
    An Ethernet interface is a physical network interface used to connect a computer to a local area network (LAN). It is one of the most common types of network interfaces used in wired networking.
- we assign the IP address 30.1.1.1 or 30.1.1.2 for host 2 to the network interface eth1.
- The /24 subnet mask indicates that the network portion of the IP address is 30.1.1, allowing for 256 addresses (from 30.1.1.0 to 30.1.1.255), where 30.1.1.0 is the network address and 30.1.1.255 is the broadcast address.

```
ip addr add 30.1.1.1/24 dev eth1
```
- we do the same for host_2, assigning the IP address 30.1.1.2/24
## set up routers
- `ip addr add 10.1.1.1/24 dev eth0` in router 1 toward switch (eth0)
- `ip addr add 10.1.1.2/24 dev eth0` in router 2 toward switch (eth0)
NB: The 10.0.0.0/8 block is designated for private use (RFC 1918), which means any IP address in the range 10.0.0.0 to 10.255.255.255 can be used within a private network without conflicting with other networks
## Static VXLAN setup
- vxlan tunnel between the 2 routers
    - we `ip link add name vxlan10 type vxlan id 10 local 10.1.1.1 remote 10.1.1.2 dstport 4789 dev eth0` (local and remote have to be inversed for router 2):
        - `ip link add vname xlan10`: This creates a new network interface named vxlan10.
        - `type vxlan`: Specifies that the interface is of type VXLAN.
        - `id 10`: The VXLAN Network Identifier (VNI), which is a unique identifier for the VXLAN segment, as the exercise requests
        - `remote 10.1.1.2` or `remote 10.1.1.1`: This is the IP address of the remote VXLAN endpoint, which is the IP address of the opposite router eth0 interface (toward switch).
        - `dstport 4789`: This specifies the UDP port used for VXLAN communication, with 4789 being the IANA-assigned default port for VXLAN.
        - `dev eth0`: This specifies the local network interface to be used for the VXLAN tunnel. We tell router 1 to use its own eth0 interface (with IP 10.1.1.1/24) to send VXLAN packets towards the remote endpoint at 10.1.1.2.
    - then we activate the vxlan: `ip link set dev vxlan10 up`
    - then we need to set a bridge (bridges are used to connect multiple network interfaces together at Layer 2, allowing them to communicate as if they were part of a single network segment):
    ```
    ip link add br0 type bridge
    ip link set dev br0 up
    brctl addif br0 eth1
    brctl addif br0 vxlan10
    ```
## Dynamic multicast VXLAN
in each router we need to
- remove the vxlan created statically (`ip link del vxlan10`)
- execute this command:
`ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789`:
    - `group 239.1.1.1`: Specifies the multicast group IP address (239.1.1.1) that VXLAN traffic will use for communication.
    - `dstport 4789`: Sets the UDP destination port (4789) that VXLAN packets will use for communication.
- readd the br0 to vxlan:
```
ip link set dev vxlan10 up
ip link set dev br0 up
brctl addif br0 vxlan10
```
- to check differences between static and dynamic look at the MAC addresses:
    - Static VXLAN: The MAC address is closer to the underlying Ethernet interface or a fixed value assigned during VXLAN creation.
    - Dynamic Multicast VXLAN: The MAC address  is generated dynamically and  follows a specific pattern for multicast operations.
## Key Points about VXLAN
- Encapsulation:
    VXLAN encapsulates Ethernet frames in UDP packets, allowing Layer 2 traffic to be tunneled over a Layer 3 network (e.g., the Internet or an IP-based LAN).
- VXLAN Tunnel Endpoints (VTEPs):
    VXLAN requires VXLAN Tunnel Endpoints (VTEPs) to encapsulate and decapsulate the Ethernet frames and sends them over an IP network (typically the underlay network).
    Each VTEP is typically a network device (like a router or switch) that terminates VXLAN tunnels.
- Encapsulation: 
    When a VTEP receives a frame destined for a remote VXLAN endpoint, it encapsulates the original Ethernet frame with a VXLAN header. This VXLAN header includes information like VXLAN Network Identifier (VNI), which identifies the specific virtual network (overlay) to which the frame belongs.
- Layer 2 Over Layer 3:
    The primary purpose of VXLAN is to extend Layer 2 networks over a Layer 3 infrastructure.
    This means that devices in different IP subnets can appear to be on the same Ethernet broadcast domain.

## Difference between Static and Dynamic multicast VXLAN

### Static 
- Static Configuration: The VXLAN tunnel (VTEP - VXLAN Tunnel Endpoint) is explicitly configured on each participating network device (typically routers or switches).
- Local and Remote Endpoints: Local and remote VTEPs are specified explicitly with IP addresses (local and remote parameters).
- Unicast Communication: VXLAN packets are unicast between VTEPs based on the explicitly configured remote IP address.
- Use Case: Typically used in scenarios where the VXLAN network is small and the topology is relatively stable, or where manual control over tunnel endpoints is preferred.
- Static VXLAN is suitable for stable network topologies where the VXLAN endpoints remain constant over time.
- Configuration changes require manual intervention to update VXLAN parameters on each affected device.

## Dynamic Multicast
- Dynamic VXLAN typically refers to a deployment where VXLAN endpoints (VTEPs, VXLAN Tunnel Endpoints) dynamically discover each other and communicate using protocols such as multicast.
- VXLAN endpoints join multicast groups dynamically to exchange VXLAN encapsulated traffic.
- This approach allows for flexible and scalable VXLAN deployments, suitable for environments where VXLAN endpoints may change dynamically (e.g., cloud environments, data centers with virtual machine mobility).
- Dynamic Discovery: VXLAN tunnels are established dynamically using a multicast group (group parameter).
- Group Membership: Devices interested in participating in the VXLAN network join the multicast group to receive and send VXLAN packets.
- Multicast Communication: VXLAN packets are multicast to the group address, allowing efficient communication within the VXLAN network without requiring explicit configuration of remote endpoints.
- Use Case: Suitable for larger VXLAN deployments where automatic discovery and scaling are important, or where the network topology may change dynamically.
