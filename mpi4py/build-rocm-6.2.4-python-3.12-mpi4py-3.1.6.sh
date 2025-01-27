#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'
CUPY_VERSION='13.2.0'
MPI4PY_VERSION='3.1.6'

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-6.2.4  \
  ../common/Dockerfile.miniconda \
  $DOCKERFILE \
  ../common/Dockerfile.cupy \
  ../common/Dockerfile.mpi4py \
  ../common/Dockerfile.osu \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg CUPY_VERSION=$CUPY_VERSION \
  --build-arg MPI4PY_VERSION=$MPI4PY_VERSION \
  -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES
