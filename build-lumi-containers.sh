#!/bin/bash -e

target=all
procs=4

#
# Change default target if that has been provided.
#
if [ $# -eq 2 ] ; then
  target=$1
  procs=$2
fi

# export  DOCKER_BUILDKIT=0
export BUILDKIT_STEP_LOG_MAX_SIZE=-1
export BUILDKIT_STEP_LOG_MAX_SPEED=-1
export DOCKERBUILD="docker build \
                      --ulimit nofile=32000:32000 \
                      --network=host "

#
# Build helper file container
#
(cd helper-files ; docker build -t h .)

#
# Build recipes
#

echo "Starting image building..."
make -j$procs $target
echo "Done building images..."

#
# Close
#
echo " ------------------------------------ "
echo " Recipes build completed successfully "
echo " ------------------------------------ "

#
# Upstream and test images.
#
LUMI_TEST_FOLDER="/pfs/lustrep3/scratch/project_462000394/containers/staging-area"
Nodes=4
echo "test.sbatch" > .all-test-files
cat > test.sbatch << EOF
#!/bin/bash -e
#SBATCH -J lumi-container-test
#SBATCH -p standard-g
#SBATCH --threads-per-core 1
#SBATCH --exclusive 
#SBATCH -N $Nodes 
#SBATCH --gpus $((Nodes*8)) 
#SBATCH -t 2:00:00 
#SBATCH --mem 0
#SBATCH -o test.out
#SBATCH -e test.err

export SIF_FOLDER=/appl/local/containers/staging-area/lumi

set -o pipefail
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3

#
# Execute examples
#

c=fe
#
# Bind mask for one and  thread per core
#
MYMASKS1="0x\${c}000000000000,0x\${c}00000000000000,0x\${c}0000,0x\${c}000000,0x\${c},0x\${c}00,0x\${c}00000000,0x\${c}0000000000"
MYMASKS2="0x\${c}00000000000000\${c}000000000000,0x\${c}00000000000000\${c}00000000000000,0x\${c}00000000000000\${c}0000,0x\${c}00000000000000\${c}000000,0x\${c}00000000000000\${c},0x\${c}00000000000000\${c}00,0x\${c}00000000000000\${c}00000000,0x\${c}00000000000000\${c}0000000000"

export SCMD="srun \
  -N $Nodes \
  -n $((Nodes*8)) \
  --cpu-bind=mask_cpu:\$MYMASKS1 \
  --gpus $((Nodes*8)) \
  singularity exec \
    -B /var/spool/slurmd \
    -B /opt/cray \
    -B /usr/lib64/libcxi.so.1"
EOF

files=''

if [[ "$files" == '' ]] ; then
  if [[ "$target" == "all" ]] ; then
    files=$(ls -1 */build-*.done)
  else
    files=$(ls -1 $target/build-*.done)
  fi
fi

set -x

mkdir -p singularity-images
rm -rf /dev/shm/singularity-images
mkdir -p /dev/shm/singularity-images

#docker login
for i in $files ; do
  while read -r line; do 
    echo $line

    project=$(dirname $i)
    filename=$(basename $i)
    test_filename=${filename%.done}.test
    local_tag=$line

    #
    # Remote names
    #

    if [ $(docker images $local_tag | wc -l) -ne 2 ] ; then
      echo "Tag $local_tag can't be found."
      false
    fi

    hash=$(docker images $local_tag | head -n2 | tail -n1 | awk '{print $3;}')
    fname="$(echo $local_tag | sed 's/:/-/g' )-dockerhash-$hash"
    tarf="${fname}.tar"
    sif="${fname}.sif"

    # Build singularity images if it does exist or if the image is broken.
    if [ ! -f singularity-images/$sif -o ! ./singularity-images/$sif ] ; then
      
      rm -rf singularity-images/$sif

      SINGULARITY_TMPDIR=/dev/shm/singularity-images \
      singularity build \
        --fix-perms \
        singularity-images/$sif \
        docker-daemon://${local_tag}
    fi

    #
    # Add entry to test script.
    #
    echo "$project/$test_filename" >> .all-test-files
    cat >> test.sbatch << EOF


    test=\$(realpath $project/$test_filename)
    sif=\$(realpath $sif)

    chmod +x \$test

    cd $project
    \$test \$sif |& tee $test_filename.log
    if [ \$? -eq 0 ] ; then
      echo "-------------------"
      echo "Test success!!! --> $local_tag (\$sif)"
      echo "-------------------"
    else
      echo "###################"
      echo "###################"
      echo "###################"
      echo "Test FAILED!!! --> $local_tag (\$sif)"
      echo "###################"
      echo "###################"
      echo "###################"
    fi
    \cd -
EOF

  done < $i
done

rm -rf test.tar 
tar -cf test.tar $(cat .all-test-files)
# scp test.tar lumi:$LUMI_TEST_FOLDER
# #ssh lumi "bash -c 'set -ex ; cd $LUMI_TEST_FOLDER; rm -rf runtests ; mkdir runtests ; cd runtests; tar -xf ../test.tar'"
# ssh lumi "bash -c 'set -ex ; cd $LUMI_TEST_FOLDER; rm -rf runtests ; mkdir runtests ; cd runtests; tar -xf ../test.tar ; sbatch < test.sbatch'"
