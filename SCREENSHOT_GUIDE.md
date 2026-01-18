# Screenshot Guide for Google Play Store - SKY HAULER

## 📱 Required Screenshots (2-8 images)

You need high-quality screenshots showing different aspects of your game. Each screenshot should be:
- **Resolution**: 1080 x 1920 pixels (9:16 aspect ratio)
- **Format**: JPG or 24-bit PNG
- **Size**: Under 15MB each
- **Content**: Clean, no overlays or watermarks

## 🎮 Recommended Screenshot Scenes

### 1. Main Menu (Required)
- Show the game title and main menu options
- Include "Start Game" and settings buttons
- Clean, attractive presentation

### 2. Cargo Selection Screen (Required)
- Display different cargo types (Mail, Food, Gold, Uranium)
- Show weight, reward, and difficulty levels
- Highlight the selection interface

### 3. Plane Selection Screen (Required)
- Show all available planes (Sparrow, Eagle, Falcon, Phoenix)
- Display stats: weight, power, fuel capacity, price
- Show locked/unlocked status

### 4. Active Gameplay (Required)
- Show the plane in flight with terrain
- Display controls (two-finger indicators)
- Show fuel gauge and physics in action
- Capture dynamic moment

### 5. Physics Demonstration
- Show weight effects (plane tilting with fuel)
- Demonstrate refueling mechanics
- Show terrain interaction

### 6. Game Over / Success Screen
- Show final score and statistics
- Display leaderboard position
- Show achievement notifications

### 7. Settings / Audio Screen
- Show sound controls and settings
- Demonstrate customization options

### 8. Achievement / Reward Screen (Optional)
- Show unlocking new planes
- Display high scores or milestones

## 📷 How to Take Screenshots

### Method 1: Android Emulator
```bash
# Run on emulator
flutter run

# Take screenshot (press F12 or use Android Studio)
# Or use adb command:
adb exec-out screencap -p > screenshot.png
```

### Method 2: Physical Device
```bash
# Connect device and run
flutter run

# Use adb to capture:
adb exec-out screencap -p > screenshot.png
```

### Method 3: Android Studio
1. Open Android Studio
2. Run app on device/emulator
3. Go to Logcat > Screenshot (camera icon)
4. Save as PNG

## 🖼️ Screenshot Editing Guidelines

### Use Image Editing Software
- **GIMP** (Free): https://www.gimp.org/
- **Photoshop** (Paid)
- **Online Tools**: Canva, Pixlr

### Editing Steps
1. **Crop to 9:16 ratio** (1080x1920)
2. **Remove status bar** if visible
3. **Adjust brightness/contrast** for visibility
4. **Add subtle vignette** for depth (optional)
5. **Ensure text is readable**
6. **Save as JPG** with 90% quality

### Design Tips
- **Clean backgrounds**: Remove distractions
- **Highlight key elements**: Use subtle arrows or highlights
- **Consistent style**: Same filter/effects across all screenshots
- **Show progression**: Order screenshots to tell a story

## 📁 File Naming Convention

```
sky_hauler_screenshot_01_main_menu.jpg
sky_hauler_screenshot_02_cargo_selection.jpg
sky_hauler_screenshot_03_plane_selection.jpg
sky_hauler_screenshot_04_gameplay.jpg
sky_hauler_screenshot_05_physics_demo.jpg
sky_hauler_screenshot_06_game_over.jpg
sky_hauler_screenshot_07_settings.jpg
sky_hauler_screenshot_08_achievement.jpg
```

## 🎨 Feature Graphic Creation

### Requirements
- **Size**: 1024 x 500 pixels
- **Format**: JPG or PNG
- **Style**: Eye-catching, professional
- **Content**: Game title, key visuals, call-to-action

### Design Elements
- **Background**: Sky gradient with clouds
- **Main Image**: Cargo plane in flight
- **Text**: "SKY HAULER: HEAVY FUEL"
- **Tagline**: "Master the Skies" or similar
- **Colors**: Blue sky, orange accents

## 🛠️ Automation Script

Create a simple script to capture multiple screenshots:

```bash
#!/bin/bash
# screenshot_capture.sh

echo "Capturing screenshots for Google Play Store..."

# Function to capture screenshot
capture_screenshot() {
    local filename=$1
    adb exec-out screencap -p > "screenshots/${filename}.png"
    echo "Captured: ${filename}.png"
    sleep 2  # Wait between captures
}

# Create screenshots directory
mkdir -p screenshots

# Navigate through app and capture
# (You'll need to manually navigate the app)
echo "Manually navigate the app and run these commands:"

echo "1. Main Menu:"
echo "capture_screenshot '01_main_menu'"

echo "2. Cargo Selection:"
echo "capture_screenshot '02_cargo_selection'"

echo "3. Plane Selection:"
echo "capture_screenshot '03_plane_selection'"

echo "4. Gameplay:"
echo "capture_screenshot '04_gameplay'"

echo "Done! Edit and crop images as needed."
```

## ✅ Quality Checklist

Before uploading to Google Play:

- [ ] All screenshots are 1080x1920 resolution
- [ ] Images are under 15MB each
- [ ] No device frames or status bars visible
- [ ] Text is clear and readable
- [ ] Game content is properly showcased
- [ ] Consistent visual style across all images
- [ ] Feature graphic meets 1024x500 requirements
- [ ] App icon is 512x512 with transparent background

## 📤 Upload to Google Play Console

1. Go to Google Play Console
2. Select your app
3. Go to "Store presence" > "Main store listing"
4. Upload feature graphic
5. Upload screenshots in order (they appear left to right)
6. Save changes

---

**Remember**: Screenshots are crucial for user acquisition. Make them compelling and representative of your game's best features!