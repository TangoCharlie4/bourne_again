#!/bin/bash

# --------------------------------------------------------------------------------------------------
#
# Description	:	The script will configure Mail App specific user accounts on a Solaris 5.10 & 5.11 host.
#
# To execute 	:	./Configure_User_Accounts_ProdMail.sh  [ Example ]
#
# Author	:	Bhavuk Taneja   c1259257
#
# Date		:	18th Nov 2015
#
# History	:	18th Nov 2015	BT  Created
#
# --------------------------------------------------------------------------------------------------

##  Functions Declaration  ##
lsscsi_file=$1
SOS_DIR=$2
ABS_PATH="`pwd`/${SOS_DIR}"

grep -vw '-' ${lsscsi_file} | awk '{print $NF}' | sort | uniq -c | sort > sorted_lsscsi


if [ $# -eq 1 ] ; then

grep -vw '-' ${lsscsi_file} | awk '{print $NF}' | sort | uniq -c | sort

elif [ -f $2 ] ; then

second_file=$2

grep -vw '-' ${lsscsi_file} | awk '{print $NF}' | sort | uniq -c > sorted_file1
grep -vw '-' ${second_file} | awk '{print $NF}' | sort | uniq -c > sorted_file2

for lunid in `grep -vw '-' ${lsscsi_file} | awk '{print $NF}' | sort -u`
do

echo "`grep $lunid sorted_file1` : `grep $lunid sorted_file2`"
echo "`grep 360060e801013a4a0058b3a1a00000010 sorted_file1` : `grep 360060e801013a4a0058b3a1a00000010 sorted_file2`"

done

elif [ -f ${SOS_DIR}/etc/multipath/bindings ] ; then

cat sorted_lsscsi | while read line
do
cd ${ABS_PATH}

LVS=sos_commands/lvm2/lvs_-a_-o_lv_tags_devices_lv_kernel_read_ahead_lv_read_ahead_stripes_stripesize_--config_global_locking_type_0_metadata_read_only_1

lun=`echo $line | awk '{print $NF}'`
mpath=`grep $lun etc/multipath/bindings | awk '{print $1}'`
VG=$(grep  "/dev/mapper/${mpath}(" $LVS | awk '{print $2}' | sort -u)
printf "$line : $mpath : $VG \n"
done

else

printf "Note: etc/multipath/bindings does not exist.\n
analysis will be limited to number of paths available per LUN\n"

grep -vw '-' ${lsscsi_file} | awk '{print $NF}' | sort | uniq -c | sort

fi

