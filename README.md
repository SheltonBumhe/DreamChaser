# DreamChaser - AI-Powered Academic & Career Companion

DreamChaser is a comprehensive Flutter application that serves as an AI-powered academic and career companion. It tracks Canvas progress, calculates grade requirements, monitors project deadlines, and finds relevant job opportunities with scam protection.

## 🌟 Features

### 🔒 Secure Job Search
- **Scam Detection**: Built-in protection against fraudulent job postings
- **Direct Application Links**: One-click application to verified companies
- **Security Verification**: Company authenticity verification system
- **Canvas Integration**: Match job requirements with your academic skills

### 🎓 Academic Management
- **Canvas Integration**: Real-time course data synchronization
- **Grade Tracking**: Monitor your academic progress
- **Assignment Management**: Track deadlines and priorities
- **Skill Extraction**: Automatically identify skills from your courses

### 🤖 AI-Powered Insights
- **Grade Predictions**: AI-driven grade forecasting
- **Career Recommendations**: Personalized job suggestions
- **Skill Gap Analysis**: Identify missing skills for target jobs
- **Academic Insights**: Data-driven academic recommendations

### 📱 Modern UI/UX
- **Responsive Design**: Works on web, mobile, and desktop
- **Intuitive Navigation**: Easy-to-use interface
- **Real-time Updates**: Live data synchronization
- **Dark/Light Theme**: Customizable appearance

## 🚀 Quick Start

### Web Deployment
1. **Fork this repository** to your GitHub account
2. **Enable GitHub Pages** in your repository settings:
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: gh-pages
   - Folder: / (root)
3. **Push to main branch** - The GitHub Action will automatically deploy your app
4. **Access your app** at: `https://yourusername.github.io/DreamChaser`

### Local Development
```bash
# Clone the repository
git clone https://github.com/yourusername/DreamChaser.git
cd DreamChaser

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for production
flutter build web --release
```

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: Go Router
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences, Hive
- **Charts**: FL Chart
- **Notifications**: Flutter Local Notifications
- **URL Handling**: URL Launcher

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── services/        # Business logic
│   ├── theme/          # UI theming
│   └── routes/         # Navigation
├── features/
│   ├── academic/       # Academic features
│   ├── ai/            # AI insights
│   ├── auth/          # Authentication
│   ├── career/        # Job search
│   ├── dashboard/     # Main dashboard
│   ├── onboarding/    # User onboarding
│   ├── profile/       # User profile
│   └── settings/      # App settings
└── main.dart          # App entry point
```

## 🔧 Configuration

### Canvas Integration
To connect your Canvas account:
1. Get your Canvas API token from your institution
2. Update the token in `lib/core/services/canvas_integration_service.dart`
3. The app will automatically sync your course data

### Job Search API
To use real job APIs:
1. Sign up for job search APIs (Indeed, LinkedIn, etc.)
2. Update API keys in `lib/core/services/secure_job_service.dart`
3. The app will fetch real job opportunities

## 🚀 Deployment

### GitHub Pages (Automatic)
The app is configured with GitHub Actions for automatic deployment:
- Every push to `main` branch triggers deployment
- Web app is automatically built and deployed to GitHub Pages
- Access your live app at the URL provided by GitHub Pages

### Manual Deployment
```bash
# Build the web app
flutter build web --release

# Deploy to any static hosting service
# Copy contents of build/web/ to your hosting provider
```

## 📱 Mobile Deployment

### iOS
```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Run on device
flutter run -d <device-id>
```

### Android
```bash
# Build APK
flutter build apk --release

# Install on device
flutter install
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Canvas API for educational data integration
- All contributors and users of DreamChaser

---

**DreamChaser** - Your AI-powered academic and career companion! 🚀