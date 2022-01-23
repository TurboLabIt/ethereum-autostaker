#!/bin/bash
echo ""

## Script name
SCRIPT_NAME="ip_watch"

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}ethereum-autostaker/

## Lib directory (will store the last IP)
LIB_DIR="/var/lib/turbolab.it/"
IP_FILE=${LIB_DIR}ip_address

CRON_FILE=/etc/cron.d/ethereum-autostaker-${SCRIPT_NAME}

## Title
WEBSTACKUP_FRAME="O===========================================================O"
echo "$WEBSTACKUP_FRAME"
echo " --> ip_watch - $(date) on $(hostname)"
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
echo "Last know IP address"
echo "--------------------"
if [ ! -f "${IP_FILE}" ]; then

    LAST_KNOWN_IP=none

else

    LAST_KNOWN_IP=$(<${IP_FILE})
fi

echo ${LAST_KNOWN_IP}


echo ""
echo "Current IP address"
echo "------------------"
CURRENT_IP=$(curl -s v4.ident.me)
echo $CURRENT_IP
echo $CURRENT_IP >${IP_FILE}


echo ""
if [ "$LAST_KNOWN_IP" == "$CURRENT_IP" ]; then

    echo "The assigned IP address is still the same. Sleeping..."
    
elif [ -z "$CURRENT_IP" ]; then

    echo "The current assigned IP is undefined. Sleeping..."

else

    echo "The assigned IP address HAS CHANGED!"
    
    if [ -f /etc/systemd/system/nimbus.service ]; then
        
        echo "Restarting Nimbus..."
        service nimbus restart
        
    else
    
        echo "Nimbus not installed, skipping"
    fi
    

    if [ -f /etc/systemd/system/besu.service ]; then
        
        echo "Restarting Besu..."
        service besu restart
        
    else
    
        echo "Besu not installed, skipping"
    fi
fi


echo ""
echo "The End"
echo "-------"
echo $(date)
echo "$WEBSTACKUP_FRAME"
