#!/bin/bash

IMAGE=couchbasebuild/dfs
TAG=$(date +%Y%m%d)

PUBLISH=false
PLATFORMS=
for arg in "$@"; do
  case "${arg}" in
    --publish)
      PUBLISH=true
      PLATFORMS=linux/arm64,linux/amd64
      ;;
    *)
      echo "Invalid flag: ${arg}"
      exit 1
      ;;
  esac
done

if ${PUBLISH}; then
  ACTION=--push
  PLATFORMS="--platforms linux/arm64,linux/arm64"
else
  ACTION=--load
  # If we're not publishing, we only build for the current architecture.
fi

docker buildx build ${ACTION} ${PLATFORMS} \
  -t couchbasebuild/dfs:${TAG} \
  -t couchbasebuild/dfs:latest \
  .
