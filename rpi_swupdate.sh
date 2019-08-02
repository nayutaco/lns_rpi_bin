#!/bin/bash

set -eu

source /home/pi/Prog/bin/rpi_config.sh

blink() {
	for i in `seq 1 $1`; do
		gpio write ${LED1} ${LED_ON}
		gpio write ${LED2} ${LED_ON}
		sleep $2
		gpio write ${LED1} ${LED_OFF}
		gpio write ${LED2} ${LED_OFF}
		sleep $2
	done
	gpio write ${LED1} ${LED_ON}
	gpio write ${LED2} ${LED_ON}
}

if [ -f ${NOTSTART} ]; then
	exit 0
fi

gpio mode ${LED1} out
gpio mode ${LED2} out
gpio mode ${BTN1} in
gpio mode ${BTN2} in

btn1_on=`gpio read ${BTN1}`
btn2_on=`gpio read ${BTN2}`

if [ -f ${SWUPDATE} ] && [ ${btn1_on} -eq 0 ] && [ ${btn2_on} -eq 0 ]; then
	${EPAPERPY} "" "SW update!" &
	blink 20 0.1

	sudo rm -rf ${UPDATEDIR}.bak
	mv ${UPDATEDIR} ${UPDATEDIR}.bak && :
	tar jxf ${SWUPDATE} -C ${HOMEDIR}

	rm ${PROGDIR}
	ln -s ${UPDATEDIR} ${PROGDIR}
	sudo rm -rf ${UPDATEDIR}.bak
	sudo rm ${SWUPDATE}
	sync

	gpio write ${LED1} ${LED_OFF}
	gpio write ${LED2} ${LED_OFF}
	sudo reboot
fi
gpio write ${LED1} ${LED_ON}
gpio write ${LED2} ${LED_ON}
