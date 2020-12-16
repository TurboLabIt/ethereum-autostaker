#!/usr/bin/env bash
echo ""

cat << "EOF"
  _____           _           _          _      _ _   
 |_   _|   _ _ __| |__   ___ | |    __ _| |__  (_) |_ 
   | || | | | '__| '_ \ / _ \| |   / _` | '_ \ | | __|
   | || |_| | |  | |_) | (_) | |__| (_| | |_) || | |_ 
   |_| \__,_|_|  |_.__/ \___/|_____\__,_|_.__(_)_|\__|
EOF
echo
echo "-> Install Ethereum staking packages automatically https://turbolab.it/3066"


## Features
SELF_UPDATE=1
INSTALL_ZZUPDATE=1
INSTALL_GETH=1
INSTALL_ETH2_DEPOSIT_CLI=1
INSTALL_NIMBUS=1
ENABLE_FIREWALL=1


## Script name
SCRIPT_NAME=ethereum-autostaker

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/


## Title printing function
function printTitle
{
    echo ""
    echo "$1"
    printf '%0.s-' $(seq 1 ${#1})
    echo ""
}


## root check
if ! [ $(id -u) = 0 ]; then

    echo ""
    echo "vvvvvvvvvvvvvvvvvvvv"
    echo "Catastrophic error!!"
    echo "^^^^^^^^^^^^^^^^^^^^"
    echo "$SCRIPT_NAME must run as root!"

    printTitle "How to fix it?"
    echo "Execute the script like this:"
    echo "sudo $SCRIPT_NAME"

    printTitle "The End"
    echo $(date)
    exit
fi


##
SCRIPT_HASH=`md5sum ${SCRIPT_FULLPATH} | awk '{ print $1 }'`
if [ $SELF_UPDATE = 1 ]; then

    printTitle "Self-updating...."
    source "${SCRIPT_DIR}setup.sh"
fi


SCRIPT_HASH_AFTER_UPDATE=`md5sum ${SCRIPT_FULLPATH} | awk '{ print $1 }'`
if [ "$SCRIPT_HASH" != "$SCRIPT_HASH_AFTER_UPDATE" ]; then

    echo ""
    echo "vvvvvvvvvvvvvvvvvvvvvv"
    echo "Self-update installed!"
    echo "^^^^^^^^^^^^^^^^^^^^^^"
    echo "$SCRIPT_NAME has been updated!"
    echo "Please run $SCRIPT_NAME again."

    printTitle "The End"
    echo $(date)
    exit
fi


if [ -z "$(command -v git)" ] || [ -z "$(command -v curl)" ] || [ -z "$(command -v dialog)" ]; then

    printTitle "Installing prerequisites..."
    apt update && apt install git curl dialog -y
fi


HEIGHT=17
WIDTH=65
CHOICE_HEIGHT=25
BACKTITLE="$SCRIPT_NAME - TurboLab.it"
TITLE="Staking box management GUI"
MENU="Choose one of the options:"

OPTIONS=(1 "🤓 Testnet setup/update"
     2 "💰 Mainnet setup/update")


CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        RUNMODE=testnet
        ;;
    2)
        RUNMODE=mainnet
        echo "We are not ready for primetime just yet"
        exit
        ;;
esac


if [ -z "$RUNMODE" ]; then

    echo "Bye bye"
    exit
fi


## zzupdate
if [ $INSTALL_ZZUPDATE = 1 ]; then

    printTitle "Installing zzupdate..."
    curl -s https://raw.githubusercontent.com/TurboLabIt/zzupdate/master/setup.sh?$(date +%s) | sudo sh
    echo "REBOOT=0" > /etc/turbolab.it/zzupdate.conf
    echo "VERSION_UPGRADE=0" >> /etc/turbolab.it/zzupdate.conf
    echo "NIMBUS_UPGRADE=1" >> /etc/turbolab.it/zzupdate.conf
    zzupdate
fi


## Go Ethereum
if [ $INSTALL_GETH = 1 ]; then

    printTitle "Installing Go Ethereum...."
    add-apt-repository -y ppa:ethereum/ethereum
    apt update && apt install geth -y
    
    useradd --no-create-home --shell /bin/false goeth
    mkdir -p /var/lib/goethereum
    chown -R goeth:goeth /var/lib/goethereum
    
    if [ $RUNMODE = "testnet" ]; then

        curl -Lo /etc/systemd/system/geth.service https://turbolab.it/scarica/344
    fi


    if [ $RUNMODE = "mainnet" ]; then

        curl -Lo /etc/systemd/system/geth.service https://turbolab.it/scarica/348
    fi


    cat /etc/systemd/system/geth.service
    
    systemctl enable geth
    systemctl restart geth
fi


## eth2.0-deposit-cli
if [ $INSTALL_ETH2_DEPOSIT_CLI = 1 ]; then

    printTitle "Installing eth2.0-deposit-cli...."
    apt install git python3 python3-pip python3-testresources -y
    
    cd $HOME
    git clone https://github.com/ethereum/eth2.0-deposit-cli.git
    cd eth2.0-deposit-cli
    
    ./deposit.sh install
    
    if [ $RUNMODE = "testnet" ]; then

        ./deposit.sh new-mnemonic --num_validators 1 --chain pyrmont
    fi


    if [ $RUNMODE = "mainnet" ]; then

        ./deposit.sh new-mnemonic --num_validators 1 --chain mainnet
    fi
fi


## Nimbus
if [ $INSTALL_NIMBUS = 1 ]; then

    printTitle "Installing Nimbus...."
    apt install build-essential git libpcre3-dev -y
    
    cd $HOME
    git clone https://github.com/status-im/nimbus-eth2.git
    
    cd nimbus-eth2
    
    make beacon_node
    mv /$HOME/nimbus-eth2/build/beacon_node /usr/local/bin/nimbus
    
    cd $HOME
    rm -rf $HOME/nimbus-eth2
    
    
    useradd --no-create-home --shell /bin/false nimbus
    mkdir -p /var/lib/nimbus
    chown -R nimbus:nimbus /var/lib/nimbus
    chmod u=rwx,g=rx,o= /var/lib/nimbus -R
    
    nimbus deposits import --data-dir=/var/lib/nimbus $HOME/eth2.0-deposit-cli/validator_keys
    
    chown nimbus:nimbus /var/lib/nimbus -R

    
    if [ $RUNMODE = "testnet" ]; then

        curl -Lo /etc/systemd/system/nimbus.service https://turbolab.it/scarica/347
    fi


    if [ $RUNMODE = "mainnet" ]; then

        curl -Lo /etc/systemd/system/nimbus.service https://turbolab.it/scarica/349
    fi


    cat /etc/systemd/system/nimbus.service
    
    systemctl enable nimbus
    systemctl restart nimbus
fi


## Firewall
if [ $ENABLE_FIREWALL = 1 ]; then

    printTitle "Enabling the firewall...."
    ufw allow 22/tcp && ufw allow 30303,9000/tcp && ufw allow 30303,9000/udp && ufw --force enable 
    ufw status
fi


## Request validator activation
printTitle "Activate your validator"
echo -n "Now you must upload your validator deposit_data to "

if [ $RUNMODE = "testnet" ]; then

    echo "https://pyrmont.launchpad.ethereum.org"
fi


if [ $RUNMODE = "mainnet" ]; then

    echo "https://launchpad.ethereum.org"
fi

echo "The file is here: $HOME/eth2.0-deposit-cli/validator_keys"
echo "You must then follow the procedure and deposit 32 ETH."


## Check the activation status
echo ""
printTitle "Check the activation"

echo "You're almost there!"
echo -n "Open this site: "

if [ $RUNMODE = "testnet" ]; then

    echo "https://pyrmont.beaconcha.in"
fi


if [ $RUNMODE = "mainnet" ]; then

    echo "https://beaconcha.in"
fi

echo "Search the address of the wallet your deposited the ETH from "
echo "to check the activation status of your validator."


printTitle "The End"
echo "Happy staking!"

echo ""
echo "Made with ♥ by https://TurboLab.it"
