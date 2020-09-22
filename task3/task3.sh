#!/bin/bash

# Script to use NCO and CDO utilities to 
# rotate vectors from model i,j directions to
# zonal and meridional directions

# NorESM User Workshop 2020
# yanchun.he@nersc.no

which ncks &>/dev/null
if [ $? -ne 0 ];then
    module -q load NCO/4.7.2-intel-2018a
fi
which ncview &>/dev/null
if [ $? -ne 0 ];then
    module load ncview/2.1.7-intel-2018a
fi

casename=NHIST_f19_tn14_20190710
archivedir=/cluster/work/users/yanchun/archive
dataname=${casename}.micom.hm.2010-01.nc
gridname=grid_tnx1v4.nc

datafile=${archivedir}/${casename}/ocn/hist/${dataname}
ln -s ${archivedir}/grid/${gridname} ../grid/$gridname
gridfile=../grid/$gridname

# Extract ubaro,vbaro
ncks -O -v ubaro,vbaro $datafile uv.nc
# Add vector angle to micom variable file
ncks -A -v angle ${gridfile} uv.nc
# Generate roated new verctors
ncap2 -O -s "urot=ubaro*cos(angle)-vbaro*sin(angle);vrot=ubaro*sin(angle)+vbaro*cos(angle)" \
            uv.nc uvrot.nc
# View the data
ncview uvrot.nc

