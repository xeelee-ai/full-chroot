# Project Context: Full Chroot Environment Setup

## Project Overview

This project provides a complete chroot environment setup with maximum compatibility for running system services including systemd. It creates an isolated Linux environment that closely mimics a real system, allowing you to run services and applications in a contained space.

## Key Components

1. **full-chroot.sh** - Sets up all necessary mounts and device files for a complete chroot environment
2. **enter-chroot.sh** - Enters the chroot environment with proper environment variables
3. **cleanup-chroot.sh** - Cleans up all mounts created by the setup script
4. **chroot-manager.sh** - A unified interface to manage the chroot environment
5. **check-chroot.sh** - Verification script to check the integrity of the chroot environment

## Usage Patterns

### Quick Start
```bash
# Make all scripts executable
chmod +x *.sh

# Enter the full chroot environment (will create ../root_fs if needed)
./chroot-manager.sh start

# Or specify a custom root filesystem path
./chroot-manager.sh start /path/to/custom/rootfs

# Clean up after exiting
./chroot-manager.sh stop
```

### Individual Script Usage

1. **Setting up the environment:**
   ```bash
   sudo bash full-chroot.sh /path/to/rootfs
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
- Automatically downloads and extracts Ubuntu base image if needed
- Shows chroot status in terminal prompt

## Automatic Root Filesystem Setup

When using `chroot-manager.sh start`, if the specified root filesystem directory doesn't exist:
1. It will be automatically created
2. The Ubuntu 24.04.3 base image will be downloaded from the official repository
3. The image will be extracted to the root filesystem directory

If no root filesystem path is specified, `../root_fs` will be used by default.

## Chroot Prompt

When inside the chroot environment, the terminal prompt will show `(chroot)` to clearly indicate that you're in a chroot environment, similar to how conda environments show the environment name.

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
- Standard Linux utilities (mount, umount, mknod, etc.)
- wget or curl for downloading the base image
- tar for extracting the base image

## Notes

- All scripts should be run from the directory containing these scripts
- The environment is designed to be as close to a real system as possible
- When exiting the chroot environment, always run the cleanup script to properly unmount filesystems

## Development Conventions

- Shell scripts follow standard bash practices
- Error handling is implemented with `set -e`
- Scripts automatically request sudo privileges if not run as root
- Cleanup functions properly unmount filesystems in the correct order
- Scripts provide informative output to guide users through the process
- Environment variables are used to pass configuration between scripts
- Scripts are designed to work with customizable root filesystem paths

## Common Tasks

When working with this chroot environment, you'll typically:

1. Set up the environment with `chroot-manager.sh start` (which automatically handles downloading the base image if needed)
2. Work within the chroot environment (the prompt will show `(chroot)` to indicate the environment)
3. Exit the chroot environment
4. Clean up with `chroot-manager.sh stop`

## Troubleshooting

If you encounter issues:
1. Check that you have root privileges
2. Verify the root filesystem exists at the expected path
3. Run `check-chroot.sh` to verify environment integrity
4. Use `chroot-manager.sh status` to check mount status
5. Clean up and restart if needed

Always ensure proper cleanup to avoid leaving mounted filesystems.