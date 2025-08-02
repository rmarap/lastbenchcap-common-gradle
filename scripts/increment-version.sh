#!/bin/bash

# Script to increment version and resolve 409 conflicts

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

# Check if increment type is provided
INCREMENT_TYPE=${1:-patch}
if [[ ! "$INCREMENT_TYPE" =~ ^(major|minor|patch)$ ]]; then
    print_error "Invalid increment type: $INCREMENT_TYPE"
    echo "Usage: $0 [major|minor|patch]"
    echo "Default: patch"
    exit 1
fi

print_status "Incrementing version by $INCREMENT_TYPE"

# Get current version
CURRENT_VERSION=$(grep "library.version=" gradle.properties | cut -d'=' -f2)
print_status "Current version: $CURRENT_VERSION"

# Parse version parts
IFS='.' read -ra VERSION_PARTS <<< "${CURRENT_VERSION%-SNAPSHOT}"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Increment based on type
case $INCREMENT_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
print_status "New version: $NEW_VERSION"

# Update gradle.properties
sed -i.bak "s/library.version=.*/library.version=$NEW_VERSION/" gradle.properties
rm gradle.properties.bak

print_success "Updated gradle.properties to version $NEW_VERSION"

# Show the change
echo ""
print_status "Version change:"
echo "  $CURRENT_VERSION → $NEW_VERSION"

# Commit the change
print_status "Committing version change..."
git add gradle.properties
git commit -m "Bump version to $NEW_VERSION [skip ci]"

print_success "Version incremented and committed successfully!"
echo ""
echo "Next steps:"
echo "1. Push the changes: git push"
echo "2. The GitHub Actions workflow will automatically publish the new version"
echo "3. Or publish manually: ./gradlew publish" 