
FROM frrouting/frr:v8.4.1

RUN apk add --no-cache busybox

RUN echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf

RUN sed -i -e "s/^bgpd=no/bgpd=yes/; s/^ospfd=no/ospfd=yes/; s/^isisd=no/isisd=yes/" /etc/frr/daemons

