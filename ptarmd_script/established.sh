#!/bin/bash
set -eu

source /home/pi/Prog/bin/rpi_config.sh

#   method: established
#   $1: short_channel_id
#   $2: node_id
#   $3: local_msat
#   $4: funding_txid
DATE=`date -u +"%Y-%m-%dT%H:%M:%S.%N"`
cat << EOS | jq .
{ "method":"established", "short_channel_id":"$1", "node_id":"$2", "date":"$DATE", "local_msat":$3, "funding_txid":"$4" }
EOS

## local_msat
echo $3 > ${NODEDIR}/local_msat.txt
