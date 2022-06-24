
setup:
	./scripts/setup-dev.sh

dev:
	./scripts/run-dev.sh $(if $(filter build-substrate,$(MAKECMDGOALS)),--build-substrate,) $(if $(filter deploy-protocol,$(MAKECMDGOALS)),--deploy-protocol,) $(if $(filter deploy-dapp,$(MAKECMDGOALS)),--deploy-dapp,) $(if $(filter deploy-demo,$(MAKECMDGOALS)),--deploy-demo,) $(if $(filter restart-chain,$(MAKECMDGOALS)),--restart-chain,)

test:
	./scripts/run-dev.sh --test-db $(if $(filter build-substrate,$(MAKECMDGOALS)),--build-substrate,) $(if $(filter deploy-protocol,$(MAKECMDGOALS)),--deploy-protocol,) $(if $(filter deploy-dapp,$(MAKECMDGOALS)),--deploy-dapp,) $(if $(filter deploy-demo,$(MAKECMDGOALS)),--deploy-demo,) $(if $(filter restart-chain,$(MAKECMDGOALS)),--restart-chain,)

restart:
	./scripts/restart-chain.sh

export:
	./scripts/export.sh --populate
