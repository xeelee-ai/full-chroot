#!/bin/bash
set -e

echo "Setting up full chroot environment..."

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <root filesystem path>"
    echo "Example: $0 ./ubuntu-base-24.04.3"
    exit 1
fi

ROOTFS=$(realpath "$1")

if [ ! -d "$ROOTFS" ]; then
    echo "Error: Directory $ROOTFS does not exist"
    exit 1
fi

echo "Target root filesystem: $ROOTFS"

# Check if running with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Root privileges required, using sudo..."
    exec sudo bash "$0" "$@"
    exit
fi

# 1. Create necessary directory structure
echo "Creating directory structure..."
mkdir -p "$ROOTFS"/{proc,sys,dev,run,tmp,var/tmp,home,root}
mkdir -p "$ROOTFS"/dev/{pts,shm}
mkdir -p "$ROOTFS"/run/{lock,systemd}
mkdir -p "$ROOTFS"/var/lib/dbus
mkdir -p "$ROOTFS"/sys/fs/cgroup

# 2. Mount core filesystems (full version)
echo "Mounting core filesystems..."

# Unmount potentially mounted filesystems
umount_recursive() {
    local dir="$1"
    if mountpoint -q "$dir"; then
        umount -l "$dir" 2>/dev/null || true
    fi
}

# Clean up old mount points
for mount_point in proc sys dev run tmp; do
    umount_recursive "$ROOTFS/$mount_point"
done

# Start mounting
echo "Mounting /proc..."
mount -t proc proc "$ROOTFS/proc"

echo "Mounting /sys..."
mount -t sysfs sys "$ROOTFS/sys"

echo "Mounting /dev (devtmpfs)..."
mount -t devtmpfs devtmpfs "$ROOTFS/dev"

echo "Mounting /dev/pts..."
mount -t devpts devpts "$ROOTFS/dev/pts"

echo "Mounting /dev/shm..."
mount -t tmpfs shm "$ROOTFS/dev/shm" -o size=64m

echo "Mounting /run..."
mount -t tmpfs tmpfs "$ROOTFS/run" -o size=128m,mode=755

echo "Mounting /tmp..."
mount -t tmpfs tmpfs "$ROOTFS/tmp" -o size=256m,mode=1777

echo "Mounting cgroup subsystems..."
# Mount all cgroup subsystems
for subsystem in cpu cpuacct cpuset memory blkio devices freezer net_cls perf_event net_prio hugetlb pids rdma; do
    if [ -d "/sys/fs/cgroup/$subsystem" ]; then
        mkdir -p "$ROOTFS/sys/fs/cgroup/$subsystem"
        mount -t cgroup cgroup "$ROOTFS/sys/fs/cgroup/$subsystem" -o "$subsystem" 2>/dev/null || true
    fi
done

# 3. Bind mount important directories
echo "Bind mounting important directories..."

# Bind mount host device files
mount --bind /dev/null "$ROOTFS/dev/null" 2>/dev/null || true
mount --bind /dev/zero "$ROOTFS/dev/zero" 2>/dev/null || true
mount --bind /dev/random "$ROOTFS/dev/random" 2>/dev/null || true
mount --bind /dev/urandom "$ROOTFS/dev/urandom" 2>/dev/null || true

# Bind mount host network configuration (if needed)
if [ -d "/sys/class/net" ]; then
    mkdir -p "$ROOTFS/sys/class/net"
    mount --bind /sys/class/net "$ROOTFS/sys/class/net" 2>/dev/null || true
fi

# Bind mount host kernel modules
if [ -d "/lib/modules" ]; then
    mkdir -p "$ROOTFS/lib/modules"
    mount --bind /lib/modules "$ROOTFS/lib/modules" 2>/dev/null || true
fi

# 4. Create device files (fallback)
echo "Creating device files..."
mknod -m 666 "$ROOTFS/dev/null" c 1 3 2>/dev/null || true
mknod -m 666 "$ROOTFS/dev/zero" c 1 5 2>/dev/null || true
mknod -m 666 "$ROOTFS/dev/random" c 1 8 2>/dev/null || true
mknod -m 666 "$ROOTFS/dev/urandom" c 1 9 2>/dev/null || true
mknod -m 666 "$ROOTFS/dev/tty" c 5 0 2>/dev/null || true
mknod -m 622 "$ROOTFS/dev/console" c 5 1 2>/dev/null || true

# 5. Set up necessary system files
echo "Setting up system files..."

# Set machine ID (systemd needs)
if [ ! -f "$ROOTFS/etc/machine-id" ]; then
    dbus-uuidgen > "$ROOTFS/etc/machine-id" 2>/dev/null || echo "1234567890abcdef1234567890abcdef" > "$ROOTFS/etc/machine-id"
fi

# Set hostname
echo "chroot-ubuntu" > "$ROOTFS/etc/hostname" 2>/dev/null || true

# Set hosts file
cat > "$ROOTFS/etc/hosts" << 'EOF'
127.0.0.1   localhost localhost.localdomain
::1         localhost ip6-localhost ip6-loopback
EOF

# 6. Copy DNS configuration
echo "Copying DNS configuration..."
if [ -f /etc/resolv.conf ]; then
    cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf" 2>/dev/null || true
fi

# 7. Set timezone
echo "Setting timezone..."
if [ -f /etc/localtime ]; then
    cp /etc/localtime "$ROOTFS/etc/localtime" 2>/dev/null || true
fi

echo "Chroot environment setup complete!"
echo ""
echo "You can now enter the full chroot environment:"
echo "chroot $ROOTFS /bin/bash"
echo ""
echo "Mount status:"
mount | grep "$ROOTFS" | head -10