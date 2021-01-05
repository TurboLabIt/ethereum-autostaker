#!/bin/bash
echo ""

## Script name
SCRIPT_NAME="traffic-control"

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}ethereum-autostaker/

## Lib directory (will store the network interface)
LIB_DIR="/var/lib/turbolab.it/"

CRON_FILE=/etc/cron.d/ethereum-autostaker-${SCRIPT_NAME}

## Title
WEBSTACKUP_FRAME="O===========================================================O"
echo "$WEBSTACKUP_FRAME"
echo " --> ${SCRIPT_NAME} - $(date) on $(hostname)"
echo "$WEBSTACKUP_FRAME"


echo ""
echo "Lib directory"
echo "-------------"
if [ ! -d "${LIB_DIR}" ]; then

    echo "Creating lib directory..."
    mkdir -p "${LIB_DIR}"

else

    echo "Lib directory exists"
fi


echo ""
echo "Cron file"
echo "---------"
if [ ! -f "$CRON_FILE" ]; then

    echo "Creating cron file..."
    cp "${INSTALL_DIR}config/cron/${SCRIPT_NAME}" "$CRON_FILE"

else

    echo "Cron file exists"
fi


echo ""
echo "Detect the network interface"
echo "----------------------------"
#https://unix.stackexchange.com/a/165067/104537
host=google.com
host_ip=$(getent ahosts "$host" | awk '{print $1; exit}')
USR_IF=$(ip route get "$host_ip" | grep -Po '(?<=(dev )).*(?= src| proto)')
echo ${USR_IF}


echo ""
echo "tcing..."
echo "--------"
tc qdisc del root dev ${USR_IF} 
tc qdisc add dev ${USR_IF} root tbf rate 1mbit burst 10kb latency 70ms peakrate 1.5mbit minburst 1540
tc -s qdisc ls dev ${USR_IF}


echo ""
echo "The End"
echo "-------"
echo $(date)
echo "$WEBSTACKUP_FRAME"
