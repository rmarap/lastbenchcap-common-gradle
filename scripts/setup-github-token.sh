#!/bin/bash

# Setup script for GitHub Packages publishing

echo "🔧 Setting up GitHub Packages publishing for LastBenchCap Common Library"
echo ""

# Check if GITHUB_TOKEN is already set
if [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ GITHUB_TOKEN is already set"
    echo "Current token: ${GITHUB_TOKEN:0:8}..."
else
    echo "❌ GITHUB_TOKEN is not set"
    echo ""
    echo "To publish to GitHub Packages, you need to:"
    echo ""
    echo "1. Create a GitHub Personal Access Token:"
    echo "   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)"
    echo "   - Click 'Generate new token (classic)'"
    echo "   - Give it a name like 'GitHub Packages Publishing'"
    echo "   - Select scopes: 'write:packages' and 'read:packages'"
    echo "   - Click 'Generate token' and copy the token"
    echo ""
    echo "2. Set the token in one of these ways:"
    echo ""
    echo "   Option A - Set for current session:"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "   Option B - Add to your shell profile (recommended):"
    echo "   echo 'export GITHUB_TOKEN=your_token_here' >> ~/.zshrc"
    echo "   source ~/.zshrc"
    echo ""
    echo "   Option C - Create a local gradle.properties file:"
    echo "   echo 'gpr.user=rmarap' >> gradle.properties"
    echo "   echo 'gpr.key=your_token_here' >> gradle.properties"
    echo ""
    echo "3. Test the publishing:"
    echo "   ./publish-to-github.sh"
    echo ""
fi

echo ""
echo "📋 Current configuration:"
echo "   Repository: https://github.com/rmarap/lastbenchcap-common"
echo "   Package URL: https://maven.pkg.github.com/rmarap/lastbenchcap-common"
echo "   Group ID: com.lastbenchcap"
echo "   Artifact ID: lastbenchcap-common"
echo "   Version: $(grep 'library.version=' gradle.properties | cut -d'=' -f2)"
echo "" 