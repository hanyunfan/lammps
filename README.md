# lammps
Lammps Dockerfile

#run
docker run -it --gpus=all  --net=host --uts=host --ulimit stack=67108864 --ulimit memlock=-1 --security-opt seccomp=unconfined -v /opt/dell/srvadmin:/opt/dell/srvadmin -v /home/frank/lammps:/lammps-stable_3Mar2020/src/results hanyunfan/lammps:8GPU bash
./runme.sh DSS8440 V100S

#recompile
Run the install_lammps.sh script inside the docker

#run with less GPUs in the nodes
Need to modify the NTASK_SLRUM parameters in the runme.sh script or use -e command to pass it into docker


