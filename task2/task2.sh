#!/bin/bash

# Script to use NCO and CDO utilities to 
# rotate vectors from model i,j directions to
# zonal and meridional directions

# NorESM workshop 2020
# yanchun.he@nersc.no

which ncks &>/dev/null
if [ $? -ne 0 ];then
    module -q load NCO/4.7.2-intel-2018a
fi
which cdo &>/dev/null
if [ $? -ne 0 ];then
    module -q load CDO/1.9.3-intel-2018a
fi
which ncview &>/dev/null
if [ $? -ne 0 ];then
    module load ncview/2.1.7-intel-2018a
fi

var=sst
casename=NHIST_f19_tn14_20190710
archivedir=/cluster/work/users/yanchun/archive

ln -sf ${archivedir}/HadISST/HadISST_sst.nc ../data/HadISST_sst.nc

#Generate 2010-2014 model mean
for mon in 01 02 03 04 05 06 07 08 09 10 11 12; do
    if [ ! -f ../data/${casename}_sst_${mon}.nc ]; then
        ncra -O -v $var ${archivedir}/${casename}/ocn/hist/${casename}.micom.hm.201[0-4]-${mon}.nc -o ../data/${casename}_sst_${mon}.nc
    fi
    monfiles+=(../data/${casename}_sst_${mon}.nc)
done


# Regrid data
echo " Interpolate from model curvlinear (tnx1v4) grid to global 1-deg grid"
ncra -O -w 31,28,31,30,31,30,31,31,30,31,30,31 ${monfiles[*]} ${casename}_sst_ann.nc
ncks -A -v plat,plon ../grid/grid_tnx1v4.nc ${casename}_sst_ann.nc
cdo -O remapbil,global_1 ${casename}_sst_ann.nc ${casename}_sst_ann_1x1d.nc

# Make 2010-2014 mean of HadISST
echo " Select 2010-2014 data of HadISSt and generate mean"
cdo -O timselmean,5 -yearmean -selyear,2010,2011,2012,2013,2014 -setctomiss,-1000 -selname,sst ../data/HadISST_sst.nc HadISST_sst_mean.nc
ncrename -d latitude,lat -d longitude,lon HadISST_sst_mean.nc
ncrename -v latitude,lat -v longitude,lon HadISST_sst_mean.nc
ncpdq -O --arrange=-lat HadISST_sst_mean.nc HadISST_sst_mean.nc

# Make difference between model and observation
ncdiff -O ${casename}_sst_ann_1x1d.nc HadISST_sst_mean.nc sst_diff.nc

# View result
ncview sst_diff.nc &>/dev/null &
