#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TARGET="default"
DRY_RUN=false
SHOW_TRACE=false

# Help message
usage() {
    echo "Usage: $0 [-t TARGET] [-d] [-s] [-h]"
    echo
    echo "Options:"
    echo "  -t TARGET   Target configuration to deploy (default, workmachine)"
    echo "  -d         Perform a dry run (show what would be done)"
    echo "  -s         Show trace for better error reporting"
    echo "  -h         Show this help message"
    exit 1
}

# Parse command line arguments
while getopts "t:dsh" opt; do
    case $opt in
        t) TARGET="$OPTARG" ;;
        d) DRY_RUN=true ;;
        s) SHOW_TRACE=true ;;
        h) usage ;;
        \?) usage ;;
    esac
done

# Validate target
if [[ ! "$TARGET" =~ ^(default|workmachine)$ ]]; then
    echo -e "${RED}Error: Invalid target '$TARGET'. Must be 'default' or 'workmachine'${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Deploying NixOS configuration for target: ${TARGET}${NC}"

# Run pre-deployment checks
echo -e "${BLUE}📋 Running pre-deployment checks...${NC}"

# Check if we're on NixOS
if ! grep -q "ID=nixos" /etc/os-release 2>/dev/null; then
    echo -e "${RED}Error: This script must be run on NixOS${NC}"
    exit 1
fi

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root or with sudo${NC}"
    exit 1
fi

# Build command
CMD="nixos-rebuild switch --flake .#${TARGET}"

# Add options
if [[ "$DRY_RUN" == true ]]; then
    CMD+=" --dry-run"
    echo -e "${YELLOW}⚠ Performing dry run${NC}"
fi

if [[ "$SHOW_TRACE" == true ]]; then
    CMD+=" --show-trace"
fi

# Run the deployment
echo -e "${BLUE}🔧 Running deployment...${NC}"
echo -e "${YELLOW}Executing: $CMD${NC}"

if eval "$CMD"; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    
    # Show current system generation
    echo -e "${BLUE}📊 System generation info:${NC}"
    nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 1
    
    if [[ "$DRY_RUN" == false ]]; then
        echo -e "${GREEN}🔄 System is ready for reboot if needed${NC}"
    fi
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi 