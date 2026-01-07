#!/bin/bash
# Generate simple sound effects using ffmpeg

OUTPUT_DIR="assets/sounds"
mkdir -p "$OUTPUT_DIR"

echo "Generating game sound effects using ffmpeg..."
echo "=================================================="

# Button click - short beep
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.1" -af "afade=t=out:st=0.05:d=0.05" "$OUTPUT_DIR/button_click.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated button_click.mp3"

# Plane engine - low rumble
ffmpeg -f lavfi -i "sine=frequency=80:duration=2" -af "volume=0.5" "$OUTPUT_DIR/plane_engine.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated plane_engine.mp3"

# Cargo pickup - rising tone
ffmpeg -f lavfi -i "sine=frequency=400:duration=0.4" -af "afade=t=out:st=0.2:d=0.2" "$OUTPUT_DIR/cargo_pickup.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated cargo_pickup.mp3"

# Cargo delivery - success tone
ffmpeg -f lavfi -i "sine=frequency=523:duration=0.5" -af "afade=t=out:st=0.3:d=0.2" "$OUTPUT_DIR/cargo_delivery.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated cargo_delivery.mp3"

# Crash - low thud
ffmpeg -f lavfi -i "sine=frequency=100:duration=0.8" -af "afade=t=out:st=0.4:d=0.4,volume=0.8" "$OUTPUT_DIR/crash.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated crash.mp3"

# Achievement - high tone
ffmpeg -f lavfi -i "sine=frequency=784:duration=0.8" -af "afade=t=out:st=0.5:d=0.3" "$OUTPUT_DIR/achievement.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated achievement.mp3"

# Whoosh - sweep
ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.3" -af "afade=t=out:st=0.1:d=0.2,volume=0.5" "$OUTPUT_DIR/whoosh.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated whoosh.mp3"

# Coin collect - ding
ffmpeg -f lavfi -i "sine=frequency=1200:duration=0.3" -af "afade=t=out:st=0.15:d=0.15,volume=0.5" "$OUTPUT_DIR/coin_collect.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated coin_collect.mp3"

# Level up - ascending tone
ffmpeg -f lavfi -i "sine=frequency=587:duration=1.0" -af "afade=t=out:st=0.7:d=0.3" "$OUTPUT_DIR/level_up.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated level_up.mp3"

# Warning - alternating tone
ffmpeg -f lavfi -i "sine=frequency=600:duration=0.5" -af "volume=0.5" "$OUTPUT_DIR/warning.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated warning.mp3"

# Menu music - calm tone
ffmpeg -f lavfi -i "sine=frequency=262:duration=10" -af "volume=0.3" "$OUTPUT_DIR/menu_music.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated menu_music.mp3"

# Gameplay music - energetic tone
ffmpeg -f lavfi -i "sine=frequency=294:duration=15" -af "volume=0.3" "$OUTPUT_DIR/gameplay_music.mp3" -y -loglevel error 2>/dev/null
echo "✓ Generated gameplay_music.mp3"

echo "=================================================="
echo "All sound files generated successfully!"
echo ""
echo "Note: These are simple synthesized sounds."
echo "For better quality, replace them with professional sound effects."
