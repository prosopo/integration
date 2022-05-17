#!/bin/zsh

cd "$1" || exit
yarn
yarn build
{ CONTRACT_ADDRESS=$(yarn deploy | tee /dev/fd/3 | tail -n 1); } 3>&1
echo "Deployed contract address: $CONTRACT_ADDRESS"
sedi () {
    sed --version >/dev/null 2>&1 && sed -i "$@" || sed -i "" "$@"
}
grep -q "^$2=.*" /usr/src/.env && sedi -e "s/$2=.*/$2=$CONTRACT_ADDRESS/g" /usr/src/.env || echo "$2=$CONTRACT_ADDRESS" >>/usr/src/.env
