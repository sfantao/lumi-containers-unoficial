#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'
PYTORCH_VERSION='2.5.1+rocm6.2'
APEX_VERSION='release/1.4.0'
TORCHVISION_VERSION='0.20.1+rocm6.2'
TORCHDATA_VERSION='0.9.0'
TORCHTEXT_VERSION='0.18.0'
TORCHAUDIO_VERSION='2.5.1+rocm6.2'
VLLM_VERSION='v0.6.3.post2+rocm'
CUPY_VERSION='13.2.0'
MPI4PY_VERSION='3.1.6'

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-6.2.3  \
  ../common/Dockerfile.miniconda \
  ../common/Dockerfile.aws-ofi-rccl \
  ../common/Dockerfile.rccltest \
  $DOCKERFILE \
  ../common/Dockerfile.cupy \
  ../common/Dockerfile.mpi4py \
  ../common/Dockerfile.no-torch-libstdc++ \
  ../common/Dockerfile.no-torch-rocm \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg PYTORCH_VERSION=$PYTORCH_VERSION \
  --build-arg APEX_VERSION=$APEX_VERSION \
  --build-arg TORCHVISION_VERSION=$TORCHVISION_VERSION \
  --build-arg TORCHDATA_VERSION=$TORCHDATA_VERSION \
  --build-arg TORCHTEXT_VERSION=$TORCHTEXT_VERSION \
  --build-arg TORCHAUDIO_VERSION=$TORCHAUDIO_VERSION \
  --build-arg VLLM_VERSION=$VLLM_VERSION \
  --build-arg CUPY_VERSION=$CUPY_VERSION \
  --build-arg MPI4PY_VERSION=$MPI4PY_VERSION \
  --build-arg PYTORCH_DEBUG=0 \
  --build-arg PYTORCH_RELWITHDEBINFO=0 \
  -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES