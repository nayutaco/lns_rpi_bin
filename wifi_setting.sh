#!/bin/bash

source /home/pi/Prog/bin/rpi_config.sh

EPAPER=0
if [ $# -eq 0 ]; then
	# ePaper output
	EPAPER=1
else
	EPAPER=0
fi

if [ -f ${APMODE} ]; then
	if [ ${EPAPER} -eq 1 ]; then
		bash ${PROGDIR}/bin/epaper_led.sh APMODE
	fi
	sudo rm -f ${APMODE}_WIFI
	sudo rm -f ${CLIENT}_WIFI
	sudo mv ${APMODE} ${APMODE}_WIFI
	sudo cp -ra ${PROGDIR}/bin/wificonf/ap_mode/* /etc/
	sudo systemctl enable dnsmasq
	sudo systemctl enable hostapd
	sudo systemctl start hostapd
	echo REBOOT
	exit 0
fi

if [ -f ${CLIENT} ]; then
	if [ ${EPAPER} -eq 1 ]; then
		bash ${PROGDIR}/bin/epaper_led.sh CLIENT
	fi
	sudo rm -f ${APMODE}_WIFI
	sudo rm -f ${CLIENT}_WIFI
	sudo mv ${CLIENT} ${CLIENT}_WIFI
	sudo cp -ra ${PROGDIR}/bin/wificonf/client/* /etc/
	sudo systemctl disable dnsmasq
	sudo systemctl disable hostapd
	echo REBOOT
	exit 0
fi

if [ -f ${APMODE}_WIFI ]; then
	sudo iptables-restore < /etc/iptables.ipv4.nat
fi
exit 0
