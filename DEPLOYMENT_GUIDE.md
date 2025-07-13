# 🚀 DreamChaser Web Deployment Guide

This guide will help you deploy your DreamChaser Flutter app as a web application on GitHub Pages.

## 📋 Prerequisites

- GitHub account
- Flutter SDK installed
- Git installed

## 🎯 Quick Deployment (3 Steps)

### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `DreamChaser` (or any name you prefer)
3. Make it public (required for GitHub Pages)
4. Don't initialize with README (we already have one)

### Step 2: Push Your Code

```bash
# Initialize git (if not already done)
git init

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/DreamChaser.git

# Add all files
git add .

# Commit
git commit -m "Initial commit - DreamChaser web app"

# Push to main branch
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Scroll down to **Pages** section
4. Under **Source**, select **Deploy from a branch**
5. Select **gh-pages** branch and **/** folder
6. Click **Save**

## 🔄 Automatic Deployment

The repository includes a GitHub Actions workflow that automatically deploys your app:

- Every time you push to the `main` branch, it automatically builds and deploys
- The workflow is located at `.github/workflows/deploy.yml`
- No manual intervention required after initial setup

## 🌐 Access Your App

Your app will be available at:
```
https://YOUR_USERNAME.github.io/DreamChaser
```

## 🛠️ Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# Build the web app
flutter build web --release

# Use the deployment script
./deploy.sh
```

## 📱 Testing Your Deployment

1. **Wait 2-3 minutes** after pushing to main branch
2. Visit your GitHub Pages URL
3. Test all features:
   - Navigation between screens
   - Job search functionality
   - Canvas integration (mock data)
   - AI insights
   - User authentication

## 🔧 Troubleshooting

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### GitHub Pages Not Updating
1. Check the **Actions** tab in your repository
2. Look for any failed workflows
3. Ensure the `gh-pages` branch exists and has content

### CORS Issues (if using real APIs)
- For development, use browser extensions to disable CORS
- For production, ensure your APIs support CORS headers

## 🎨 Customization

### Change App Title
Edit `web/index.html`:
```html
<title>Your App Name</title>
```

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`

### Add Custom Domain
1. In repository settings → Pages
2. Add your custom domain
3. Update DNS settings with your domain provider

## 📊 Monitoring

- **GitHub Actions**: Monitor deployment status
- **GitHub Pages**: Check site analytics
- **Browser DevTools**: Debug any issues

## 🚀 Next Steps

After successful deployment:

1. **Share your app** with friends and colleagues
2. **Add real API keys** for Canvas and job search
3. **Customize the design** to match your brand
4. **Add more features** based on user feedback

## 📞 Support

If you encounter issues:

1. Check the [Flutter Web documentation](https://docs.flutter.dev/deployment/web)
2. Review [GitHub Pages documentation](https://docs.github.com/en/pages)
3. Open an issue in this repository

---

**🎉 Congratulations! Your DreamChaser web app is now live!**

Your app includes:
- ✅ Secure job search with scam protection
- ✅ Canvas integration for academic tracking
- ✅ AI-powered insights and recommendations
- ✅ Modern, responsive UI
- ✅ Direct application links
- ✅ Real-time data synchronization

Visit your app and start exploring the features! 