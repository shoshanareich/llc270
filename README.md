Using bathymetry and IC's for Jan. 1, 2012 from run here: /nobackup/dcarrol2/v05_latest/darwin3/run/pickup*.0000525960.data /nobackup/dcarrol2/v05_latest/darwin3/run/bathy270_filled_noCaspian_r4

See simulation documentation here: https://github.com/MITgcm-contrib/ecco_darwin/tree/master/v05/llc270

Use 45x45x362 tile size from here: https://github.com/MITgcm-contrib/ecco_darwin/blob/master/v05/llc270/code/SIZE.h_45x45x362 https://github.com/MITgcm-contrib/ecco_darwin/blob/master/v05/llc270/input/data.exch2_362

mkdir build cd build cp ../code/SIZE.h_snxxsnyxnprocs SIZE.h ../../MITgcm/tools/genmake2 -of=/home3/sreich/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas -mpi -mods=../code -rd=../../MITgcm make depend make -j 4 mv mitgcmuv mitgcmuv_snxxsnyxnprocs
