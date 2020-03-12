# Infrastructure for the PRM Deductions Application


# VPN

## Generating VPN client keys

On the VPN server run:

```
docker run -v /var/nhs/openvpn:/etc/openvpn --rm -ti kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
```

Then get archive of certificates
```
docker run -v /var/nhs/openvpn:/etc/openvpn --rm -ti kylemanna/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
```

Getting all client keys at once:
```
docker run --rm -it -v /var/nhs/openvpn/:/etc/openvpn --volume /home/ubuntu/openvpn_clients:/etc/openvpn/clients kylemanna/openvpn ovpn_getclient_all
```

Add stunnel key to the collection:
```
sudo cp /etc/stunnel/*-stunnel.pem /home/ubuntu/openvpn_clients
```

Then distribute `/home/ubuntu/openvpn_clients` to all clients.
