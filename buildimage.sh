#!/bin/bash
IMAGE_NAME=payara:4.1.152

docker build -t $IMAGE_NAME .

echo "====================="

docker build -t $IMAGE_NAME .

echo ""
echo "Payara Docker Image has been built. To start a new container, execute: docker run -i -t payara:4.1.152  /bin/bash "


