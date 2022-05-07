#!/bin/bash
echo ""

echo "Updating Nimbus.."
  
if [ -f "/usr/local/bin/nimbus" ]; then

  sudo apt update
  sudo apt install build-essential git libpcre3-dev -y

  cd $HOME
  git clone https://github.com/status-im/nimbus-eth2.git
  cd nimbus-eth2
  make -j4 nimbus_beacon_node
  sudo service nimbus stop
  sudo mv "$HOME/nimbus-eth2/build/nimbus_beacon_node" "/usr/local/bin/nimbus"
  cd $HOME
  rm -rf $HOME/nimbus-eth2
  sudo service nimbus restart
  nimbus --version

else

  echo "Nimbus is not installed"
fi
