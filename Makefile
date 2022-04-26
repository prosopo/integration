
setup:
	./scripts/setup-dev.sh

dev:
	./scripts/run-dev.sh $(if $(filter install,$(MAKECMDGOALS)),--install,) $(if $(filter build-provider,$(MAKECMDGOALS)),--build-provider,) $(if $(filter build-substrate,$(MAKECMDGOALS)),--build-substrate,) $(if $(filter build-redspot,$(MAKECMDGOALS)),--build-redspot,) $(if $(filter deploy-protocol,$(MAKECMDGOALS)),--deploy-protocol,) $(if $(filter deploy-dapp,$(MAKECMDGOALS)),--deploy-dapp,)

restart:
	./scripts/restart-chain.sh
