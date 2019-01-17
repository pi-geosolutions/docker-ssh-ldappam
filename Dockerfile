FROM debian:stretch

MAINTAINER Jean Pommier "jean.pommier@pi-geosolutions.fr"

# Gives a SSH access with user authentification & session against LDAP directory
# Uses supervisor in order to run side-by-side cron and sshd

ENV DEBIAN_FRONTEND=noninteractive \
    NAME=geoporegion \
    LDAP_BASE="dc=georchestra,dc=org" \
    LDAP_URI="ldap://ldap.georchestra" \
    LDAP_BINDDN="cn=admin,dc=georchestra,dc=org" \
    LDAP_BINDPW="secret"

# variable to be visible from user session
# RUN echo "export NAME=${NAME}" >> /etc/profile

# install ssh server + system utilities
RUN apt-get update && \
    apt-get install -y \
                bzip2 \
                dos2unix \
                ldap-utils \
                libnss-ldapd \
                nano \
                openssh-server \
                p7zip-full \
                rsync \
                supervisor \
                tar \
                unzip \
                vim \
                wget \
                zip \
      && apt-get clean \

# install postgresql client, gdal
# & python virtualenv that will be used by any user needing it to install its
# specific python libs
# python-gdal is necessary to get gdal python tools such as gdal_edit.py
RUN apt-get update && \
    apt-get install -y \
              gdal-bin \
              postgresql-client \
              python3-gdal \
              python3-pip \
              python3-venv \
    && apt-get clean \
    && pip3 install --upgrade pip

COPY etc/* /etc/
COPY etc/pam.d/* /etc/pam.d/

EXPOSE 22

ADD supervisord.conf /etc/supervisor/
RUN mkdir -p /var/log/supervisor

ADD entry.sh /entry.sh
RUN chmod u+x /entry.sh

ENTRYPOINT ["/entry.sh"]

#CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
