#!/bin/bash
export HOMEDIR=/home/pi
export PROGDIR=${HOMEDIR}/Prog
export PROGORGDIR=${HOMEDIR}/ProgOrg
export UPDATEDIR=${HOMEDIR}/ProgUpd
export COPYNODEDIR=${HOMEDIR}/NodeData

export PTARMDIR=${PROGDIR}/ptarmigan/install
export NODEDIR=${PTARMDIR}/node
export EPAPERDIR=${PROGDIR}/rpi_epaper
export UARTDIR=${PROGDIR}/rpi_uart
export WEBDIR=${PROGDIR}/rpi_web

export EPAPERPY="/usr/bin/python3 ${EPAPERDIR}/epaper.py"
export SPV_STARTUPPY="/usr/bin/python3 ${EPAPERDIR}/spv_startup.py"
export UARTPY="/usr/bin/python3 ${UARTDIR}/rpi_uart.py"
export WEBPY="sudo /usr/bin/python3 ${WEBDIR}/rpi_web.py"

export NOTSTART=/boot/RPI_NOTSTART
export FIRSTBOOT=/boot/RPI_FIRSTBOOT
export APMODE=/boot/RPI_APMODE
export CLIENT=/boot/RPI_CLIENT
export USEWEB=/boot/RPI_USEWEB
export MAINNET=/boot/RPI_MAINNET
export SWUPDATE=/boot/RPI_SWUPDATE
export UPDATED=${HOMEDIR}/rpi_updated

export LED1=3
export LED2=2
export LED_ON=0
export LED_OFF=1
export BTN1=21
export BTN2=22
