# poroid-kernel

Podroid custom Linux kernel (aarch64) builder.

Produces `vmlinuz-virt` (compressed `Image.gz`) with every option the Podroid
guest VM needs built in (`=y`): virtio_blk/net/9p, bridge, netfilter/nftables,
tun, veth, overlayfs, fuse, vsock, NFS, binder, and the HVC tty adapter limit
raised to 32 for multi-window terminals.

Consumed by [poroid-apk](https://github.com/nike64542-byte/poroid-apk): its CI
downloads `vmlinuz-virt` from this repo's `latest` GitHub Release.

## Build

```bash
./build.sh                 # default kernel version (gradle.properties)
./build.sh 7.1.5           # specific version
```

Output lands in `out/vmlinuz-virt`.

## CI

- `push` to `main` (when `podroid_kernel.config` / `Dockerfile` change) or
  `workflow_dispatch` builds the kernel and uploads `vmlinuz-virt` to the
  `latest` Release.
