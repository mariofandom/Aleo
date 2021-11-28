#/bin/zsh
]
if [ -z "$1" ]
	then
		node="localhost:3032"
else
	node="$1"
fi

clear;
printf "Aleo.org TESTNET2 monitoring for:\t$node\n"
echo ""
echo "-----------------------------------------------"
printf "CONNECTED PEERS:\n";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getconnectedpeers", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result[]';
echo ""
printf "LATEST BLOCK HEIGHT:\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "latestblockheight", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result';
echo "-----------------------------------------------"
echo ""
printf "NODE STATE:\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getnodestate", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result';
echo "-----------------------------------------------"
echo ""
#printf "LATEST BLOCK HEADER:\n\n";
#curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "latestblockheader", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result';
#echo "-----------------------------------------------"
#echo ""
#printf "LATEST BLOCK CONTENT:\n\n";
#curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "latestblock", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result';
#echo "-----------------------------------------------"
#echo ""
#printf "LATEST BLOCK TXS:\n\n";
#curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "latestblocktransactions", "params": [] }' -H 'content-type: application/json' http://$node/ | jq '.result.transactions[]';
#echo ""
