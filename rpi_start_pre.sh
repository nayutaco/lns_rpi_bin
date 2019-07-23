#!/bin/bash

set -eu

source /home/pi/Prog/bin/rpi_config.sh

if [ -f ${NOTSTART} ]; then
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
	sleep 3
	sudo reboot
}
#############################

stage_log "STAGE0"

gpio write ${LED1} ${LED_ON}
gpio write ${LED2} ${LED_ON}

if [ -f ${FIRSTBOOT} ]; then
	# expand SD card patition
	${EPAPERPY} "" "First Boot"&
	sudo rm ${FIRSTBOOT}
	sudo raspi-config nonint do_expand_rootfs
	sleep 5
	do_reboot "*First Boot"
fi

stage_log_add "STAGE1"

rm -f ${PROGDIR}/ipaddr.txt

stage_log_add "STAGE2"

#wifi
RET=`bash ${PROGDIR}/bin/wifi_setting.sh`
if [ "${RET}" = "REBOOT" ]; then
	do_reboot "*WIFI Setting"
fi

stage_log_add "STAGE3"

#web
if [ -f ${USEWEB} ]; then
	stage_log_add "STAGE4"
	nohup ${WEBPY} > /dev/null&
fi

stage_log_add "STAGE5"

#clear
TITLE_WAKEUP=""
if [ -f ${APMODE}_WIFI ]; then
	TITLE_WAKEUP="AP mode.."
else
	TITLE_WAKEUP=""
fi

${EPAPERPY} "" "${TITLE_WAKEUP}"

stage_log_add "STAGE6"

# IP address

count=0
while :
do
	stage_log_add "STAGE7:${count}"
	ipaddr=`ip -4 address show wlan0`
	if [ -n "${ipaddr}" ]; then
		ipaddr=`echo ${ipaddr} | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
	fi
	echo addr=${ipaddr}
	if [ -n "${ipaddr}" ]; then
		stage_log_add "STAGE7-x"
		qrencode -s 3 -o ${PROGDIR}/website.png http://${ipaddr}
		${EPAPERPY} ${PROGDIR}/website.png ${ipaddr}&
		break
	fi
	sleep 1
	count=$((count+1))
	if [ $count -gt 10 ]; then
		# timeout
		stage_log_add "*IPaddr exit"
		${EPAPERPY} "" "no IP addr"&
		exit 0
	fi
done

stage_log_add "STAGE8"

echo ${ipaddr} > ${PROGDIR}/ipaddr.txt
echo "done: IP addr"
gpio write ${LED1} ${LED_OFF}

stage_log_add "STAGE9"

if [ -f ${APMODE}_WIFI ]; then
	stage_log_add "*APmode"
	sleep 600
	sudo reboot
fi

stage_log_add "STAGE10"
echo 0 > ${PROGDIR}/start_count.txt

# copy ptarmigan script(update)
cp ${PROGDIR}/bin/ptarmd_script/* ${PTARMDIR}/script/
cp ${PROGDIR}/bin/ptarmd_script/* ${PTARMDIR}/testnet/script/
cp ${PROGDIR}/bin/ptarmd_script/* ${PTARMDIR}/mainnet/script/

gpio write ${LED1} ${LED_OFF}
gpio write ${LED2} ${LED_OFF}
