#!/bin/bash
set -e

ROOTFS="./ubuntu-base-24.04.3"

if [ "$EUID" -ne 0 ]; then
    echo "Root privileges required"
    exec sudo bash "$0" "$@"
    exit
fi

# Run full mount first
echo "Preparing chroot environment..."
bash full-chroot.sh "$ROOTFS"

echo "Entering chroot environment..."
echo "========================================"

# Set environment variables
export container=chroot
export SYSTEMD_IGNORE_CHROOT=0

# Enter chroot (maximum compatibility)
chroot "$ROOTFS" /bin/bash -c "
    # Set terminal
    export TERM=xterm-256color
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    
    # Set language
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    
    # Initialize environment
    source /etc/profile
    source ~/.bashrc 2>/dev/null || true
    
    # Change to root directory
    cd /
    
    # Check system status
    echo 'System status check:'
    echo '- Current directory: \$(pwd)'
    echo '- Process ID: \$\$'
    echo '- User: \$(whoami)'
    echo ''
    echo 'Mount points check:'
    mount | grep -E '(proc|sys|dev|run|tmp)' | head -5
    echo ''
    echo 'Distribution info:'
    lsb_release -a 2>/dev/null || cat /etc/os-release 2>/dev/null || echo 'Unable to get system info'
    echo ''
    echo 'Starting interactive shell...'
    echo '========================================'
    
    # Start interactive shell
    exec /bin/bash --login
"