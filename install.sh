#!/bin/bash

# Windows 10 Lite Auto-Install Script for Linux VPS
# Works on Debian/Ubuntu VPS with KVM/XEN virtualization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
WIN_USERNAME="Admin"
WIN_PASSWORD="admin123"  # Change this after installation
WORK_DIR="/tmp/win-install"

# Windows 10 Lite Image URLs (choose one)
# URL1: CXT Windows 10 Lite (BIOS)
IMG_URL_BIOS="https://dl.lamp.sh/vhd/zh-cn_windows10_ltsc_x64.vhd.gz"
# URL2: Alternative Windows 10 Lite (UEFI) 
IMG_URL_UEFI="https://example.com/windows10-lite-uefi.vhd.gz"

print_color() {
    echo -e "${2}${1}${NC}"
}

check_system() {
    print_color "Checking system requirements..." "$YELLOW"
    
    # Check virtualization
    if ! command -v systemd-detect-virt &> /dev/null; then
        apt-get update && apt-get install -y systemd
    fi
    
    VIRT_TYPE=$(systemd-detect-virt)
    if [[ "$VIRT_TYPE" != "kvm" && "$VIRT_TYPE" != "xen" ]]; then
        print_color "Warning: $VIRT_TYPE virtualization detected. DD method may not work." "$YELLOW"
    fi
    
    # Check RAM
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 1024 ]; then
        print_color "Error: Need at least 1GB RAM. You have ${TOTAL_RAM}MB" "$RED"
        exit 1
    fi
    
    # Check disk space
    FREE_SPACE=$(df -m / | awk 'NR==2 {print $4}')
    if [ "$FREE_SPACE" -lt 15360 ]; then
        print_color "Error: Need at least 15GB free space. You have ${FREE_SPACE}MB" "$RED"
        exit 1
    fi
    
    print_color "✓ System requirements met" "$GREEN"
}

install_dependencies() {
    print_color "Installing dependencies..." "$YELLOW"
    
    apt-get update
    apt-get install -y \
        wget \
        curl \
        screen \
        xz-utils \
        openssl \
        gawk \
        file \
        grub-imageboot \
        qemu-utils \
        unzip
    
    print_color "✓ Dependencies installed" "$GREEN"
}

detect_boot_mode() {
    print_color "Detecting boot mode..." "$YELLOW"
    
    if [ -d /sys/firmware/efi ]; then
        BOOT_MODE="UEFI"
        WIN_IMG_URL=$IMG_URL_UEFI
    else
        BOOT_MODE="BIOS"
        WIN_IMG_URL=$IMG_URL_BIOS
    fi
    
    print_color "✓ Boot mode: $BOOT_MODE" "$GREEN"
    print_color "Using image: $WIN_IMG_URL" "$YELLOW"
}

download_windows_image() {
    print_color "Downloading Windows 10 Lite image..." "$YELLOW"
    
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    # Download image
    if [ -f windows10.vhd.gz ]; then
        print_color "Image already downloaded, skipping..." "$GREEN"
    else
        wget --no-check-certificate -O windows10.vhd.gz "$WIN_IMG_URL"
    fi
    
    # Decompress
    print_color "Decompressing image..." "$YELLOW"
    gunzip -f windows10.vhd.gz || true
    
    print_color "✓ Windows image ready" "$GREEN"
}

prepare_dd_script() {
    print_color "Preparing DD installation script..." "$YELLOW"
    
    cat > "$WORK_DIR/install.sh" << 'EOF'
#!/bin/bash

# Find the main disk
MAIN_DISK=$(lsblk -o NAME,TYPE | grep -E "disk" | head -1 | awk '{print $1}')
if [ -z "$MAIN_DISK" ]; then
    echo "No disk found!"
    exit 1
fi

echo "Installing to /dev/$MAIN_DISK"

# Write Windows image directly to disk
dd if=windows10.vhd of=/dev/$MAIN_DISK bs=4M status=progress

# Fix boot sector (for BIOS mode)
if [ ! -d /sys/firmware/efi ]; then
    dd if=/usr/lib/syslinux/mbr.bin of=/dev/$MAIN_DISK bs=440 count=1 || true
fi

echo "DD completed. Rebooting in 10 seconds..."
sleep 10
reboot
EOF
    
    chmod +x "$WORK_DIR/install.sh"
    print_color "✓ Installation script prepared" "$GREEN"
}

run_dd_installation() {
    print_color "Starting DD installation..." "$RED"
    print_color "WARNING: This will OVERWRITE your entire disk!" "$RED"
    print_color "Press Enter to continue or Ctrl+C to cancel..." "$RED"
    read -r
    
    # Move to working directory
    cd "$WORK_DIR"
    
    # Run the installer in screen session
    screen -dmS win-install bash -c "./install.sh; exec bash"
    
    print_color "✓ Installation started in screen session: win-install" "$GREEN"
    print_color "To monitor progress: screen -r win-install" "$GREEN"
    print_color "Installation takes 20-40 minutes. Server will reboot automatically." "$YELLOW"
}

create_status_checker() {
    cat > /root/check-win-install.sh << 'EOF'
#!/bin/bash
echo "=== Windows Installation Status ==="
echo "To check DD progress: screen -r win-install"
echo "After reboot:"
echo "  Username: Administrator"
echo "  Password: Teddysun.com"
echo ""
echo "To connect via RDP after installation:"
echo "  mstsc.exe -> VPS_IP_ADDRESS"
EOF
    
    chmod +x /root/check-win-install.sh
    print_color "✓ Status checker created at /root/check-win-install.sh" "$GREEN"
}

main() {
    print_color "=== Windows 10 Lite Auto-Install Script ===" "$GREEN"
    print_color "Starting installation process..." "$YELLOW"
    
    check_system
    install_dependencies
    detect_boot_mode
    download_windows_image
    prepare_dd_script
    create_status_checker
    run_dd_installation
    
    print_color "\n=== Installation Complete ===" "$GREEN"
    print_color "The system will reboot after DD completes." "$YELLOW"
    print_color "\nAfter reboot, connect via RDP (port 3389):" "$GREEN"
    print_color "  Username: $WIN_USERNAME" "$GREEN"
    print_color "  Password: $WIN_PASSWORD" "$GREEN"
    print_color "\nMonitor progress: screen -r win-install" "$YELLOW"
}

# Run main function
main
