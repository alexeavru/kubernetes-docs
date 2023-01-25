### Cert-Manager
---
Установка
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml
```
Манифесты Cluster Issuer + Certificate Authorities (CA)
```
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
# Самоподписанный сертификат CA
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ca
  namespace: cert-manager
spec:
  isCA: true
  duration: 87600h # 10y
  subject:
    organizations:
      - "NDR"
    organizationalUnits:
      - "DevOps dep"
    localities:
      - "Saint-Petersburg"
    countries:
      - "RU"
  commonName: NDR OKD CA
  secretName: ca-secret
  privateKey:
    algorithm: RSA
    encoding: PKCS8
    size: 4096
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
```
Манифест для PostgreSQL сервера и клиента
```
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: postgresql-issuer
spec:
  ca:
    secretName: ca-secret
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: pgserver-cert
  namespace: default
spec:
  secretName: pgserver-tls

  duration: 87600h # 10y

  commonName: postgres
  subject:
    organizations:
      - "NDR"
    organizationalUnits:
      - "DEVOPS dep"
    localities:
      - "Saint-Petergurs"
    countries:
      - "RU"

  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS8
    rotationPolicy: Always
    size: 4096
  usages:
    - server auth
    - client auth
  dnsNames:
    - localhost
    - postgres-postgresql
    - postgres-postgresql.default.svc
    - postgres-postgresql.default.svc.cluster.local
  ipAddresses:
    - 127.0.0.1
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: postgresql-issuer
```
Манифест для клиента
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: pg-user-cert
  namespace: default
spec:
  secretName: pg-user-tls

  duration: 87600h # 10y

  commonName: user
  subject:
    organizations:
      - "NDR"
    organizationalUnits:
      - "DEVOPS dep"
    localities:
      - "Saint-Petergurs"
    countries:
      - "RU"

  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS8
    rotationPolicy: Always
    size: 4096
  usages:
    - client auth
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: postgresql-issuer
```