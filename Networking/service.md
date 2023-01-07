## Service
> В качестве бэкенда для сервиса может быть **IPTABLES** или **IPVS** (задается при создании кластера)
Сервис - это набор правил **Iptables** или **IPVS**

### Типы сервисов
- ClusterIP
- NodePort
- LoadBalancer
- ExternalName
- ExternalIps
- Headless

### IPTABLES
```
iptables -t nat -S | grep <service_name>
```
### Сервис без селектора
---
Предназначен для предоаставления доступа к сервисам вне кластера через внутренний сервис. 
При создании сервиса без селектора Endpoint с указанием IP адресов создаем самостоятельно
```
---
apiVersion: v1
kind: Service
metadata:
  name: ndp-minio
  namespace: ndp-dev
spec:
  ports:
  - port: 9000
    protocol: TCP
    targetPort: 32594
  type: ClusterIP
---
apiVersion: v1
kind: Endpoints
metadata:
  name: ndp-minio
  namespace: ndp-dev
subsets:
  - addresses:
      - ip: 172.29.253.9
      - ip: 172.29.253.31
      - ip: 172.29.253.25
    ports:
      - port: 32594
```
### Сервис ExternalIPs
---
Предназначен для предоставления доступа к севису по внешнему IP адресу. Похож на NodePort, но позволяет дать доступ к сервису по любому порту, например <NODE_IP_ADDRESS:9000>. В секции externalIPs указываем адреса воркер нод на которых будет открыт указанный порт. 
**Важно!** Не указывать адреса мастер нод (перестает работать API сервер мастер ноды)
```
apiVersion: v1
kind: Service
metadata:
  name: minio-external
  namespace: datalab
spec:
  selector:
    app.kubernetes.io/instance: minio
    app.kubernetes.io/name: minio
  ports:
  - name: minio-api
    port: 9000
    protocol: TCP
    targetPort: minio-api
  - name: minio-console
    port: 9001
    protocol: TCP
    targetPort: minio-console
  externalIPs:
    - 172.29.253.9
    - 172.29.253.31
    - 172.29.253.25
```
Если хотим добвить дополнительный (виртуальный) IP адрес на сетевой интерфейс ноды
```
ifconfig eth0:alt 172.29.253.10
```
### Сервис ExternalName
---
Данный сервис позволяет получитьдоступ к внешнему сервису по DNS имени, например к базе данных расположенной вне кластера
Порты доступны все, при обращении указываем нужный порт (minio-ui:443, minio-ui:80)
```
apiVersion: v1
kind: Service
metadata:
  name: minio-ui
  namespace: ndp-dev
spec:
  type: ExternalName
  externalName: minio.example.com
```
### Сервис NodePort
---
Данный сервис открывает на всех воркер нодах кластера порт для сервиса из диапазона `30000-32767` данный диапазон можно изменить в настройках API сервера
```
vim /etc/kubernetes/manifests/kube-apiserver.yaml

  - kube-apiserver
  - --service-node-port-range=30000-32767
``` 
```
apiVersion: v1
kind: Service
  name: minio
  namespace: ndp-dev
spec:
  ports:
  - name: minio-api
    nodePort: 32594
    port: 9000
    protocol: TCP
    targetPort: minio-api
  - name: minio-console
    nodePort: 31622
    port: 9001
    protocol: TCP
    targetPort: minio-console
  selector:
    app.kubernetes.io/instance: minio
    app.kubernetes.io/name: minio
  sessionAffinity: None
  type: NodePort
```