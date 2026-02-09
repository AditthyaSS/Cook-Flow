# CookFlow Deployment Guide

This guide covers the complete deployment process for CookFlow, from development to production.

## 🎯 Deployment Checklist

Before deploying to production, ensure you have completed all items:

### Pre-Deployment

- [ ] All features tested and working
- [ ] No critical bugs or errors
- [ ] All environment variables configured
- [ ] API keys secured (not in version control)
- [ ] Firebase project set up
- [ ] Backend deployed to production server
- [ ] Database migrations completed
- [ ] SSL certificate installed
- [ ] Privacy policy and terms of service added
- [ ] App icons and splash screens configured
- [ ] Release notes prepared

### App Store Requirements

**iOS App Store**
- [ ] Apple Developer account ($99/year)
- [ ] App icons (all required sizes)
- [ ] Screenshots (6.7", 5.5", 12.9")
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] App Store Connect metadata

**Google Play Store**
- [ ] Google Play Developer account ($25 one-time)
- [ ] App icons and feature graphic
- [ ] Screenshots (phone and tablet)
- [ ] Short and full descriptions
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] Categories and tags

---

## 🔧 Environment Setup

### Backend Environment Variables

Create a `.env.production` file in the `backend/` directory:

```bash
# Server Configuration
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# API Keys
GEMINI_API_KEY=your_production_api_key_here

# CORS Settings
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
LOG_FILE=/var/log/cookflow/app.log

# Database (if using external DB in future)
# DATABASE_URL=postgresql://user:pass@host:5432/cookflow

# Affiliate API Keys (Phase 2)
AMAZON_AFFILIATE_TAG=your_tag_here
INSTACART_API_KEY=your_key_here

# Session Secret (for future auth features)
SESSION_SECRET=generate_a_secure_random_string_here
```

### Flutter App Configuration

Create environment-specific API configurations:

**lib/config/environment.dart:**
```dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.cookflow.com',
  );
  
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
}
```

### Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project "CookFlow Production"
   - Enable Google Analytics (optional)

2. **Configure Firebase Authentication**
   ```bash
   # Enable sign-in methods:
   - Email/Password
   - Google
   ```

3. **Set up Firestore Database**
   ```bash
   # Create database in production mode
   # Location: Choose closest to users
   # Rules: Set up security rules (see FIREBASE_SETUP.md)
   ```

4. **Download Configuration Files**
   - iOS: `GoogleService-Info.plist`
   - Android: `google-services.json`

---

## 📱 Building the Flutter App

### iOS Build

#### Prerequisites
- macOS with Xcode installed
- Apple Developer account
- Signing certificates and provisioning profiles

#### Build Steps

```bash
# 1. Navigate to project
cd cookflow_app

# 2. Clean previous builds
flutter clean
flutter pub get

# 3. Update version in pubspec.yaml
# version: 1.0.0+1

# 4. Build for iOS
flutter build ios --release --dart-define=API_URL=https://api.cookflow.com

# 5. Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# - Select "Product" > "Archive"
# - After archiving, select "Distribute App"
# - Choose "App Store Connect"
# - Upload to App Store Connect
```

#### App Store Submission

1. **App Store Connect**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Create new app
   - Fill in metadata (name, description, keywords)
   - Upload screenshots
   - Submit for review

2. **Review Process**
   - Typically 1-3 days
   - Address any rejection reasons
   - Monitor status in App Store Connect

### Android Build

#### Prerequisites
- Android Studio installed
- Google Play Developer account
- Signing key created

#### Create Signing Key

```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/cookflow-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias cookflow
```

#### Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=cookflow
storeFile=/Users/you/cookflow-release-key.jks
```

Add to `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Build Steps

```bash
# 1. Navigate to project
cd cookflow_app

# 2. Clean previous builds
flutter clean
flutter pub get

# 3. Build APK (for testing)
flutter build apk --release --dart-define=API_URL=https://api.cookflow.com

# 4. Build App Bundle (for Play Store)
flutter build appbundle --release --dart-define=API_URL=https://api.cookflow.com

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Google Play Submission

1. **Google Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new application
   - Fill in store listing
   - Upload screenshots and graphics

2. **Upload App Bundle**
   - Go to "Release" > "Production"
   - Create new release
   - Upload `app-release.aab`
   - Add release notes
   - Submit for review

3. **Review Process**
   - Typically 1-3 days
   - Monitor status in Play Console

---

## 🖥️ Backend Deployment

### Option 1: Deploy to Heroku (Free Tier)

```bash
# 1. Install Heroku CLI
# Download from https://devcenter.heroku.com/articles/heroku-cli

# 2. Login to Heroku
heroku login

# 3. Create Heroku app
cd backend
heroku create cookflow-api

# 4. Set environment variables
heroku config:set GEMINI_API_KEY=your_key_here
heroku config:set NODE_ENV=production

# 5. Deploy
git push heroku main

# 6. Verify deployment
heroku open
heroku logs --tail
```

### Option 2: Deploy to DigitalOcean (Recommended)

```bash
# 1. Create Droplet
- Ubuntu 22.04 LTS
- $6/month plan
- Add SSH key

# 2. SSH into server
ssh root@your_server_ip

# 3. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4. Install PM2
sudo npm install -g pm2

# 5. Clone repository
git clone https://github.com/yourusername/cookflow.git
cd cookflow/backend

# 6. Install dependencies
npm install --production

# 7. Create .env file
nano .env
# Add your production environment variables

# 8. Start with PM2
pm2 start server.js --name cookflow-api
pm2 save
pm2 startup

# 9. Set up Nginx reverse proxy
sudo apt install nginx
sudo nano /etc/nginx/sites-available/cookflow

# Add configuration:
server {
    listen 80;
    server_name api.cookflow.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# 10. Enable site and restart Nginx
sudo ln -s /etc/nginx/sites-available/cookflow /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 11. Set up SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.cookflow.com
```

### Option 3: Deploy to AWS (Scalable)

```bash
# Use AWS Elastic Beanstalk or EC2
# Full tutorial: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/nodejs-getstarted.html
```

---

## 🔒 Security Checklist

### API Security
- [x] All API keys in environment variables
- [x] CORS configured with allowed origins only
- [x] Rate limiting enabled
- [x] Request validation implemented
- [x] HTTPS enforced
- [ ] API authentication tokens
- [ ] Request logging for monitoring

### Firebase Security
- [x] Firestore security rules configured
- [x] User data isolated by UID
- [x] Read/write permissions strict
- [ ] Backup strategy in place

### App Security
- [x] No hardcoded secrets
- [x] Secure storage for sensitive data
- [ ] Certificate pinning (advanced)
- [ ] ProGuard enabled for Android

---

## 📊 Monitoring & Analytics

### Set Up Error Tracking

**Option 1: Sentry**
```bash
# Add to pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0

# Initialize in main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'your_sentry_dsn';
  },
  appRunner: () => runApp(MyApp()),
);
```

**Option 2: Firebase Crashlytics**
```bash
# Add to pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.0.0

# Initialize in main.dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

### Analytics Setup

```dart
// Add Firebase Analytics
dependencies:
  firebase_analytics: ^10.0.0

// Track events
FirebaseAnalytics.instance.logEvent(
  name: 'recipe_extracted',
  parameters: {'recipe_id': recipeId},
);
```

---

## 🚀 Post-Deployment

### Health Checks

```bash
# Check backend API
curl https://api.cookflow.com/health

# Expected response:
{
  "status": "ok",
  "timestamp": "2026-02-09T10:00:00.000Z",
  "version": "1.0.0"
}
```

### Monitoring

Set up monitoring with:
- **Uptime Monitoring**: UptimeRobot, Pingdom
- **Performance**: New Relic, DataDog
- **Logs**: Papertrail, Loggly

### Backup Strategy

**Database Backups**
```bash
# If using PostgreSQL
pg_dump cookflow > backup_$(date +%Y%m%d).sql

# Automate with cron
0 2 * * * /usr/local/bin/backup_database.sh
```

**Firestore Backups**
- Use Firebase Console
- Schedule daily exports
- Store in Google Cloud Storage

---

## 📈 Scaling Considerations

### Backend Scaling

**Horizontal Scaling**
- Use load balancer (Nginx, HAProxy)
- Multiple backend instances
- Session management with Redis

**Database Scaling**
- Add read replicas
- Implement caching (Redis/Memcached)
- Database connection pooling

### Cost Optimization

- Monitor API usage
- Optimize Gemini API calls
- Use CDN for static assets
- Implement request caching

---

## 🐛 Troubleshooting

### Common Deployment Issues

**Issue: App crashes on startup**
```bash
# Check logs
heroku logs --tail
# or
pm2 logs cookflow-api

# Verify environment variables
heroku config
```

**Issue: Firebase connection failed**
- Verify configuration files
- Check Firebase project settings
- Ensure API keys are correct

**Issue: Certificate errors (iOS)**
- Regenerate provisioning profile
- Update signing certificates
- Clean build folder

---

## 📝 Release Process

### Version Numbering

Use Semantic Versioning (semver):
- **Major**: Breaking changes (2.0.0)
- **Minor**: New features (1.1.0)
- **Patch**: Bug fixes (1.0.1)

### Release Workflow

1. **Update Version**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2
   ```

2. **Create Release Notes**
   ```markdown
   ## Version 1.0.1
   
   ### New Features
   - Added notification preferences
   - Improved recipe extraction
   
   ### Bug Fixes
   - Fixed crash on account deletion
   - Resolved dark mode issues
   ```

3. **Build and Test**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   flutter build apk --release
   ```

4. **Deploy Backend**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   # Deploy via CI/CD or manually
   ```

5. **Submit to App Stores**
   - Upload to App Store Connect
   - Upload to Google Play Console
   - Wait for review approval

6. **Monitor Launch**
   - Watch crash reports
   - Monitor user feedback
   - Prepare hotfix if needed

---

## 📞 Support

For deployment questions:
- **Documentation**: [CookFlow Docs](https://docs.cookflow.com) (fictional)
- **GitHub Issues**: [Report Issues](https://github.com/cookflow/issues) (fictional)
- **Email**: deploy@cookflow.com (fictional)

---

**Last Updated**: February 2026
**Version**: 1.0
