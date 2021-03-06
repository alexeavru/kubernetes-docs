## KIND (Kubernetes in Docker)
**kind** is a tool for running local Kubernetes clusters using Docker container “nodes” <br/>
https://kind.sigs.k8s.io/ <br/>
https://github.com/kubernetes-sigs/kind <br/>
```
## Создать кластер
kind create cluster --config kind-config.yaml --name test --image=kindest/node:v1.24.0

## Установка Calico
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml

## Удалить кластер
kind delete cluster --name test

## Взять конфиг кластера
kind get kubeconfig --name test

## Команды
kind get clusters
kind get nodes --name test
```
### Альтернативные CNI
```
## Установка Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

## Установка Cilium
helm repo add cilium https://helm.cilium.io/
helm repo update
docker pull quay.io/cilium/cilium:v1.11.6
kind load docker-image quay.io/cilium/cilium:v1.11.6 --name test
helm install cilium cilium/cilium --version 1.11.6 \
   --namespace kube-system \
   --set kubeProxyReplacement=partial \
   --set hostServices.enabled=false \
   --set externalIPs.enabled=true \
   --set nodePort.enabled=true \
   --set hostPort.enabled=true \
   --set bpf.masquerade=false \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

```