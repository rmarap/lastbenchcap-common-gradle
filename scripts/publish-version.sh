#!/bin/bash

# Publish LastBenchCap Common Library to GitHub Packages with Version Management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if version is provided
VERSION=${1:-}
if [ -z "$VERSION" ]; then
    print_error "Version is required!"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    echo "Example: $0 1.1.0-SNAPSHOT"
    exit 1
fi

# Validate version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-SNAPSHOT)?$ ]]; then
    print_error "Invalid version format: $VERSION"
    echo "Version should be in format: X.Y.Z or X.Y.Z-SNAPSHOT"
    exit 1
fi

print_status "Publishing version: $VERSION"

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GITHUB_TOKEN environment variable is not set."
    echo ""
    echo "To publish to GitHub Packages, you need to:"
    echo "1. Create a GitHub Personal Access Token with 'write:packages' permission"
    echo "2. Set the GITHUB_TOKEN environment variable:"
    echo "   export GITHUB_TOKEN=your_github_token"
    echo ""
    echo "You can also set it temporarily for this session:"
    echo "   GITHUB_TOKEN=your_token $0 $VERSION"
    exit 1
fi

print_success "GITHUB_TOKEN is set"

# Set up environment variables for GitHub Packages
export GPR_KEY=$GITHUB_TOKEN
export GPR_USER=lastbenchcap

# Update version in gradle.properties
print_status "Updating version to $VERSION in gradle.properties..."
if [ -f "gradle.properties" ]; then
    sed -i.bak "s/library.version=.*/library.version=$VERSION/" gradle.properties
    rm gradle.properties.bak
else
    sed -i.bak "s/library.version=.*/library.version=$VERSION/" ../gradle.properties
    rm ../gradle.properties.bak
fi

# Build the library
print_status "Building library..."
if [ -f "gradlew" ]; then
    ./gradlew clean build
else
    ../gradlew clean build
fi

if [ $? -ne 0 ]; then
    print_error "Build failed!"
    exit 1
fi

print_success "Build completed successfully"

# Publish to GitHub Packages
print_status "Publishing to GitHub Packages..."
if [ -f "gradlew" ]; then
    ./gradlew publish
else
    ../gradlew publish
fi

if [ $? -eq 0 ]; then
    print_success "Successfully published version $VERSION to GitHub Packages!"
    echo ""
    echo "The library is now available at:"
    echo "https://maven.pkg.github.com/lastbenchcap/lastbenchcap-common"
    echo ""
    echo "You can now use it in other projects by adding:"
    echo ""
    echo "repositories {"
    echo "    maven {"
    echo "        url = uri(\"https://maven.pkg.github.com/lastbenchcap/lastbenchcap-common\")"
    echo "        credentials {"
    echo "            username = project.findProperty(\"gpr.user\") ?: System.getenv(\"GITHUB_USERNAME\")"
    echo "            password = project.findProperty(\"gpr.key\") ?: System.getenv(\"GITHUB_TOKEN\")"
    echo "        }"
    echo "    }"
    echo "}"
    echo ""
    echo "And the dependency:"
    echo "implementation 'com.lastbenchcap:lastbenchcap-common:$VERSION'"
    echo ""
    
    # Create git tag for release versions
    if [[ ! $VERSION =~ SNAPSHOT$ ]]; then
        print_status "Creating git tag for version $VERSION..."
        git tag -a "v$VERSION" -m "Release version $VERSION"
        print_success "Git tag v$VERSION created"
        echo "To push the tag: git push origin v$VERSION"
    fi
else
    print_error "Failed to publish to GitHub Packages"
    exit 1
fi 