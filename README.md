# ory-k8s

## YugabyteDB


[tags](https://hub.docker.com/r/yugabytedb/yugabyte/tags)

postgresql://yugabyte:yugabyte@yugabytedb:5433/ory?sslmode=disable&max_conns=20&max_idle_conns=4
cG9zdGdyZXNxbDovL3l1Z2FieXRlOnl1Z2FieXRlQHl1Z2FieXRlZGI6NTQzMy9vcnk/c3NsbW9kZT1kaXNhYmxlJm1heF9jb25ucz0yMCZtYXhfaWRsZV9jb25ucz00

### Deploy 

```bash
make y-deploy

```

### UnDeploy 

```bash
make udeploy
```

## PostgreSQL


[tags](https://hub.docker.com/r/yugabytedb/yugabyte/tags)

postgresql://oryadmin:oryadminpwd@postgres:5432/ory?sslmode=disable&max_conns=20&max_idle_conns=4
cG9zdGdyZXNxbDovL29yeWFkbWluOm9yeWFkbWlucHdkQHBvc3RncmVzOjU0MzIvb3J5P3NzbG1vZGU9ZGlzYWJsZSZtYXhfY29ubnM9MjAmbWF4X2lkbGVfY29ubnM9NA==

### Deploy 

```bash
make y-deploy

```

### UnDeploy 

```bash
make udeploy

## Ory

http://k8s.ory.sh/helm/


```bash
helm repo add ory https://k8s.ory.sh/helm/charts
helm repo update

helm template --name-template=ory --namespace=ory-poc -f ./helm-template/kratos/values.yml \
  ory/kratos > ./kratos/v2/deploy.yml

helm template --name-template=demo --namespace=ory-poc \
  --set 'demo=true' \
  --set maester.enabled=false \
  --set service.enabled=false \
  --set service.api.enabled=false \
  --set service.proxy.enabled=false \
  --set global.ory.oathkeeper.maester.mode=this_prevents_rendering_the_deployment \
  ory/oathkeeper > ./oathkeeper/deploy.yml
```

## Kratos

[tags](https://hub.docker.com/r/oryd/kratos/tags)

### Deploy 

```bash
make k-deploy
curl -v -s -k -X GET -H "Accept: application/json" https://api.example.com/kratos/self-service/registration/browser

```

### UnDeploy 

```bash
make k-udeploy
```

## Links

http://k8s.ory.sh/helm/
https://www.ory.sh/kratos-knative-demo/
https://devpress.csdn.net/k8s/62ebfa4c19c509286f415f3f.html
https://pumpingco.de/blog/develop-against-a-cloud-hosted-ory-kratos-instance-from-localhost/
https://blog.getambassador.io/part-2-api-access-control-and-authentication-with-kubernetes-ambassador-and-ory-oathkeeper-q-a-127fa57f6332
https://github.com/pngouin/k8s-ory-example
