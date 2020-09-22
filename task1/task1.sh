#!/bin/bash
set -ex
# NorESM User Workshop 2019
# yanchun.he@nersc.no

# Interpolate vertical hybrid pressure-sigma layers of CAM output ...
# to pressure levels

DIRROOT=/projects/NS2345K/workshop
CASENAME=N1850_f19_tn14_20190621
filename=${DIRROOT}/cases/${CASENAME}/atm/hist/N1850_f19_tn14_20190621.cam.h0.1750-01.nc
VAR=T

# Change to working directory
mkdir -p ~/workshop/task4.1
cd ~/workshop/task4.1

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
# View result
ncview var_ml2pl_zm.nc &

