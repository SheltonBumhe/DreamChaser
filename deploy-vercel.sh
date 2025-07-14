#!/bin/bash

echo "🚀 Deploying DreamChaser to Vercel..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 Next steps for Vercel deployment:"
    echo "1. Go to https://vercel.com"
    echo "2. Sign up/login with your GitHub account"
    echo "3. Click 'New Project'"
    echo "4. Import your DreamChaser repository"
    echo "5. Vercel will auto-detect Flutter and deploy"
    echo "6. Your app will be live in minutes!"
    echo ""
    echo "📁 Your built files are in: build/web/"
    echo "🌐 Your app will be available at: your-app.vercel.app"
    echo ""
    echo "💡 Alternative deployment options:"
    echo "- Netlify: https://netlify.com"
    echo "- Firebase: https://firebase.google.com"
    echo "- AWS Amplify: https://aws.amazon.com/amplify/"
    echo "- Cloudflare Pages: https://pages.cloudflare.com/"
else
    echo "❌ Build failed! Please fix the errors above."
    exit 1
fi 