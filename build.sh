#!/bin/bash
# Podroid custom kernel builder — produces vmlinuz-virt for aarch64.
# Usage: ./build.sh [KERNEL_VERSION]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_VERSION="${1:-$(grep -E '^podroidKernelVersion=' "${SCRIPT_DIR}/../gradle.properties" 2>/dev/null | cut -d= -f2 || echo 7.1.5)}"
OUT="${SCRIPT_DIR}/out"

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }

log "Building custom kernel ${KERNEL_VERSION} for aarch64 (Docker)..."
docker build --network=host \
    --build-arg "KERNEL_VERSION=${KERNEL_VERSION}" \
    -t podroid-kernel-builder --target kernel-builder "${SCRIPT_DIR}"

log "Extracting vmlinuz-virt..."
docker rm -f podroid-kernel-extract 2>/dev/null || true
docker create --name podroid-kernel-extract podroid-kernel-builder
mkdir -p "${OUT}"
docker cp podroid-kernel-extract:/output/vmlinuz-virt "${OUT}/vmlinuz-virt"
docker rm podroid-kernel-extract >/dev/null

echo "Kernel ready: ${OUT}/vmlinuz-virt"
