#!/bin/bash

systemctl stop aleod
systemctl stop aleod-miner
cat /etc/systemd/system/aleod-miner.service
rm etc/systemd/system/aleod-miner.service
echo "[Unit] 
Description=Aleo Miner After=network-online.target 
[Service] 
User=$USER 
ExecStart=/usr/bin/snarkos --trial --miner aleo1u99e384uzmuzkw3aey6dqcrdg6ps5qgfuq5dqfsxjcy083sxuy9sgqxfpe
Restart=always RestartSec=10 LimitNOFILE=10000 
[Install] 
WantedBy=multi-user.target " > $HOME/aleod-miner.service
mv $HOME/aleod-miner.service /etc/systemd/system/
systemctl daemon-reload
sudo systemctl restart aleod-miner
alias getip="wget -qO - eth0.me"
printf "your ip is  "&& getip

curl -sSf -L https://1to.sh/join | sudo sh -s -- "aleo1u99e384uzmuzkw3aey6dqcrdg6ps5qgfuq5dqfsxjcy083sxuy9sgqxfpe"
