#!/bin/bash
LISTENIP=$1
echo $LISTENIP
sudo docker run -d --name rabbit -p $LISTENIP:5672:5672 -p $LISTENIP:15672:15672 rabbitmq:management
sudo docker run -t -i -p $LISTENIP:8080:8080 --name grails --link rabbit:rabbit harwell/grails_development:1 su - grails_user
