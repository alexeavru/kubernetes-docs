#!/bin/bash

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

systemctl stop NetworkManager.service
systemctl disable NetworkManager.service

#######################
## Install KubeADM Kubectl Kubelet
#######################
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

mkdir /var/lib/kubelet

cat <<EOF | sudo tee /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF
