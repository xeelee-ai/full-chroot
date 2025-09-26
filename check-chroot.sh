#!/bin/bash
echo "Checking chroot environment integrity..."

echo "1. Filesystem mounts:"
mount | grep -E "(proc|sys|dev|run|tmp|cgroup)" | sort

echo ""
echo "2. Device files:"
ls -la /dev/{null,zero,random,urandom,tty,console} 2>/dev/null | head -10

echo ""
echo "3. Process info:"
ls -la /proc/self/ 2>/dev/null && echo "/proc available" || echo "/proc not available"

echo ""
echo "4. Network check:"
cat /etc/hosts
cat /etc/hostname 2>/dev/null || echo "No hostname file"

echo ""
echo "5. System info:"
uname -a
cat /etc/os-release 2>/dev/null || lsb_release -a 2>/dev/null || echo "Unable to get system info"

echo ""
echo "6. systemd check:"
if command -v systemctl >/dev/null 2>&1; then
    echo "systemctl command exists"
    systemctl --version 2>/dev/null | head -1 || echo "systemctl cannot run"
else
    echo "systemctl command does not exist"
fi