#!/usr/bin/env bash
# move a docker image from one harbor to the other
set -eo pipefail

path="$1"
from="$2"
to="$3"
docker pull "$from/$path"
docker tag "$from/$path" "$to/$path"
docker push "$to/$path"
