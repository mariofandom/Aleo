#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi

echo "=================================================="
sleep 1 && sleep 3
echo "=================================================="
echo -e 'Removing all snarkos 2.0.0 Testnet2 files ...\n\n'
echo '/etc/systemd/system/aleod.service'
echo '/etc/systemd/system/aleod-miner.service'
echo '$HOME/.aleo'
echo '$HOME/.cargo'
echo '$HOME/.rustup'
echo '$HOME/.ledger-2'
echo '.ledger-2'
echo '$HOME/snarkOS'
echo '$HOME/aleo'
echo '$HOME/aleo_snarkos2.sh'
echo '/usr/bin/snarkos (or other dir)'
echo "=================================================="

services=$(ls /etc/systemd/system | grep aleod)

if [ -z "$services" ]; then
	echo "service files are already removed"
else
	systemctl stop aleod aleod-miner
	rm -rf /etc/systemd/system/aleod*
fi

cd $HOME/
rm -rf .aleo .cargo .rustup .ledger-2 snarkOS aleo aleo_snarkos2.sh
cd ~/..
rm -rf .ledger-2

if exists snarkos; then
	rm $(which snarkos)
else
	echo "snarkos is already removed"
fi

echo "=================================================="
echo -e 'Aleo Testnet2 snarkos version 2.0.0 is removed \n' && sleep 1
