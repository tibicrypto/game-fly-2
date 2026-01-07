# Sound System Documentation

## Overview
The game now includes a comprehensive sound system with background music, sound effects, and volume controls.

## Features

### Sound Manager (`lib/services/sound_manager.dart`)
- Centralized audio management
- Persistent volume settings
- Separate controls for music and sound effects
- Background music looping
- Sound effect playback

### Sound Effects
The following sound effects are integrated throughout the game:

1. **button_click** - UI button interactions
2. **plane_engine** - Starting flight
3. **cargo_pickup** - Selecting cargo
4. **cargo_delivery** - Successful cargo delivery
5. **crash** - Plane collision with terrain/obstacles
6. **achievement** - New record achieved
7. **whoosh** - Cargo jettison
8. **coin_collect** - Collecting coins
9. **level_up** - Level progression
10. **warning** - Low fuel alert

### Background Music
- **menu_music** - Plays in menu screen
- **gameplay_music** - Plays during active gameplay

## Integration Points

### Menu Screen
- Music starts automatically
- Button clicks have sound effects
- Sound settings button in top left
- Volume controls via settings dialog

### Cargo Selection
- Button clicks
- Cargo selection sound

### Plane Selection
- Button clicks
- Plane selection sound
- Engine sound on takeoff

### Gameplay
- Crash sounds on collision
- Warning sound for low fuel
- Whoosh sound when jettisoning cargo
- Background music loops

### Game Over
- Music stops
- Achievement sound for new records
- Button click sounds

## Sound Settings UI
Access from menu screen (speaker icon in top left):
- Toggle music on/off
- Adjust music volume (0-100%)
- Toggle sound effects on/off
- Adjust SFX volume (0-100%)
- Settings persist between sessions

## Customizing Sounds

### Option 1: Use FFmpeg (Recommended)
```bash
# Install ffmpeg
sudo apt install ffmpeg

# Generate sounds
cd /home/tibi/game-fly-2
bash generate_sounds.sh
```

### Option 2: Use Your Own Sound Files
Replace the placeholder files in `assets/sounds/` with your own MP3 files. Keep the same filenames:
- All sound files must be in MP3 format
- Recommended: Short duration for SFX (0.1-1.0s)
- Recommended: Loopable tracks for music (10-30s)

### Option 3: Professional Sound Libraries
Download free sound effects from:
- [Freesound.org](https://freesound.org)
- [OpenGameArt.org](https://opengameart.org)
- [Zapsplat.com](https://www.zapsplat.com)

## Technical Details

### Audio Package
Uses `audioplayers` package (v6.5.1) for audio playback.

### Storage
Volume settings stored in SharedPreferences:
- `music_volume` (0.0 - 1.0)
- `sfx_volume` (0.0 - 1.0)
- `music_enabled` (boolean)
- `sfx_enabled` (boolean)

### Performance
- Two audio players: one for music, one for SFX
- Music loops automatically
- SFX stops previous sound when playing new one
- Minimal memory footprint with small sound files

## Troubleshooting

### Sounds not playing
1. Check volume settings in Sound Settings dialog
2. Verify sound files exist in `assets/sounds/`
3. Ensure device volume is not muted

### Poor sound quality
1. Install ffmpeg and regenerate sounds
2. Replace with professional sound files
3. Adjust format/bitrate of MP3 files

### App size concerns
- Current placeholder files are minimal (~14 bytes each)
- Full quality sounds will add 1-5 MB to app size
- Consider compressing MP3 files to reduce size

## Future Enhancements
- [ ] Doppler effect for passing obstacles
- [ ] Wind sound based on velocity
- [ ] Engine pitch variation with throttle
- [ ] Ambient environment sounds
- [ ] Voice notifications
- [ ] Custom sound packs
