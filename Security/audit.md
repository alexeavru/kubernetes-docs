## Kubernetes Audit [https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/]


### Audit policy
```
vim /etc/kubernetes/audit-policy.yaml

apiVersion: audit.k8s.io/v1 # This is required.
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
      resourceNames: ["controller-leader"]

  - level: None
    users:
    - "system:kube-scheduler"
    - "system:kube-proxy"
    - "system:apiserver"
    - "system:kube-controller-manager"
    - "system:serviceaccount:gatekeeper-system:gatekeeper-admin"
    - "system:serviceaccount:nfs:nfs-client-provisioner"

  - level: None
    userGroups: ["system:authenticated"]
    nonResourceURLs:
    - "/api*"
    - "/version"

  - level: Request
    resources:
    - group: ""
      resources: ["configmaps"]
    namespaces: ["kube-system"]

  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets", "configmaps"]
```

### Настройка kube-apiserver.yaml
```
mkdir -p /var/log/kubernetes/audit/
vim /etc/kubernetes/manifests/kube-apiserver.yaml

  - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
  - --audit-log-path=/var/log/kubernetes/audit/audit.log
  - --audit-log-maxsize=50
  - --audit-log-maxbackup=3

  volumeMounts:
  - mountPath: /var/log/kubernetes/audit/
    name: audit-log

  volumes:
  - name: audit-log
    hostPath:
      path: /var/log/kubernetes/audit/
      type: DirectoryOrCreate
```

### Promtail
```
  - job_name: kubernetes-audit
    pipeline_stages:
    static_configs:
      - targets:
          - localhost
        labels:
          job: auditlog
          __path__: /var/log/kubernetes/audit/audit.log
```