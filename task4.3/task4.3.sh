#!/bin/bash
set -e

# NorESM workshop 2019
# yanchun.he@nersc.no

datain=/projects/NS9560K/noresm/cases/NHIST_f19_tn14_20190710/ocn/hist
workingdir=/tos-project1/NS2345K/workshop/regrid

mkdir -p $workingdir
cd $workingdir
mkdir -p ../data

#Generate 2010-2014 model mean
for mon in 01 02 03 04 05 06 07 08 09 10 11 12
    do
    ncra -O -v sst ${datain}/NHIST_f19_tn14_20190710.micom.hm.201[0-4]-${mon}.nc -o ../data/micom_sst_2010-2014_${mon}.nc
    monfiles+=(../data/micom_sst_2010-2014_${mon}.nc)
done


# Regrid data
echo " Interpolate from model curvlinear (tnx1v4) grid to global 1-deg grid"
ncra -O -w 31,28,31,30,31,30,31,31,30,31,30,31 ${monfiles[*]} micom_sst_2010-2014_ann.nc
ncks -A -v plat,plon ../grid/grid_tnx1v4.nc micom_sst_2010-2014_ann.nc
cdo -O remapbil,global_1 micom_sst_2010-2014_ann.nc micom_sst_2010-2014_ann_1x1d.nc

# Make 2010-2014 mean of HadISST
echo " Select 2010-2014 data of HadISSt and generate mean"
cdo -O timselmean,5 -yearmean -selyear,2010,2011,2012,2013,2014 ../data/HadISST_sst.nc HadISST_sst_2010-2014mean.nc
ncrename -d latitude,lat -d longitude,lon HadISST_sst_2010-2014mean.nc
ncrename -v latitude,lat -v longitude,lon HadISST_sst_2010-2014mean.nc
ncpdq -O --arrange=-lat HadISST_sst_2010-2014mean.nc HadISST_sst_2010-2014mean.nc

# Make difference between model and observation
ncdiff -O micom_sst_2010-2014_ann_1x1d.nc HadISST_sst_2010-2014mean.nc sst_diff.nc

# View result
ncview sst_diff.nc &>/dev/null &
