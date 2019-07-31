#!/bin/bash

set -eu

source /home/pi/Prog/bin/rpi_config.sh

if [ -f ${NOTSTART} ]; then
	exit 0
fi

mkdir -p ${COPYNODEDIR}

if [ -f ${RPI_SWUPDATE} ]; then
	stage_log_add "UPDATE"

	if [ -L ${PROGDIR} ]; then
		rm ${PROGDIR}
	else
		# first update
		mv ${PROGDIR} ${PROGORGDIR}
	fi

	mkdir -p ${UPDATEDIR}
	tar jxf ${RPI_SWUPDATE} -C ${UPDATEDIR}
	ln -s ${UPDATEDIR} ${PROGDIR}
	sleep 5
	do_reboot "*Update"
fi
