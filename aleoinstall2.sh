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
ufw allow 4132/tcp && ufw allow 3032/tcp
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
cd $HOME
mkdir Aleo_old_Wallet
cd Aleo_old_Wallet 
cat $HOME/aleo/account_new.txt |    tee OLD_account_new.txt

cd $HOME


curl -s https://raw.githubusercontent.com/mariofandom/Aleo/main/total_remove_testnet1.sh > total_remove_testnet1.sh && chmod +x total_remove_testnet1.sh && ./total_remove_testnet1.sh


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


echo "==================================================
Your Aleo account:
==================================================
" >> $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt

snarkos experimental new_account >> $HOME/aleo/account_new.txt && cat $HOME/aleo/account_new.txt && sleep 2



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
WantedBy=multi-user.target" > $HOME/aleod-miner.service
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
sudo systemctl start aleod-miner
echo -e "Installing Aleo Updater\n"
cd $HOME
#wget -q -O $HOME/aleo_updater_testnet2.sh https://github.com/mariofandom/Aleo/blob/main/aleo_updater_testnet2.sh && chmod +x  $HOME/aleo_updater_testnet2.sh
wget -q -O $HOME/aleo_updater.sh https://raw.githubusercontent.com/mariofandom/Aleo/main/aleo_updater.sh && chmod +x  $HOME/aleo_updater.sh
#wget -q -O $HOME/aleo_updater.sh https://github.com/mariofandom/Aleo/blob/main/aleo_updater.sh 


echo "[Unit]
Description=Aleo Updater Testnet2
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=/bin/bash $HOME/aleo_updater.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-updater.service
sudo mv $HOME/aleo-updater.service /etc/systemd/system
systemctl daemon-reload
echo -e 'Enabling Aleo Updater services\n' && sleep 1
systemctl enable aleo-updater
systemctl restart aleo-updater
sudo systemctl restart systemd-journald








#show message about ip
export getip=$(wget -qO - eth0.me)
printf "your ip is  "&& echo ${getip}
echo "open link below to see your miner in checker"
printf "https://nodes.guru/aleo/aleochecker?q="&&  echo ${getip}
printf " use command below to see miner status      \n " 
printf "systemctl status aleod-miner \n" && sleep 100


