SHELL := /bin/bash
IMAGE=pigeosolutions/georchestra-ssh-ldappam
REV=`git rev-parse --short HEAD`
DATE=`date +%Y%m%d-%H%M`

all: pull-deps docker-build-withgdal docker-push

pull-deps:
	docker pull debian:bookworm-slim

docker-build-light:
	docker build -t ${IMAGE}:latest . ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${DATE}-${REV} ;\
	echo tagged ${IMAGE}:${DATE}-${REV}

docker-build-withgdal: docker-build-light
	docker build -t ${IMAGE}:latest-withGDAL -f Dockerfile-withGDAL . ;\
	docker tag  ${IMAGE}:latest-withGDAL ${IMAGE}:${DATE}-${REV}-withGDAL

docker-push:
	docker push ${IMAGE}:latest ;\
	docker push ${IMAGE}:latest-withGDAL ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${DATE}-${REV} ;\
	docker tag  ${IMAGE}:latest-withGDAL ${IMAGE}:${DATE}-${REV}-withGDAL ;\
	docker push ${IMAGE}:${DATE}-${REV} ;\
	docker push ${IMAGE}:${DATE}-${REV}-withGDAL
