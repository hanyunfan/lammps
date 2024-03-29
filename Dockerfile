ARG FROM_IMAGE_NAME=nvcr.io/nvidia/cuda:11.4.1-devel-centos8
FROM ${FROM_IMAGE_NAME}
MAINTAINER Frank Han <frank.han@dell.com>
RUN \
	mkdir /cuda &&\
        yum -y update && \
        #yum -y install gcc vim rsync make gcc-gfortran gcc-c++ wget curl tar bzip2 perl ssh rsh numactl numactl-devel bc pciutils
        yum -y install gcc vim rsync make gcc-gfortran gcc-c++ wget curl tar bzip2 perl openssh-clients numactl numactl-devel bc pciutils
#Install openmpi
WORKDIR /
RUN \
        wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.bz2 && \
        tar xvf openmpi-4.1.1.tar.bz2 && \
        cd openmpi-4.1.1 && rm -rf build;mkdir build && cd build && \

        #../configure --prefix=$OMP_INSTALL_PATH --with-cuda=/cm/shared/apps/cuda10.1/toolkit/10.1.130 --with-pmi && \
        ../configure --prefix=/openmpi --with-cuda && \

        make all -j 20 && \
        make install -j20
#        rm -rf /openmpi-4.1.1 && rm -rf \openmpi-4.1.1.tar.bz2
# lammps code
WORKDIR /
#COPY . .
RUN \
	wget https://github.com/lammps/lammps/archive/refs/tags/stable_29Sep2021_update1.tar.gz && \
	tar xvf stable_29Sep2021_update1.tar.gz && \
	rm -rf stable_29Sep2021_update1.tar.g openmpi-4.1.1.tar.bz2
ENV \
        PATH=/openmpi/bin:/usr/local/cuda/bin:/bin:/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin \
        LD_LIBRARY_PATH=/openmpi/lib:/usr/local/cuda/lib64:/cuda/lib64
#Dataset and run
WORKDIR /lammps-stable_29Sep2021_update1/src
RUN \
	mkdir results && \
	wget https://lammps.sandia.gov/inputs/in.lj.txt && \
	sed -i "s/100/1000/" in.lj.txt 
#	mpirun --allow-run-as-root --report-bindings --bind-to core -np 8 ./lmp_kokkos_cuda_mpi -sf kk -pk kokkos neigh full comm device binsize 2.8 -v x 8 -v y 8 -v z 8 -v t 1000 -k on g 8 -in in.lj.txt -log lj_results.log
#run and install scripts
COPY runme.sh .
COPY install_lammps.sh .

#ENTRYPOINT [“./install_lammps.sh”]
