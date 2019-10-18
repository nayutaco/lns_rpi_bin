#!/bin/bash

set -u

source /home/pi/Prog/bin/rpi_config.sh

if [ -f ${NOTSTART} ]; then
	exit 0
fi

if [ ! -f ${PROGDIR}/ipaddr.txt ]; then
	do_reboot "no ipaddr.txt"
	exit 0
fi

mkdir -p ${PROGDIR}/logs

#############################
stage_log() {
	echo $1
	echo "`date -u +"%Y-%m-%dT%H:%M:%S.%N"` $1" > ${PROGDIR}/logs/stage.log
	sudo cp ${PROGDIR}/logs/stage.log /boot/RPI_STAGE.LOG
}

stage_log_add() {
	echo $1
	echo "`date -u +"%Y-%m-%dT%H:%M:%S.%N"` $1" >> ${PROGDIR}/logs/stage.log
	sudo cp ${PROGDIR}/logs/stage.log /boot/RPI_STAGE.LOG
}

do_reboot() {
	stage_log_add $1
	bash ${PROGDIR}/epaper_led.sh REBOOT
	sudo reboot
}
#############################

START_COUNT=`cat ${PROGDIR}/start_count.txt`
START_COUNT=$((START_COUNT+1))
echo ${START_COUNT} > ${PROGDIR}/start_count.txt

if [ ${START_COUNT} -gt 3 ]; then
	#too many restart ==> reboot
	${EPAPERPY} "" "Many Restart"
	do_reboot "*exit"
	exit 0
fi

ipaddr=$(<${PROGDIR}/ipaddr.txt)

export JDK_HOME=/usr/lib/jvm/java-8-openjdk-armhf
export JDK_CPU=arm/client
export LD_LIBRARY_PATH=${JDK_HOME}/jre/lib/${JDK_CPU}

# start ptarmd
if [ -f ${MAINNET} ]; then
	CHAIN=mainnet
else
	CHAIN=testnet
fi
rm -f ${NODEDIR}
ln -s ${COPYNODEDIR}/${CHAIN} ${NODEDIR}
rm -f ${NODEDIR}/logs/bitcoinj_startup.log
stage_log_add "chain=${CHAIN}"

${SPV_STARTUPPY}&

PTARMD_LOOP=1
PTARMD_REBOOT=180
while [ ${PTARMD_LOOP} -gt 0 ]
do
	${PTARMDIR}/ptarmd -d ${NODEDIR} --network=${CHAIN} | cronolog -p 1hours ${PROGDIR}/logs/ptarm%H_${CHAIN}.log&

	stage_log_add "STAGE11"

	echo "done: ptarmd start"
	sleep 10

	count=0
	bitcoinj_startup=""
	while :
	do
		sleep 1

		# check ptarmd port
		stage_log_add "STAGE11-a"
		port_ln=`netstat -na | grep "9735" | wc -l`
		port_rpc=`netstat -na | grep "9736" | wc -l`
		if [ ${port_ln} -gt 0 ] && [ ${port_rpc} -gt 0 ]; then
			# detect start ptarmd
			stage_log_add "STAGE11-x1"
			PTARMD_LOOP=0
			break
		fi
		
		#  check bitcoinj startup log updating
		bitcoinj_startup_now=""
		if [ -f ${NODEDIR}/logs/bitcoinj_startup.log ]; then
			bitcoinj_startup_now=`cat ${NODEDIR}/logs/bitcoinj_startup.log`
			echo bitcoinj_startup_now=${bitcoinj_startup_now}
		fi
		if [ "${bitcoinj_startup}" = "${bitcoinj_startup_now}" ]; then
			echo "same"
			count=$((count+1))
		else
			bitcoinj_startup=${bitcoinj_startup_now}
			echo "update"
			count=0
		fi
		if [ $count -gt $PTARMD_REBOOT ]; then
			# maybe bitcoinj not working --> ptarmd restart
			stage_log_add "STAGE11-x2"
			killall ptarmd
			sleep 5
			break
		fi

		stage_log_add "STAGE11-b"

		# check ptarmd process
		PTARMD_PROC=`ps aux | grep ptarmd | grep -c network`
		if [ ${PTARMD_PROC} -eq 0 ]; then
			# no ptarmd process
			PTARMD_LOOP=$((PTARMD_LOOP+1))
			if [ ${PTARMD_LOOP} -gt 3 ]; then
				echo "STOP=** FAIL **" > ${NODEDIR}/logs/bitcoinj_startup.log
				sleep 10
				PTARMD_LOOP=-1
			else
				echo "CONT=*restart*" > ${NODEDIR}/logs/bitcoinj_startup.log
			fi
			stage_log_add "STAGE11-x3"
			break
		fi
	done
done

if [ ${PTARMD_LOOP} -eq 0 ]; then
	stage_log_add "STAGE12"
else
	stage_log_add "MANY REBOOT"
	exit 0
fi

sudo rm -f ${PROGDIR}/invoice.png ${PROGDIR}/invoice.txt
${UARTPY}&

echo "done: uart"

node_id=`${PTARMDIR}/ptarmcli -l | jq -r -e '.["result"]["node_id"]'`
if [ -z "$node_id" ]; then
	echo "fail: get node_id"
	do_reboot "*fail node_id"
fi

stage_log_add "STAGE13"

${EPAPERPY} ${PROGDIR}/website.png "${CHAIN}"&

stage_log_add "STAGE14"

echo "done: get node_id"

while :
do
	port_ln=`netstat -na | grep "9735" | wc -l`
	port_rpc=`netstat -na | grep "9736" | wc -l`
	if [ ${port_ln} -eq 0 ] || [ ${port_rpc} -eq 0 ]; then
		stage_log_add "ptarmd stopped"
		break
	fi
	sleep 5
done

stage_log_add "*RESTART"
exit 1
