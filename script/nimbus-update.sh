#!/bin/bash
echo ""

echo "Updating Nimbus.."
  
if [ -f "/usr/local/bin/nimbus" ]; then

  cd $HOME
  git clone https://github.com/status-im/nimbus-eth2.git
  cd nimbus-eth2
  make -j4 nimbus_beacon_node
  service nimbus stop
  mv $HOME/nimbus-eth2/build/nimbus_beacon_node /usr/local/bin/nimbus
  cd $HOME
  rm -rf $HOME/nimbus-eth2
  service nimbus restart
  nimbus --version

else

  echo "Nimbus is not installed"
fi
