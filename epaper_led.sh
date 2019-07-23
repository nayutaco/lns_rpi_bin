#!/bin/bash

source /home/pi/Prog/bin/rpi_config.sh

blink() {
	for i in `seq 1 $1`; do
		gpio write ${LED1} ${LED_ON}
		gpio write ${LED2} ${LED_OFF}
		sleep $2
		gpio write ${LED1} ${LED_OFF}
		gpio write ${LED2} ${LED_ON}
		sleep $2
	done
	gpio write ${LED1} ${LED_ON}
	gpio write ${LED2} ${LED_ON}
}

if [ $# -eq 1 ]; then
	if [ "$1" == "SHUTDOWN" ]; then
		${EPAPERPY}&
		NUM=10
		TIME=0.3
	elif [ "$1" == "REBOOT" ]; then
		${EPAPERPY} "" "Reboot"&
		NUM=10
		TIME=0.3
	elif [ "$1" == "APMODE" ]; then
		${EPAPERPY} "" "reboot AP"&
		NUM=30
		TIME=0.1
	elif [ "$1" == "CLIENT" ]; then
		${EPAPERPY} "" "reboot CLI"&
		NUM=15
		TIME=0.2
	else
		NUM=0
		TIME=0
	fi
	sudo systemctl stop rpi_ptarm
	blink ${NUM} ${TIME}
fi
