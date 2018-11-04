#!/bin/bash

apt update
apt upgrade -y
apt install curl -y

curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://440d3ed3.m.daocloud.io
systemctl daemon-reload
systemctl restart docker

apt install qemu-kvm qemu uml-utilities libvirt-dev virtinst libvirt-daemon-system -y
apt install dnsmasq ebtables -y

echo "
listen_tls = 0
listen_tcp = 1
listen_addr = \"0.0.0.0\"
unix_sock_group = \"libvirt\"
unix_sock_ro_perms = \"0777\"
unix_sock_rw_perms = \"0770\"
auth_unix_ro = \"none\"
auth_unix_rw = \"none\"
auth_tcp = \"none\"
auth_tls = \"none\"
" >> /etc/libvirt/libvirtd.conf
echo "
vnc_tls = 0
" >> /etc/libvirt/qemu.conf
echo "
libvirtd_opts=\"-d -l --config /etc/libvirt/libvirtd.conf\"
" >> /etc/default/libvirtd
sleep 1
systemctl enable libvirtd.service
sleep 1
service libvirtd stop
sleep 1
service libvirtd start
echo "#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will \"exit 0\" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

sleep 30

echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables

exit 0
" > /etc/rc.local
chmod +x /etc/rc.local

docker pull unws/webvirtmgr
groupadd -g 1010 webvirtmgr
mkdir /data
mkdir /data/vm
useradd -u 1010 -g webvirtmgr -s /sbin/nologin -d /data/vm webvirtmgr
chown -R webvirtmgr:webvirtmgr /data/vm
docker run --restart=always -d -p 8080:8080 -p 6080:6080 --name webvirtmgr -v /data/vm:/data/vm unws/webvirtmgr
sleep 10
docker exec -it webvirtmgr /usr/bin/python /webvirtmgr/manage.py changepassword admin

reboot now
