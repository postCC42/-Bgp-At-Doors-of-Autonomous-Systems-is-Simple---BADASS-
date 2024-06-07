
FROM frrouting/frr:v8.4.1

RUN apk add --no-cache busybox

RUN sed -i -e "s/^bgpd=no/bgpd=yes/; s/^ospfd=no/ospfd=yes/; s/^isisd=no/isisd=yes/" /etc/frr/daemons

