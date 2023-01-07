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

#y-deploy: @ Deploy Yugabyte
y-deploy:
	kubectl apply -f ./yugabytedb
	kubectl wait pods -n ory-poc -l app=yugabytedb --for condition=Ready --timeout=180s
	echo "waiting for yugabytedb service to get External-IP"
	@until kubectl get service/yugabytedb -n ory-poc --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
	@echo xdg-open http://$(shell kubectl get svc/yugabytedb -n ory-poc -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):7000

#y-undeploy: @ UnDeploy Yugabyte
y-uneploy:
	kubectl delete -f ./yugabytedb


#k-deploy: @ Deploy Kratos
k-deploy:
	kubectl apply -f ./kratos/identity-schema.yml -n ory-poc
	kubectl apply -f ./kratos/config.yml -n ory-poc
	kubectl apply -f ./kratos/env.yml -n ory-poc
	kubectl apply -f ./kratos/migration-job.yml -n ory-poc
	kubectl apply -f ./kratos/service.yml -n ory-poc
	kubectl create ingress ory-kratos --class=nginx --rule="*.example.com/*=kratos-service:80"
	kubectl apply -f ./kratos/deployment.yml -n ory-poc

#k-undeploy: @ UnDeploy Kratos
k-undeploy:
	kubectl delete -f ./kratos/deployment.yml -n ory-poc
	kubectl delete ingress ory-kratos
	kubectl delete -f ./kratos/service.yml -n ory-poc
	kubectl delete -f ./kratos/migration-job.yml -n ory-poc
	kubectl delete -f ./kratos/env.yml -n ory-poc
	kubectl delete -f ./kratos/config.yml -n ory-poc
	kubectl delete -f ./kratos/identity-schema.yml -n ory-poc
	
	
	
	

	