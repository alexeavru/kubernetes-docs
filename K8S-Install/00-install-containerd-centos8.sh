#!/bin/bash

swapoff -a
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

iptables -P FORWARD ACCEPT

#######################
## Install containerd
#######################
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
fs.inotify.max_user_watches         = 524288
fs.inotify.max_user_instances       = 512
EOF

sysctl --system

dnf install -y yum-utils device-mapper-persistent-data lvm2 net-tools tc ipvsadm vim wget
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y containerd.io
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false$/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
systemctl status containerd