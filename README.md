# SSH ldappdam

SSHD container with authentication over LDAP

It is supposed to be configured to connect to an LDAP server (tested on
OpenLDAP server) for authentication. If the account does not exist, it is
created on first login. By default, on /home/$uid (the uid in the LDAP entry)

## ROLE
geOrchestra uses roles to define which users can do what. To be allowed to connect to the console, by default, it is expected that the user belong to `SSH_USER` role. This role is not present by default in geOrchestra, and thus might need to be created, prior to affecting it to any user.

## Important information
This image uses the employeeNumber LDAP attribute as uid. This means that to
avoid side-effects, you should ensure employeeNumber can't take low values.
For example, set them to be above 1000. Since it is automatically incremented
you won't risk having one of your users seen as a system service because of a
low uid

Since geOrchestra 19.x, employeeNumber is not set by the console. You'll need to run a sidecar container to maintain an employeeNumber for users meant to log in the SSH console

## Content
Images created using the withgdal branch provide additional tools:
 * python 3 virtual env & pip support so you can manage a python3 environment
 * gdal-bin
 * postgresql client

All images provide several system utilities:
 * rsync
 * editors (vi, nano)
 * compression (p7zip,tar, zip, bzip2),
 * ldap utils
 * wget
 * CRON
 * git

## Environment vars
 * `NAME` the "hostname" displayed in the console prompt
 * `LDAP_BASE` defaults to "dc=georchestra,dc=org"
 * `LDAP_URI` defaults to "ldap://ldap.georchestra"
 * `NSLCD_FILTER` the LDAP filter to apply on user selection. Defaults to `(&(objectClass=person)(memberOf=cn=SSH_USER,ou=roles,$LDAP_BASE))`
 * `NSLCD_GIDNUMBER` the gid number to apply to the users. Defaults to "999"
 * `NSLCD_HOMEDIR` the home dir definition. Defaults to /home/$uid. Creates the directory if it doesn't exist. $uid corresponds to the uid attribute in the LDAP directory
 * `NSLCD_LOGINSHELL` defaults to /bin/bash
 * `SSH_ROOT_AUTHORIZED_KEYS` or `SSH_ROOT_AUTHORIZED_KEYS_FILE` SSH key(s) used to connect as root
 * `SSHD_CONFIG_SECRET`: a kubernetes secret, providing configuration for the SSHD server. It is expected to contain the following files:
  * `ssh_host_ed25519_key`: the private SSH key for identifying the server (ED25519 algorithm)
  * `ssh_host_ed25519_key.pub`: the matching pub key
  * `sshd_config`: the /etc/ssh/sshd_config file
