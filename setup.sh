#!/bin/bash
echo ""

## Script name
SCRIPT_NAME="ethereum-autostaker"

## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/

## Install/update
echo ""
if [ ! -d "$INSTALL_DIR" ]; then

  ## Pre-requisites
  apt update && apt install git -y

  echo "Installing..."
  echo "-------------"
  mkdir -p "$INSTALL_DIR_PARENT"
  cd "$INSTALL_DIR_PARENT"
  git clone https://github.com/TurboLabIt/${SCRIPT_NAME}.git
  
else

  echo "Updating..."
  echo "----------"
  
fi

## Fetch & pull new code
cd "$INSTALL_DIR"
git pull --no-rebase

## Symlink (globally-available command)
if [ ! -f "/usr/local/bin/${SCRIPT_NAME}" ]; then
  ln -s "${INSTALL_DIR}${SCRIPT_NAME}.sh" "/usr/local/bin/${SCRIPT_NAME}"
fi

if [ ! -f "/usr/local/bin/nimbus-update" ]; then
  ln -s "${INSTALL_DIR}script/nimbus-update.sh" "/usr/local/bin/nimbus-update"
fi

## Restore working directory
cd $WORKING_DIR_ORIGINAL

echo ""
echo "Setup completed!"
echo "----------------"
echo "See https://github.com/TurboLabIt/${SCRIPT_NAME} for the quickstart guide."
