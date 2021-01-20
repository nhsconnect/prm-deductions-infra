#!/bin/bash -e

sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

eval $(aws ecr get-login --no-include-email --region eu-west-2)

docker run -d --name unbound \
 -p 53:53/udp -p 53:53/tcp \
 -e GLOBAL_FORWARD_SERVER=${GLOBAL_FORWARD_SERVER} \
 -e FORWARD_ZONE_NAME="${FORWARD_ZONE_NAME}" \
 -e HSCN_FORWARD_SERVER_1=${HSCN_FORWARD_SERVER_1} \
 -e HSCN_FORWARD_SERVER_2=${HSCN_FORWARD_SERVER_2} \
 ${DOCKER_IMAGE_URL}
