## KIND (Kubernetes in Docker)
**kind** is a tool for running local Kubernetes clusters using Docker container “nodes”.
https://kind.sigs.k8s.io/ https://github.com/kubernetes-sigs/kind
```
# Создать кластер
kind create cluster --config kind-config.yaml --name test --image=kindest/node:v1.23.1

# Удалить кластер
kind delete cluster --name test
```