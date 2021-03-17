#!/bin/bash
#SBATCH --account=nn9989k
## change or remove (training_2 is for 2nd day)
#SBATCH --reservation=training_2
## adjust number of cores with ntasks
#SBATCH --ntasks=1
# only for Saga
## adjust to what is needed for all tasks together
#SBATCH --mem=100M
## adjust runtime limit as needed
#SBATCH --time=00:02:00

## keep for getting some information on requested resources
env

## initializes EESSI pilot on reserved compute nodes
## Note, EESSI pilot requires CernVM-FS client which is
## only installed & configured on the compute nodes
## reserved for the course (see 'scontrol show res').
echo
echo Sourcing EESSI pilot init script
source /cvmfs/pilot.eessi-hpc.org/2020.12/init/bash

## Circumvents an issue with the EESSI pilot.
## Note, the IP addresses differ from Saga to Fram.
## If you copy the script between HPC clusters, you
## need to adjust the variables accordingly.
##
## Settings for Fram
#export http_proxy=http://10.1.1.16:3128/
#export https_proxy=http://10.1.1.16:3128/
##
## Settings for Saga
export http_proxy=http://10.31.0.23:3128/
export https_proxy=http://10.31.0.23:3128/

## Target value is 20000. Begin with small increases.
NSTEPS=100

echo Run GROMACS demo
module load GROMACS/2020.1-foss-2020a-Python-3.8.2

if [ ! -f GROMACS_TestCaseA.tar.gz ]; then
  curl -OL https://repository.prace-ri.eu/ueabs/GROMACS/1.2/GROMACS_TestCaseA.tar.gz
fi
if [ ! -f ion_channel.tpr ]; then
  tar xfz GROMACS_TestCaseA.tar.gz
fi

rm -f ener.edr logfile.log

# note: downscaled to just 1k steps (full run is 10k steps)
time mpirun gmx_mpi mdrun -s ion_channel.tpr -maxh 0.50 -resethway -noconfout -nsteps ${NSTEPS} -g logfile

