#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'
PYTORCH_VERSION='2.2.2+rocm5.7'
APEX_VERSION='release/1.2.0'
TORCHVISION_VERSION='0.17.2+rocm5.7'
TORCHDATA_VERSION='0.7.1'
TORCHTEXT_VERSION='0.17.2'
TORCHAUDIO_VERSION='2.2.2+rocm5.7'
TRITON_VERSION=2.2.0
# MPI needs ROCm 6 to work, so we don't add MPI4PY in this container.

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-5.7.3  \
  ../common/Dockerfile.miniconda \
  ../common/Dockerfile.aws-ofi-rccl \
  ../common/Dockerfile.rccltest \
  $DOCKERFILE \
  ../common/Dockerfile.no-torch-libstdc++ \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg SERVER_PORT=$SERVER_PORT \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg PYTORCH_VERSION=$PYTORCH_VERSION \
  --build-arg APEX_VERSION=$APEX_VERSION \
  --build-arg TORCHVISION_VERSION=$TORCHVISION_VERSION \
  --build-arg TORCHDATA_VERSION=$TORCHDATA_VERSION \
  --build-arg TORCHTEXT_VERSION=$TORCHTEXT_VERSION \
  --build-arg TORCHAUDIO_VERSION=$TORCHAUDIO_VERSION \
  --build-arg TRITON_VERSION=$TRITON_VERSION \
  --build-arg PYTORCH_DEBUG=0 \
  --build-arg PYTORCH_RELWITHDEBINFO=0 \
  --progress=plain -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES