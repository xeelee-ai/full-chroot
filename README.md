# Full Chroot Environment Setup

This project provides a complete chroot environment setup with maximum compatibility for running system services including systemd.

## Scripts Overview

1. `full-chroot.sh` - Sets up all necessary mounts and device files for a complete chroot environment
2. `enter-chroot.sh` - Enters the chroot environment with proper environment variables
3. `cleanup-chroot.sh` - Cleans up all mounts created by the setup script
4. `chroot-manager.sh` - A unified interface to manage the chroot environment
5. `check-chroot.sh` - Verification script to check the integrity of the chroot environment

## Usage

### Quick Start

```bash
# Make all scripts executable
chmod +x *.sh

# Enter the full chroot environment
./chroot-manager.sh start

# Or step by step
sudo bash full-chroot.sh ./ubuntu-base-24.04.3
sudo chroot ./ubuntu-base-24.04.3 /bin/bash

# Clean up after exiting
./chroot-manager.sh stop
```

### Individual Script Usage

1. **Setting up the environment:**
   ```bash
   sudo bash full-chroot.sh ./ubuntu-base-24.04.3
   ```

2. **Entering the environment:**
   ```bash
   sudo bash enter-chroot.sh
   ```

3. **Cleaning up:**
   ```bash
   sudo bash cleanup-chroot.sh
   ```

4. **Checking status:**
   ```bash
   ./chroot-manager.sh status
   ```

## Features

- Mounts all essential filesystems (proc, sys, dev, run, tmp)
- Sets up cgroup subsystems for systemd compatibility
- Binds host device files for proper functionality
- Creates necessary device nodes as fallback
- Configures DNS, hostname, and timezone
- Sets proper environment variables for chroot
- Includes cleanup functionality to unmount everything

## Verification

After entering the chroot environment, run the check script to verify integrity:

```bash
bash check-chroot.sh
```

This will verify:
- Filesystem mounts
- Device files
- Process information
- Network configuration
- System information
- systemd compatibility

## Requirements

- Root privileges
- A valid root filesystem (e.g., extracted Ubuntu base image)
- Standard Linux utilities (mount, umount, mknod, etc.)

## Notes

- All scripts should be run from the directory containing the root filesystem
- The default root filesystem path is `./ubuntu-base-24.04.3` but can be modified in the scripts
- The environment is designed to be as close to a real system as possible