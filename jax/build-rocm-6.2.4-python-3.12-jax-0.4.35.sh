#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'
JAX_VERSION='0.4.35'

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-6.2.4  \
  ../common/Dockerfile.miniconda \
  ../common/Dockerfile.aws-ofi-rccl \
  ../common/Dockerfile.rccltest \
  $DOCKERFILE \
  ../common/Dockerfile.jax \
  ../common/Dockerfile.no-torch-libstdc++ \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg JAX_VERSION=$JAX_VERSION \
  -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES
