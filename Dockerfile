# Use a lightweight Linux base image
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OPENVPN_CONFIG_DIR=/etc/openvpn
ENV EASYRSA_DIR=/etc/openvpn/easy-rsa
ENV OVPN_NETWORK=10.8.0.0/24
ENV OVPN_PORT=1194

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openvpn \
    easy-rsa \
    iproute2 \
    iptables \
    net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create OpenVPN and EasyRSA directories
RUN mkdir -p $OPENVPN_CONFIG_DIR && \
    mkdir -p $EASYRSA_DIR && \
    ln -s /usr/share/easy-rsa/* $EASYRSA_DIR

# Copy default server configuration template
COPY server.conf $OPENVPN_CONFIG_DIR/server.conf

# Configure EasyRSA
WORKDIR $EASYRSA_DIR
RUN ./easyrsa init-pki && \
    ./easyrsa build-ca nopass && \
    ./easyrsa gen-dh && \
    ./easyrsa build-server-full server nopass && \
    ./easyrsa gen-crl

# Copy certificates and keys to the OpenVPN directory
RUN cp pki/ca.crt pki/dh.pem pki/issued/server.crt pki/private/server.key $OPENVPN_CONFIG_DIR && \
    cp pki/crl.pem $OPENVPN_CONFIG_DIR && \
    chmod 644 $OPENVPN_CONFIG_DIR/crl.pem

# Configure server.conf for OpenVPN
RUN sed -i 's/^;tls-auth/tls-auth/' $OPENVPN_CONFIG_DIR/server.conf && \
    sed -i 's/^cipher AES-256-CBC/cipher AES-256-GCM/' $OPENVPN_CONFIG_DIR/server.conf && \
    sed -i 's/^;user nobody/user nobody/' $OPENVPN_CONFIG_DIR/server.conf && \
    sed -i 's/^;group nogroup/group nogroup/' $OPENVPN_CONFIG_DIR/server.conf

# Expose the OpenVPN port
EXPOSE $OVPN_PORT/udp

# Script to add new users
COPY add_user.sh /usr/local/bin/add_user.sh
RUN chmod +x /usr/local/bin/add_user.sh

# Start OpenVPN server
CMD ["openvpn", "--config", "/etc/openvpn/server.conf"]