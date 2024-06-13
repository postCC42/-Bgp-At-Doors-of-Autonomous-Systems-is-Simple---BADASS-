# Bgp At Doors of Autonomous Systems is Simple ( BADASS )

## Important
- this project scripts are tested on VM VMWare running Ubuntu 24.04 or 22.04 as OS
## Walkthrough
- [P1](P1/setup.md)
- [P2](P2/setup.md)
<br><br>

## Overview
- for an overview of how Routing Tables work: `show ip route`: [ref](https://www.youtube.com/watch?v=uKiM9-tGuc4)
- for an overview on routing, the funniest and easier to understand we find: [here](https://www.youtube.com/watch?v=kyMoEgdMbH8)

### AUTONOMOUS SYSTEMS (AS)
- A collection of IP networks and routers under the control of a single organization that presents a common routing policy to the internet.

### LAN, VLAN, VXLAN, AS
**Key differences**
- LAN vs. VLAN:

  - LAN: Physical network connecting devices within a limited area.
  - VLAN: Logical segmentation within a physical LAN, isolating traffic for security and performance.

- VLAN vs. VXLAN:
  - VLAN: Limited to 4096 segments, confined to a single Layer 2 network, ideal for small to medium-sized networks.
  - VXLAN: Supports up to 16 million segments, extends Layer 2 networks over Layer 3 infrastructure, ideal for large-scale data centers and cloud environments.
 
- LAN vs. AS:

  - Scope: LAN is confined to a small area, while an AS can span large geographic areas and include multiple networks.
  - Components: LAN includes local devices and simple network infrastructure; AS includes multiple networks and routers with sophisticated routing policies.
  - Purpose: LAN focuses on local communication and resource sharing; AS focuses on global routing and traffic management.

- VXLAN vs. AS:

  - Scope: VXLAN extends virtual networks across large data centers; AS includes multiple physical and logical networks across broader areas.
  - Components: VXLAN involves virtualization technologies and overlays; AS involves physical and logical networks with advanced routing protocols.
  - Purpose: VXLAN facilitates network virtualization and scalability in data centers; AS ensures efficient and reliable routing of IP traffic across multiple networks.
  - Relationship: VXLANs can be used within an AS to manage large-scale data centers and virtual networks, while the AS manages overall routing policies and connectivity to the internet.
 


  
