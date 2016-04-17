# Artdc: Ansible Role Tests with Docker Container
[![Build Status](https://travis-ci.org/kjtanaka/art_dc.svg?branch=master)](https://travis-ci.org/kjtanaka/artdc)

Artdc is a simple handy template of Ansible `<role>/tests` that lets you test a role with
Docker container.

## Supported container distros and versions

| Distro | Versions          |
|:-------|:------------------|
|Ubuntu  |14.04, 15.10, 16.04|
|Debian  |Wheezy, Jessie     |
|Fedora  |22, 23             |
|CentOS  |6, 7               |
|OpenSUSE|13.2               |

> **Note:** You may want to take a look at the Dockerfiles in `Dockerfile.d`.
> Each of them pulls an image from the official repository of each distro and
> enable ssh key authentication.

## Installation

Create a role with `ansible-galaxy` and replace the `tests` directory like this:

```bash
$ ansible-galaxy init new-playbook
$ cd new-playbook
$ rm -rf tests
$ git clone https://github.com/kjtanaka/artdc.git tests
$ cd tests
```

## How to use

Take a look at `Makefile`, and update variables as you need. The default container
is Ubuntu 14.04, and the default variables are set to work for the default environment
of the Docker Toolbox on Mac OS X.

If your docker machine is your localhost, the following setting should work:

```
docker_machine_ip = 127.0.0.1
docker_config =
```

If you're using Docker for Mac, the following setting should work:

```
docker_machine_ip = 192.168.64.2
docker_config =
docker_ssh_timeout = 30
```

> **Note:** On Docker for Mac, it somehow takes long for Ansible to log in to container,
> and the default timeout(10 seconds) isn't long enough on my MacBook. That's the reason
> I set the timeout as 30 seconds.

Here's the commands

```bash
# Initialize the environment
$ ./artdc.sh init

# Test your playbook
$ ./artdc.sh provision

# Log into the container
$ ./artdc.sh ssh

# Destroy container and provision it from scratch
$ ./artdc.sh reprovision

# Clean container and image
$ ./artdc.sh clean
```

Basically, when you update your role, you just need to execute `make provision`,
and then when you want to test the role from scratch, execute `make reprovision`.
After you finish everything, you can clean it by `make clean`.

## Author
Maintained by Koji Tanaka

## License

MIT license.

## Acknowledgements

The idea is inspired by these things:

- [Vagrant](https://www.vagrantup.com/)
- [Test Kitchen](http://kitchen.ci/)
- [tutumcloud/tutum-centos](https://github.com/tutumcloud/tutum-centos.git)
- [Dockerizing an SSH daemon service](https://docs.docker.com/engine/examples/running_ssh_service/)
