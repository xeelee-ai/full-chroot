#!/bin/bash

ROOTFS="./ubuntu-base-24.04.3"

case "$1" in
    "start"|"enter")
        echo "Starting full chroot environment..."
        bash full-chroot.sh "$ROOTFS"
        bash enter-chroot.sh
        ;;
    "stop"|"cleanup")
        echo "Cleaning up chroot environment..."
        bash cleanup-chroot.sh
        ;;
    "status")
        echo "Chroot environment status:"
        mount | grep "$ROOTFS" | while read line; do
            echo "  $line"
        done
        ;;
    *)
        echo "Usage: $0 {start|enter|stop|cleanup|status}"
        echo ""
        echo "Commands:"
        echo "  start/enter - Enter full chroot environment"
        echo "  stop/cleanup - Clean up mount points"
        echo "  status      - View current mount status"
        ;;
esac