#!/bin/bash
#set -x

# Script to use NCO and CDO utilities to interpolate
# hybrid pressure-sigma layers of CAM output to
# pressure levels

# NorESM User Workshop 2020
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

VAR=T
casename=NHIST_f19_tn14_20190710
archivedir=/cluster/work/users/yanchun/archive
dataname=${casename}.cam.h0.2010-01.nc

datafile=${archivedir}/${casename}/atm/hist/${dataname}

# Extract variable
ncks -O -v ${VAR},ilev $filename var_tmp.nc
# Add layer interface 'ilev' as bounds of vertical coordinate 'lev'
ncatted -a bounds,lev,c,c,"ilev" var_tmp.nc
# Interpolate from hybrid sigma-pressure to pressure levels
cdo -s ml2pl,3000.,5000.,7000.,10000.,15000.,20000.,25000.,30000.,35000.,40000.,45000.,50000.,55000.,60000.,65000.,70000.,75000.,80000.,85000.,87500.,90000.,92500.,95000.,97500.,100000.\
    var_tmp.nc var_ml2pl.nc
# Convert Pa to hPA
ncap2 -O -s 'plev=plev/100' var_ml2pl.nc var_ml2pl.nc
# Change the "units" from Pa to hPa
ncatted -a units,plev,m,c,"hPa" var_ml2pl.nc
# Make zonal mean
cdo -s zonmean var_ml2pl.nc var_ml2pl_zm.nc
# Clean temp file
rm -f var_tmp.nc
# View result
ncview var_ml2pl_zm.nc &

