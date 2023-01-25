# ory-k8s

## Create namespace

```bash
kubectl create ns threeport-api
```

## Data Storage and Persistence

https://www.ory.sh/docs/ecosystem/deployment

Choose and deploy Data Storage and Persistense provider (PostgreSQL, MySQL, SQLite and CockroachDB)

## [CockroachDB](https://www.ory.sh/docs/ecosystem/deployment#cockroachdb)

Modify `dsn` value in [kratos-cockroachdb.yml](./k8s/kratos/cockroachdb/kratos-cockroachdb.yml#L424) with the output of 
following
```bash
echo -n 'cockroach://tp_rest_api:tp-rest-api-pwd@crdb-public.threeport-api.svc.cluster.local:26257/threeport_api?sslmode=disable' | base64
```
for example above it's:
```text
Y29ja3JvYWNoOi8vdHBfcmVzdF9hcGk6dHAtcmVzdC1hcGktcHdkQGNyZGItcHVibGljLnRocmVlcG9ydC1hcGkuc3ZjLmNsdXN0ZXIubG9jYWw6MjYyNTcvdGhyZWVwb3J0X2FwaT9zc2xtb2RlPWRpc2FibGU=
```

### Deploy

```bash
kubectl apply -f ./k8s/kratos/cockroachdb/cockroachdb.yml
echo "waiting for cockroachdb to get ready"
kubectl wait pod -n threeport-api crdb-0 --for condition=Ready --timeout=180s
```

## [PostgreSQL](https://www.ory.sh/docs/ecosystem/deployment#postgresql)

postgresql://oryadmin:oryadminpwd@postgres:5432/ory?sslmode=disable&max_conns=20&max_idle_conns=4
cG9zdGdyZXNxbDovL29yeWFkbWluOm9yeWFkbWlucHdkQHBvc3RncmVzOjU0MzIvb3J5P3NzbG1vZGU9ZGlzYWJsZSZtYXhfY29ubnM9MjAmbWF4X2lkbGVfY29ubnM9NA==

### Deploy

```bash
make p-deploy

```
### UnDeploy

```bash
make p-udeploy
```

## YugabyteDB (Experimental, doesn't work, column type incompatibility)

```ini
postgresql://yugabyte:yugabyte@yugabytedb:5433/ory?sslmode=disable&max_conns=20&max_idle_conns=4
cG9zdGdyZXNxbDovL3l1Z2FieXRlOnl1Z2FieXRlQHl1Z2FieXRlZGI6NTQzMy9vcnk/c3NsbW9kZT1kaXNhYmxlJm1heF9jb25ucz0yMCZtYXhfaWRsZV9jb25ucz00
```

### Deploy 

```bash
make y-deploy
```

### UnDeploy 

```bash
make udeploy
```

## Ory

http://k8s.ory.sh/helm/

```bash
helm repo add ory https://k8s.ory.sh/helm/charts
helm repo update

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

[Kratos tags](https://hub.docker.com/r/oryd/kratos/tags)

### Deploy 

Create k8s templates for Kratos if you need to override existing ones 

```bash
helm template --name-template=ory --namespace=threeport-api -f ./helm-template/kratos/values.yml ory/kratos > ./k8s/kratos/kratos-cockroachdb.yml
```

Deploy Kratos
```bash
kubectl apply -f ./k8s/kratos/cockroachdb/kratos-cockroachdb.yml
kubectl describe deployments.apps -n threeport-api ory-kratos

kubectl apply -f ./k8s/kratos/cockroachdb/crdb-test-pod.yml
kubectl logs -n threeport-api crdb-test
kubectl delete -f ./k8s/kratos/cockroachdb/crdb-test-pod.yml

curl -v -s -k -X GET -H "Accept: application/json" https://api.example.com/kratos/self-service/registration/browser
curl -v -s -k -X GET -H "Accept: application/json" https://api.example.com/self-service/registration/browser
```

UnDeploy
```bash
kubectl delete -f ./k8s/kratos/cockroachdb/kratos-cockroachdb.yml

kubectl delete -f ./k8s/kratos/cockroachdb/cockroachdb.yml
```

## Resources

- http://k8s.ory.sh/helm/
- https://www.ory.sh/kratos-knative-demo/
- https://devpress.csdn.net/k8s/62ebfa4c19c509286f415f3f.html
- https://pumpingco.de/blog/develop-against-a-cloud-hosted-ory-kratos-instance-from-localhost/
- https://blog.getambassador.io/part-2-api-access-control-and-authentication-with-kubernetes-ambassador-and-ory-oathkeeper-q-a-127fa57f6332
- https://github.com/pngouin/k8s-ory-example
