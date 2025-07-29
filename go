#!/bin/bash

IMAGE=couchbasebuild/dfs
TAG=$(date +%Y%m%d)

PUBLISH=false
case "$(uname -m)" in
  x86_64)
    PLATFORM=linux/amd64
    ;;
  aarch64)
    PLATFORM=linux/arm64
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac
for arg in "$@"; do
  case "${arg}" in
    --publish)
      PUBLISH=true
      ;;
    --aarch64)
      PLATFORM=linux/arm64
      ;;
    --x86_64)
      PLATFORM=linux/amd64
      ;;
    *)
      echo "Invalid flag: ${arg}"
      exit 1
      ;;
  esac
done

if ${PUBLISH}; then
  ACTION=--push
  PLATFORM="linux/amd64,linux/arm64"
else
  ACTION=--load
  # If we're not publishing, we only build for the current architecture.
fi

set -x
docker buildx build ${ACTION} --platform ${PLATFORM} \
  -t couchbasebuild/dfs:${TAG} \
  -t couchbasebuild/dfs:latest \
  .
