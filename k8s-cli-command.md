## Примеры выборок в консоли
---
```
## Выборка деплойментов с подами в статусе unavailable
k get --raw=/apis/apps/v1/deployments | jq '.items[] | {name: .metadata.name, replicas: .status.replicas, available: (.status.availableReplicas // 0), unavailable: (.status.unavailableReplicas // 0)} | select (.unavailable > 0)'
```
```
## Подсчёт количества подов с разбивкой по нодам
kubectl get pods --all-namespaces -o json | jq '.items[] | .spec.nodeName' -r | sort | uniq -c
```

```
## Удалить поды в статусе Terminating
kubectl get pods -n default | grep Terminating | while read line; do
  pod_name=$(echo $line | awk '{print $2}' ) \
  name_space=$(echo $line | awk '{print $1}' ); \
  kubectl delete pods $pod_name -n $name_space --grace-period=0 --force
done
```

```
## Удалить EVICTED поды во всех NS
oc get po --all-namespaces -o json | \
jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | 
"oc delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c
```
```
## Почистить поды по маске имени
kubectl get pods -n testlink --no-headers=true | awk '/stash-backup-testlink-data-pvc-backup*/{print $1}' | xargs  kubectl delete -n testlink pod
```