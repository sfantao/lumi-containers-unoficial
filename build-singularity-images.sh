#!/bin/bash -eux

mkdir -p /tmp/singularity-images
export SINGULARITY_TMPDIR=/tmp/singularity-images

mkdir -p /pfs/lustrep3/scratch/project_462000394/containers/staging-area/lumi
cd /pfs/lustrep3/scratch/project_462000394/containers/staging-area


    # Build singularity images if it does exist or if the image is broken.
    if [ -f lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-dockerhash-0fb1415058b3.sif ] && lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-dockerhash-0fb1415058b3.sif ls ; then
      echo "SIF image $(realpath lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-dockerhash-0fb1415058b3.sif) already exists!"
    else
      echo Building "SIF image $(realpath lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-dockerhash-0fb1415058b3.sif)..."
      rm -rf lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-*.sif

      singularity build \
        --fix-perms \
        lumi/lumi-pytorch-rocm-6.2.4-python-3.12-pytorch-v2.6.0-dockerhash-0fb1415058b3.sif \
        docker://127.0.0.1:5000/lumi/lumi-pytorch:rocm-6.2.4-python-3.12-pytorch-v2.6.0
    fi
