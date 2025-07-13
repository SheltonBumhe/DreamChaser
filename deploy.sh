#!/bin/bash

# DreamChaser Deployment Script
# This script helps deploy the Flutter web app to GitHub Pages

echo "🚀 DreamChaser Deployment Script"
echo "================================"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git repository not found. Please initialize git first:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit'"
    exit 1
fi

# Check if remote origin exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "❌ No remote origin found. Please add your GitHub repository:"
    echo "   git remote add origin https://github.com/yourusername/DreamChaser.git"
    exit 1
fi

# Build the web app
echo "📦 Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix the errors and try again."
    exit 1
fi

echo "✅ Build completed successfully!"

# Check if gh-pages branch exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "🔄 Updating gh-pages branch..."
    git checkout gh-pages
    git pull origin gh-pages
else
    echo "🆕 Creating gh-pages branch..."
    git checkout --orphan gh-pages
fi

# Remove all files except build/web contents
git rm -rf .
git clean -fxd

# Copy web build files
cp -r build/web/* .

# Add all files
git add .

# Commit changes
git commit -m "Deploy DreamChaser web app - $(date)"

# Push to gh-pages branch
echo "🚀 Pushing to GitHub Pages..."
git push origin gh-pages

# Switch back to main branch
git checkout main

echo "✅ Deployment completed!"
echo ""
echo "🌐 Your app should be available at:"
echo "   https://$(git remote get-url origin | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')"
echo ""
echo "📝 To enable automatic deployment:"
echo "   1. Go to your repository settings"
echo "   2. Navigate to Pages"
echo "   3. Set source to 'Deploy from a branch'"
echo "   4. Select 'gh-pages' branch and '/' folder"
echo "   5. Save the settings"
echo ""
echo "🔄 For automatic deployments, push to the main branch and the GitHub Action will handle the rest!" 