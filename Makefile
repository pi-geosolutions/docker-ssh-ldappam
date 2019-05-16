TAG=1.1

docker-build-latest: docker-pull-deps
	docker build -t pigeosolutions/georchestra-ssh-ldappam:latest . ; \
	docker build -t pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL -f Dockerfile-withGDAL . ; \

docker-push:
	docker tag pigeosolutions/georchestra-ssh-ldappam:latest pigeosolutions/georchestra-ssh-ldappam:${TAG}-light ; \
	docker tag pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL pigeosolutions/georchestra-ssh-ldappam:${TAG}-withGDAL ; \
	docker push pigeosolutions/georchestra-ssh-ldappam:latest ; \
	docker push pigeosolutions/georchestra-ssh-ldappam:latest-withGDAL ; \
	docker push pigeosolutions/georchestra-ssh-ldappam:${TAG}-light ; \
	docker push pigeosolutions/georchestra-ssh-ldappam:${TAG}-withGDAL ; \

docker-build-push: docker-build-latest docker-push

docker-pull-deps:
	docker pull debian:stretch ; \

all: docker-build-latest
