#!/usr/bin/env bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

curl -L "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.8.tar.xz" -o ./linux.tar.xz
curl -L "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-minirootfs-3.22.1-x86_64.tar.gz" -o ./alpine-minirootfs.tar.gz
curl -L "https://downloads.sourceforge.net/project/slirp/slirp/1.0.17%20patch/slirp_1_0_17_patch.tar.gz" -o ./slirp_1_0_17_patch.tar.gz
curl -L "https://downloads.sourceforge.net/project/slirp/slirp/1.0.16/slirp-1.0.16.tar.gz" -o ./slirp-1.0.16.tar.gz