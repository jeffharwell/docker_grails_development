#!/bin/bash

## The required starting variables
CURRENT_VERSION=`cat ./CURRENT_VERSION`
CONTAINER_NAME="grails_dev"
LINK_TO="rabbit"
# 192.168.27.81 is docker1dev
# 192.168.27.23 is docker1
IP_ADDR="192.168.27.81"

if [ 'root' != `whoami` ]; then
    echo "You must run this as root"
    exit 1
fi

## Prereq check, the rabbit container must be running first
docker inspect ${LINK_TO} 1>/dev/null 2>/dev/null
if [ $? -gt 0 ]; then
  echo "Couldn't find container '${LINK_TO}'"
  echo "The '${LINK_TO}' container must be running before starting this container"
  exit
fi

## Cleanup (hope you got your changes up to the repository!)
docker stop ${CONTAINER_NAME}
docker rm -v ${CONTAINER_NAME}

## you probably want to change 192.168.27.81 to something appropriate
## for the host you are launching on
sudo docker run -d --name ${CONTAINER_NAME} --link ${LINK_TO}:${LINK_TO} -p ${IP_ADDR}:8080:8080 harwell/grails_development:${CURRENT_VERSION}

## Push in the real certificate for this docker host
echo "Pushing private key for" `whoami` "into the container"
cat ${HOME}/.ssh/id_rsa.pub | docker exec -i $CONTAINER_NAME sh -c 'cat > /root/.ssh/authorized_keys'
docker exec -i $CONTAINER_NAME chmod 600 /root/.ssh/authorized_keys

## Return the IP address
echo "IP Address for container '${CONTAINER_NAME}' is:"
docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CONTAINER_NAME}

