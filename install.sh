#!/bin/bash

clear
echo "======================================"
echo "   Windows 10 Tiny VPS Installer"
echo "======================================"

sleep 2

# Check KVM
if [ ! -e /dev/kvm ]; then
    echo ""
    echo "KVM not enabled on this VPS!"
    echo "Windows VM cannot run."
    exit 1
fi

echo ""
echo "Installing Docker..."
apt update -y
apt install -y curl wget docker.io

systemctl enable docker
systemctl start docker

echo ""
echo "Downloading Tiny10 ISO..."

mkdir -p /opt/win10
cd /opt/win10

wget -O tiny10.iso \
https://archive.org/download/tiny-10-23h2/tiny10.iso

echo ""
echo "Removing old container..."
docker rm -f win10 2>/dev/null

echo ""
echo "Starting Windows 10 Tiny..."

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
echo " Windows 10 Tiny Started Successfully"
echo "======================================"
echo ""
echo "Open in browser:"
echo "http://YOUR_VPS_IP:8006"
echo ""
echo "RDP:"
echo "YOUR_VPS_IP:3389"
echo ""
echo "Username: admin"
echo "Password: admin123"
echo ""
