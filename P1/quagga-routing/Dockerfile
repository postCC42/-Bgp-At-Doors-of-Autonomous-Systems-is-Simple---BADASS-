FROM ubuntu:latest
RUN apt-get update && apt-get install -y quagga busybox
# Enable services
RUN echo "zebra=yes\nbgpd=yes\nospfd=yes\nisisd=yes" > /etc/quagga/daemons
COPY quagga.conf /etc/quagga/