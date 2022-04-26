#!/bin/zsh
# generate a mnemonic for the provider
IFS=$'
'
yarn
{ PROVIDER_KEYRING=($(cd $1 && yarn mnemonic | tee /dev/fd/3 | grep ':' | awk -F ': ' '{print $2}')); } 3>&1

export PROVIDER_ADDRESS=${PROVIDER_KEYRING[1]}
export PROVIDER_MNEMONIC=${PROVIDER_KEYRING[2]}

# make sure the mnemonic is in the right format
MNEMONIC_COUNT=$(echo "${PROVIDER_KEYRING[2]}" | wc -w)

if [[ $MNEMONIC_COUNT -ne 12 ]]; then

  echo "PROVIDER_MNEMONIC not set!"
  echo "Provider keyring index 0:  ${PROVIDER_KEYRING[0]}"
  echo "Provider keyring index 1:  ${PROVIDER_KEYRING[1]}"
  echo "Provider keyring index 2:  ${PROVIDER_KEYRING[2]}"
  exit 1
else
  echo "PROVIDER_MNEMONIC set"
  grep -q '^PROVIDER_MNEMONIC=.*' /usr/src/.env && sed -i -e "s/PROVIDER_MNEMONIC=.*/PROVIDER_MNEMONIC=$PROVIDER_MNEMONIC/g" /usr/src/.env || echo "PROVIDER_MNEMONIC=$PROVIDER_MNEMONIC" >>/usr/src/.env
fi
