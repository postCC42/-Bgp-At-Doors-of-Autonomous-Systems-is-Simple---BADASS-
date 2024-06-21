# P3

## Ref
- [BGP rfc-7432](https://www.rfc-editor.org/rfc/rfc7432.html)

## Config
- import project in gns3 and activate the network
- access a router container in -it mode and type `vtysh`: vtysh is the primary CLI tool to configure and manage FRRouting daemons. It provides a unified interface to configure Zebra, BGP, OSPF, ISIS, and static routes.
- we enter in config mode

## Overview
- Configure OSPF for IP routing:
    Ensure all VTEPs (leaf switches) and the route reflector (RR) have IP connectivity using OSPF.
- Configure BGP (or MP-BGP, it's the same, multi protocol BGP) with EVPN for MAC address learning and advertisement over a VXLAN network:
    Enable MP-BGP on the VTEPs and the route reflector.
    Configure the EVPN address family within BGP.

## BGP
- The primary goal of BGP is exchange routing information inter AS (Autonomous systems), each of them managed by a single service provider => EGP family, eternal gateay protocol
- Instead of just handling IP routing information, BGP (specifically, MP-BGP for EVPN) is used to learn and advertise MAC addresses. This enables Layer 2 connectivity over a Layer 3 infrastructure, such as IP networks.
- Routing Policies: BGP allows administrators to define routing policies that control how routes are advertised and selected. This can be based on various factors like path attributes, prefix lengths, and policies that prefer certain paths over others.
- Path Vector Protocol: BGP uses a variety of path attributes (such as AS Path, Next Hop, and Multi-Exit Discriminator) to determine the best path to a destination. This provides flexibility in route selection and enables complex routing decisions.
- Loop Prevention: The AS Path attribute helps prevent routing loops by maintaining a list of ASes that a route has traversed.

## EvPN and Route Type 2
- Route Types in EVPN
    - Route Type 1: Ethernet Auto-Discovery (A-D) Route
    - Route Type 2: MAC/IP Advertisement Route
    - Route Type 3: Inclusive Multicast Ethernet Tag Route
    - Route Type 4: Ethernet Segment Route
    - Route Type 5: IP Prefix Route

- Route Type 2: MAC/IP Advertisement Route
    A Route Type 2 in EVPN, also known as the MAC/IP Advertisement route, is used to advertise the association between a MAC address and an IP address in the VXLAN network. This route type allows the distribution of Layer 2 and Layer 3 reachability information.

- Key Components of Route Type 2:
    - MAC Address: The MAC address of the device in the VXLAN.
    - IP Address: The IP address associated with the MAC address, if applicable.
    - Ethernet Tag ID: Used for identifying the Layer 2 segment in the EVPN instance.
    - VNI (VXLAN Network Identifier): Used to identify the VXLAN segment.
    - ESI (Ethernet Segment Identifier): Optional, used if the MAC address is part of a multi-homed Ethernet     Segment.
- Role of RR (Route Reflector)
    - The Route Reflector (RR) is a component in the BGP (Border Gateway Protocol) that helps in reducing the number of BGP peer connections by reflecting routes between clients.
    - the RR is responsible for generating and distributing the Route Type 2 advertisements to other VTEPs (VXLAN Tunnel Endpoints) in the network.

## Internet Service Providers
- ISPs manage one or more ASes, providing connectivity to customers, including individuals, businesses, and other ISPs. They route data packets between different ASes across the internet.
- ISPs use Border Gateway Protocol (BGP) to exchange routing information between ASes.
- BGP enables ISPs to determine the best paths for data to travel across the complex web of networks that make up the internet.

## useful cmds and how to read outputs
- `do sh ip route`
    - ouput example: `O>* 1.1.1.1/32 [110/10] via 10.1.1.9, eth2, weight 1, 00:01:05`
    - Protocol: O: Indicates that the route is learned via OSPF.
    - Route Selection Indicator: >* > indicates that this route is the currently selected route among OSPF-learned routes.
    - Network Address: 1.1.1.1/32 : The destination network address with its subnet mask (/32).
    - OSPF Metrics: [110/10]: 110 is the administrative distance of OSPF.
    10 is the OSPF metric for this route.
    - Next Hop: via 10.1.1.9. Specifies the IP address of the next hop router.
    - Outgoing Interface: eth2, how to reach the next hop.
    - Route Weight: weight 1: Weight assigned to this route within OSPF.
    - Time: 00:01:05: Time elapsed since this route was last updated or refreshed.
- `do sh bgp summary`
    - Neighbor: Refers to the BGP neighbor router (in this case, 1.1.1.1).
    - V: BGP protocol version (4 indicates BGP version 4).
    - BGP table: Also known as the BGP routing table, it holds all the BGP-learned routes.
    - RIB (Routing Information Base): It's the main database that stores routes learned from all routing protocols, including BGP.
    - RIB entries: Number of routes currently stored in the BGP routing table.
    - Memory usage: Amount of memory (in KiB) used by the BGP process to maintain routing information.
    - State/PfxRcd: BGP session state and number of prefixes received from the neighbor.
- `do sh bgp l2vpn evpn`: For each route distinguisher (RD), it shows the associated prefixes and their attributes.
    -  "prefixes" refer to the network layer reachability information advertised and exchanged between BGP routers.
        - example:
            - Type-3 prefix ([3]:[0]:[32]:[1.1.1.2])
            - Next hop is 1.1.1.2 with metric 0, Local Preference (LocPrf) 100, and Weight 0.
            - Originated locally (i).
        - NB for type-2 prefix we have just MAC address
        - NB: Without explicitly assigning an IP address to the VTEP (Virtual Tunnel Endpoint), the VTEP is able to discover MAC addresses of functional machines (endpoints) in the network.
