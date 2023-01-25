### ServiceAccount (SA)
Создать SA
```
kubectl create serviceaccount jenkins -n default
```
Создать токен для SA (с временным токеном) (этот вариан подходит для временного доступа, для постоянного доступа нужно создать секрет руками для SA)
```
kubectl create token jenkins -n default --duration=87600h # 10 лет
```
Создать секрет для SA (с бессрочным токеном)
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: jenkins
  namespace: default
  annotations:
    kubernetes.io/service-account.name: "jenkins"
EOF

## Добавить секрет в SA (добавляет только если раздел secrets уже есть)
kubectl patch sa jenkins -n default --type='json' -p='[{"op": "add", "path": "/secrets/-", "value": {"name": "jenkins" } }]'
```

Сформировать kube.conf
```
kubectl krew install view-serviceaccount-kubeconfig
kubectl view-serviceaccount-kubeconfig jenkins -n datalab > jenkins.kube-conf
```


Посмотреть секрет
```
kubectl describe secret jenkins -n default

kubectl get secret jenkins -n default -ojsonpath='{.data.token}' | base64 --decode
```

Добавить роль SA
```
kubectl create rolebinding jenkins-edit --clusterrole=edit --serviceaccount=default:jenkins -n default
```

Добавить кластерную роль SA
```
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:kubeconfig-sa
```

Проверка прав
```
kubectl auth can-i get pods --all-namespaces
kubectl auth can-i get pods -n default
kubectl auth can-i create pods
kubectl auth can-i delete pods

## С конкретным конфигом 
KUBECONFIG=jenkins.kube-conf kubectl auth can-i get pods -n default
```
