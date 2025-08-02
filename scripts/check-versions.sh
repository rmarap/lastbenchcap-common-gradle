#!/bin/bash

# Script to check GitHub Packages versions and resolve conflicts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GITHUB_TOKEN environment variable is not set."
    echo "Please set it with: export GITHUB_TOKEN=your_github_token"
    exit 1
fi

# Get repository info from gradle.properties
if [ -f "gradle.properties" ]; then
    GITHUB_OWNER=$(grep "github.owner=" gradle.properties | cut -d'=' -f2)
    GITHUB_REPO=$(grep "github.repo=" gradle.properties | cut -d'=' -f2)
    CURRENT_VERSION=$(grep "library.version=" gradle.properties | cut -d'=' -f2)
else
    GITHUB_OWNER=$(grep "github.owner=" ../gradle.properties | cut -d'=' -f2)
    GITHUB_REPO=$(grep "github.repo=" ../gradle.properties | cut -d'=' -f2)
    CURRENT_VERSION=$(grep "library.version=" ../gradle.properties | cut -d'=' -f2)
fi

print_status "Repository: $GITHUB_OWNER/$GITHUB_REPO"
print_status "Current version in gradle.properties: $CURRENT_VERSION"

# Check if we can access the GitHub Packages API
print_status "Checking GitHub Packages API access..."

# Try to get package information
PACKAGE_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/user/packages/maven/com.lastbenchcap.lastbenchcap-common")

if echo "$PACKAGE_INFO" | grep -q "Bad credentials"; then
    print_error "Invalid GitHub token or insufficient permissions"
    exit 1
fi

if echo "$PACKAGE_INFO" | grep -q "Not Found"; then
    print_warning "Package not found. This might be the first publish."
    echo "Available versions: None (package doesn't exist yet)"
else
    print_success "Package found. Checking available versions..."
    
    # Get versions
    VERSIONS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/user/packages/maven/com.lastbenchcap.lastbenchcap-common/versions" | \
        jq -r '.[].name' 2>/dev/null || echo "Could not parse versions")
    
    if [ "$VERSIONS" = "Could not parse versions" ]; then
        print_warning "Could not parse version information. You may need to install jq."
        echo "Raw response:"
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/user/packages/maven/com.lastbenchcap.lastbenchcap-common/versions"
    else
        echo "Available versions:"
        echo "$VERSIONS" | sort -V
    fi
fi

# Check if current version already exists
if [ -n "$VERSIONS" ] && [ "$VERSIONS" != "Could not parse versions" ]; then
    if echo "$VERSIONS" | grep -q "^$CURRENT_VERSION$"; then
        print_warning "Version $CURRENT_VERSION already exists in GitHub Packages!"
        echo ""
        echo "To resolve this, you can:"
        echo "1. Increment the version in gradle.properties"
        echo "2. Delete the existing version from GitHub Packages (if needed)"
        echo "3. Use a different version number"
        echo ""
        echo "To increment the version, run:"
        echo "  ./publish-version.sh <new_version>"
        echo ""
        echo "Or manually update gradle.properties with a new version."
    else
        print_success "Version $CURRENT_VERSION does not exist in GitHub Packages."
    fi
fi

echo ""
print_status "To publish the current version, run:"
echo "  ./gradlew publish"
echo ""
print_status "To publish with a new version, run:"
echo "  ./publish-version.sh <new_version>" 