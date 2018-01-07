 
sed -i 's/#alias ll/alias ll/g' ~/.bashrc
sed -i 's/#alias la/alias la/g' ~/.bashrc

su - debian -c "sed -i 's/#alias ll/alias ll/g' ~/.bashrc"
su - debian -c "sed -i 's/#alias la/alias la/g' ~/.bashrc"

apt update
apt upgrade -y

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# enable unattended upgrades
# https://wiki.debian.org/UnattendedUpgrades
apt install unattended-upgrades apt-listchanges -y
dpkg-reconfigure -plow unattended-upgrades

# enable additional network interfaces
cat <<EOT > /etc/network/interfaces.d/additionalifs

# lets add some more to be on the save side
allow-hotplug eth3
iface eth3 inet dhcp

allow-hotplug eth4
iface eth4 inet dhcp
EOT

# install some tools
apt install -y \
    curl \

reboot
