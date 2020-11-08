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
sleep 5


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
printTitle "Self-update...."
source "${SCRIPT_DIR}setup.sh"

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


printTitle "Installing prerequisites"
apt update
apt install git curl dialog -y


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
            ;;
esac


if [ -z "$RUNMODE" ]; then

	echo "Bye bye"
fi

