# notes -- possible improvements

## simple way: use sudoers file with hardcoded names
To give Oliver TH access to wordpress config files, I can probably
- install sudo
- add a line in /etc/sudoers to give him
  - nopasswd access
  - right to run some commands (sync or simple copy)

## Possible lead to explore (didn't manage to make them work):
Apparently, it works well when you have PosixAccounts in LDAP, but I didn't manage to make it work with our custom structure using roles (mapping roles to linux group)

## extended rights based on user role(s)

With PAM + LDAP, one can set some rules or group ownerships based on the user's ldap roles

There are several ways: using group ownership, or using sudoers file

Some interesting refs:
- https://unix.stackexchange.com/questions/129079/sudo-permissions-by-ldap-groups-via-nslcd
- https://help.ubuntu.com/community/LDAPClientAuthentication#Assign_local_groups_to_users
- https://www.debian.org/doc/manuals/debian-reference/ch04.fr.html#_pam_and_nss
- https://wiki.debian.org/LDAP/NSS
- https://manpages.debian.org/bookworm/pynslcd/nslcd.conf.5.en.html
- https://arthurdejong.org/nss-pam-ldapd/setup


### nslcd config

In interactive, the files are configured after answering some questions. It is quite easy to reproduce in non-interactive mode. I have most of it right on my docker image conf.
```
apt install dialog # interactive
apt install libnss-ldapd libpam-ldapd sudo
```

In nslcd.conf, you can filter on several roles:
```
filter passwd (&(objectClass=person)(|(memberOf=cn=SSH_USER,ou=roles,dc=georchestra,dc=org)(memberOf=cn=SSH_ADMIN,ou=roles,dc=georchestra,dc=org)))
```

