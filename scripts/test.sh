./scripts/start-substrate.sh --test-db --restart-chain
./scripts/start-db.sh --env-file=.env.test
cp .database_accounts.json database_accounts.json
yarn workspace @prosopo/provider run test:mock
./scripts/start-substrate.sh
./scripts/start-db.sh