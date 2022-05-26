#!/bin/bash
cd "$1/contracts" || exit
SALT=$(date | sha256sum | cut -b 1-64)
OWNER="5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
ENDOWMENT=1000000000000
CONTRACT_ARGS='"5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY" "1000000000000"'
CONSTRUCTOR="default"
VALUE="2000000000000"
ENDPOINT="ws://substrate-node"
PORT="9944"
SURI="//Alice"
{
  DEPLOY_RESULT=$(
    cargo contract instantiate ./target/ink/prosopo.wasm \
      --args $OWNER $ENDOWMENT \
      --constructor "$CONSTRUCTOR" \
      --suri "$SURI" \
      --value "$VALUE" \
      --salt "$SALT" \
      --url "$ENDPOINT:$PORT"
  )
}
CONTRACT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep 'who:\s' | tail -1 | tr "[:space:]" '\n' | tail -1)
echo "$CONTRACT_ADDRESS"
#echo "Deployed contract address: $CONTRACT_ADDRESS"
#grep -q "^$2=.*" /usr/src/.env && sed -i -e "s/$2=.*/$2=$CONTRACT_ADDRESS/g" /usr/src/.env || echo "$2=$CONTRACT_ADDRESS" >>/usr/src/.env
#ddea46e7be76d6106bb3909be9e132e5749aa3e0579fba27549c028e4986d521
