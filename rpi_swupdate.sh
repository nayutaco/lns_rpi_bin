#!/bin/bash

set -eu

source /home/pi/Prog/bin/rpi_config.sh

if [ -f ${NOTSTART} ]; then
	exit 0
fi

gpio mode ${LED1} out
gpio mode ${LED2} out
gpio mode ${BTN1} in
gpio mode ${BTN2} in

btn1_on=`gpio read ${BTN1}`
btn2_on=`gpio read ${BTN2}`

if [ -f ${RPI_SWUPDATE} ] && [ ${btn1_on} -eq 0 ] && [ ${btn2_on} -eq 0 ]; then
	stage_log_add "UPDATE"


	tar jxf ${RPI_SWUPDATE} -C ${HOMEDIR}

	rm ${PROGDIR}
	ln -s ${UPDATEDIR} ${PROGDIR}

	sleep 5
	do_reboot "*Update"
fi
