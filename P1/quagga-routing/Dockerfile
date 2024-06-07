FROM kathara/quagga

RUN apt-get update && apt-get install -y busybox

# Enable services
RUN echo "zebra=yes\nbgpd=yes\nospfd=yes\nisisd=yes" > /etc/quagga/daemons
COPY quagga.conf /etc/quagga/
