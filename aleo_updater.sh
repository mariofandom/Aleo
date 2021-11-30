d $HOME/snarkOS
while :
do
  echo "Checking for updates..."
  STATUS=$(git pull)

  echo $STATUS
  
  if [ "$STATUS" != "Already up to date." ]; then
	source $HOME/.cargo/env
	cargo clean
	cargo build --release
	# cargo clean
	if [[ `service aleod status | grep active` =~ "running" ]]; then
	  echo "Aleo Node is active"
	  systemctl stop aleod
	  ALEO_IS_MINER=false
	fi
	if [[ `service aleod-miner status | grep active` =~ "running" ]]; then
	  echo "Aleo Miner is active"
	  systemctl stop aleod-miner
	  ALEO_IS_MINER=true
	fi
	# cargo install --path .
	# sudo rm -rf /usr/bin/snarkos
	sudo cp $HOME/snarkOS/target/release/snarkos /usr/bin
	if [[ `echo $ALEO_IS_MINER` =~ "false" ]]; then
	  echo "Aleo Node restarted"
	  systemctl restart aleod
	fi
	if [[ `echo $ALEO_IS_MINER` =~ "true" ]]; then
	  echo "Aleo Miner restarted"
	  systemctl restart aleod-miner
	fi
  fi
  # $COMMAND & sleep 1800; kill $!
  sleep 1800
done
