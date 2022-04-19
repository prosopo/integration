#!/bin/zsh

cd "$1" || exit
yarn
yarn build
{ CONTRACT_ADDRESS=$(yarn deploy | tee /dev/fd/3 | tail -n 1); } 3>&1
echo "Deployed contract address: $CONTRACT_ADDRESS"
grep -q "^$2=.*" /usr/src/.env && sed -i -e "s/$2=.*/$2=$CONTRACT_ADDRESS/g" /usr/src/.env || echo "$2=$CONTRACT_ADDRESS" >>/usr/src/.env
