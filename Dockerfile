# Pull base image.
FROM ubuntu 

# Maintainer
# ----------
MAINTAINER David Winters <dwinters@c2b2.co.uk>

ENV PAYARA_PKG http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-prerelease.zip
ENV PKG_FILE_NAME payara-prerelease.zip

#Instal packages on ubuntu base image

RUN \
 apt-get clean && \ 
 apt-get install -y unzip && \
 apt-get install -y curl && \ 
 apt-get install -y software-properties-common python-software-properties


# Install Java 8

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \ 
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# add payara user, download payara nightly build and unzip
RUN useradd -b /opt -m -s /bin/bash payara && echo payara:payara | chpasswd
RUN cd /opt && curl -O $PAYARA_PKG && unzip $PKG_FILE_NAME && rm $PKG_FILE_NAME
RUN chown -R payara:payara /opt/payara41*

# Default payara ports to expose
EXPOSE 4848 8009 8080 8181

# Set up payara user and the home directory for the user
USER payara
WORKDIR /opt/payara41/glassfish/bin

# User: admin / Pass: glassfish
RUN echo "admin;{SSHA256}80e0NeB6XBWXsIPa7pT54D9JZ5DR5hGQV1kN1OAsgJePNXY6Pl0EIw==;asadmin" > /opt/payara41/glassfish/domains/payaradomain/config/admin-keyfile
RUN echo "AS_ADMIN_PASSWORD=glassfish" > pwdfile

# enable secure admin to access DAS remotely
RUN \
  ./asadmin start-domain payaradomain && \
  ./asadmin --user admin --passwordfile pwdfile enable-secure-admin && \
  ./asadmin stop-domain payaradomain

RUN echo "export PATH=$PATH:/opt/payara41/glassfish/bin" >> /opt/payara/.bashrc

# Default command to run on container boot
CMD ["/opt/payara41/glassfish/bin/asadmin", "start-domain", "payaradomain"]
