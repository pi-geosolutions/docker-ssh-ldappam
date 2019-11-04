SHELL := /bin/bash
TAG=1.1

all: pull-deps docker-build-withgdal docker-push

pull-deps:
	docker pull debian:stretch

docker-build-light:
	docker build -t pigeosolutions/georchestra-ssh-ldappam:v${TAG} .

docker-build-withgdal: docker-build-light
	docker build -t pigeosolutions/georchestra-ssh-ldappam:v${TAG}-withGDAL  -f Dockerfile-withGDAL .

docker-push:
	docker push pigeosolutions/georchestra-ssh-ldappam:v${TAG} ;\
	docker push pigeosolutions/georchestra-ssh-ldappam:v${TAG}-withGDAL
