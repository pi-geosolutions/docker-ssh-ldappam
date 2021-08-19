#!/usr/bin/env bash

set -e

source /root/scripts/utils.sh

[ "$DEBUG" == 'true' ] && set -x

DAEMON=sshd

# We run sshd using supervisord, hence not using init.d, so we apprently need to make this directory
# see https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
# or we would get a 'Missing privilege separation directory: /var/run/sshd' error
[ -d /var/run/sshd ] || mkdir /var/run/sshd

# Copy default config from cache
if [ ! "$(ls -A /etc/ssh)" ]; then
   cp -a /etc/ssh.cache/* /etc/ssh/
fi
# Customize sshd_config (set some keepalive. Should ensure 1h connexions)
# sed -i "s|#TCPKeepAlive yes|TCPKeepAlive yes\nClientAliveInterval 20\nClientAliveCountMax 180|g" /etc/ssh/sshd_config
#sed -i "s|Subsystem\t	sftp\t	/usr/lib/openssh/sftp-server|Subsystem\t	sftp\t	/usr/lib/openssh/sftp-server -u 002|g" /etc/ssh/sshd_config


# Load sshd config & SSH key from kubernetes secret if provided
if [ "$SSHD_CONFIG_SECRET" ]; then
  for f in sshd_config ssh_host_ed25519_key ssh_host_ed25519_key.pub; do
    if [ -f "$SSHD_CONFIG_SECRET/$f" ]; then
      echo cp $SSHD_CONFIG_SECRET/$f /etc/ssh/
      cp $SSHD_CONFIG_SECRET/$f /etc/ssh/
      chmod 644 /etc/ssh/$f
    fi
  done
  chmod 600 /etc/ssh/*_key
else
  # Generate Host keys, if required
  if ! ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
      ssh-keygen -A
  fi
fi

# set root's ssh key. Allows using a _FILE var (use secrets)
mkdir -p /root/.ssh
chmod 755 /root/.ssh
touch /root/.ssh/authorized_keys


file_env 'SSH_ROOT_AUTHORIZED_KEYS'
# if [ "$SSH_ROOT_AUTHORIZED_KEYS_FILE" ] && [ -f $SSH_ROOT_AUTHORIZED_KEYS_FILE ]; then
#     echo `cat $SSH_ROOT_AUTHORIZED_KEYS_FILE` > /root/.ssh/authorized_keys
# fi
if [ "$SSH_ROOT_AUTHORIZED_KEYS" ]; then
    echo "$SSH_ROOT_AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
fi
chmod 600 /root/.ssh/authorized_keys

#get a nice prompt with project name
echo "export PS1='\[\e]0;\u@\h: \w\a\]\${debian_chroot:+(\$debian_chroot)}\u@${NAME}:\w\$ '" >> /etc/profile
sed -i "s|\\\h|${NAME}|g" /etc/skel/.bashrc


# Set LDAP auth config (nslcd)
cp /etc/nslcd.conf /etc/nslcd.conf.bak
echo "" >> /etc/nslcd.conf
echo "# configure logging" >> /etc/nslcd.conf
echo "log /dev/stdout info" >> /etc/nslcd.conf

sed -i "s|uri ldap://geoporegion.pigeosolutions.fr|uri $LDAP_URI|" /etc/nslcd.conf
sed -i "s|dc=georchestra,dc=org|$LDAP_BASE|g" /etc/nslcd.conf
if [ -n "$NSLCD_FILTER" ]; then
    sed -i "s|(&(objectClass=person)(memberOf=cn=SSH_USER,ou=roles,$LDAP_BASE))|$NSLCD_FILTER|" /etc/nslcd.conf
fi
if [ -n "$NSLCD_GIDNUMBER" ]; then
    sed -i "s|gidNumber \"999\"|gidNumber \"$NSLCD_GIDNUMBER\"|" /etc/nslcd.conf
fi
if [ -n "$NSLCD_HOMEDIR" ]; then
    touch /nslcd_modified
    sed -i "s|homeDirectory \"/home/\$uid\"|homeDirectory \"$NSLCD_HOMEDIR\"|" /etc/nslcd.conf
fi
if [ -n "$NSLCD_LOGINSHELL" ]; then
    sed -i "s|/bin/bash|$NSLCD_LOGINSHELL" /etc/nslcd.conf
fi

# Configure PAM
# PAM files are directly copied at compile time (see Dockerfile)

# Configure NSS
sed -i -r 's/(^passwd:)(\s+)(.*)/\1\2compat ldap/' /etc/nsswitch.conf
sed -i -r 's/(^group:)(\s+)(.*)/\1\2compat ldap/' /etc/nsswitch.conf
sed -i -r 's/(^shadow:)(\s+)(.*)/\1\2compat ldap/' /etc/nsswitch.conf


# Welcome banner
cat >> /etc/banner.txt <<EOF
###############################################################################
# Welcome to ${NAME}'s SSH service.
# This access is limited to authorized members of the ${NAME}'s platform.
# If you have trouble connecting, please first check the documentation
# provided to you, and then, if the problem persists, contact your platform
# administrator.
###############################################################################
EOF
sed -i "s|#Banner none|Banner /etc/banner.txt|" /etc/ssh/sshd_config

# Update motd
cat >> /etc/motd <<EOF
###############################################################################
# Welcome to ${NAME}'s SSH service.
# You are now connected. Please proceed with caution. Please read carefully the
# documentation you have been provided before modifying content.
# Do not alter someone else's files without checking with him first.
# In any doubt, please contact your platform administrator.
# Do not give your password to anyone. Someone without credentials is simply
# not supposed to connect to this service.
#
# And, VERY IMPORTANT : please disconnect (type 'exit' then enter) before
# leaving your computer without surveillance.
#
###############################################################################
EOF

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $@"
if [ "$(basename $1)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi
