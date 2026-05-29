#!/bin/bash

clear

# RGB Gradient Function
print_gradient() {
  colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 51 45 39 33 27 21 57 93 129 165 201)

  text=(
"            .     .       ."
"         .       🌙        ."
"      .      .       .        ."
""
"     ██╗     ██╗   ██╗███╗   ██╗ █████╗ ██████╗ "
"     ██║     ██║   ██║████╗  ██║██╔══██╗██╔══██╗"
"     ██║     ██║   ██║██╔██╗ ██║███████║██████╔╝"
"     ██║     ██║   ██║██║╚██╗██║██╔══██║██╔══██╗"
"     ███████╗╚██████╔╝██║ ╚████║██║  ██║██║  ██║"
"     ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝"
""
"        🌙  L U N A R   P A N E L  🌙"
"=========================================="
  )

  for i in "${!text[@]}"; do
    color=${colors[$((i % ${#colors[@]}))]}
    echo -e "\e[38;5;${color}m${text[$i]}\e[0m"
  done
}

# Show banner
print_gradient

# Colors for logs
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Error check
check() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error occurred! Exiting...${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}[1/12] Updating system...${NC}"
apt update && apt upgrade -y
check

echo -e "${YELLOW}[2/12] Installing OpenJDK 21...${NC}"
apt install openjdk-21-jdk -y
check

echo -e "${YELLOW}[3/12] Installing Node.js 23...${NC}"
curl -sL https://deb.nodesource.com/setup_23.x | bash -
apt install nodejs -y
check

echo -e "${YELLOW}[4/12] Installing Git...${NC}"
apt install git -y
check

echo -e "${YELLOW}[5/12] Cloning MCPANEL repo...${NC}"
git clone https://github.com/notpieyt011-ui/mcpanel
check

cd mcpanel || { echo -e "${RED}Failed to enter mcpanel folder${NC}"; exit 1; }

echo -e "${YELLOW}[6/12] Installing unzip...${NC}"
apt install unzip -y
check

echo -e "${YELLOW}[7/12] Extracting files...${NC}"
unzip mcpanel.zip
check

cd panel || { echo -e "${RED}Panel folder not found${NC}"; exit 1; }

echo -e "${YELLOW}[8/12] Installing npm dependencies...${NC}"
npm i
check

echo -e "${YELLOW}[9/12] Installing PM2...${NC}"
npm install pm2@latest -g
check

echo -e "${YELLOW}[10/12] Starting panel with PM2...${NC}"
pm2 start app.js
check

echo -e "${YELLOW}[11/12] Enabling startup...${NC}"
pm2 startup
pm2 save

echo -e "${GREEN}"
echo "=========================================="
echo "   ✅ LUNAR PANEL INSTALLED & RUNNING 🌙  "
echo "=========================================="
echo -e "${NC}"

echo -e "${CYAN}Use 'pm2 list' to check status${NC}"
echo -e "${CYAN}Use 'pm2 logs' to view logs${NC}"

# Important Section
echo -e "\033[1;33m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  IMPORTANT SETUP REQUIRED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\033[0m"

echo -e "\033[1;36m➤ INSTALL CLOUDFLARE AND SETUP\033[0m"
echo -e "\033[1;36m➤ PANEL URL: http://localhost:3000\033[0m"

echo ""
echo -e "\033[1;31m━━━━━━━━━━━━━━ NOTE ⚠️ ━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;33m➤ ADMIN USER : admin\033[0m"
echo -e "\033[1;33m➤ ADMIN PASS : admin123\033[0m"
echo -e "\033[1;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo ""
echo -e "\033[1;36mUse 'pm2 list' to check status\033[0m"
echo -e "\033[1;36mUse 'pm2 logs' to view logs\033[0m"