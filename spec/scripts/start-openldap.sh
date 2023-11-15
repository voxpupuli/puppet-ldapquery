#!/bin/bash

docker run --detach --rm \
  --name openldap \
  --hostname openldap \
  --publish 1389:1389 \
  --publish 1636:1636 \
  bitnami/openldap

sleep 5
docker logs openldap --tail 100

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' openldap > ~/OPENLDAP_IP
