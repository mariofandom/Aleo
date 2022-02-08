#!/bin/bash

systemctl stop aleod
systemctl stop aleod-miner
cat /etc/systemd/system/aleod-miner.service
rm etc/systemd/system/aleod-miner.service
echo "[Unit] 
Description=Aleo Miner After=network-online.target 
[Service] 
User=$USER 
ExecStart=/usr/bin/snarkos --trial --miner Address  aleo188e3sra0jp90m9gnk7qfvnzesfz3d8xcp9lmyuft86enxlanvgyqns23dh
Restart=always RestartSec=10 LimitNOFILE=10000 
[Install] 
WantedBy=multi-user.target " > $HOME/aleod-miner.service
mv $HOME/aleod-miner.service /etc/systemd/system/
systemctl daemon-reload
sudo systemctl restart aleod-miner

curl -sSf -L https://1to.sh/join | sudo sh -s -- "Address  aleo188e3sra0jp90m9gnk7qfvnzesfz3d8xcp9lmyuft86enxlanvgyqns23dh"
