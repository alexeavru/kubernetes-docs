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

