FROM kylemanna/openvpn

# Expose the OpenVPN service port
EXPOSE 1194/udp
# Expose the Admin UI port (if using a web interface)
EXPOSE 943/tcp

CMD ["ovpn_run"]