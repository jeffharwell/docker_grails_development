FROM java:8-jdk
MAINTAINER Jeff Harwell <jharwell@fuller.edu>

## Based on niaquinto/grails ... but I wanted a newer version of grails
ENV GRAILS_VERSION 3.0.4
WORKDIR /usr/lib/jvm

RUN wget https://github.com/grails/grails-core/releases/download/v${GRAILS_VERSION}/grails-${GRAILS_VERSION}.zip && \
    unzip grails-${GRAILS_VERSION}.zip && \
    rm -rf grails-${GRAILS_VERSION}.zip && \
    ln -s grails-${GRAILS_VERSION} grails

ENV GRAILS_HOME /usr/lib/jvm/grails
ENV PATH $GRAILS_HOME/bin:$PATH

## Create the Banner Systems User
run /usr/sbin/adduser --gecos "Grails User" --disabled-login --disabled-password grails_user

RUN apt-get -y update
RUN apt-get -y install vim
RUN apt-get -y install openssh-server
## Got to Have Wget
#run apt-get -y install wget gcc python-dev libffi-dev libaio1 libldap2-dev libsasl2-dev
#run apt-get -y install git
#run apt-get -y build-essential libssl-dev sudo

##
## VIM Setup
##
COPY files/vimrc /root/.vimrc
COPY files/vimrc /home/grails_user/.vimrc
RUN chown grails_user:grails_user /home/grails_user/.vimrc

##
## Some SSH Setup
## 

# SSH Keys for Remote Server Access (these are sensitive)
RUN mkdir /home/grails_user/.ssh &&\
    chown grails_user:grails_user /home/grails_user/.ssh &&\
    chmod 700 /home/grails_user/.ssh
COPY files/known_hosts /home/grails_user/.ssh/
RUN chown grails_user:grails_user /home/grails_user/.ssh/*
RUN chmod 600 /home/grails_user/.ssh/*
COPY files/get_grailsrestfulapiservice.sh /home/grails_user/
RUN chown grails_user:grails_user /home/grails_user/get_grailsrestfulapiservice.sh
RUN chmod +x /home/grails_user/get_grailsrestfulapiservice.sh
COPY files/profile /home/grails_user/.profile
RUN chown grails_user:grails_user /home/grails_user/.profile

# Set up the SSH directory
RUN mkdir /root/.ssh &&\
    chown root:root /root/.ssh &&\
    chmod 700 /root/.ssh
# "Seperation of Privileges" directory
RUN mkdir /var/run/sshd
# I want the message of the day
#RUN sed -i 's/PrintMotd no/PrintMotd yes/' /etc/ssh/sshd_config
# Copy a helpful usage message for login
COPY files/motd /etc/motd

## And Clean the Cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Git setup from the grails user
RUN su - grails_user -c 'git config --global user.email "jharwell@fuller.edu"'
RUN su - grails_user -c 'git config --global user.name "Jeff Harwell"'

## By default run by starting the SSH server
##  -D mean "don't become a daemon", which keeps our docker image
##  from going away immediately.
CMD ["/usr/sbin/sshd","-D"]
