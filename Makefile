
setup:
	./scripts/setup-dev.sh

dev:
	./scripts/run-dev.sh $(if $(filter build-substrate,$(MAKECMDGOALS)),--build-substrate,) $(if $(filter restart-chain,$(MAKECMDGOALS)),--restart-chain,)

test:
	./scripts/run-dev.sh --test-db $(if $(filter build-substrate,$(MAKECMDGOALS)),--build-substrate,) $(if $(filter restart-chain,$(MAKECMDGOALS)),--restart-chain,)

restart:
	./scripts/restart-chain.sh

export:
	./scripts/export.sh --populate
