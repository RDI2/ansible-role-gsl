#!/bin/bash

source artdcrc

show_help () {
    echo "Usage: ./test.sh <command>

Common command:
    init            initialize test environment
    provision       provision container
    reprovision     reprovision container
    ssh             log in to container
    clean           clean test environment.
    "
}

if [ $# != 1 ]; then
  show_help
  exit 1
fi

arr=" init provision rm rmi run reprovision stop ssh verify clean remove_ps remove_image "
if [[ ! " $arr " =~ " $1 " ]]; then
  show_help
  exit 1
fi

# Check if Docker is installed
which docker 1>/dev/null
if [ $? != 0 ]; then
    echo "Docker is not installed."
    exit 1
fi

# Check if Ansible is installed
which ansible 1>/dev/null
if [ $? != 0 ]; then
    echo "Ansible is not installed."
    exit 1
fi

inventory () {
  echo docker-container ansible_port=$DOCKER_SSH_PORT\
    ansible_user=root ansible_host=$DOCKER_MACHINE_IP timeout=$DOCKER_SSH_TIMEOUT\
    ansible_ssh_private_key_file=$DOCKER_SSH_PRIVKEY_PATH > inventory
}

init () {
  test -d $ROLE_TEST_DOTFILE_PATH 2>/dev/null || mkdir $ROLE_TEST_DOTFILE_PATH
  test -f $DOCKER_SSH_PRIVKEY_PATH >/dev/null ||\
    ssh-keygen -q -N "" -t rsa -f $DOCKER_SSH_PRIVKEY_PATH
  docker $DOCKER_CONFIG images | grep $DOCKER_IMAGE >/dev/null ||\
    docker $DOCKER_CONFIG build -t $DOCKER_IMAGE -f $DOCKERFILE_DIR/$DOCKERFILE .
  inventory
}

run_container () {
  docker $DOCKER_CONFIG ps | grep $DOCKER_CONTAINER > /dev/null ||\
    (echo \>\> runing container \'$DOCKER_CONTAINER\'... &&\
    (docker $DOCKER_CONFIG run -p $DOCKER_SSH_PORT:22 --name=$DOCKER_CONTAINER\
	  -e AUTHORIZED_KEYS="$DOCKER_SSH_PUBKEY" -dt $DOCKER_IMAGE) > /dev/null)
}

provision () {
  run_container
  ansible-playbook -i inventory test.yml
}

login () {
  ssh -p $DOCKER_SSH_PORT -i $DOCKER_SSH_PRIVKEY_PATH -o StrictHostKeyChecking=no root@$DOCKER_MACHINE_IP
}

stop_ps () {
  set +e
  docker $DOCKER_CONFIG ps | grep $DOCKER_CONTAINER 1>/dev/null &&\
    echo \>\> Stopping container \'$DOCKER_CONTAINER\'... &&
  	docker $DOCKER_CONFIG stop $DOCKER_CONTAINER > /dev/null
  set -e
}

remove_ps () {
  stop_ps
  set +e
  docker $DOCKER_CONFIG ps -a | grep $DOCKER_CONTAINER 1>/dev/null && \
    echo \>\> Removing container \'$DOCKER_CONTAINER\'... && \
    docker $DOCKER_CONFIG rm $DOCKER_CONTAINER > /dev/null
  set -e
}

remove_image () {
  docker $DOCKER_CONFIG images | grep $DOCKER_IMAGE 1>/dev/null && \
    echo \>\> Removing image \'$DOCKER_IMAGE\'... && \
  	docker $DOCKER_CONFIG rmi $DOCKER_IMAGE > /dev/null
}

verify () {
  provision
  echo \>\> Running bats...
  scp -P $DOCKER_SSH_PORT \
    -i $DOCKER_SSH_PRIVKEY_PATH \
    -o StrictHostKeyChecking=no \
    -o LogLevel=FATAL \
    test.bats root@$DOCKER_MACHINE_IP:/root/
  ssh -p $DOCKER_SSH_PORT \
    -i $DOCKER_SSH_PRIVKEY_PATH \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -o LogLevel=FATAL \
    root@$DOCKER_MACHINE_IP /usr/local/bin/bats /root/test.bats
}

case "$1" in
    init)
        init
        ;;
    run)
        run_container
        ;;
    provision)
        provision
        ;;
    ssh)
        login
        ;;
    stop)
        stop_ps
        ;;
    rm)
        remove_ps
        ;;
    rmi)
        remove_image
        ;;
    reprovision)
        remove_ps
        provision
        ;;
    verify)
        verify
        ;;
    clean)
        remove_ps
        remove_image
        test -f inventory && rm inventory
        ;;
    help)
        help
esac
