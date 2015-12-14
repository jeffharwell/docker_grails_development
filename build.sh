#!/bin/bash

if [ 'root' != `whoami` ]; then
    echo "You must run this as root"
    exit 1
fi

CURRENT_VERSION=`cat ./CURRENT_VERSION`
docker build -t harwell/grails_development:${CURRENT_VERSION} .
