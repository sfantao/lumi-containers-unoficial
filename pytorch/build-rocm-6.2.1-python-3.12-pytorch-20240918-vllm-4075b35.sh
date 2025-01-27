#!/bin/bash -eux 
set -o pipefail

PYTHON_VERSION='3.12'

#PYTORCH_VERSION='2.6.0.dev20240918'
PYTORCH_VERSION='2.6.0.dev20241122'
#TORCHVISION_VERSION='0.20.0.dev20240918' # 2024-08-03 nightly release
TORCHVISION_VERSION='0.20.0.dev20241206'
FLASH_ATTENTION_VERSION='3cea2fb'
TRITON_VERSION='e192dba' 
LLVM_VERSION='4e0a0eae58f7a6998866719f7eb970096a2a52e9'
VLLM_VERSION="4075b35"

cat \
  ../common/Dockerfile.header \
  ../common/Dockerfile.rocm-6.2.1  \
  ../common/Dockerfile.miniconda \
  ../common/Dockerfile.aws-ofi-rccl \
  ../common/Dockerfile.rccltest \
  $DOCKERFILE \
  ../common/Dockerfile.no-torch-libstdc++ \
  > $DOCKERFILE_TMP

$DOCKERBUILD \
  -f $DOCKERFILE_TMP \
  --build-arg PYTHON_VERSION=$PYTHON_VERSION \
  --build-arg PYTORCH_VERSION=$PYTORCH_VERSION \
  --build-arg TORCHVISION_VERSION=$TORCHVISION_VERSION \
  --build-arg FLASH_ATTENTION_VERSION=$FLASH_ATTENTION_VERSION \
  --build-arg TRITON_VERSION=$TRITON_VERSION \
  --build-arg LLVM_VERSION=$LLVM_VERSION \
  --build-arg VLLM_VERSION=$VLLM_VERSION \
  --build-arg PYTORCH_DEBUG=0 \
  --build-arg PYTORCH_RELWITHDEBINFO=0 \
  -t $TAG . 2>&1 | tee $LOG

echo "$TAG" > $RES