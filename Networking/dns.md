## CoreDNS
---
```
# IP адрес CoreDNS
k get svc kube-dns -n kube-system

NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   91s

# или так
kubectl get svc kube-dns -n kube-system -o jsonpath={.spec.clusterIP}

# Конфиг DNS в поде
cat /etc/resolv.conf

search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5

# Настройка search + cluster name (лежат на ноде)
cat /var/lib/kubelet/config.yaml

...
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
...

```





## Node Local DNS
---
Install NodeLocal DNSCache https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/
```
# Скачаем манифест
wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml

# Определим переменные
domain=cluster.local
localdns=169.254.20.10
kubedns=$(kubectl get svc kube-dns -n kube-system -o jsonpath={.spec.clusterIP})

# Сконфигурируем манифест
gsed -i "s/__PILLAR__LOCAL__DNS__/$localdns/g; s/__PILLAR__DNS__DOMAIN__/$domain/g; s/__PILLAR__DNS__SERVER__/$kubedns/g" nodelocaldns.yaml

# Применим манифест
k create -f nodelocaldns.yaml

# Конфиг DNS
k -n kube-system edit configmap node-local-dns

# Запустим под для тестирования DNS
k apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml

# Тестирование DNS
dig +short @169.254.20.10 www.com
dig +short @10.96.0.10 example.com
nslookup kubernetes.default

# Создать под с tcpdump
k run tcpdump-pod --image=corfr/tcpdump
```
