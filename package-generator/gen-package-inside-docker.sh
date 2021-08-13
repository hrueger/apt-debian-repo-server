#! /bin/bash

docker exec -it deb-repo /package-generator/gen-package.sh $*
docker exec -it deb-istemci apt-get update && apt list $2