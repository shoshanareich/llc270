#!/bin/bash
#PBS -q normal
#PBS -N mitgcm
#PBS -l select=16:ncpus=24:model=has
#PBS -l walltime=01:00:00
#PBS -o llc270.out
#PBS -e llc270.err
#PBS -M sreich@utexas.edu
#PBS -m bae



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
niter="0000841536"

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

workdir=$scratchdir/run${whichcode}_pk${niter}_obsfit_2

mkdir $workdir
cd $workdir


#--- 3. link forcing -------------
ln -sf /nobackup/hzhang1/forcing/era5 .

#--- 4. linking binary ---------

ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/runoff1p2472-360x180x12.bin .
#ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/* .
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/bathy270_filled_noCaspian_r4 .
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/tile* .
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/Eta.${niter}.data ./Eta.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/Salt.${niter}.data ./Salt.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/Theta.${niter}.data ./Theta.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/U.${niter}.data ./U.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/V.${niter}.data ./V.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIarea.${niter}.data ./SIarea.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIheff.${niter}.data ./SIheff.data
#ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIhsalt.${niter}.data ./SIhsalt.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIhsnow.${niter}.data ./SIhsnow.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIuice.${niter}.data ./SIuice.data
ln -sf /nobackup/sreich/llc270_c68w_runs/run_template/SIvice.${niter}.data ./SIvice.data
ln -sf /nobackup/sreich/swot/swot_obsfit_L3/swot_cycles_009_llc270_45_test_obsfit.nc .

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
# pickupdir=/nobackup/sreich/llc270_c68w_runs/run_pk0000019440_450s_nouv/
# cp -f ${pickupdir}/pickup.${niter}.data ./pickup.0000021744.data
# cp -f ${pickupdir}/pickup.${niter}.meta ./pickup.0000021744.meta
# cp -f ${pickupdir}/pickup_seaice.${niter}.data ./pickup_seaice.0000021744.data
# cp -f ${pickupdir}/pickup_seaice.${niter}.meta ./pickup_seaice.0000021744.meta

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
