#!/bin/bash
git submodule update --init --recursive --force --checkout
git checkout milestone1 --recurse-submodules
$(cd protocol && git checkout milestone1)
$(cd dapp-example && git checkout milestone1)
$(cd provider && git checkout milestone1)