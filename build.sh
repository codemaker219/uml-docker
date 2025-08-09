#!/usr/bin/env bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

podman build -t uml .

podman create --name uml  uml
mkdir -p out
podman cp uml:/uml/linux out/
podman rm -f uml