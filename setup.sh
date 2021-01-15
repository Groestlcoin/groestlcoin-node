#!/bin/bash

# =============================================
# Usage:
# sudo chmod +x ./setup.sh
# sudo ./setup.sh rcpUser rpcPassword

# =============================================
# Install groestlcoind
sudo apt-add-repository ppa:groestlcoin/groestlcoin -y
sudo apt update && sudo apt install groestlcoind -y

# =============================================
# Setup additional volume
sudo mkfs.ext4 /dev/xvdb #Format the volume to ext4 filesystem
sudo mkdir /grsdata #Create a directory to mount the new volume
sudo mount /dev/xvdb /grsdata/ #Mount the volume to grsdata directory
df -h /grsdata #Check the disk space to confirm the volume mount

#EBS Automount on Reboot
sudo cp /etc/fstab /etc/fstab.bak
echo "/dev/xvdb  /grsdata/  ext4    defaults,nofail  0   0" | sudo tee -a /etc/fstab #Make a new entry in /etc/fstab
sudo mount -a #Check if the fstab file has any errors

lsblk #List the available disks
sudo file -s /dev/xvdb #Check if the volume has any data

# =============================================
RPCUSER=$1
RPCPASS=$2

# Copy config files
sudo rm -rf $HOME/build && sudo mkdir -p $HOME/build
sed -e "s;%RPCUSER%;$RPCUSER;g" -e "s;%RPCPASS%;$RPCPASS;g" groestlcoin.conf.tmpl > $HOME/build/groestlcoin.conf
cp notify.sh.tmpl $HOME/build/notify.sh

# =============================================
cat $HOME/build/groestlcoin.conf | sudo tee /grsdata/groestlcoin.conf
cat $HOME/build/notify.sh | sudo tee /btcdata/notify.sh

sudo mkdir $HOME/.groestlcoin
cat $HOME/build/groestlcoin.conf | sudo tee $HOME/.groestlcoin/groestlcoin.conf
cat $HOME/build/notify.sh | sudo tee $HOME/.groestlcoin/notify.sh
ls -la $HOME/.groestlcoin

sudo chmod +x /grsdata/notify.sh
sudo touch /grsdata/notify.log

# =============================================
sudo cp /etc/crontab /etc/crontab.bak
echo "@reboot root groestlcoind -daemon -datadir=/grsdata/" | sudo tee -a /etc/crontab #Make a new entry in /etc/crontab

# =============================================
echo "# START -----------------------------------------------------------------"
echo "# SMD00    sudo groestlcoind -daemon -datadir=/grsdata/"
echo "# END   -----------------------------------------------------------------"
sudo groestlcoind -daemon -datadir=/grsdata/

# =============================================
# sudo pkill -9 -f groestlcoind

ps -e | grep groestlcoin
sudo tail /grsdata/debug.log
groestlcoin-cli getblockcount
