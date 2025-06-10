#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================"
echo -e " Debian Hardware Check Report"
echo -e "============================${NC}"
echo -e "Generated on: $(date)"
echo -e "Hostname: $(hostname)\n"

echo -e "${YELLOW}>> Step 1: Checking kernel messages for missing firmware...${NC}\n"
dmesg | grep -i firmware | grep -E "failed|missing|error" --color=always || echo -e "${GREEN}✔ No firmware errors found in dmesg${NC}"

echo -e "\n${YELLOW}>> Step 2: Listing PCI devices and associated drivers...${NC}\n"
lspci -nnk | grep -A3 '^[0-9a-f]' | grep -E 'Kernel driver|Kernel modules|^' --color=never

echo -e "\n${YELLOW}>> Step 3: Listing USB devices...${NC}\n"
lsusb

echo -e "\n${YELLOW}>> Step 4: Checking for unclaimed hardware (no driver)...${NC}\n"
lshw -short 2>/dev/null | grep -i unclaimed && echo -e "${RED}⚠ Found unclaimed devices${NC}" || echo -e "${GREEN}✔ All hardware claimed successfully${NC}"

echo -e "\n${YELLOW}>> Step 5: Checking installed firmware packages...${NC}\n"
dpkg -l | grep firmware || echo -e "${RED}⚠ No firmware packages installed${NC}"

echo -e "\n${YELLOW}>> Step 6: Network interfaces detected...${NC}\n"
ip link show | grep -E '^[0-9]+:' --color=never

echo -e "\n${YELLOW}>> Step 7: Summary of loaded kernel modules...${NC}\n"
lsmod | sort | head -20

echo -e "\n${CYAN}============================"
echo -e " Report Complete"
echo -e "============================${NC}"

# Optional: Save to file
echo ""
read -p "Save this report to ~/hardware-report.txt (without colors)? [y/N] " choice
if [[ "$choice" == [yY] ]]; then
  ./check-hardware-color.sh > ~/hardware-report.txt
  echo -e "${GREEN}✔ Report saved to ~/hardware-report.txt${NC}"
fi
