#!/bin/bash
set -x

#SBATCH -w node001,node002
#SBATCH --gres=gpu:4
#SBATCH -p C4140K
#SBATCH -J lammps
#SBATCH -D /cm/shared/apps/lammps/lammps-patch_24Oct2018/src/


set -x
if [ $# -ne 2 ]
then
   echo "Usage: $0 server_model GPU_num GPU_Type, ex. $0 C4130M V100-16G" && exit 1
fi

#module load shared gcc/7.2.0 cuda10.0 openmpi/cuda/64/3.1.3
#module list

echo $OMP_NUM_THREADS

#SLURM_NTASKS=8

#export CUDA_MPS_PIPE_DIRECTORY=/tmp/nvidia-mps
#export CUDA_MPS_LOG_DIRECTORY=/tmp/nvidia-log

#export OMP_NUM_THREADS=9
#export GOMP_CPU_AFFINITY=0-8

#DATETIME=`hostname`.`date +"%m%d.%H%M%S"`
#mkdir results/lammps-results-$DATETIME
DATETIME=`date +"%m%d.%H%M%S"`
TEST_NAME="$1"_"$SLURM_NTASKS"x_$2
OUTPUT_DIR=./results/$TEST_NAME-`hostname`-$DATETIME
mkdir -p ./results


if [ -z "$SLURM_NTASKS" ];
then
	SLURM_NTASKS=`lspci | grep NVIDIA | wc -l`;
elif [ "$SLURM_NTASKS" -eq 1 ]
then
export CUDA_VISIBLE_DEVICES=0
elif [ "$SLURM_NTASKS" -eq 2 ]
then
export CUDA_VISIBLE_DEVICES=0,1
#export CUDA_VISIBLE_DEVICES=0,2
elif [ "$SLURM_NTASKS" -eq 3 ]
then
export CUDA_VISIBLE_DEVICES=0,1,2
elif [ "$SLURM_NTASKS" -eq 4 ]
then
export CUDA_VISIBLE_DEVICES=0,1,2,3
elif [ "$SLURM_NTASKS" -eq 4 ]
then
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
fi



# setup for 1 GPU

num_proc_list=$SLURM_NTASKS
#num_proc_list="2 4 8"
#size_list="1x1x1 2x2x2 4x4x4 8x8x8 16x8x8 12x12x8 12x12x10"
size_list="8x8x8"
#size_list="1x1x1 2x2x2"
NUM_GPU=$SLURM_NTASKS
#sudo nvidia-smi -c 3
#echo "starting MPS on 1 GPU"
#export CUDA_VISIBLE_DEVICES=0
#nvidia-cuda-mps-control -d
#export CUDA_VISIBLE_DEVICES=0
#sleep 30




# setup for 4 GPUs

#num_proc_list="4"  # not using MPS

#num_proc_list="8 16 32"
#num_proc_list="32"
#num_proc_list="40"
#size_list="16x18x20"
#size_list="16x16x18 16x16x20"
#size_list="1x1x1 2x2x2 4x4x4 8x8x8 16x16x16 16x16x18 16x16x20"
#NUM_GPU=4


# for using MPS
#sudo nvidia-smi -c 3
#echo "starting MPS on 4 GPUs"
#export CUDA_VISIBLE_DEVICES=0,1,2,3
#nvidia-cuda-mps-control -d
#export CUDA_VISIBLE_DEVICES=0,1,2,3
#sleep 30

# if not using MPS with one GPU per rank
#sudo nvidia-smi -c 0
#echo "not usin MPS on 4 GPUs"
#export CUDA_VISIBLE_DEVICES=0,1,2,3



#for NUM_PROC in 2 4
for NUM_PROC in $num_proc_list
do

#	for SIZE_xyz in 16x8x8 12x12x8
#       for SIZE_xyz in 1x1x1 2x2x2 4x4x4 8x8x8 16x8x8 12x12x8 
       for SIZE_xyz in $size_list
	do

		case $SIZE_xyz in 

                1x1x1)
		ATOMS=32000
                SIZE="-v x 1 -v y 1 -v z 1"
                ;;

                2x2x2)
		ATOMS=`expr 32000 "*" 2 "*" 2 "*" 2`
                SIZE="-v x 2 -v y 2 -v z 2"
                ;;

                4x4x4)
                ATOMS=`expr 32000 "*" 4 "*" 4 "*" 4`
                SIZE="-v x 4 -v y 4 -v z 4"
                ;;

                8x8x8)
                ATOMS=`expr 32000 "*" 8 "*" 8 "*" 8`
                SIZE="-v x 8 -v y 8 -v z 8"
                ;;

		16x8x8)
                ATOMS=`expr 32000 "*" 16 "*" 8 "*" 8`
		SIZE="-v x 16 -v y 8 -v z 8"
		;;

		12x12x8)
                ATOMS=`expr 32000 "*" 12 "*" 12 "*" 8`
		SIZE="-v x 12 -v y 12 -v z 8"
		;;

                12x12x10)
                ATOMS=`expr 32000 "*" 12 "*" 12 "*" 10`
                SIZE="-v x 12 -v y 12 -v z 10"
                ;;

                16x16x16)
                ATOMS=`expr 32000 "*" 16 "*" 16 "*" 16`
                SIZE="-v x 16 -v y 16 -v z 16"
                ;;

                16x16x18)
                ATOMS=`expr 32000 "*" 16 "*" 16 "*" 18`
                SIZE="-v x 16 -v y 16 -v z 18"
                ;;

                16x16x20)
                ATOMS=`expr 32000 "*" 16 "*" 16 "*" 20`
                SIZE="-v x 16 -v y 16 -v z 20"
                ;;

                16x18x20)
                ATOMS=`expr 32000 "*" 16 "*" 18 "*" 20`
                SIZE="-v x 16 -v y 18 -v z 20"
                ;;

		esac

		echo "************** running lammps with $NUM_PROC MPI procs and $NUM_GPU GPU and SIZE = $SIZE_xyz = $ATOMS atoms  *********************"
export OMP_PROC_BIND=true
#mpirun -np $NUM_PROC  --allow-run-as-root /root/andy/LAMMPS/lammps-20Apr18/src/lmp_kokkos_cuda_mpi_sm70 -sf kk -pk kokkos neigh full comm device binsize 2.8 -v x 16 -v y 8 -v z 8 -v t 1000 -k on g 1 -in in.lj -log lj_1gpu_test.log

		#mpirun -np $NUM_PROC  --allow-run-as-root lmp_kokkos_cuda_mpi -sf kk -pk kokkos neigh full comm device binsize 2.8 $SIZE  -v t 1000 -k on g $NUM_GPU -in in.lj -log results/lammps-$DATETIME/lj_1gpu_test-$NUM_GPU-gpu--$NUM_PROC-MPI-$SIZE_xyz-SIZE.log
		mpirun --allow-run-as-root --report-bindings --bind-to core -np $NUM_GPU ./lmp_kokkos_cuda_mpi -sf kk -pk kokkos neigh full comm device binsize 2.8 $SIZE -v t 1000 -k on g $NUM_GPU -in in.lj.txt -log "$OUTPUT_DIR"_$SIZE_xyz-SIZE_lj.log
	done
done

echo ""
echo "****************************************************************"
echo "logs for this set of runs in : "$OUTPUT_DIR"_$SIZE_xyz-SIZE_lj.log"
echo "perf summary :"
echo " "

for NUM_PROC in $num_proc_list
do

       	for SIZE_xyz in $size_list
        do

		#echo "NUM_GPU=$NUM_GPU NUM_PROC=$NUM_PROC SIZE=$SIZE_xyz" |tee -a results/summary.txt
		echo "$TEST_NAME SIZE=$SIZE_xyz" |tee -a results/summary.txt
#                grep "atoms" "$OUTPUT_DIR"_$SIZE_xyz-SIZE_lj.log |tee -a results/summary.txt
#		grep "Performance" results/lammps-results-$DATETIME/lj_1gpu_test-$NUM_GPU-gpu--$NUM_PROC-MPI-$SIZE_xyz-SIZE.log
		tail -n 30 "$OUTPUT_DIR"_$SIZE_xyz-SIZE_lj.log |grep 'timesteps/s' | awk '{ total += $4 } END { print total/NR }' |tee -a results/summary.txt
		echo " " |tee -a results/summary.txt
	done

done


#	        sleep 20
#	        echo "stopping MPS"
#	        echo quit | nvidia-cuda-mps-control
#       	sleep 60
