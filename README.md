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

## Kratos

[tags](https://hub.docker.com/r/oryd/kratos/tags)

### Deploy 

```bash
make k-deploy
curl -v -s -k -X GET -H "Accept: application/json" https://api.example.com/kratos/self-service/registration/browser

curl -v -s -k -X GET -H "Accept: application/json" https://api.example.com/self-service/registration/browser

```

### UnDeploy 

```bash
make k-udeploy
```