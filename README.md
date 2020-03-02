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
