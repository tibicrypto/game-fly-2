# Google Play Publishing Guide - SKY HAULER: HEAVY FUEL

## 📱 App Information

### Basic Details
- **App Name**: SKY HAULER: HEAVY FUEL
- **Package Name**: sky_hauler (from pubspec.yaml)
- **Version**: 1.0.0 (Version Code: 1)
- **Category**: Arcade & Action > Simulation
- **Content Rating**: Everyone (PEGI 3, ESRB E)
- **Supported Languages**: English, Vietnamese
- **Price**: Free

### Short Description (80 characters max)
```
Master aerial cargo delivery in this physics-based flying game!
```

### Full Description (4000 characters max)
```
🎮 TAKE TO THE SKIES IN SKY HAULER: HEAVY FUEL! 🎮

Become a legendary cargo pilot in this addictive physics-based flying game! Control your aircraft with intuitive two-finger controls while managing fuel weight, cargo, and treacherous terrain.

✈️ UNIQUE GAMEPLAY MECHANICS
• Two-Finger Control: Hold 2 fingers to refuel and thrust, release to glide
• Weight Physics: Fuel adds weight - balance power vs. maneuverability
• Procedural Terrain: Infinite landscapes generated with Perlin noise
• Multiple Cargo Types: From easy mail to explosive uranium
• Upgradable Fleet: 4 aircraft with unique stats and capabilities

🎯 CHALLENGING MISSIONS
Choose from 4 cargo classes with increasing difficulty and rewards:
• C-Class Mail (10kg) - $100 reward
• B-Class Food (40kg) - $300 reward
• A-Class Gold (100kg) - $1000 reward
• S-Class Uranium (200kg) - $5000 reward (EXTREME!)

🛩️ AIRCRAFT FLEET
Unlock and upgrade your planes:
• Sparrow - Lightweight beginner plane (FREE)
• Eagle - Balanced mid-tier aircraft ($500)
• Falcon - Powerful heavy-lifter ($1500)
• Phoenix - Ultimate cargo hauler ($5000)

⚖️ REALISTIC PHYSICS
Experience authentic flight physics where every decision matters:
• Total Weight = Plane + Cargo + (Fuel × 0.8)
• Too much fuel makes you heavy and hard to control
• Too little fuel and you'll fall from the sky
• Master the rhythm of refueling bursts

🌟 FEATURES
• Smooth 60 FPS physics simulation
• Infinite procedural terrain
• Haptic feedback and sound effects
• Portrait-optimized gameplay
• Local leaderboard system
• Multiple language support

🎵 IMMERSIVE AUDIO
• Dynamic soundtrack that adapts to gameplay
• Satisfying sound effects for every action
• Customizable audio settings

Download SKY HAULER: HEAVY FUEL now and prove you're the best cargo pilot in the skies!

#skyhauler #flyinggame #physicsgame #mobilegaming
```

## 🖼️ Store Graphics Requirements

### Feature Graphic (1024 x 500 pixels, JPG/PNG, < 15MB)
**Design Requirements:**
- Background: Dynamic sky with clouds and terrain
- Main Element: Cargo plane in flight with contrails
- Text: "SKY HAULER: HEAVY FUEL" in bold, modern font
- Style: Action-oriented, adventurous, professional
- Colors: Blue sky theme with orange accents

**Suggested Content:**
- Plane silhouette against sunset sky
- Cargo containers floating
- Fuel gauge and physics elements
- Tagline: "Master the Skies"

### Screenshots (Minimum 2, Maximum 8, 16:9 aspect ratio)
**Required Screenshots:**
1. **Main Menu** - Show game title and start options
2. **Cargo Selection** - Display different cargo types and rewards
3. **Plane Selection** - Show aircraft lineup with stats
4. **Gameplay** - Active flight with terrain and controls
5. **Physics Demo** - Show weight effects and refueling
6. **Game Over** - Show scoring and leaderboard
7. **Settings** - Audio controls and options
8. **Achievement** - Success moment with rewards

**Technical Specs:**
- Resolution: 1080 x 1920 pixels (or equivalent 16:9)
- Format: JPG or 24-bit PNG (no alpha)
- File Size: < 15MB each
- No text overlays or watermarks
- Clean device frames (use Google Play device frames)

### Icon (512 x 512 pixels, 32-bit PNG with alpha)
**Design Requirements:**
- Main Element: Stylized cargo plane
- Background: Circular with sky gradient
- Style: Modern, clean, recognizable at small sizes
- Colors: Match app branding

## 📋 App Content

### Privacy Policy URL
```
https://yourwebsite.com/privacy-policy
```

### Terms of Service URL
```
https://yourwebsite.com/terms-of-service
```

### Contact Information
- **Website**: https://yourwebsite.com
- **Email**: support@yourwebsite.com
- **Phone**: +1 (XXX) XXX-XXXX

## 🔧 Technical Requirements

### Build Configuration
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release --target-platform android-arm,android-arm64,android-x64

# Build App Bundle (AAB) - Recommended
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64
```

### Android Manifest Requirements
Ensure `android/app/src/main/AndroidManifest.xml` includes:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="SKY HAULER: HEAVY FUEL"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### Build.gradle Configuration
Ensure `android/app/build.gradle` has:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.yourcompany.skyhauler"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 📝 Privacy Policy Template

Create a `privacy_policy.html` file with the following content:

```html
<!DOCTYPE html>
<html>
<head>
    <title>SKY HAULER Privacy Policy</title>
</head>
<body>
    <h1>Privacy Policy for SKY HAULER: HEAVY FUEL</h1>
    <p><strong>Effective Date:</strong> January 18, 2026</p>

    <h2>Information We Collect</h2>
    <p>SKY HAULER collects the following types of information:</p>
    <ul>
        <li><strong>Game Progress Data:</strong> High scores, unlocked planes, game settings</li>
        <li><strong>Device Information:</strong> Device type, OS version, screen resolution</li>
        <li><strong>Usage Analytics:</strong> How you play the game (optional)</li>
    </ul>

    <h2>How We Use Information</h2>
    <ul>
        <li>To save your game progress locally on your device</li>
        <li>To provide personalized game experience</li>
        <li>To improve game performance and features</li>
    </ul>

    <h2>Data Storage</h2>
    <p>All game data is stored locally on your device. We do not collect or transmit personal information to external servers.</p>

    <h2>Third-Party Services</h2>
    <p>This game does not use third-party analytics or advertising services.</p>

    <h2>Children's Privacy</h2>
    <p>This game is rated "Everyone" and does not collect personal information from children.</p>

    <h2>Changes to This Policy</h2>
    <p>We may update this privacy policy occasionally. We will notify users of any changes.</p>

    <h2>Contact Us</h2>
    <p>If you have questions about this Privacy Policy, please contact us at support@yourwebsite.com</p>
</body>
</html>
```

## 📄 Terms of Service Template

Create a `terms_of_service.html` file:

```html
<!DOCTYPE html>
<html>
<head>
    <title>SKY HAULER Terms of Service</title>
</head>
<body>
    <h1>Terms of Service for SKY HAULER: HEAVY FUEL</h1>
    <p><strong>Effective Date:</strong> January 18, 2026</p>

    <h2>Acceptance of Terms</h2>
    <p>By downloading and playing SKY HAULER: HEAVY FUEL, you agree to these terms.</p>

    <h2>Description of Service</h2>
    <p>SKY HAULER is a mobile game available for Android devices.</p>

    <h2>User Conduct</h2>
    <ul>
        <li>Use the game for personal, non-commercial purposes only</li>
        <li>Do not attempt to reverse engineer or modify the game</li>
        <li>Respect other players and the game community</li>
    </ul>

    <h2>Intellectual Property</h2>
    <p>All game content, trademarks, and copyrights belong to the game developer.</p>

    <h2>Disclaimer</h2>
    <p>The game is provided "as is" without warranties. We are not responsible for any damages.</p>

    <h2>Limitation of Liability</h2>
    <p>Our liability is limited to the amount paid for the game (which is free).</p>

    <h2>Governing Law</h2>
    <p>These terms are governed by the laws of [Your Country/State].</p>

    <h2>Contact Information</h2>
    <p>For questions, contact support@yourwebsite.com</p>
</body>
</html>
```

## 🏷️ Store Listing Checklist

### Before Publishing
- [ ] Create Google Play Developer Account ($25 one-time fee)
- [ ] Prepare all required graphics (icon, feature graphic, screenshots)
- [ ] Write compelling app description
- [ ] Create privacy policy and terms of service
- [ ] Test app thoroughly on multiple devices
- [ ] Build release APK or AAB file
- [ ] Set up app signing (Google recommends App Bundle)

### Google Play Console Steps
1. **Create App**
   - Choose app name and default language
   - Select app type (Game)

2. **Store Listing**
   - Upload app icon and feature graphic
   - Write short and full descriptions
   - Add screenshots (2-8 images)
   - Set category and tags
   - Add contact information

3. **Content Rating**
   - Submit for content rating questionnaire
   - Wait for rating approval

4. **Pricing & Distribution**
   - Set price (Free)
   - Choose countries for distribution
   - Set content guidelines

5. **App Release**
   - Upload APK/AAB file
   - Add release notes
   - Submit for review

### Post-Publish Tasks
- [ ] Monitor crash reports and user feedback
- [ ] Respond to reviews
- [ ] Plan updates and new features
- [ ] Track download and engagement metrics

## 📊 Release Notes for Version 1.0.0

```
🎉 SKY HAULER: HEAVY FUEL - Launch Version! 🎉

Welcome to the ultimate cargo flying experience!

✈️ NEW FEATURES
• Innovative two-finger flight controls
• Realistic physics-based gameplay
• 4 unique cargo types with different challenges
• 4 upgradable aircraft with distinct capabilities
• Infinite procedural terrain generation
• Immersive sound effects and music
• Local leaderboard system

🎮 GAMEPLAY
• Master weight management and fuel economy
• Navigate treacherous terrain and weather
• Complete cargo delivery missions
• Unlock new planes and achievements

🎵 AUDIO & VISUALS
• Dynamic soundtrack that adapts to gameplay
• Satisfying sound effects for every action
• Smooth 60 FPS performance
• Haptic feedback support

Download now and prove you're the best cargo pilot in the skies!
```

## 🚀 Marketing Suggestions

### Social Media Posts
```
🚀 NEW GAME ALERT! 🚀

Just launched: SKY HAULER: HEAVY FUEL - The most addictive physics-based flying game!

✌️ Control your cargo plane with two fingers
⚖️ Master weight physics and fuel management
🛩️ Upgrade your fleet from Sparrow to Phoenix
💰 Deliver high-value cargo for massive rewards

Download now on Google Play! #SkyHauler #MobileGaming #PhysicsGame

[Link to Google Play Store]
```

### Keywords for ASO (App Store Optimization)
Primary: sky hauler, heavy fuel, cargo plane, flying game, physics game
Secondary: aerial delivery, aircraft simulator, mobile pilot, flight control, cargo game

### Target Audience
- Age: 13-35
- Interests: Action games, simulation games, physics-based games
- Platforms: Android users who enjoy challenging mobile games

## 🐛 Testing Checklist

### Pre-Release Testing
- [ ] Test on multiple Android devices (different screen sizes)
- [ ] Verify all cargo types work correctly
- [ ] Test plane upgrades and unlocks
- [ ] Check audio settings and sound effects
- [ ] Validate physics calculations
- [ ] Test save/load functionality
- [ ] Verify leaderboard system
- [ ] Check for crashes and performance issues

### Google Play Pre-Launch Report
- [ ] Run pre-launch report in Google Play Console
- [ ] Fix any critical issues found
- [ ] Address performance warnings
- [ ] Resolve security vulnerabilities

## 📞 Support Plan

### User Support Channels
- **Email**: support@yourwebsite.com
- **Website**: FAQ section on your site
- **In-App**: Settings menu with contact option

### Common Issues & Solutions
1. **No Sound**: Check device volume and in-app settings
2. **Performance Issues**: Restart device, check available storage
3. **Crashes**: Update to latest version, clear app cache
4. **Progress Lost**: Check if data is saved locally

---

**Ready to publish SKY HAULER: HEAVY FUEL to Google Play!** 🚀

This guide covers everything needed for a successful Google Play Store launch. Follow each section carefully to ensure compliance and maximize your game's visibility.
