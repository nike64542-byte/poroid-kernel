FROM debian:bookworm AS kernel-builder
ARG KERNEL_VERSION=7.1.5
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates xz-utils make gcc gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    bc bison flex libssl-dev libelf-dev python3 kmod cpio \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN for i in 1 2 3 4 5; do \
        echo "Attempt $i: downloading kernel..." && \
        wget -q --tries=3 --timeout=60 --waitretry=5 \
            https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${KERNEL_VERSION}.tar.xz \
        && echo "Download OK" && break || \
        { echo "Attempt $i failed, retrying in 10s..."; sleep 10; }; \
    done \
    && tar xf linux-${KERNEL_VERSION}.tar.xz \
    && rm linux-${KERNEL_VERSION}.tar.xz

COPY podroid_kernel.config /tmp/podroid_kernel.config
# Force-builtin fragment: options netavark + podman need as =y so there's no
# modprobe round-trip (modules caused silent failures in the past). Applied
# WITHOUT -m on top of the main fragment, then locked in with olddefconfig.
RUN printf '%s\n' \
    'CONFIG_IPV6=y' \
    'CONFIG_BRIDGE=y' \
    'CONFIG_BRIDGE_NETFILTER=y' \
    'CONFIG_BRIDGE_VLAN_FILTERING=y' \
    'CONFIG_VLAN_8021Q=y' \
    'CONFIG_STP=y' \
    'CONFIG_LLC=y' \
    'CONFIG_VETH=y' \
    'CONFIG_TUN=y' \
    'CONFIG_DUMMY=y' \
    'CONFIG_NETFILTER=y' \
    'CONFIG_NETFILTER_ADVANCED=y' \
    'CONFIG_NETFILTER_NETLINK=y' \
    'CONFIG_NF_CONNTRACK=y' \
    'CONFIG_NF_CT_NETLINK=y' \
    'CONFIG_NF_NAT=y' \
    'CONFIG_NF_TABLES=y' \
    'CONFIG_NF_TABLES_INET=y' \
    'CONFIG_NF_TABLES_IPV4=y' \
    'CONFIG_NF_TABLES_IPV6=y' \
    'CONFIG_NF_TABLES_BRIDGE=y' \
    'CONFIG_NFT_NAT=y' \
    'CONFIG_NFT_MASQ=y' \
    'CONFIG_NFT_CT=y' \
    'CONFIG_NFT_COMPAT=y' \
    'CONFIG_NF_NAT_MASQUERADE=y' \
    'CONFIG_IP_NF_IPTABLES=y' \
    'CONFIG_IP_NF_FILTER=y' \
    'CONFIG_IP_NF_NAT=y' \
    'CONFIG_IP_NF_TARGET_MASQUERADE=y' \
    'CONFIG_IP6_NF_IPTABLES=y' \
    'CONFIG_IP6_NF_FILTER=y' \
    'CONFIG_IP6_NF_NAT=y' \
    'CONFIG_IP6_NF_TARGET_MASQUERADE=y' \
    'CONFIG_NETFILTER_XTABLES=y' \
    'CONFIG_NETFILTER_XTABLES_LEGACY=y' \
    'CONFIG_IP_NF_IPTABLES_LEGACY=y' \
    'CONFIG_IP6_NF_IPTABLES_LEGACY=y' \
    'CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y' \
    'CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y' \
    'CONFIG_NETFILTER_XT_MATCH_MARK=y' \
    'CONFIG_NETFILTER_XT_MATCH_COMMENT=y' \
    'CONFIG_NETFILTER_XT_TARGET_MASQUERADE=y' \
    'CONFIG_NETFILTER_XT_TARGET_REDIRECT=y' \
    'CONFIG_NETFILTER_XT_TARGET_MARK=y' \
    'CONFIG_OVERLAY_FS=y' \
    'CONFIG_FUSE_FS=y' \
    'CONFIG_EXT4_FS_SECURITY=y' \
    'CONFIG_SQUASHFS_XATTR=y' \
    'CONFIG_SQUASHFS_ZSTD=y' \
    'CONFIG_DECOMPRESS_ZSTD=y' \
    'CONFIG_ZSTD_DECOMPRESS=y' \
    'CONFIG_IKCONFIG=y' \
    'CONFIG_IKCONFIG_PROC=y' \
    'CONFIG_IP_NF_RAW=y' \
    'CONFIG_IP6_NF_RAW=y' \
    'CONFIG_BLK_DEV_THROTTLING=y' \
    'CONFIG_NET_CLS_CGROUP=y' \
    'CONFIG_CFS_BANDWIDTH=y' \
    'CONFIG_IP_NF_TARGET_REDIRECT=y' \
    'CONFIG_IP_SCTP=y' \
    'CONFIG_IP_VS=y' \
    'CONFIG_IP_VS_NFCT=y' \
    'CONFIG_IP_VS_PROTO_TCP=y' \
    'CONFIG_IP_VS_PROTO_UDP=y' \
    'CONFIG_IP_VS_RR=y' \
    'CONFIG_NFT_FIB=y' \
    'CONFIG_NFT_FIB_IPV4=y' \
    'CONFIG_NFT_FIB_IPV6=y' \
    'CONFIG_VXLAN=y' \
    'CONFIG_IPVLAN=y' \
    'CONFIG_MACVLAN=y' \
    'CONFIG_DUMMY=y' \
    'CONFIG_CRYPTO_GCM=y' \
    'CONFIG_CRYPTO_GHASH=y' \
    'CONFIG_CRYPTO_SEQIV=y' \
    'CONFIG_XFRM=y' \
    'CONFIG_XFRM_USER=y' \
    'CONFIG_XFRM_ALGO=y' \
    'CONFIG_INET_ESP=y' \
    'CONFIG_NETFILTER_XT_MATCH_BPF=y' \
    'CONFIG_NF_CONNTRACK_FTP=y' \
    'CONFIG_NF_NAT_FTP=y' \
    'CONFIG_NF_CONNTRACK_TFTP=y' \
    'CONFIG_NF_NAT_TFTP=y' \
    'CONFIG_BTRFS_FS=y' \
    'CONFIG_BTRFS_FS_POSIX_ACL=y' \
    'CONFIG_SECURITY_APPARMOR=y' \
    'CONFIG_IP6_NF_MANGLE=y' \
    'CONFIG_BINFMT_MISC=y' \
    'CONFIG_VSOCKETS=y' \
    'CONFIG_VSOCKETS_DIAG=y' \
    'CONFIG_VIRTIO_VSOCKETS=y' \
    'CONFIG_NFSD=y' \
    'CONFIG_NFSD_V4=y' \
    'CONFIG_NFS_FS=y' \
    'CONFIG_NFS_V4=y' \
    'CONFIG_CONFIGFS_FS=y' \
    'CONFIG_TARGET_CORE=y' \
    'CONFIG_TCM_IBLOCK=y' \
    'CONFIG_TCM_FILEIO=y' \
    'CONFIG_ISCSI_TARGET=y' \
    'CONFIG_ISCSI_TCP=y' \
    'CONFIG_SCSI_ISCSI_ATTRS=y' \
    'CONFIG_ANDROID_BINDER_IPC=y' \
    'CONFIG_ANDROID_BINDERFS=y' \
    'CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"' \
    'CONFIG_PSI=y' \
    > /tmp/forced_builtin.config
RUN cd linux-${KERNEL_VERSION} \
    && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig \
    && ./scripts/kconfig/merge_config.sh -m .config /tmp/podroid_kernel.config \
    && ./scripts/kconfig/merge_config.sh -m .config /tmp/forced_builtin.config \
    && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig \
    && echo "=== patching hvc_console tty adapter limit for multi-window terminals ===" \
    && sed -i 's/^#define HVC_ALLOC_TTY_ADAPTERS[[:space:]]*8$/#define HVC_ALLOC_TTY_ADAPTERS 32/' \
        drivers/tty/hvc/hvc_console.h \
    && grep -q '^#define HVC_ALLOC_TTY_ADAPTERS 32$' drivers/tty/hvc/hvc_console.h \
        || { echo "FATAL: HVC_ALLOC_TTY_ADAPTERS patch did not apply" >&2; \
             grep HVC_ALLOC_TTY_ADAPTERS drivers/tty/hvc/hvc_console.h >&2; exit 1; } \
    && echo "=== verifying critical options are =y ===" \
    && for opt in IPV6 BRIDGE BRIDGE_NETFILTER NF_TABLES_BRIDGE \
                  NETFILTER_XTABLES_LEGACY \
                  IP_NF_IPTABLES_LEGACY IP6_NF_IPTABLES_LEGACY \
                  IP6_NF_IPTABLES IP6_NF_FILTER IP6_NF_NAT \
                  IP_NF_TARGET_MASQUERADE IP6_NF_TARGET_MASQUERADE \
                  NETFILTER_XT_TARGET_MASQUERADE NF_NAT_MASQUERADE \
                  NFT_COMPAT NFT_MASQ NFT_NAT \
                  VETH TUN NF_TABLES NF_NAT NETFILTER OVERLAY_FS FUSE_FS \
                  EXT4_FS_SECURITY SQUASHFS_XATTR SQUASHFS_ZSTD \
                  DECOMPRESS_ZSTD ZSTD_DECOMPRESS \
                  IKCONFIG IKCONFIG_PROC BINFMT_MISC \
                  VSOCKETS VIRTIO_VSOCKETS \
                  RFKILL LEDS_CLASS CFG80211 MAC80211 RTW88 BT \
                  USB USB_SUPPORT WLAN \
                  RTW88_8821AU RTW88_8812AU RTW88_8814AU \
                  FW_LOADER_COMPRESS FW_LOADER_COMPRESS_ZSTD UNICODE \
                  USB_XHCI_HCD USB_XHCI_PCI USB_STORAGE USB_UAS \
                  SCSI BLK_DEV_SD VFAT_FS EXFAT_FS \
                  NFSD NFSD_V4 NFS_FS NFS_V4 SUNRPC CONFIGFS_FS \
                   TARGET_CORE TCM_IBLOCK TCM_FILEIO ISCSI_TARGET ISCSI_TCP \
                   ANDROID_BINDER_IPC ANDROID_BINDERFS PSI; do \
           grep -q "^CONFIG_${opt}=y\$" .config \
               || { echo "FATAL: CONFIG_${opt} is not =y after merge" >&2; \
                    grep "CONFIG_${opt}" .config >&2; exit 1; }; \
       done \
    && echo "=== all critical options are built-in ===" \
    && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image.gz
# NOTE: no `modules` target. Every option the VM needs (virtio_blk, virtio_net,
# 9p, bridge, netfilter, tun, veth, overlayfs, fuse) is forced =y built-in in the
# fragments above. Building the full defconfig module set (thousands of phy/
# pinctrl/gpio/sound drivers) bloats the runner disk to "No space left on device"
# and adds ~60min of compile time for zero VM benefit.
# init-podroid's `modprobe virtio_blk` is already a no-op safety net: it checks
# `[ -d /lib/modules/$(uname -r) ]` and skips when modules are absent.

# Provide an empty modules dir so the initramfs packer COPY succeeds.
RUN mkdir -p /modules/lib/modules

RUN mkdir -p /output \
    && cp linux-${KERNEL_VERSION}/arch/arm64/boot/Image.gz /output/vmlinuz-virt


FROM scratch AS export
COPY --from=kernel-builder /output/vmlinuz-virt /vmlinuz-virt
