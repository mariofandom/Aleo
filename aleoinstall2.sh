#!/bin/bash

sudo apt update
sudo apt install ufw -y
sudo ufw allow 22:65535/tcp
sudo ufw allow 22:65535/udp
sudo ufw deny out from any to 10.0.0.0/8
sudo ufw deny out from any to 192.168.0.0/16
sudo ufw deny out from any to 169.254.0.0/16
sudo ufw deny out from any to 198.18.0.0/15
sudo ufw deny out from any to 100.64.0.0/10
sudo ufw --force enable

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi

echo -e 'Setting up swapfile...\n'
echo -e '\n\e[42m[Swap] Starting...\e[0m\n'
grep -q "swapfile" /etc/fstab
if [[ ! $? -ne 0 ]]; then
    echo -e '\n\e[42m[Swap] Swap file exist, skip.\e[0m\n'
else
    cd $HOME
    sudo fallocate -l 4G $HOME/swapfile
    sudo dd if=/dev/zero of=swapfile bs=1K count=4M
    sudo chmod 600 $HOME/swapfile
    sudo mkswap $HOME/swapfile
    sudo swapon $HOME/swapfile
    sudo swapon --show
    echo $HOME'/swapfile swap swap defaults 0 0' >> /etc/fstab
    echo -e '\n\e[42m[Swap] Done\e[0m\n'
fi



echo -e 'Installing dependencies...\n' && sleep 1
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential gcc xz-utils tmux git curl ntp jq llvm -y < "/dev/null"
echo -e 'Installing Rust (stable toolchain)...\n' && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y

sudo systemctl stop aleod
sudo systemctl stop aleod-miner

source $HOME/.cargo/env
rustup default stable
rustup update stable --force
sudo rm $HOME/aleo/account_new.txt
sudo rm -r $HOME/snarkOS

echo -e 'Cloning snarkOS...\n' && sleep 1
cd $HOME
git clone https://github.com/AleoHQ/snarkOS.git --depth 1 -b testnet2
cd snarkOS

echo -e 'Installing snarkos v2.0.0 ...\n' && sleep 1
cargo install --path .

sudo rm -rf /usr/bin/snarkos
sudo cp $HOME/snarkOS/target/release/snarkos /usr/bin
cd $HOME
echo -e 'Creating Aleo account for Testnet2...\n' && sleep 1
mkdir $HOME/aleo

Your Aleo account:
echo "==================================================
==================================================
" >> $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt

apt install screen
screen -dmS snarkos_keygen bash -c "snarkos experimental new_account &>> $HOME/aleo/account_new.txt"
cat $HOME/aleo/account_new.txt

echo 'export ALEO_ADDRESS='$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}') >> $HOME/.bashrc && . $HOME/.bashrc
source $HOME/.bashrc
export ALEO_ADDRESS=$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}' | tail -1)
printf 'Your miner address - ' && echo ${ALEO_ADDRESS} && sleep 1
echo -e 'Creating a service for Aleo Node...\n' && sleep 1
echo "[Unit]
Description=Aleo Client Node Testnet2
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleod.service
echo -e 'Creating a service for Aleo Miner...\n' && sleep 1
echo "[Unit]
Description=Aleo Miner Testnet2
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos --trial --miner $ALEO_ADDRESS
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleod-miner.service
sudo mv $HOME/aleod.service /etc/systemd/system
sudo mv $HOME/aleod-miner.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e 'Enabling Aleo Node and Miner services\n' && sleep 1
sudo systemctl enable aleod
sudo systemctl enable aleod-miner
#sudo systemctl restart aleod
#sudo systemctl restart aleod-miner
#echo -e 'To check your node/miner status - run this script in 15-20 minutes:\n' && sleep 1
#echo -e 'wget -O snarkos_monitor.sh https://api.nodes.guru/snarkos_monitor.sh && chmod +x snarkos_monitor.sh && ./snarkos_monitor.sh' && echo && sleep 1

