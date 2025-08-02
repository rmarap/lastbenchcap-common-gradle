#!/bin/bash

# Create New Library Script
# This script helps you create a new library based on this template

set -e

echo "🚀 Create New Library from Template"
echo "=================================="
echo ""

# Check if required parameters are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <library-name> <github-owner> <github-repo> [group-id] [description]"
    echo ""
    echo "Parameters:"
    echo "  library-name    : Name of your library (e.g., 'my-awesome-lib')"
    echo "  github-owner    : Your GitHub username"
    echo "  github-repo     : Your GitHub repository name"
    echo "  group-id        : Maven group ID (optional, defaults to com.lastbenchcap)"
    echo "  description     : Library description (optional)"
    echo ""
    echo "Example:"
    echo "  $0 my-awesome-lib rmarap my-awesome-lib com.mycompany 'My awesome library'"
    exit 1
fi

LIBRARY_NAME=$1
GITHUB_OWNER=$2
GITHUB_REPO=$3
GROUP_ID=${4:-"com.lastbenchcap"}
DESCRIPTION=${5:-"A shared library for ${LIBRARY_NAME}"}

echo "📋 Creating new library with the following configuration:"
echo "   Library Name: $LIBRARY_NAME"
echo "   GitHub Owner: $GITHUB_OWNER"
echo "   GitHub Repo: $GITHUB_REPO"
echo "   Group ID: $GROUP_ID"
echo "   Description: $DESCRIPTION"
echo ""

# Create the new directory
NEW_DIR="../$LIBRARY_NAME"
if [ -d "$NEW_DIR" ]; then
    echo "❌ Directory $NEW_DIR already exists!"
    echo "Please choose a different library name or remove the existing directory."
    exit 1
fi

echo "📁 Creating new library directory: $NEW_DIR"
mkdir -p "$NEW_DIR"

# Copy all files except git directory and this script
echo "📋 Copying template files..."
rsync -av --exclude='.git' --exclude='scripts/create-new-library.sh' --exclude='node_modules' --exclude='.DS_Store' ./ "$NEW_DIR/"

# Navigate to the new directory
cd "$NEW_DIR"

# Update gradle.properties
echo "⚙️  Updating gradle.properties..."
sed -i.bak "s/github.owner=.*/github.owner=$GITHUB_OWNER/" gradle.properties
sed -i.bak "s/github.repo=.*/github.repo=$GITHUB_REPO/" gradle.properties
sed -i.bak "s/library.group=.*/library.group=$GROUP_ID/" gradle.properties
sed -i.bak "s/library.artifactId=.*/library.artifactId=$LIBRARY_NAME/" gradle.properties
sed -i.bak "s/library.name=.*/library.name=$LIBRARY_NAME/" gradle.properties
sed -i.bak "s/library.description=.*/library.description=$DESCRIPTION/" gradle.properties
sed -i.bak "s/library.version=.*/library.version=1.0.0/" gradle.properties

# Remove backup files
rm -f gradle.properties.bak

# Update build.gradle artifactId
echo "🔧 Updating build.gradle..."
sed -i.bak "s/artifactId = '.*'/artifactId = '$LIBRARY_NAME'/" build.gradle
rm -f build.gradle.bak

# Update README.md
echo "📝 Updating README.md..."
sed -i.bak "s/lastbenchcap-common/$LIBRARY_NAME/g" README.md
sed -i.bak "s/LastBenchCap Common Library/$LIBRARY_NAME/g" README.md
rm -f README.md.bak

# Update GitHub Actions workflows
echo "🔄 Updating GitHub Actions workflows..."
find .github/workflows -name "*.yml" -exec sed -i.bak "s/lastbenchcap-common/$LIBRARY_NAME/g" {} \;
find .github/workflows -name "*.yml" -exec sed -i.bak "s/LastBenchCap Common Library/$LIBRARY_NAME/g" {} \;
find .github/workflows -name "*.yml" -exec sed -i.bak "s/com.lastbenchcap:lastbenchcap-common/$GROUP_ID:$LIBRARY_NAME/g" {} \;
find .github/workflows -name "*.yml" -exec sed -i.bak "s/rmarap/$GITHUB_OWNER/g" {} \;
find .github/workflows -name "*.bak" -delete

# Update publish scripts
echo "📤 Updating publish scripts..."
sed -i.bak "s/lastbenchcap-common/$LIBRARY_NAME/g" scripts/publish.sh
sed -i.bak "s/lastbenchcap-common/$LIBRARY_NAME/g" scripts/publish-to-github.sh
sed -i.bak "s/rmarap/$GITHUB_OWNER/g" scripts/publish.sh
sed -i.bak "s/rmarap/$GITHUB_OWNER/g" scripts/publish-to-github.sh
find . -name "*.bak" -delete

# Update setup script
echo "🔧 Updating setup script..."
sed -i.bak "s/lastbenchcap-common/$LIBRARY_NAME/g" scripts/setup-github-token.sh
sed -i.bak "s/rmarap/$GITHUB_OWNER/g" scripts/setup-github-token.sh
rm -f scripts/setup-github-token.sh.bak

# Initialize git repository
echo "🔧 Initializing git repository..."
git init
git add .
git commit -m "Initial commit: $LIBRARY_NAME library"

echo ""
echo "✅ Successfully created new library: $LIBRARY_NAME"
echo ""
echo "📋 Next steps:"
echo "1. Create a new repository on GitHub: https://github.com/$GITHUB_OWNER/$GITHUB_REPO"
echo "2. Add the remote origin:"
echo "   cd $NEW_DIR"
echo "   git remote add origin https://github.com/$GITHUB_OWNER/$GITHUB_REPO.git"
echo "   git push -u origin main"
echo ""
echo "3. Configure GitHub Actions permissions:"
echo "   - Go to your repository → Settings → Actions → General"
echo "   - Set 'Workflow permissions' to 'Read and write permissions'"
echo "   - Check 'Allow GitHub Actions to create and approve pull requests'"
echo ""
echo "4. Test the build:"
echo "   cd $NEW_DIR"
echo "   ./gradlew clean build"
echo ""
echo "5. Publish to GitHub Packages:"
echo "   ./scripts/publish-to-github.sh"
echo ""
echo "🎉 Your new library is ready!" 