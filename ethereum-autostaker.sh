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
echo "-> Install build-essential offline https://turbolab.it/2237"
sleep 5

ORIGINAL_WORKING_DIR=$(pwd)
SCRIPT_FULLPATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/
cd "${SCRIPT_DIR}"



cd "$ORIGINAL_WORKING_DIR"
echo "*** DONE ***"

