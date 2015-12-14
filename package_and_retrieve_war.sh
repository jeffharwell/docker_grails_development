#!/bin/bash
CONTAINER_NAME="grails"
APP_VERSION="0.1"
GRAILS_REPO="GrailsRestfulAPIService"
GRAILS_APP="apiservice"

## Instruct grails inside of docker to build the WAR file
docker exec grails su grails_user -c /home/grails_user/$GRAILS_REPO/$GRAILS_APP/build_grails_war.sh
## Retrieve the completed WAR from the container
echo "Retrieving WAR file apiservice-$APP_VERSION.war"
docker cp $CONTAINER_NAME:/home/grails_user/$GRAILS_REPO/$GRAILS_APP/build/libs/apiservice-$APP_VERSION.war ./
