## Примеры выборок в консоли
---
```bash
## Выборка деплойментов с подами в статусе unavailable
kubectl get --raw=/apis/apps/v1/deployments | jq '.items[] | {name: .metadata.name, replicas: .status.replicas, available: (.status.availableReplicas // 0), unavailable: (.status.unavailableReplicas // 0)} | select (.unavailable > 0)'
```

```bash
## Подсчёт количества подов с разбивкой по нодам
kubectl get pods --all-namespaces -o json | jq '.items[] | .spec.nodeName' -r | sort | uniq -c
```

```bash
## Удалить поды в статусе Terminating
kubectl get pods -n default | grep Terminating | while read line; do
  pod_name=$(echo $line | awk '{print $2}' ) \
  name_space=$(echo $line | awk '{print $1}' ); \
  kubectl delete pods $pod_name -n $name_space --grace-period=0 --force
done
```

```bash
## Удалить EVICTED поды во всех NS
oc get po --all-namespaces -o json | \
jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | 
"oc delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c
```
```bash
## Почистить поды по маске имени
kubectl get pods -n testlink --no-headers=true | awk '/stash-backup-testlink-data-pvc-backup*/{print $1}' | xargs  kubectl delete -n testlink pod
```

```bash
## Создать под
kubectl run nginx --image=nginx --restart=Never --port=80 -n default
kubectl run dnstools --restart=Never --rm -it --image=infoblox/dnstools:latest

## Создать сервис
kubectl expose pod nginx --port=80 --target-port=80 -n default

## Создать деплоймент
kubectl create deployment nginx-deployment --image nginx:1.19  --port=80 -n default
kubectl create deployment dns-tools --image infoblox/dnstools:latest -n default

```

```bash
## Стресс тест
kubectl run stress --image=containerstack/stress:1.0.4 --restart=Never --command -- stress --cpu 1 -m 1024m --vm-bytes 1024m --timeout 60s

kubectl create deployment stress --image containerstack/stress:1.0.4 -n default
```

```bash
## Посмотреть API сущности
kubectl api-resources
kubectl api-resources --api-group=user.openshift.io

## Посомтреть секрет (декодированный)
kubectl get secret <sec_name> -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}' -n default
```

```bash
# Получить IP-адреса (InternalIP) всех узлов
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

```bash
# Вывести постоянные тома (PersistentVolumes), отсортированные по емкости
kubectl get pv --sort-by='.spec.capacity.storage'

# Вывести поды, отсортированные по количеству перезагрузок
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount' --all-namespaces

# Выборка подов по лейблам
kubectl get pods --selector="app=front" -n test

# Удаление всех сущностей по лейблу
kubectl delete all --selector="app=back" -n test
```