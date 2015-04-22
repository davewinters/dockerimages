
# Pull base image.
FROM ubuntu 

# Maintainer
# ----------
MAINTAINER David Winters <dwinters@c2b2.co.uk>

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV JAVA_GZ jdk-8u45-linux-x64.tar.gz
ENV JAVA_TAR jdk-8u45-linux-x64.tar
ENV JAVA_VERSION jdk1.8.0_45
ENV PAYARA_PKG http://payara.co.s3-website-eu-west-1.amazonaws.com/payara-prerelease.zip
ENV PKG_FILE_NAME payara-prerelease.zip

#Install rpm package on ubuntu base image

RUN sudo apt-get install -y gzip
RUN sudo apt-get install -y tar
RUN sudo apt-get install -y unzip
RUN sudo apt-get install -y curl
# Install and configure Oracle JDK 8u45
# -------------------------------------
COPY $JAVA_GZ /root/
RUN gzip -d /root/$JAVA_GZ 
RUN sleep 5
RUN tar -xvf /root/$JAVA_TAR
RUN sleep 10
ENV JAVA_HOME /root/$JAVA_VERSION
ENV PATH $JAVA_HOME/bin:$PATH
#ENV CONFIG_JVM_ARGS -Djava.security.egd=file:/dev/./urandom

# Setup required packages (unzip), filesystem, and oracle user
# ------------------------------------------------------------
# Enable this if behind proxy
# RUN sed -i -e '/^\[main\]/aproxy=http://proxy.com:80' /etc/yum.conf
RUN useradd -b /opt -m -s /bin/bash payara && echo payara:payara | chpasswd
RUN cd /opt && curl -O $PAYARA_PKG && unzip $PKG_FILE_NAME && rm $PKG_FILE_NAME
RUN chown -R payara:payara /opt/payara41*
#RUN chown -R payara:payara /opt/*

# Default payara ports
EXPOSE 4848 8009 8080 8181

# Set payara user in its home/bin by default
USER payara
WORKDIR /opt/payara41/glassfish/bin

RUN echo "export PATH=$PATH:/opt/payara41/glassfish/bin" >> /opt/payara41/.bashrc

RUN echo $PATH
#RUN ls -l /opt/$JAVA_VERSION

# User: admin / Pass: glassfish
RUN echo "admin;{SSHA256}80e0NeB6XBWXsIPa7pT54D9JZ5DR5hGQV1kN1OAsgJePNXY6Pl0EIw==;asadmin" > /opt/payara41/glassfish/domains/payaradomain/config/admin-keyfile
RUN echo "AS_ADMIN_PASSWORD=glassfish" > pwdfile

# Default to admin/glassfish as user/pass
RUN ./asadmin start-domain payaradomain && \
RUN ./asadmin --user admin --passwordfile pwdfile enable-secure-admin && \
RUN ./asadmin stop-domain payaradomain

#RUN echo "export PATH=$PATH:/opt/payara41/glassfish/bin" >> /opt/payara41/.bashrc

# Default command to run on container boot
CMD ["/opt/payara41/glassfish/bin/asadmin", "start-domain payaradomain", "--verbose=true"]
