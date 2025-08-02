#!/bin/bash

# Publish script for LastBenchCap Common Library

echo "Building and publishing LastBenchCap Common Library..."

# Build the library
./gradlew clean build

# Publish to local Maven repository (for testing)
echo "Publishing to local Maven repository..."
./gradlew publishToMavenLocal

# Publish to GitHub Packages (requires GITHUB_TOKEN environment variable)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Publishing to GitHub Packages..."
    export GPR_KEY=$GITHUB_TOKEN
    export GPR_USER=rmarap
    ./gradlew publish
else
    echo "GITHUB_TOKEN not set. Skipping GitHub Packages publish."
    echo "To publish to GitHub Packages, set the GITHUB_TOKEN environment variable:"
    echo "export GITHUB_TOKEN=your_github_token"
fi

echo "Publish complete!" 