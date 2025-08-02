#!/bin/bash

# Publish LastBenchCap Common Library to GitHub Packages

echo "Publishing LastBenchCap Common Library to GitHub Packages..."

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable is not set."
    echo ""
    echo "To publish to GitHub Packages, you need to:"
    echo "1. Create a GitHub Personal Access Token with 'write:packages' permission"
    echo "2. Set the GITHUB_TOKEN environment variable:"
    echo "   export GITHUB_TOKEN=your_github_token"
    echo ""
    echo "You can also set it temporarily for this session:"
    echo "   GITHUB_TOKEN=your_token ./publish-to-github.sh"
    exit 1
fi

# Set up environment variables for GitHub Packages
export GPR_KEY=$GITHUB_TOKEN
export GPR_USER=rmarap

echo "✅ GITHUB_TOKEN is set"
echo "Building and publishing..."

# Build the library (skip tests for now)
./gradlew clean build -x test

# Publish to GitHub Packages
echo "Publishing to GitHub Packages..."
./gradlew publish

if [ $? -eq 0 ]; then
    echo "✅ Successfully published to GitHub Packages!"
    echo ""
    echo "The library is now available at:"
    echo "https://maven.pkg.github.com/rmarap/lastbenchcap-common"
    echo ""
    echo "You can now use it in other projects by adding:"
    echo "repositories {"
    echo "    maven {"
    echo "        url = uri(\"https://maven.pkg.github.com/rmarap/lastbenchcap-common\")"
    echo "        credentials {"
    echo "            username = project.findProperty(\"gpr.user\") ?: System.getenv(\"USERNAME\")"
    echo "            password = project.findProperty(\"gpr.key\") ?: System.getenv(\"TOKEN\")"
    echo "        }"
    echo "    }"
    echo "}"
    echo ""
    echo "And the dependency:"
    echo "implementation 'com.lastbenchcap:lastbenchcap-common:1.0.0'"
else
    echo "❌ Failed to publish to GitHub Packages"
    exit 1
fi 