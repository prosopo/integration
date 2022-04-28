#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--test-db]

    Options:
        --test-db:      use test db
USAGE
  exit 1
}

TEST_DB=false

for arg in "$@"; do
  case $arg in
  --test-db)
    TEST_DB=true
    shift # Remove --install from `$@`
    ;;
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
done

echo "Test DB $TEST_DB"

if [[ $TEST_DB == true ]]; then
  ./scripts/export-chain.sh --test-db
else
  ./scripts/export-chain.sh
fi;
./scripts/export-db.sh
