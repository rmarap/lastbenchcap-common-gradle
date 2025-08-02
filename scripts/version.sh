#!/bin/bash

# Version Management Script for LastBenchCap Common Library

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

# Function to get current version
get_current_version() {
    grep "library.version=" gradle.properties | cut -d'=' -f2
}

# Function to update version
update_version() {
    local new_version=$1
    sed -i.bak "s/library.version=.*/library.version=$new_version/" gradle.properties
    rm gradle.properties.bak
    print_success "Version updated to $new_version"
}

# Function to show current version
show_version() {
    local current_version=$(get_current_version)
    echo "Current version: $current_version"
}

# Function to bump version
bump_version() {
    local current_version=$(get_current_version)
    local bump_type=$1
    
    if [ -z "$bump_type" ]; then
        print_error "Bump type required: major, minor, or patch"
        echo "Usage: $0 bump <major|minor|patch>"
        exit 1
    fi
    
    # Parse current version
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid bump type: $bump_type"
            echo "Valid types: major, minor, patch"
            exit 1
            ;;
    esac
    
    local new_version="$major.$minor.$patch"
    update_version "$new_version"
    print_success "Version bumped to $new_version"
}

# Function to set snapshot version
set_snapshot() {
    local base_version=$1
    if [ -z "$base_version" ]; then
        print_error "Base version required"
        echo "Usage: $0 snapshot <base-version>"
        echo "Example: $0 snapshot 1.0.0"
        exit 1
    fi
    
    local snapshot_version="$base_version-SNAPSHOT"
    update_version "$snapshot_version"
    print_success "Snapshot version set to $snapshot_version"
}

# Function to set release version
set_release() {
    local version=$1
    if [ -z "$version" ]; then
        print_error "Version required"
        echo "Usage: $0 release <version>"
        echo "Example: $0 release 1.0.0"
        exit 1
    fi
    
    # Remove SNAPSHOT if present
    local release_version=${version%-SNAPSHOT}
    update_version "$release_version"
    print_success "Release version set to $release_version"
}

# Main script logic
case "${1:-}" in
    show)
        show_version
        ;;
    bump)
        bump_version "$2"
        ;;
    snapshot)
        set_snapshot "$2"
        ;;
    release)
        set_release "$2"
        ;;
    set)
        if [ -z "$2" ]; then
            print_error "Version required"
            echo "Usage: $0 set <version>"
            exit 1
        fi
        update_version "$2"
        ;;
    *)
        echo "LastBenchCap Common Library Version Manager"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  show                    Show current version"
        echo "  bump <major|minor|patch> Bump version by type"
        echo "  snapshot <version>      Set snapshot version (e.g., 1.0.0-SNAPSHOT)"
        echo "  release <version>       Set release version (removes SNAPSHOT)"
        echo "  set <version>           Set specific version"
        echo ""
        echo "Examples:"
        echo "  $0 show"
        echo "  $0 bump patch"
        echo "  $0 snapshot 1.1.0"
        echo "  $0 release 1.0.0-SNAPSHOT"
        echo "  $0 set 2.0.0"
        echo ""
        echo "Current version: $(get_current_version)"
        exit 1
        ;;
esac 