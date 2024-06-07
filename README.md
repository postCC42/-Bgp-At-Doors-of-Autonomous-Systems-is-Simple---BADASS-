# Bgp At Doors of Autonomous Systems is Simple ( BADASS )

## Quagga
- Quagga is a network routing software suite providing implementations of Open Shortest Path First (OSPF), Routing Information Protocol (RIP), Border Gateway Protocol (BGP) and IS-IS for Unix-like platforms.
- It has been created as a fork of Zebra (discontinued in 2005)
- The Quagga architecture consists of a core daemon (zebra) which is an abstraction layer to the underlying Unix kernel and presents the Zserv API over a Unix-domain socket or TCP socket to Quagga clients. The Zserv clients typically implement a routing protocol and communicate routing updates to the zebra daemon.
- curiosity: quagga is the name of an extinct sub-species of the African zebra.
- [ref](https://www.openmaniak.com/fr/quagga.php)