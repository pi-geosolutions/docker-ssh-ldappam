# SSH ldappdam

SSHD container with authentication over LDAP

It is supposed to be configured to connect to an LDAP server (tested on
OpenLDAP server) for authentication. If the account does not exist, it is
created on first login. By default, on /home/$uid (the uid in the LDAP entry)

## Important information
This image uses the employeeNumber LDAP attribute as uid. This means that to
avoid side-effects, you should ensure employeeNumber can't take low values.
For example, set them to be above 1000. Since it is automatically incremented
you won't risk having one of your users seen as a system service because of a
low uid

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

## Environment vars
 * `NAME` the "hostname" displayed in the console prompt
 * `LDAP_BASE` defaults to "dc=georchestra,dc=org"
 * `LDAP_URI` defaults to "ldap://ldap.georchestra"
 * `NSLCD_FILTER` the LDAP filter to apply on user selection. Defaults to `(&(objectClass=person)(memberOf=cn=SSH_USER,ou=roles,$LDAP_BASE))`
 * `NSLCD_GIDNUMBER` the gid number to apply to the users. Defaults to "999"
 * `NSLCD_HOMEDIR` the home dir definition. Defaults to /home/$uid. Creates the directory if it doesn't exist. $uid corresponds to the uid attribute in the LDAP directory
 * `NSLCD_LOGINSHELL` defaults to /bin/bash
 * `SSH_KEY` or `SSH_KEY_FILE` SSH key(s) used to connect as root
