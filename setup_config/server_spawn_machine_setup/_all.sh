# keep first line empty!!


sed -i 's/#alias ll/alias ll/g' ~/.bashrc
sed -i 's/#alias la/alias la/g' ~/.bashrc

su - debian -c "sed -i 's/#alias ll/alias ll/g' ~/.bashrc"
su - debian -c "sed -i 's/#alias la/alias la/g' ~/.bashrc"

echo "--- upgrade -------------------------------------------------------------"
apt update
apt upgrade -y

echo "--- create ssh keys -----------------------------------------------------"
if [ ! -f /home/debian/.ssh/id_rsa ]; then
    su - debian -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
    echo "ssh key generated"
else
    echo "ssh key already created"
fi

echo "--- enable unattended uppgrades -----------------------------------------"
# enable unattended upgrades
# https://wiki.debian.org/UnattendedUpgrades
apt install unattended-upgrades apt-listchanges -y
dpkg-reconfigure --frontend=noninteractive -plow unattended-upgrades

# # enable additional network interfaces
# cat <<EOT > /etc/network/interfaces.d/additionalifs
# 
# # lets add some more to be on the save side
# allow-hotplug eth3
# iface eth3 inet dhcp
# 
# allow-hotplug eth4
# iface eth4 inet dhcp
# EOT

# # install some tools
apt install -y \
    curl \

