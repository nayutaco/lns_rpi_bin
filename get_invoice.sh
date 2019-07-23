#!/bin/bash
set -eu

echo Generate invoice

source /home/pi/Prog/bin/rpi_config.sh

gpio write ${LED1} ${LED_ON}

exec 9< $0
flock -n 9 || exit 1

DESC=`echo $2 | sed 's/"//g'`
${PTARMDIR}/ptarmcli -i $1 --description="${DESC}" --no-rfield | jq -r '.result.bolt11' | tr -d '\n' > ${PROGDIR}/invoice.txt
qrencode -s 2 -o ${PROGDIR}/invoice.png `cat ${PROGDIR}/invoice.txt`
python3 ${EPAPERDIR}/epaper.py ${PROGDIR}/invoice.png

gpio write ${LED1} ${LED_OFF}

