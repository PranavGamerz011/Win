#!/bin/bash

clear
echo "======================================"
echo "   Windows 10 Lite VPS Installer"
echo "======================================"

sleep 2

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# KVM check
if [ ! -e /dev/kvm ]; then
    echo ""
    echo "KVM virtualization is NOT enabled!"
    echo "Windows cannot run on this VPS."
    exit 1
fi

echo ""
echo "Installing Docker..."

apt update -y
apt install -y curl wget docker.io

systemctl enable docker
systemctl start docker

echo ""
echo "Preparing Windows files..."

mkdir -p /opt/win10
cd /opt/win10

echo ""
echo "Downloading Windows 10 Lite ISO..."

wget -O tiny10.iso \
https://archive.org/download/tiny-10-ntdev/tiny10.iso

echo ""
echo "Removing old Windows container..."

docker rm -f win10 2>/dev/null

echo ""
echo "Starting Windows 10 Lite..."

docker run -d \
--name win10 \
--device /dev/kvm \
-p 8006:8006 \
-p 3389:3389/tcp \
-v /opt/win10:/storage \
-e VERSION="10" \
-e RAM_SIZE="6G" \
-e CPU_CORES="2" \
-e DISK_SIZE="28G" \
-e USERNAME="admin" \
-e PASSWORD="admin123" \
--restart unless-stopped \
dockurr/windows

clear

echo "======================================"
echo " Windows 10 Lite is Starting"
echo "======================================"
echo ""
echo "Open Browser:"
echo "http://YOUR_VPS_IP:8006"
echo ""
echo "RDP:"
echo "YOUR_VPS_IP:3389"
echo ""
echo "Username: admin"
echo "Password: admin123"
echo ""
echo "Windows 10 Lite ISO downloaded automatically."
echo ""
