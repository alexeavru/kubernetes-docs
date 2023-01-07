## Установка кластера Kubernetes

### Установка ContainerD
Запускаем на мастерах и воркерах
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/00-install-containerd-centos8.sh | bash
```
### Установка бинарей k8s
Запускаем на мастерах и воркерах
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/01-install-k8s-centos8.sh | bash
```
### Установка кластера
Конфиг кластера (используем для single-master)
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
Установка сингл мастера
```
kubeadm init --config kube-config.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```
Проверка
```
kubectl get nodes -o wide
```
Установка 1го мастеров в HA режиме (вместо <HAPROXY_URL:PORT> можно использовать адрес первого мастера 172.29.253.15:6443)
```
kubeadm init \
    --control-plane-endpoint <HAPROXY_URL:PORT> \
    --pod-network-cidr 10.244.0.0/16 \
    --service-cidr 10.96.0.0/16 \
    --service-dns-domain cluster.local \
    --upload-certs
```
Выставить работу kube-proxy в ipvs режим
```
kubectl edit configmap kube-proxy -n kube-system
  mode: ipvs

kubectl rollout restart daemonset/kube-proxy -n kube-system
```

Присоединение остальных мастеров
```
kubeadm join <HAPROXY_URL:PORT> --token vijzd7.akfzyhhgvakpt6pz \
    --discovery-token-ca-cert-hash sha256:ba08792c545fb72c99677a31fb504850c493007d8f422075b1c217f274810c0a \
    --control-plane --certificate-key 4c9c3abf488753016c5626b7e957da1aef020a394e78a55f013093d891aeb200
```
Присоединение воркера
```
kubeadm join <HAPROXY_URL:PORT> --token vijzd7.akfzyhhgvakpt6pz \
    --discovery-token-ca-cert-hash sha256:ba08792c545fb72c99677a31fb504850c493007d8f422075b1c217f274810c0a 
```
### Установка сети Calico
---
#### Выбор режима работы
Calico поддерживает три режима:
 - **Direct** - когда все ноды находятся в одной сети и поды меджду нодами могут общаться через обычные сетевые соединения без использовани различных видов тунелей (инкапсуляций пакетов).
 - **IP-in-IP** - когда ноды находятся в разных сетях используется возможность Linux: [IP in IP tunneling](https://tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.tunnel.ip-ip.html)
 - **VXLAN** - когда ноды находятся в разных сетях инкапсуляция L2 в UDP пакеты. [Virtual eXtensible Local Area Networking documentation](https://www.kernel.org/doc/Documentation/networking/vxlan.txt)

#### Установка Calico
Если мы используем NetworkManager, то необходимо ему запретить работать с интерфейсами, управляемыми calico
> Поумолчанию NetworkManager отключается в скрипте установки 01-install-k8s-centos8.sh

**На всех нодах** cоздадим конфигурационный файл /etc/NetworkManager/conf.d/calico.conf
```
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/calico.conf
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
EOF

systemctl restart NetworkManager
```

Скачать конфиг Calico
```
curl -s https://docs.projectcalico.org/manifests/calico.yaml -O
```
В файле заменим
```
vim calico.yaml
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
```
на
```
- name: CALICO_IPV4POOL_IPIP
  value: "Never"
```
Переменная определяет режим работы сети. Отключив оба режима оверлея, мы включаем Direct режим сети.

Подробное описание параметров, используемых при конфигурации calico/node, можно посмотреть в [документации](https://docs.projectcalico.org/reference/node/configuration)

Установим **Calico**
```
kubectl apply -f calico.yaml
```
### Установка утилиты calicoctl
**Важно!** версия программы должна совпадать с версией установленного драйвера.
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/04-install-calicoctl.sh | bash
```
Создаем конфигурационный файл программы
```
curl -s https://raw.githubusercontent.com/alexeavru/kubernetes-docs/main/K8S-Install/05-calicoctl.cfg -o /etc/calico/calicoctl.cfg 
```
Проверяем работу программы
```
calicoctl get nodes
calicoctl node status
calicoctl get ippool
```
