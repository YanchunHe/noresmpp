#!/bin/bash
set -ex
# NorESM User Workshop 2019
# yanchun.he@nersc.no

DIRROOT=/projects/NS2345K/workshop
CASENAME=N1850_f19_tn14_20190621
filename=${DIRROOT}/cases/${CASENAME}/ocn/hist/N1850_f19_tn14_20190621.micom.hm.1750-01.nc
VAR=T

# Change to working directory
mkdir -p ~/workshop/task4.2
cd ~/workshop/task4.2
mkdir -p ~/workshop/grid
ln -sf $DIRROOT/grid/grid_tnx1v4.nc ../grid/grid_tnx1v4.nc

# Extract ubaro,vbaro
ncks -O -v ubaro,vbaro $filename uv.nc
# Add vector angle to micom variable file
ncks -A -v angle ${DIRROOT}/grid/grid_tnx1v4.nc uv.nc
# Generate roated new verctors
ncap2 -O -s "urot=ubaro*cos(angle)-vbaro*sin(angle);vrot=ubaro*sin(angle)+vbaro*cos(angle)" \
            uv.nc uvrot.nc
# View the data
ncview uvrot.nc

