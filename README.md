Ansible Role - gsl
==================

This playbook installs GNU Scientific Library (GSL).

Platforms
---------

CentOS 6.7 is the only platform that is supported and tested so far.

Role Variables
--------------

- Check out [defaults/main.yml](defaults/main.yml)

Dependencies
------------

None.

Installation
------------

Regular installation:

```
ansible-galaxy install rdi2sys.gsl
```

Installation to a specific directory(e.g. roles/):

```
ansible-galaxy install -p roles/ rdi2sys.gsl
```

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: rdi2sys.gsl }

License
-------

MIT License.

Author Information
------------------

- Koji Tanaka, RDI2
