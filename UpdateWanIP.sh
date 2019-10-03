echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET localAddress='"'$DOCKER_HOST_IP'" 'WHERE id='1'';'\' > /install/updateip.sh
echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET address='"'$WAN_IP_ADDRESS'" 'WHERE id='1'';'\' >> /install/updateip.sh
chmod +x /install/updateip.sh
/install/updateip.sh
