# DreamChaser Deployment Guide

This guide covers deploying your Flutter web app to various platforms.

## 🚀 Quick Deploy Options

### 1. **Vercel** (Recommended)
**Pros**: Fast, automatic deployments, great Flutter support
**URL**: `your-app.vercel.app`

#### Setup:
1. Go to [vercel.com](https://vercel.com)
2. Sign up with GitHub
3. Click "New Project"
4. Import your DreamChaser repository
5. Vercel will auto-detect Flutter and deploy
6. Your app will be live in minutes!

### 2. **Netlify**
**Pros**: Free tier, drag-and-drop deployment
**URL**: `your-app.netlify.app`

#### Setup:
1. Go to [netlify.com](https://netlify.com)
2. Sign up with GitHub
3. Click "New site from Git"
4. Select your repository
5. Build command: `flutter build web --release`
6. Publish directory: `build/web`

### 3. **Firebase Hosting**
**Pros**: Google's platform, integrates with other Firebase services
**URL**: `your-app.web.app`

#### Setup:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting

# Build your app
flutter build web --release

# Deploy
firebase deploy
```

### 4. **AWS Amplify**
**Pros**: Full AWS integration, CI/CD
**URL**: `your-app.amplifyapp.com`

#### Setup:
1. Go to AWS Amplify Console
2. Click "New app" → "Host web app"
3. Connect your GitHub repository
4. Build settings:
   - Build command: `flutter build web --release`
   - Output directory: `build/web`

### 5. **Cloudflare Pages**
**Pros**: Fast CDN, free tier
**URL**: `your-app.pages.dev`

#### Setup:
1. Go to Cloudflare Dashboard
2. Navigate to Pages
3. Create new project
4. Connect GitHub repository
5. Build settings:
   - Framework preset: None
   - Build command: `flutter build web --release`
   - Output directory: `build/web`

## 🔧 Manual Deployment

### Build for Production
```bash
# Build the web app
flutter build web --release

# The built files are in build/web/
```

### Upload to Any Static Hosting
You can upload the contents of `build/web/` to any static hosting service:
- **Surge.sh**: `surge build/web your-app.surge.sh`
- **GitHub Pages**: Push to gh-pages branch
- **Any web server**: Upload files to your server

## 🌐 Custom Domain Setup

### Vercel
1. Go to your project settings
2. Click "Domains"
3. Add your custom domain
4. Update DNS records as instructed

### Netlify
1. Go to Site settings → Domain management
2. Add custom domain
3. Update DNS records

### Firebase
```bash
firebase hosting:channel:deploy preview
firebase hosting:sites:add your-domain.com
```

## 📱 Mobile App Deployment

### Android (Google Play Store)
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (recommended)
flutter build appbundle --release
```

### iOS (App Store)
```bash
# Build iOS
flutter build ios --release
```

## 🔒 Environment Variables

For production, set these environment variables:

### Vercel/Netlify
- `CANVAS_API_URL`: Your Canvas API URL
- `OPENAI_API_KEY`: Your OpenAI API key
- `JOB_API_KEY`: Your job search API key

### Firebase
```bash
firebase functions:config:set canvas.api_url="your-url"
firebase functions:config:set openai.api_key="your-key"
```

## 🚨 Troubleshooting

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Deployment Issues
1. Check build logs for errors
2. Verify `build/web/` contains files
3. Ensure `index.html` exists in root
4. Check platform-specific requirements

### Performance Issues
1. Enable tree shaking: `flutter build web --release --tree-shake-icons`
2. Optimize images and assets
3. Use CDN for static assets

## 📊 Analytics & Monitoring

### Vercel Analytics
- Built-in analytics
- Performance monitoring
- Error tracking

### Firebase Analytics
```dart
// Add to your app
import 'package:firebase_analytics/firebase_analytics.dart';
```

### Custom Analytics
```dart
// Google Analytics
import 'package:google_analytics/google_analytics.dart';
```

## 🔄 Continuous Deployment

### GitHub Actions (Vercel/Netlify)
```yaml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      # Platform-specific deployment steps
```

## 💡 Pro Tips

1. **Use CDN**: Deploy static assets to CDN for faster loading
2. **Enable compression**: Gzip/Brotli compression for smaller files
3. **Cache strategy**: Set appropriate cache headers
4. **Error monitoring**: Set up error tracking (Sentry, Bugsnag)
5. **Performance monitoring**: Use Lighthouse for optimization

## 🆘 Need Help?

- **Vercel**: [vercel.com/docs](https://vercel.com/docs)
- **Netlify**: [netlify.com/docs](https://netlify.com/docs)
- **Firebase**: [firebase.google.com/docs](https://firebase.google.com/docs)
- **Flutter Web**: [flutter.dev/web](https://flutter.dev/web) 