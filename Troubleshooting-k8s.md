## Kubernetes troubleshooting
- Потерян конфиг файл кластера
    ```
    # Откроем insecure порт на API сервере
    # добавим параметр в манифест запуска API сервера
    vim /etc/kubernetes/manifests/kube-apiserver.yaml
    ...
    - --insecure-port=8080
    ...
    ```
    после перезапуска API сервер будет принимать запросы на порту localhost:8080 без авторизациии </br>
    далее сервисаккаунт для админского доступа
    ```
    k create sa admin -n kube-system
    k create clusterrolebinding admin -n kube-system --clusterrole --cluster-admin --serviceaccount kube-system:admin
    k get secret $(k get serviceaccount -n kube-system admin -o jsonpath='{.secrets[].name}') -n kube-system -o jsonpath='{.data.token}' | base64 -d
    
    # Создаем kube-config
    k config set-cluster k8s --enbed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://172.16.0.2:6443
    k config set-credintials admin --token=$(k get secret $(k get serviceaccount -n kube-system admin -o jsonpath='{.secrets[].name}') -n kube-system -o jsonpath='{.data.token}' | base64 -d)
    k config set-context k8s-admin --cluster=k8s --user admin
    k config use-context k8s-admin
    
    ```
-  Сертификаты
    Проверка срока действия сертификатов мастер ноды
    ```
    kubeadm certs check-expiration
    ```
    Обновить все сертификаты мастер ноды
    ```
    kubeadm certs renew all
    ```