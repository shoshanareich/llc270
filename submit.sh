#!/bin/bash
#PBS -q normal
#PBS -N mitgcm
#PBS -l select=19:ncpus=20:model=ivy
#PBS -l walltime=8:00:00
#PBS -o llc270.out
#PBS -e llc270.err

#--- 0.load modules ------
#ulimit -s unlimited
module purge
module load comp-intel/2018.3.222
module load szip/2.1.1
module load mpi-hpe/mpt
module load hdf4/4.2.12
module load hdf5/1.8.18_mpt
module load netcdf/4.4.1.1_mpt

echo $LD_LIBRARY_PATH

ulimit -s hard
ulimit -u hard

#---- 1.set variables ------
#note for bash: can not have any space around =

nprocs=362
snx=45
sny=45
#pickupts1="0001051920"
extpickup=
forwadj=

# --------------------------------------------
#whichcode="_ad_obsfit"
whichcode=
# --------------------------------------------

jobfile=submit${whichcode}.bash

#--- 2.set dir ------------
basedir=/home3/sreich/MITgcm_c68w/llc270/
scratchdir=/nobackup/sreich/llc270_c68w_runs/
codedir=$basedir/code${whichcode}
builddir=$basedir/build${whichcode}_${snx}x${sny}x${nprocs}
inputdir=$basedir/input${whichcode}

workdir=$scratchdir/run${whichcode}

mkdir $workdir
cd $workdir


#--- 3. link forcing -------------
ln -sf /nobackup/hzhang1/forcing/era5 .

#--- 4. linking binary ---------

ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
ln -sf /home3/sreich/MITgcm_c68w/llc270/run_template/* .


#
#=================================================================================
#--- 6. NAMELISTS ---------
cp -f ${inputdir}/* .
mv data.exch2_${snx}x${sny}x${nprocs} data.exch2
mv data.exf_era5 data.exf

#--- 7. executable --------
cp -f ${builddir}/mitgcmuv_${snx}x${sny}x${nprocs}${mitgcmext}${forwadj} ./mitgcmuv${forwadj}
cp -f ${builddir}/Makefile ./

#--- 8. pickups -----------
#NOTE: for pickup: copy instead of link to prevent accidental over-write
#  if [[ ${pickupts1} ]]; then
#    pickupdir=$scratchdir/run_pk0001051920
#    cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.data ./pickup.${pickupts1}.data
#    cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.meta ./pickup.${pickupts1}.meta
#  fi

mkdir -p $workdir/diags/state_avg_2d
mkdir -p $workdir/diags/state_avg_3d

#--- 9. make a list of all linked files ------

#  \rm -f command_ln_input
#  ls -l input_*/* > command_ln_input

  \rm -f command_ln_binary
  ls -l *.bin >> command_ln_binary
  ls -l tile* >> command_ln_binary
#
#
  set -x
  date > run.MITGCM.timing
  #-- for openmpi:
  #-- testing for mpavich2
  #ibrun -n 117  ${workdir}/mitgcmuv${forwadj}
  mpiexec -n ${nprocs} ./mitgcmuv
  date >> run.MITGCM.timing

# tidy up
#---- 12. cleanup -----------------------------
  #du -sh tapes > list_tapes
  #\rm -rf tapes/
  #\rm *.bin *.nc tile* smooth* input* wunit* *.m jra55* list1 list2 *mask* my_* msk*
  #gael_cleanup
  #command_mv_pk
  #tar_command_grid
  #rm_command_grid
  #tar_outputdump
  #rm_outputdump
  #ls -l pickup* > list_pickup
  #tar czvf PICKUP.tgz pickup*
  #\rm pickup*
  #\rm w2_tile_topology.*
  #rm data* eedata
  #tar czvf STDs.tgz STDs; chmod a-wx *.tgz
  #tar czvf NAMELISTS.tgz NAMELISTS
  #tar czvf profiles.tgz profiles/
  #cd $workdir/diags;cp /scratch/atnguyen/aste_90x150x60/tar_diags ./;./tar_diags;chmod a-wx *.tgz;
  #cd $workdir/ADJfiles;cp ~/bin/tar_ADJ1 ./;./tar_ADJ1;chmod a-wx *.tgz;
  #cd $workdir/
  #echo "finished cleaning up $workdir"
