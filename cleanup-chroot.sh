#!/bin/bash
set -e

# Check if ROOTFS is set as environment variable, otherwise use default
if [ -z "$ROOTFS" ]; then
    ROOTFS="./ubuntu-base-24.04.3"
fi

if [ "$EUID" -ne 0 ]; then
    echo "Root privileges required"
    exec sudo ROOTFS="$ROOTFS" bash "$0" "$@"
    exit
fi

echo "Cleaning up chroot environment at $ROOTFS..."

# Unmount filesystems in order (to avoid dependency issues)
for mount_point in \
    "$ROOTFS/sys/fs/cgroup/"* \
    "$ROOTFS/dev/shm" \
    "$ROOTFS/dev/pts" \
    "$ROOTFS/dev" \
    "$ROOTFS/sys" \
    "$ROOTFS/proc" \
    "$ROOTFS/run" \
    "$ROOTFS/tmp" \
    "$ROOTFS/sys/class/net" \
    "$ROOTFS/lib/modules"; do
    
    if mountpoint -q "$mount_point" 2>/dev/null; then
        echo "Unmounting $mount_point"
        umount -l "$mount_point" 2>/dev/null || true
    fi
done

# Clean up bind mounts
for bind_mount in \
    "$ROOTFS/dev/null" \
    "$ROOTFS/dev/zero" \
    "$ROOTFS/dev/random" \
    "$ROOTFS/dev/urandom"; do
    
    if mountpoint -q "$bind_mount" 2>/dev/null; then
        echo "Unmounting bind $bind_mount"
        umount -l "$bind_mount" 2>/dev/null || true
    fi
done

echo "Cleanup complete!"