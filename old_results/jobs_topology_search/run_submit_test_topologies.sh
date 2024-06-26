#!/bin/bash
#SBATCH --job-name=topo_search	 # create a short name for your job
#SBATCH --output=./run_ml/slurm-%A.%a.out # stdout file
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=2G         # memory per cpu-core (4G is default)
#SBATCH --time=10:00:00          # total run time limit (HH:MM:SS)

mkdir -p run_ml

m=10
# k=20
for k in 30 40 50 100 200 # 300 400 500 5000
# for k in 20 30 40 50 100 200 # 300 400 500 5000
do
	s=0
	# outdir="/n/fs/ragr-research/projects/problin/jobs_topology_search/log_mlnone_results_k${k}"
	# mkdir -p ${outdir}
	outfile="mlnone_results_k${k}/rep${rep}/topo${idx}.txt"
	if [ ! -f ${outfile} ]
	then
		echo "sbatch run_test_topologies.sh ${k} ${s}" 
		sbatch run_test_topologies.sh ${k} ${s} 
	else
		echo "${outfile} already exists."
	fi
	#	done


done
	:'
	for s in {1..9}
	do
		outfile="/n/fs/ragr-research/projects/problin/Experiment/jobs_topology_search/mlnone_results_k${k}_rep${rep}/topo${idx}.txt"
		if [ ! -f ${outfile} ]
		then
			echo "sbatch run_test_topologies.sh ${k} ${s}00" 
			sbatch run_test_topologies.sh ${k} ${s}00 
		else
			echo "${outfile} already exists."
		fi
	done
	'
