FROM debian:bullseye-slim

MAINTAINER Jean Pommier "jean.pommier@pi-geosolutions.fr"

# Gives a SSH access with user authentification & session against LDAP directory
# Uses supervisor in order to run side-by-side cron and sshd

ENV DEBIAN_FRONTEND=noninteractive \
    NAME=geoporegion \
    LDAP_BASE="dc=georchestra,dc=org" \
    LDAP_URI="ldap://ldap.georchestra"

# install ssh server + system utilities + man pages
RUN apt-get update && \
    apt-get install -y \
                bzip2 \
                cron \
                curl \
                dos2unix \
                ldap-utils \
                libnss-ldapd \
                git \
                nano \
                openssh-server \
                man-db \
                p7zip-full \
                rsync \
                screen \
                supervisor \
                tar \
                unzip \
                vim \
                wget \
                zip \
      && apt-get clean

COPY root /

EXPOSE 22

RUN mkdir -p /var/log/supervisor

RUN chmod u+x /entry.sh

ENTRYPOINT ["/entry.sh"]

#CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
