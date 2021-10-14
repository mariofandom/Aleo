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
#sleep 1 && curl -s https://api.nodes.guru/logo.sh | bash && sleep 3
echo -e 'Setting up swapfile...\n'
curl -s https://api.nodes.guru/swap4.sh | bash
echo -e 'Installing dependencies...\n' && sleep 1
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git curl ntp jq llvm -y < "/dev/null"
echo -e 'Installing Rust (stable toolchain)...\n' && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y

source $HOME/.cargo/env
rustup default stable
rustup update stable --force

echo -e 'Cloning snarkOS...\n' && sleep 1
cd $HOME
git clone https://github.com/AleoHQ/snarkOS
cd snarkOS

git checkout v1.3.16
echo -e 'Compiling snarkos v1.3.16 ...\n' && sleep 1
cargo build --release
sudo cp $HOME/snarkOS/target/release/snarkos /usr/bin
echo -e 'Clone Aleo...\n' && sleep 1
cd $HOME
git clone https://github.com/AleoHQ/aleo && cd aleo
cargo install --path . --locked
echo -e 'Creating account...\n' && sleep 1
aleo account new >> $HOME/aleo/account_new.txt && cat $HOME/aleo/account_new.txt && sleep 3
echo 'export ALEO_ADDRESS='$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}') >> $HOME/.bashrc && . $HOME/.bashrc
source $HOME/.bashrc
export ALEO_ADDRESS=$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}')
echo -e 'Your miner address - ' && echo ${ALEO_ADDRESS} && sleep 1
echo -e 'Creating a service for Aleo Node...\n' && sleep 1
echo "[Unit]

Description=Aleo Node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target

echo -e 'Creating a service for Aleo Miner...\n' && sleep 1
echo "[Unit]
Description=Aleo Miner
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos --is-miner --miner-address '$ALEO_ADDRESS' --connect 46.101.144.133:4131,167.71.79.152:4131,46.101.147.96:4131,167.99.53.204:4131,128.199.15.82:4131,159.89.152.247:4131,128.199.7.1:4131,167.99.69.230:4131,178.128.18.3:4131,206.189.80.245:4131
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
sudo mv $HOME/aleod.service /etc/systemd/system
sudo mv $HOME/aleod-miner.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e 'Starting Aleo Node service\n' && sleep 1
sudo systemctl enable aleod
sudo systemctl restart aleod
sudo systemctl enable aleod-miner

. $HOME/.bashrc
