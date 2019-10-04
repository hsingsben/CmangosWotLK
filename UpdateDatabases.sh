#!/bin/sh
##############################################################################
# This utility assist you in setting up your mangos database.                #
# This is a port of InstallDatabases.bat written by Antz for Windows         #
#                                                                            #
##############################################################################



printf "Updating Docker Host IP and/or WAN IP into realm database\n"
printf "\n"
echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET localAddress='"'$DOCKER_HOST_IP'" 'WHERE id='1'';'\' > /install/updateip.sh
echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET address='"'$WAN_IP_ADDRESS'" 'WHERE id='1'';'\' >> /install/updateip.sh
chmod +x /install/updateip.sh
/install/updateip.sh
printf "Updated Docker Host IP into realm database\n"
printf "\n"
