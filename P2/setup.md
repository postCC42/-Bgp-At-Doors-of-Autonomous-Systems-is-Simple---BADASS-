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
