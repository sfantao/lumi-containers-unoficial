#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'
JAX_VERSION='0.4.28'
XLA_VERSION='rocm-jaxlib-v0.4.28-qa'
JAXLIB_VERSION='rocm-jaxlib-v0.4.28'

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-6.2.0  \
  ../common/Dockerfile.miniconda \
  ../common/Dockerfile.aws-ofi-rccl \
  ../common/Dockerfile.rccltest \
  $DOCKERFILE \
  ../common/Dockerfile.jax \
  ../common/Dockerfile.no-torch-libstdc++ \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg SERVER_PORT=$SERVER_PORT \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg JAX_VERSION=$JAX_VERSION \
  --build-arg XLA_VERSION=$XLA_VERSION \
  --build-arg JAXLIB_VERSION=$JAXLIB_VERSION \
  --progress=plain -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES
