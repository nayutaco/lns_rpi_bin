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

gpio write ${LED1} ${LED_ON}
gpio write ${LED2} ${LED_ON}

sleep 3

btn1_on=`gpio read ${BTN1}`
btn2_on=`gpio read ${BTN2}`

if [ -f ${SWUPDATE} ] && [ ${btn1_on} -eq 0 ] && [ ${btn2_on} -eq 0 ]; then
	${EPAPERPY} "" "SW update!" &
	blink 15 0.1

	# /home/pi/ProgUpd.new
	sudo rm -rf ${UPDATEDIR}.new
	tar jxf ${SWUPDATE} -C ${HOMEDIR}

	for dname in bin rpi_epaper rpi_uart rpi_web ptarmigan; do
		if [ ! -f ${UPDATEDIR}.new/${dname} ]; then
			cp -ra ${PROGDIR}/${dname} ${UPDATEDIR}.new/
		fi
	done

	rm ${PROGDIR}
	sudo mv ${UPDATEDIR}.new ${UPDATEDIR}
	ln -s ${UPDATEDIR} ${PROGDIR}
	sudo rm ${SWUPDATE}
	sync

	gpio write ${LED1} ${LED_OFF}
	gpio write ${LED2} ${LED_OFF}
	sudo reboot
fi

blink 3 0.3
