#!/bin/bash

# SKY HAULER - Release Build Script
# This script builds release versions of the app for Google Play Store

echo "🚀 Building SKY HAULER: HEAVY FUEL for Google Play Store"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Navigate to project root (assuming script is run from project root)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

print_status "Project root: $PROJECT_ROOT"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Check for any issues
print_status "Analyzing code..."
flutter analyze

# Build APK (for testing and backup)
print_status "Building release APK..."
flutter build apk --release --target-platform android-arm,android-arm64,android-x64

if [ $? -eq 0 ]; then
    print_status "APK built successfully: build/app/outputs/flutter-apk/app-release.apk"
else
    print_error "APK build failed"
    exit 1
fi

# Build App Bundle (recommended for Google Play)
print_status "Building App Bundle (AAB)..."
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64

if [ $? -eq 0 ]; then
    print_status "App Bundle built successfully: build/app/outputs/bundle/release/app-release.aab"
else
    print_error "App Bundle build failed"
    exit 1
fi

# Generate build summary
echo ""
echo "======================================================"
print_status "BUILD SUMMARY"
echo "======================================================"
echo "APK Location: $PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
echo "AAB Location: $PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
echo ""
print_status "Next steps:"
echo "1. Test the APK on your device"
echo "2. Upload the AAB file to Google Play Console"
echo "3. Fill out store listing information"
echo "4. Submit for review"
echo ""
print_warning "Remember to:"
echo "- Update version code in pubspec.yaml for future updates"
echo "- Keep your signing keys safe"
echo "- Test on multiple devices before publishing"

echo ""
print_status "Build completed successfully! 🎉"