#!/bin/bash

# Default root filesystem path
DEFAULT_ROOTFS="../root_fs"
ROOTFS="$DEFAULT_ROOTFS"

# Check if a custom rootfs path was provided
if [ -n "$2" ]; then
    ROOTFS="$2"
fi

# Function to download and extract Ubuntu base image
setup_rootfs() {
    if [ ! -d "$ROOTFS" ]; then
        echo "Root filesystem directory $ROOTFS does not exist. Creating and downloading Ubuntu base image..."
        mkdir -p "$ROOTFS"
        
        # Download Ubuntu base image
        UBUNTU_BASE_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/24.04.3/release/ubuntu-base-24.04.3-base-arm64.tar.gz"
        TEMP_FILE="/tmp/ubuntu-base-24.04.3-base-arm64.tar.gz"
        
        echo "Downloading Ubuntu base image from $UBUNTU_BASE_URL..."
        if command -v wget >/dev/null 2>&1; then
            wget "$UBUNTU_BASE_URL" -O "$TEMP_FILE"
        elif command -v curl >/dev/null 2>&1; then
            curl -L "$UBUNTU_BASE_URL" -o "$TEMP_FILE"
        else
            echo "Error: Neither wget nor curl is available for downloading the base image."
            exit 1
        fi
        
        # Extract the base image
        echo "Extracting Ubuntu base image to $ROOTFS..."
        tar -xzf "$TEMP_FILE" -C "$ROOTFS"
        
        # Clean up temporary file
        rm "$TEMP_FILE"
        
        echo "Ubuntu base image successfully installed to $ROOTFS"
    else
        echo "Using existing root filesystem at $ROOTFS"
    fi
}

case "$1" in
    "start"|"enter")
        echo "Starting full chroot environment at $ROOTFS..."
        setup_rootfs
        # Pass the rootfs path to the other scripts
        ROOTFS="$ROOTFS" bash full-chroot.sh "$ROOTFS"
        ROOTFS="$ROOTFS" bash enter-chroot.sh
        ;;
    "stop"|"cleanup")
        echo "Cleaning up chroot environment at $ROOTFS..."
        ROOTFS="$ROOTFS" bash cleanup-chroot.sh
        ;;
    "status")
        echo "Chroot environment status for $ROOTFS:"
        mount | grep "$ROOTFS" | while read line; do
            echo "  $line"
        done
        ;;
    *)
        echo "Usage: $0 {start|enter|stop|cleanup|status} [rootfs_path]"
        echo ""
        echo "Commands:"
        echo "  start/enter - Enter full chroot environment"
        echo "  stop/cleanup - Clean up mount points"
        echo "  status      - View current mount status"
        echo ""
        echo "If rootfs_path is not specified, $DEFAULT_ROOTFS will be used."
        echo "If the rootfs directory doesn't exist, it will be created and populated"
        echo "with the Ubuntu 24.04.3 base image automatically."
        ;;
esac