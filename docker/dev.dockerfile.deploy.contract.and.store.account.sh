cd $1
yarn
yarn build
{ CONTRACT_ADDRESS=$(yarn deploy | tee /dev/fd/3 | tail -n 2 | head -n 1 ); } 3>&1
echo "$2=$CONTRACT_ADDRESS" >> /usr/src/env