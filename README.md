# SKY HAULER: HEAVY FUEL 🛩️⛽

A mobile game built with Flutter where you control a cargo plane using two-finger controls while managing fuel weight and physics!

## Game Features

### 🎮 Core Mechanics
- **Two-Finger Control**: Hold 2 fingers to refuel and thrust
- **Weight Physics**: Fuel adds weight, making your plane harder to fly
- **Procedural Terrain**: Infinite terrain generated using Perlin noise
- **Multiple Cargo Types**: 4 classes from easy mail to explosive uranium
- **Upgradable Planes**: 4 aircraft with different stats
- **Jettison System**: Swipe down to emergency-drop cargo

### 🎯 Game Loop
1. Select a cargo contract (higher weight = higher reward)
2. Choose your plane (must balance cargo weight with plane capacity)
3. Fly through procedurally generated terrain
4. Manage fuel carefully (more fuel = heavier plane)
5. Avoid crashing, running out of fuel, or hitting lightning clouds
6. Earn money to unlock better planes

### ⚖️ Physics System
The game uses realistic weight-based physics:
- **Total Weight** = Plane Weight + Cargo Weight + (Fuel × 0.8)
- **Thrust** varies based on refueling state
- Balance is key: too much fuel makes you heavy, too little and you fall

## Project Structure

```
lib/
├── config/
│   └── game_config.dart         # Game constants and balance
├── engine/
│   ├── physics_engine.dart      # Core physics calculations
│   └── terrain_generator.dart   # Perlin noise terrain
├── screens/
│   ├── menu_screen.dart         # Main menu
│   ├── cargo_selection_screen.dart
│   ├── plane_selection_screen.dart
│   ├── game_screen.dart         # Main gameplay
│   └── game_over_screen.dart
├── state/
│   └── game_state_manager.dart  # Game state with Provider
└── main.dart
```

## How to Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. **Navigate to the project**
```bash
cd /home/tibi/game-fly-2
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run on Android**
```bash
flutter run
```

4. **Run on iOS** (Mac only)
```bash
flutter run
```

5. **Build APK for Android**
```bash
flutter build apk --release
```

6. **Build for iOS** (Mac only)
```bash
flutter build ios --release
```

## Controls

- **✌️ Hold 2 Fingers**: Refuel and activate thrust
- **🤚 Release**: Glide and consume less fuel
- **👇 Swipe Down**: Emergency jettison cargo (lose reward but save your flight)

## Game Tips

1. **Don't overfuel**: More fuel = heavier plane = harder to control
2. **Learn the rhythm**: Tap refuel in bursts rather than holding constantly
3. **Watch the terrain**: Look ahead to prepare for climbs
4. **Use jettison wisely**: Better to lose cargo than crash completely
5. **Match plane to cargo**: Heavy cargo needs powerful planes

## Technical Features

- **Responsive Design**: Auto-scales to any mobile screen size
- **60 FPS Physics**: Smooth gameplay with fixed timestep
- **Terrain Caching**: Optimized Perlin noise generation
- **State Management**: Provider pattern for clean architecture
- **Portrait Lock**: Optimized for portrait mode gameplay
- **Haptic Feedback**: Vibration on refueling and events

## Cargo Classes

| Class | Weight | Reward | Difficulty |
|-------|--------|--------|------------|
| C - Mail | 10kg | $100 | Easy |
| B - Food | 40kg | $300 | Medium |
| A - Gold | 100kg | $1000 | Hard |
| S - Uranium | 200kg | $5000 | Extreme (Explosive!) |

## Plane Stats

| Plane | Weight | Power | Fuel Cap | Price |
|-------|--------|-------|----------|-------|
| Sparrow | 50 | 15 | 50 | FREE |
| Eagle | 80 | 22 | 80 | $500 |
| Falcon | 120 | 30 | 120 | $1500 |
| Phoenix | 150 | 40 | 150 | $5000 |

## Configuration

Game balance can be adjusted in `lib/config/game_config.dart`:
- Gravity
- Refuel speed
- Fuel weight ratio
- Terrain generation parameters
- Cloud ceiling height

## Graphics Suggestion

Since this is a code-first implementation, here are recommended graphics to add:

1. **Plane sprites**: Side-view aircraft with animation frames
2. **Terrain textures**: Grass, rock, snow layers
3. **Cloud sprites**: Animated storm clouds at ceiling
4. **Particle effects**: Engine flames, explosion effects, fuel droplets
5. **UI elements**: Gauge needles, warning lights, cargo icons
6. **Background**: Parallax sky layers with moving clouds

To add graphics, place assets in `assets/images/` and update `pubspec.yaml`.

## License

This project is open source and available for modification.

## Credits

Game design inspired by classic physics-based flying games with modern mobile controls.