# VPN (PPTP) for Docker

This Docker image uses the following environment variable(s), that can be declared in an env file (see vpn.env.example file):
```
VPN_USER_CREDENTIAL_LIST=[{"login":"userTest1","password":"test1"},{"login":"userTest2","password":"test2"}]
```
- `VPN_USER_CREDENTIAL_LIST `: Multiple users VPN credentials list. Users login and password must be defined in a json format array. Each user should be define with a "login" and a "password" attribute.


## Starting VPN server
Firstly,build image if necessary:
```
docker build -t ecat/docker-vpn-pptp .
```
Or pull it (recommended):
```
docker pull ecat/docker-vpn-pptp
```
To start VPN server as a docker container run:

````
docker run -d --privileged \
           -p 1723:1723 \
           --env-file ./vpn.env \
           --name docker-vpn-pptp \
           ecat/docker-vpn-pptp
````


## Connecting to VPN service
You can use any VPN (PPTP) client to connect to the service.
To authenticate use credentials provided in **vpn.env** file.


