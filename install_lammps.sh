#!/bin/bash

# pick appropriate Makefile and edit for compiler and FFT library
makefile_original="MAKE/OPTIONS/Makefile.kokkos_cuda_mpi"
# MPI C++ compiler
#mpicompiler="<..>"
# FFT configuration - leave all blank for internal KISS FFT
#fft_includes=""
#fft_paths=""
#fft_libs=""

#make_target="benchmark"
if lspci | grep NVIDIA | grep TU
then
#sed -i "/Kepler35/s/Kepler35/Turing75/" $makefile_original
sed "/KOKKOS_ARCH/s|= .*|= Turing75|" MAKE/OPTIONS/Makefile.kokkos_cuda_mpi
fi

if lspci | grep NVIDIA | grep GV
then
#sed -i "/Kepler35/s/Kepler35/Volta70/" $makefile_original
sed "/KOKKOS_ARCH/s|= .*|= Volta70|" MAKE/OPTIONS/Makefile.kokkos_cuda_mpi
fi

# select desired LAMMPS packages
# these are required for this benchmark
make no-all
make yes-CLASS2
make yes-KSPACE
make yes-MANYBODY
make yes-MISC
make yes-MOLECULE
make yes-USER-MISC
# add any LAMMPS accelerator packages (if relevant)
make yes-replica yes-asphere yes-rigid yes-user-omp yes-user-reaxc

make yes-kokkos

# build
#make $make_target
CPUs=`lscpu | grep ^CPU\( | awk '{print $2}'`
make kokkos_cuda_mpi -j $CPUs
