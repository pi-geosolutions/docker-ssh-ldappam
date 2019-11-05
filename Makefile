SHELL := /bin/bash
TAG=1.2

all: pull-deps docker-build-withgdal docker-push

pull-deps:
	docker pull debian:stretch

docker-build-light:
	docker build -t pigeosolutions/georchestra-ssh-ldappam:latest . ;\
	docker tag  pigeosolutions/georchestra-ssh-ldappam:latest pigeosolutions/georchestra-ssh-ldappam:v${TAG}

docker-build-withgdal: docker-build-light
	docker build -t pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL -f Dockerfile-withGDAL . ;\
	docker tag  pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL pigeosolutions/georchestra-ssh-ldappam:v${TAG}-withGDAL

docker-push:
	docker push pigeosolutions/georchestra-ssh-ldappam:latest ;\
	docker push pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL ;\
	docker tag  pigeosolutions/georchestra-ssh-ldappam:latest pigeosolutions/georchestra-ssh-ldappam:v${TAG} ;\
	docker tag  pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL pigeosolutions/georchestra-ssh-ldappam:v${TAG}-withGDAL ;\
	docker push pigeosolutions/georchestra-ssh-ldappam:v${TAG} ;\
	docker push pigeosolutions/georchestra-ssh-ldappam:v${TAG}-withGDAL
