#!/bin/bash

# =============================================================================
# SETUP GRADLE PLUGIN SCRIPT
# =============================================================================
# This script helps set up and use the LastBenchCap Common Gradle Plugin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
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

show_usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build        Build the plugin"
    echo "  publish      Publish the plugin to GitHub Packages"
    echo "  test         Test the plugin"
    echo "  setup-lib    Set up a new library to use this plugin"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 publish"
    echo "  $0 setup-lib ../my-new-library"
}

# Check if we're in the plugin directory
if [[ ! -f "build.gradle" ]] || [[ ! -f "settings.gradle" ]]; then
    print_error "Please run this script from the plugin directory"
    print_error "Expected: /Users/rammarappan/Projects/spikes-2025/com.lastbenchcap.common.gradle"
    exit 1
fi

case "${1:-help}" in
    build)
        print_info "Building the plugin..."
        ./gradlew build
        print_success "Plugin built successfully!"
        ;;
    publish)
        print_info "Publishing the plugin to GitHub Packages..."
        ./gradlew publish
        print_success "Plugin published successfully!"
        print_info "You can now use it in other projects with:"
        print_info "  id 'com.lastbenchcap.common.gradle.library' version '1.0.0'"
        ;;
    test)
        print_info "Testing the plugin..."
        ./gradlew test
        print_success "Plugin tests passed!"
        ;;
    setup-lib)
        if [[ -z "$2" ]]; then
            print_error "Please provide the library directory"
            show_usage
            exit 1
        fi
        
        LIB_DIR="$2"
        print_info "Setting up library: $LIB_DIR"
        
        if [[ ! -d "$LIB_DIR" ]]; then
            print_error "Directory does not exist: $LIB_DIR"
            exit 1
        fi
        
        # Create settings.gradle
        cat > "$LIB_DIR/settings.gradle" << EOF
pluginManagement {
    repositories {
        maven {
            url = uri("https://maven.pkg.github.com/rmarap/com.lastbenchcap.common.gradle")
            credentials {
                username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_USERNAME")
                password = project.findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN")
            }
        }
        gradlePluginPortal()
        mavenCentral()
    }
}
EOF
        
        # Create minimal build.gradle
        cat > "$LIB_DIR/build.gradle" << EOF
plugins {
    id 'com.lastbenchcap.common.gradle.library' version '1.0.0'
}

// Library-specific customizations can be added here
dependencies {
    // Add your library-specific dependencies
    // api 'my-specific-dependency:1.0.0'
}
EOF
        
        # Create gradle.properties template
        cat > "$LIB_DIR/gradle.properties" << EOF
# =============================================================================
# LIBRARY CONFIGURATION
# =============================================================================

# Version Management
library.version=1.0.0

# GitHub Configuration
github.owner=rmarap
github.repo=your-library-name

# Library Information
library.group=com.lastbenchcap
library.artifactId=your-library-name
library.name=Your Library Name
library.description=Description of your library

# Build Configuration
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
org.gradle.parallel=true
org.gradle.caching=true

# Publishing Configuration
gpr.user=rmarap
#gpr.key=Create-personal-access-token-write-permissions-for-package
EOF
        
        print_success "Library setup complete!"
        print_info "Next steps:"
        print_info "1. Update gradle.properties with your library details"
        print_info "2. Add your source code to src/main/java/"
        print_info "3. Add tests to src/test/java/"
        print_info "4. Run: cd $LIB_DIR && ./gradlew build"
        ;;
    help)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac 