#!/bin/bash
# Create empty placeholder MP3 files for game sounds

OUTPUT_DIR="assets/sounds"
mkdir -p "$OUTPUT_DIR"

echo "Creating placeholder sound files..."
echo "=================================================="

# Create a very small silent MP3 file as placeholder
# This is a minimal valid MP3 file (silence)
BASE64_SILENT_MP3="//uQxAAAAAAAAAAAAAAAAAAAAAAAWGluZwAAAA8AAAACAAADhAC7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7v////////////////////////////////8AAAA5TEFNRTMuMTAwVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//uQxDsAAANIAAAAAExgAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="

# List of sound files to create
SOUNDS=(
  "button_click"
  "plane_engine"
  "cargo_pickup"
  "cargo_delivery"
  "crash"
  "achievement"
  "whoosh"
  "coin_collect"
  "level_up"
  "warning"
  "menu_music"
  "gameplay_music"
)

for sound in "${SOUNDS[@]}"; do
  echo "$BASE64_SILENT_MP3" | base64 -d > "$OUTPUT_DIR/${sound}.mp3" 2>/dev/null || echo "//placeholder" > "$OUTPUT_DIR/${sound}.mp3"
  echo "✓ Created ${sound}.mp3"
done

echo "=================================================="
echo "All placeholder sound files created!"
echo ""
echo "Note: These are placeholder files."
echo "To create real sounds:"
echo "  1. Install ffmpeg: sudo apt install ffmpeg"
echo "  2. Run: bash generate_sounds.sh"
echo ""
echo "Or replace with your own sound files in assets/sounds/"
