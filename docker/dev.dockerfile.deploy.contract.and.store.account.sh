cd $1
yarn
yarn build
{ CONTRACT_ADDRESS=$(yarn deploy | tee /dev/fd/3 | tail -n 2 | head -n 1 ); } 3>&1
rm ../env
echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> /usr/src/env