#!/bin/bash
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' 

# Enhanced welcome banner
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   🚀 CLOUD MASTERY SERIES 🚀                ║"
echo "║                                                              ║"
echo "║           📺 DR. ABHISHEK CLOUD TUTORIALS 📺                ║"
echo "║                                                              ║"
echo "║    🌐 YouTube: https://www.youtube.com/@kailash_parmar       ║"
echo "║    ⭐ Subscribe for Daily Cloud & DevOps Content ⭐         ║"
echo "║                                                              ║"
echo "║         💻 Google Cloud VM Network Tiers Demo 💻            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${MAGENTA}${BOLD}🎯 Learn: Premium vs Standard Network Tiers${NC}"
echo -e "${MAGENTA}${BOLD}🎯 Build: Hands-on Google Cloud Infrastructure${NC}"
echo -e "${MAGENTA}${BOLD}🎯 Master: Real-world Cloud Networking Concepts${NC}"
echo ""

export REGION="${ZONE%-*}"
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION
gcloud compute instances create vm-premium \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM

gcloud compute instances create vm-standard \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=STANDARD

# Completion banner
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   🎉 MISSION ACCOMPLISHED! 🎉               ║"
echo "║                                                              ║"
echo "║          ✅ Successfully Created 2 Google Cloud VMs          ║"
echo "║          ✅ Configured Different Network Tiers               ║"
echo "║          ✅ Hands-on Learning Complete                       ║"
echo "║                                                              ║"
echo "║    📺 Don't forget to like and subscribe on YouTube!         ║"
echo "║    🌐 https://www.youtube.com/@kailash_parmar                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
