# CmangosWotLK

Unofficial Mangos WotLK docker container

contains:
```
realmd for managing realm
Cmangos WotLK emulator
mariadb for hosting the database
nginx for mangosweb enhanced v4.03
```

up and running with 2 simple scripts
run the container like this.

```
docker run \
--name=wotlk \
-d \
-p 80:80 \
-p 8085:8085 \
-p 3724:3724 \
-p 3443:3443 \
-e PUID=0 -e PGID=0 \
-e WAN_IP_ADDRESS=127.0.0.1 \
-e DOCKER_HOST_IP=192.168.1.210 \
-e MYSQL_ROOT_PASSWORD=mangos \
-e TZ=Europe/Paris \
-v /your/location/your-wow-3.3.5a-client:/wow \
-v /your/location/config:/config \
--restart always \
brouzuf/cmangostwo
```
when it's running type the following in your prompt
```
docker exec -it wotlk /bin/bash
```
Now you will be connected to the docker container.
```
/install/InstallDatabases.sh
```
This will generate the database in the mariadb database

```
/install/InstallWowfiles.sh
```
This will generate the DBC, MAPS, MMAPS, VMAPS.
They will be moved to your /config directory

browse to yourdockerip:80 and setup the mangosweb website.

If you have chosen a different password as root sql password, edit your realmd.conf and mangosd.conf in your /config/wowfiles directory
```
docker restart wotlk
```
Now everything is done.

You will have a working Cmangos woltk up and running in a docker container.

Every file is linked and/or moved to the /config directory so settings, wowfiles, databases, will persist container destruction or upgrades.

this is an automated build, which will automatically build the latest version of mangos two.

automatic database upgrades on startup is in the works

# Remote Admin
You need to have a GM level 3 account to access the remote admin port.
Create one the following way.

```
docker exec -it wotlk /mangos/mangosd -c /config/wowconfig/console.conf
```

This will run a Cmangos config on another port with console enabled.
Essentially connecting you to the Cmangos console.
You can do this while your production Cmangos is running. 

Now create your GM account (or just elevate your current account)

```
account create gmadmin Y0UB4HDSTR0NGP4SSW0RD
account set gmlevel gmadmin 3
```

*// You can now connect with telnet to port 3443 with your gm account for abuse of GM power ;) //


# Optional

After generating the wowfiles, you don't need to have linked your wow installation client anymore.

remove the docker container with:
docker rm woltk -f

now re-run it with:
```
docker run \
--name=wotlk \
-d \
-p 80:80 \
-p 8085:8085 \
-p 3724:3724 \
-p 3443:3443 \
-e PUID=0 -e PGID=0 \
-e WAN_IP_ADDRESS=127.0.0.1 \
-e DOCKER_HOST_IP=192.168.1.210 \
-e MYSQL_ROOT_PASSWORD=mangos \
-e TZ=Europe/Paris \
-v /your/location/config:/config \
--restart always \
brouzuf/cmangostwo
```
Parameter breakdown:

```
docker run \
--name=wotlk \ #you can chose your own name here
-d \ #run as daemon
-p 80:80 \ #nginx web port
-p 8085:8085 \ #mangos port
-p 3724:3724 \ #realmd port
-p 3443:3443 \ #Remote Admin port (telnet)
-e PUID=0 -e PGID=0 \ #root
-e WAN_IP_ADDRESS=127.0.0.1 \ #if you want to port forward for external connection, change to your internet ip address. this address can be updated by running /install/InstallDatabases.sh
-e DOCKER_HOST_IP=192.168.1.210 \ #ip address of your docker host
-e MYSQL_ROOT_PASSWORD=mangos \ #root password of database
-e TZ=Europe/Paris \ #timezone of your docker host
-v /your/location/your-wowv-3.3.5a-client:/wow \ #location to your wow client.
-v /your/location/config:/config \ #location where config files are stored
--restart always \ #automatically start when docker host restarts
brouzuf/cmangostwo
```
NB: Localized DB : https://metagit.org/blizzlike/cmangos-wotlk-db-localized
