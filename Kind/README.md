## KIND (Kubernetes in Docker)
**kind** is a tool for running local Kubernetes clusters using Docker container “nodes” <br/>
https://kind.sigs.k8s.io/ <br/>
https://github.com/kubernetes-sigs/kind <br/>
```
# Создать кластер
kind create cluster --config kind-config.yaml --name test --image=kindest/node:v1.23.1

# Удалить кластер
kind delete cluster --name test

# Взять конфиг кластера
kind get kubeconfig --name test

# Команды
kind get clusters
kind get nodes --name test
```