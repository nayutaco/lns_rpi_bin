#!/bin/bash

source /home/pi/Prog/bin/rpi_config.sh

if [ -f ${NOTSTART} ]; then
	exit 0
fi

echo "LnShield button watching..."

gpio mode ${LED1} out
gpio mode ${LED2} out
gpio mode ${BTN1} in
gpio mode ${BTN2} in

count_halt=0
count_apmode=0

while :
do
	btn1_on=`gpio read ${BTN1}`
	btn2_on=`gpio read ${BTN2}`
	if [ ${btn1_on} -eq 0 ]; then
		#echo "BUTTON1 DOWN: " ${count_halt}
		count_halt=$((count_halt+1))
	fi
	if [ ${btn2_on} -eq 0 ]; then
		#echo "BUTTON2 DOWN: " ${count_apmode}
		count_apmode=$((count_apmode+1))
	fi
	if [ ${btn1_on} -ne 0 ] && [ ${btn2_on} -ne 0 ]; then
		#echo "CLEAR"
		count_halt=0
		count_apmode=0
	fi
	if [ ${count_halt} -eq 5 ]; then
		if [ ${count_apmode} -eq 5 ]; then
			# emergency reboot
			bash ${PROGDIR}/bin/epaper_led.sh REBOOT
			rm -f ${PTARMDIR}/testnet/wallettest/ptarm_p2wpkh.spvchain
			rm -f ${PTARMDIR}/mainnet/walletmain/ptarm_p2wpkh.spvchain
			sync; sync; sync
			sudo reboot
		else
			#shutdown
			bash ${PROGDIR}/bin/epaper_led.sh SHUTDOWN
			sudo halt
		fi
	fi
	if [ ${count_apmode} -eq 5 ]; then
		if [ -f ${APMODE}_WIFI ]; then
			bash ${PROGDIR}/bin/epaper_led.sh CLIENT
			sudo touch ${CLIENT}
		else
			bash ${PROGDIR}/bin/epaper_led.sh APMODE
			sudo touch ${APMODE}
		fi
		bash /home/pi/Prog/bin/wifi_setting.sh 1
		sudo reboot
	fi
	sleep 1
done

echo "exit"
