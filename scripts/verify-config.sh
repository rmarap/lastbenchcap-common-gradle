#!/bin/bash

# =============================================================================
# CONFIGURATION VERIFICATION SCRIPT
# =============================================================================
# This script verifies the current configuration and identifies potential issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Configuration Verification Script${NC}"
echo "====================================="
echo ""

# Check if gradle.properties exists
if [ ! -f "gradle.properties" ]; then
    echo -e "${RED}Error: gradle.properties not found${NC}"
    exit 1
fi

# Extract configuration values
GROUP_ID=$(grep "library.group=" gradle.properties | cut -d'=' -f2)
ARTIFACT_ID=$(grep "library.artifactId=" gradle.properties | cut -d'=' -f2)
VERSION=$(grep "library.version=" gradle.properties | cut -d'=' -f2)
GITHUB_OWNER=$(grep "github.owner=" gradle.properties | cut -d'=' -f2)
GITHUB_REPO=$(grep "github.repo=" gradle.properties | cut -d'=' -f2)

echo -e "${YELLOW}Current Configuration:${NC}"
echo "Group ID: $GROUP_ID"
echo "Artifact ID: $ARTIFACT_ID"
echo "Version: $VERSION"
echo "GitHub Owner: $GITHUB_OWNER"
echo "GitHub Repo: $GITHUB_REPO"
echo ""

# Check for potential issues
issues=0

echo -e "${YELLOW}Checking for potential issues:${NC}"

# Check if artifact ID is the same as group ID
if [ "$ARTIFACT_ID" = "$GROUP_ID" ]; then
    echo -e "${RED}❌ Issue: Artifact ID is the same as Group ID${NC}"
    echo "   This can cause publishing conflicts"
    issues=$((issues + 1))
else
    echo -e "${GREEN}✅ Artifact ID is different from Group ID${NC}"
fi

# Check if artifact ID contains dots (which can cause issues)
if [[ "$ARTIFACT_ID" == *.* ]]; then
    echo -e "${YELLOW}⚠️  Warning: Artifact ID contains dots${NC}"
    echo "   This might cause issues with some Maven repositories"
else
    echo -e "${GREEN}✅ Artifact ID format is good${NC}"
fi

# Check if version is valid
if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${GREEN}✅ Version format is valid${NC}"
else
    echo -e "${RED}❌ Issue: Invalid version format${NC}"
    issues=$((issues + 1))
fi

# Check if GitHub configuration is complete
if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO" ]; then
    echo -e "${RED}❌ Issue: Incomplete GitHub configuration${NC}"
    issues=$((issues + 1))
else
    echo -e "${GREEN}✅ GitHub configuration is complete${NC}"
fi

echo ""
if [ $issues -eq 0 ]; then
    echo -e "${GREEN}✅ No issues found! Configuration looks good.${NC}"
else
    echo -e "${RED}❌ Found $issues issue(s) that need to be addressed${NC}"
fi

echo ""
echo -e "${YELLOW}Expected package names:${NC}"
echo "Main artifact: $GROUP_ID:$ARTIFACT_ID:$VERSION"
echo "Plugin marker: $GROUP_ID:$ARTIFACT_ID.gradle.plugin:$VERSION"
echo ""

echo -e "${YELLOW}To test the configuration:${NC}"
echo "1. Run: ./gradlew clean build"
echo "2. Run: ./gradlew publishToMavenLocal"
echo "3. Check the generated files in ~/.m2/repository/$GROUP_ID/$ARTIFACT_ID/" 