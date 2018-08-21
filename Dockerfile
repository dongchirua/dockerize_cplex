FROM ubuntu:16.04

RUN \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential && \
    apt-get install -y software-properties-common && \
    apt-get install -y unzip apt-utils wget python-pip

# Install Java.
RUN \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer && \
    rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

WORKDIR /App
ENV APP /App

# Install CPLEX
COPY cplex_studio12.7.1.linux-x86-64.bin .
RUN ["chmod", "u+x", "./cplex_studio12.7.1.linux-x86-64.bin"]
COPY installer.properties .
RUN ./cplex_studio12.7.1.linux-x86-64.bin -i Silent -f installer.properties
ENV PATH=${APP}/ibm/cplex/bin/x86-64_linux:${APP}/ibm/cpoptimizer/bin/x86-64_linux:${PATH}
ENV PYTHONPATH=${APP}/ibm/cplex/python/2.7/x86-64_linux
RUN \
    touch $PYTHONPATH/cpo_config.py && echo "set_default(LOCAL_CONTEXT)" > $PYTHONPATH/cpo_config.py && \
    rm -f cplex_studio12.7.1.linux-x86-64.bin installer.properties
