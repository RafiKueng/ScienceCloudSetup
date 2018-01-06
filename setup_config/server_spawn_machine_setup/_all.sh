 
sed -i 's/#alias ll/alias ll/g' ~/.bashrc
sed -i 's/#alias la/alias la/g' ~/.bashrc

sudo -i

sed -i 's/#alias ll/alias ll/g' ~/.bashrc
sed -i 's/#alias la/alias la/g' ~/.bashrc

apt update
apt upgrade -y

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# enable unattended upgrades
# https://wiki.debian.org/UnattendedUpgrades
sudo apt install unattended-upgrades apt-listchanges -y
sudo dpkg-reconfigure -plow unattended-upgrades

# enable additional network interfaces
cat <<EOT > /etc/network/interfaces.d/additionalifs

# lets add some more to be on the save side
allow-hotplug eth3
iface eth3 inet dhcp

allow-hotplug eth4
iface eth4 inet dhcp

allow-hotplug eth5
iface eth5 inet dhcp

allow-hotplug eth6
iface eth6 inet dhcp

allow-hotplug eth7
iface eth7 inet dhcp

allow-hotplug eth8
iface eth8 inet dhcp

allow-hotplug eth9
iface eth9 inet dhcp
EOT

# install some tools
sudo apt install -y \
    curl \



    
sudo reboot
