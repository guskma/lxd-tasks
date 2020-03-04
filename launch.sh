#!/bin/bash

LOGFILE="lxd-tasks.log"
LXDBASEDIR="/tmp"

SCRIPTBASEDIR=$(cd $(dirname $0); pwd)
TASK=$1

if [[ $TASK == "" ]];
then
	echo "usage: ./launch.sh TASK"
	exit 1
fi

script=${SCRIPTBASEDIR}/scripts/${TASK}.sh
tmpscript="${LXDBASEDIR}/lxdmainte-${TASK}-`date +%Y%m%d%H%M%S`.sh"

if [[ ! -f $script ]];
then
	echo "Not found: $script"
	exit 1
fi

echo "***** [`date`]: EXEC: $TASK *****" | tee -a $LOGFILE

containers=`lxc list -c ns --format csv | grep RUNNING | cut -d, -f1`

for nm in $containers
do
	echo "### $nm"
	echo -n "  $nm ... " | tee -a $LOGFILE
	lxc file push $script $nm$tmpscript
	lxc exec $nm -- /bin/bash $tmpscript
	( [[ $? == 0 ]] && echo "OK" || echo "NG" ) | tee -a $LOGFILE
	lxc file delete $nm$tmpscript
done
