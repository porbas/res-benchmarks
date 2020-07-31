#!/bin/bash

set -e

rm -f benchmarks/ips-state
touch benchmarks/ips-state

TARGETS=$(ls -1 apps)

for target in $TARGETS; do
  echo "Benchmarking $target"
  pushd "apps/$target"
  rake db:drop db:create db:migrate
  bin/rails runner ../../$1
  popd
done
