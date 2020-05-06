#!/bin/bash

docker pull hanyunfan/lammps:8GPU

outputdir=/home/frank/lammps
docker run -it --gpus=all  --net=host --uts=host --ulimit stack=67108864 --ulimit memlock=-1 --security-opt seccomp=unconfined -v /opt/dell/srvadmin:/opt/dell/srvadmin -v $outputdir:/lammps-stable_3Mar2020/src/results hanyunfan/lammps:8GPU ./runme.sh R7525 V100S


