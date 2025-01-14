#!/bin/bash

EASYRSA_DIR=/etc/openvpn/easy-rsa
OPENVPN_CONFIG_DIR=/etc/openvpn

if [ -z "$1" ]; then
  echo "Usage: $0 <client-name>"
  exit 1
fi

CLIENT_NAME=$1

cd $EASYRSA_DIR
./easyrsa build-client-full $CLIENT_NAME nopass
cp pki/issued/$CLIENT_NAME.crt pki/private/$CLIENT_NAME.key $OPENVPN_CONFIG_DIR