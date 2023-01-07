# ory-k8s

## YugabyteDB


[tags](https://hub.docker.com/r/yugabytedb/yugabyte/tags)

### Deploy 

```bash
make y-deploy

```

### UnDeploy 

```bash
make udeploy
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