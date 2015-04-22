#!/bin/bash
IMAGE_NAME=payara:4.1.152
JAVA_VERSION="8u45"
JAVA_PKG="jdk-${JAVA_VERSION}-linux-x64.tar.gz"

# Validate Java Package
echo "====================="

if [ ! -e $JAVA_PKG ]
then
  echo "Download the Oracle JDK ${JAVA_VERSION} gunzip for 64 bit and"
  echo "drop the file $JAVA_PKG in this folder before"
  echo "building this image!"
  exit
fi

docker build -t $IMAGE_NAME .

echo "====================="

docker build -t $IMAGE_NAME .

echo ""
echo "Payara  Docker Container is ready to be used. To start, run 'dockerPayara.sh'"


