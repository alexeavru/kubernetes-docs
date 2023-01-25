### Kyverno [https://kyverno.io/docs/kyverno-policies/, https://github.com/kyverno/policies]

#### Install
```
# Чарт
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
kubectl create namespace kyverno
helm install kyverno kyverno/kyverno -n kyverno

# Политики (https://kyverno.io/policies/)
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```

#### Policy Reporter [https://github.com/kyverno/policy-reporter]
```
## Installation with Policy Reporter UI and Kyverno Plugin enabled
helm install policy-reporter policy-reporter/policy-reporter --set kyvernoPlugin.enabled=true --set ui.enabled=true --set ui.plugins.kyverno=true -n policy-reporter --create-namespace

## Дашборды для Grafana
https://grafana.com/orgs/policyreporter/dashboards

```

#### Команды
  - Типы политик
    - Validation
    - Mutation
    - Generation
    - Verify Image
  - Политики могут работать в 3х режимах: 
    - audit
    - enforce
  - Оповещения о срабатывании можно отсылать на таргеты (loki, webhook, slack, email, elasticsearch ...)
    - https://kyverno.github.io/policy-reporter/core/targets
```
## Просмотрт политик
kubectl get policies
kubectl get clusterpolicies

## Просмотр policyreport
kubectl get policyreport -A
kubectl get clusterpolicyreport

## Проверка вэбхуков
kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
```

#### Kyverno CLI
```
# Install Kyverno CLI using kubectl krew plugin manager
kubectl krew install kyverno

brew install kyverno
```

#### Политики [./kyverno-policies]
| File | Policy |
|:-----|-------|
| disallow-privileged-containers.yaml | Запретит запуска privilege контейнеров|
|add-default-securitycontext.yaml| Установка securityContext для всех ресурсов |
clone-secret.yaml| копирование секрета в каждый namespace |
|require-requests-limits.yaml| Требование установки реквестов и лимитов |
|require-labels.yaml| Требование наличия лейбла app.kubernetes.io/name: |
|policy-disallow-default-namespace.yaml| Запрет деплоя в нэймспейс default|
|create-cm-all-namespace.yaml| Создать конфигмап во всех нейспейсах за исключением системных|
|clone-docker-secret.yaml| Клонирование докер секрета во все неймспейсы и добавление секрета к SA default|
