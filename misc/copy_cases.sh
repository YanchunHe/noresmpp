#!/bin/bash
#set -e

#CASE=NHIST_f19_tn14_20190710
CASE=N1850_f19_tn14_20190621
CASEfrom=/projects/NS9560K/noresm/cases/$CASE
CASEto=/projects/NS2345K/Workshop2021/$USER

cd $CASEfrom
#files=($(find -name '*201[0-4]-*.nc' -print))   #NHIST_f19_tn14_20190710
files=($(find -name '*175[0-4]-*.nc' -print))   #N1850_f19_tn14_20190621
echo ${#files[*]}

mkdir -p $CASEto/$CASE
cd $CASEto/$CASE

for (( i = 0; i < ${#files[*]}; i++ )); do
    fname=${files[i]}
    bname=$(basename $fname)
    dname=$(dirname $fname)
    #echo $fname
    mkdir -p $dname
    cp -u -v $CASEfrom/$fname $fname
done
