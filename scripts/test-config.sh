#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Testing NixOS configuration..."

# Test flake
echo "📦 Checking flake..."
if nix flake check; then
    echo -e "${GREEN}✓ Flake check passed${NC}"
else
    echo -e "${RED}✗ Flake check failed${NC}"
    exit 1
fi

# Test NixOS configurations
echo "🔧 Building NixOS configurations..."
if nix build .#nixosConfigurations.default.config.system.build.toplevel; then
    echo -e "${GREEN}✓ Default NixOS configuration built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build default NixOS configuration${NC}"
    exit 1
fi

if nix build .#nixosConfigurations.workmachine.config.system.build.toplevel; then
    echo -e "${GREEN}✓ Work machine NixOS configuration built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build work machine NixOS configuration${NC}"
    exit 1
fi

# Test Home configurations
echo "🏠 Building Home configurations..."
if nix build .#homeConfigurations.default.activationPackage; then
    echo -e "${GREEN}✓ Default Home configuration built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build default Home configuration${NC}"
    exit 1
fi

if nix build .#homeConfigurations.mac.activationPackage; then
    echo -e "${GREEN}✓ Mac Home configuration built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build Mac Home configuration${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All tests passed!${NC}" 