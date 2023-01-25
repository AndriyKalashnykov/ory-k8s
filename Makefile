THIS_FILE := $(lastword $(MAKEFILE_LIST))""
CURRENTTAG:=$(shell git describe --tags --abbrev=0)
NEWTAG ?= $(shell bash -c 'read -p "Please provide a new tag (currnet tag - ${CURRENTTAG}): " newtag; echo $$newtag')
GOFLAGS=-mod=mod

#help: @ List available tasks
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-19s\033[0m - %s\n", $$1, $$2}'

#release: @ Create and push a new tag
release: build clean
	$(eval NT=$(NEWTAG))
	@echo -n "Are you sure to create and push ${NT} tag? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo ${NT} > ./version.txt
	@git add -A
	@git commit -a -s -m "Cut ${NT} release"
	@git tag ${NT}
	@git push origin ${NT}
	@git push
	@echo "Done."

#version: @ Print current version(tag)
version:
	@echo $(shell git describe --tags --abbrev=0)

#p-deploy: @ Deploy PostgreSQL
p-deploy:
	kubectl apply -f ./k8s/db/postgresql -n threeport-api
	kubectl wait pods -n threeport-api -l app=postgres --for condition=Ready --timeout=180s
	echo "waiting for postgres service to get External-IP"
	@until kubectl get service/postgres -n threeport-api --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done

#p-undeploy: @ UnDeploy PostgreSQL
p-undeploy:
	kubectl delete -f ./k8s/db/postgresql -n threeport-api --ignore-not-found=true

#c-deploy: @ Deploy CockroachDB
c-deploy:
	kubectl apply -f ./k8s/db/cockroachdb -n threeport-api
	kubectl wait pods -n threeport-api -l app=postgres --for condition=Ready --timeout=180s
	@echo "waiting for CockroachDB service to get External-IP"
	@until kubectl get service/crdb-public -n threeport-api --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
	@echo "Create CockroachDB for Kratos"
	kubectl apply -f ./k8s/db/cockroachdb/crdb-test-pod.yml -n threeport-api
	kubectl logs -n threeport-api crdb-test

#c-undeploy: @ UnDeploy CockroachDB
c-undeploy:
	kubectl delete -f ./k8s/db/cockroachdb -n threeport-api --ignore-not-found=true

#y-deploy: @ Deploy Yugabyte
y-deploy:
	kubectl apply -f ./k8s/db/v1/yugabytedb -n threeport-api
	kubectl wait pods -n threeport-api -l app=yugabytedb --for condition=Ready --timeout=180s
	echo "waiting for yugabytedb service to get External-IP"
	@until kubectl get service/yugabytedb -n threeport-api --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
	@echo xdg-open http://$(shell kubectl get svc/yugabytedb -n threeport-api -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):7000

#y-undeploy: @ UnDeploy Yugabyte
y-undeploy:
	kubectl delete -f ./k8s/db/v1/yugabytedb -n threeport-api --ignore-not-found=true

#k-deploy: @ Deploy Kratos
k-deploy:
	kubectl apply -f ./k8s/kratos/v1/identity-schema.yml -n threeport-api
	kubectl apply -f ./k8s/kratos/v1/config.yml -n threeport-api
	kubectl apply -f ./k8s/kratos/v1/env.yml -n threeport-api
	kubectl apply -f ./k8s/kratos/v1/migration-job.yml -n threeport-api
	kubectl apply -f ./k8s/kratos/v1/service.yml -n threeport-api
	kubectl create ingress ory-kratos --class=nginx --rule="app.example.com/*=kratos-service:443"
	kubectl apply -f ./k8s/kratos/v1/deployment.yml -n threeport-api
#	kubectl apply -f ./k8s/kratos/v2/kratos-deploy.yml
#	kubectl describe deployments.apps -n threeport-api ory-kratos
#	kubectl describe deployments.apps -n threeport-api ory-kratos

#k-undeploy: @ UnDeploy Kratos
k-undeploy:
	kubectl delete -f ./k8s/kratos/v1/migration-job.yml -n threeport-api --ignore-not-found=true
	kubectl delete -f ./k8s/kratos/v1/deployment.yml -n threeport-api --ignore-not-found=true
	kubectl delete ingress ory-kratos --ignore-not-found=true
	kubectl delete -f ./k8s/kratos/v1/service.yml -n threeport-api --ignore-not-found=true
	kubectl delete -f ./k8s/kratos/v1/env.yml -n threeport-api --ignore-not-found=true
	kubectl delete -f ./k8s/kratos/v1/config.yml -n threeport-api --ignore-not-found=true
	kubectl delete -f ./k8s/kratos/v1/identity-schema.yml -n threeport-api --ignore-not-found=true
#	kubectl delete -f ./k8s/kratos/v2/kratos-deploy.yml
	
#clean-all: @ UnDeploy all
clean-all: y-uneploy p-uneploy k-undeploy
	@echo "Done."
