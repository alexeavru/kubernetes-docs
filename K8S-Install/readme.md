## Установка кластера Kubernetes

### Установка ContainerD
Запускаем на мастерахи воркерах
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/00-install-containerd-centos8.sh | bash
```
### Установка бинарей k8s
Запускаем на мастерахи воркерах
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/01-install-k8s-centos8.sh | bash
```
### Установка мастера
Конфиг кластера
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/03-kube-config.yaml -o kube-config.yaml
```
В конфиге можно указать версию кубернетес (по умолчанию устанавливается последняя версия)
```yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: cluster.local
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/16
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
# kubernetesVersion: "v1.25.0"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs # iptables

```
Проверка установки
```
kubeadm init --config kube-config.yaml --dry-run
```
Запуск установка мастера
```
kubeadm init --config kube-config.yaml
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```
