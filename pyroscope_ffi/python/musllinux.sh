#!/bin/sh
set -ex

apk add --no-cache gcc libffi-dev openssl-dev wget g++ libc-dev make cargo
cargo --version

# Build wheels
/opt/python/cp39-cp39/bin/python -m build --wheel

# Audit wheels
for wheel in dist/*-linux_*.whl; do
  auditwheel repair $wheel -w dist/
  rm $wheel
done
