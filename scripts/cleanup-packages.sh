#!/bin/bash

# =============================================================================
# GITHUB PACKAGES CLEANUP SCRIPT
# =============================================================================
# This script helps clean up existing GitHub packages that might be causing conflicts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_OWNER=${GITHUB_OWNER:-$(grep "github.owner=" gradle.properties | cut -d'=' -f2)}
GITHUB_REPO=${GITHUB_REPO:-$(grep "github.repo=" gradle.properties | cut -d'=' -f2)}
GITHUB_TOKEN=${GITHUB_TOKEN:-$GITHUB_TOKEN}

echo -e "${YELLOW}GitHub Packages Cleanup Script${NC}"
echo "=================================="
echo "Owner: $GITHUB_OWNER"
echo "Repository: $GITHUB_REPO"
echo ""

# Check if GitHub token is available
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN environment variable is required${NC}"
    echo "Please set your GitHub token:"
    echo "export GITHUB_TOKEN=your_github_token"
    exit 1
fi

# Function to list packages
list_packages() {
    echo -e "${YELLOW}Listing existing packages...${NC}"
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         "https://api.github.com/user/packages?package_type=maven" | \
    jq -r '.[] | select(.repository.name == "'$GITHUB_REPO'") | .name'
}

# Function to delete a package
delete_package() {
    local package_name=$1
    echo -e "${YELLOW}Deleting package: $package_name${NC}"
    
    # Get package versions
    local versions=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/user/packages/maven/$package_name/versions" | \
        jq -r '.[].id')
    
    # Delete each version
    for version_id in $versions; do
        echo "  Deleting version ID: $version_id"
        curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
             "https://api.github.com/user/packages/maven/$package_name/versions/$version_id"
    done
    
    echo -e "${GREEN}Package $package_name deleted${NC}"
}

# Main script
echo -e "${YELLOW}This script will help clean up conflicting GitHub packages.${NC}"
echo ""

# List existing packages
packages=$(list_packages)
if [ -z "$packages" ]; then
    echo -e "${GREEN}No packages found for this repository${NC}"
    exit 0
fi

echo -e "${YELLOW}Found the following packages:${NC}"
echo "$packages"
echo ""

# Ask user which packages to delete
echo -e "${YELLOW}Which packages would you like to delete?${NC}"
echo "Enter package names separated by spaces, or 'all' to delete all:"
read -r package_list

if [ "$package_list" = "all" ]; then
    echo -e "${YELLOW}Deleting all packages...${NC}"
    for package in $packages; do
        delete_package "$package"
    done
else
    for package in $package_list; do
        if echo "$packages" | grep -q "^$package$"; then
            delete_package "$package"
        else
            echo -e "${RED}Package '$package' not found${NC}"
        fi
    done
fi

echo -e "${GREEN}Cleanup completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update your gradle.properties with the correct artifactId"
echo "2. Run: ./gradlew clean build"
echo "3. Run: ./gradlew publish" 