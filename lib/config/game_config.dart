import 'dart:math';

class GameConfig {
  // Physics constants
  static const double gravity = 9.8;
  static const double refuelSpeed = 3.5;
  static const double fuelWeightRatio = 0.8;
  static const double baseThrust = 12.0;
  static const double maxThrust = 20.0;
  static const double idleThrust = 2.0;
  static const double fuelBurnRate = 2.5;
  static const double horizontalSpeed = 100.0;

  // Obstacle settings
  static const double obstacleMinDistance = 200.0;
  static const double obstacleMaxDistance = 400.0;

  // Difficulty scaling
  static const double difficultyIncreaseRate = 0.001; // Difficulty per meter
  static const double maxDifficultyMultiplier = 3.0; // Cap at 3x difficulty

  // Terrain generation
  static const double noiseFrequency = 0.02;
  static const double noiseAmplitude = 300.0;
  static const double groundBaseHeight = 100.0;

  // Cloud ceiling
  static const double cloudCeilingHeight = 600.0;
  static const double lightningDamage = 2.0;

  // Screen scaling
  static const double gameWorldHeight = 800.0;
  static const double gameWorldWidth = 1200.0;

  // Visual feedback
  static const bool enableVibration = true;
  static const int vibrationDuration = 100;

  // Daily events (can be loaded from server)
  static double windForce = 0.0;
  static double bonusGoldMultiplier = 1.0;
}

enum CargoType {
  mail,
  food,
  gold,
  uranium,
}

class CargoClass {
  final CargoType type;
  final String name;
  final double weight;
  final int reward;
  final String description;
  final bool explosive;

  const CargoClass({
    required this.type,
    required this.name,
    required this.weight,
    required this.reward,
    required this.description,
    this.explosive = false,
  });

  static const List<CargoClass> all = [
    CargoClass(
      type: CargoType.food,
      name: 'Food (Class B)',
      weight: 40.0,
      reward: 300,
      description: 'Medium weight - Moderate',
    ),
    CargoClass(
      type: CargoType.gold,
      name: 'Gold (Class A)',
      weight: 100.0,
      reward: 1000,
      description: 'Heavy cargo - Difficult',
    ),
    CargoClass(
      type: CargoType.uranium,
      name: 'Uranium (Class S)',
      weight: 200.0,
      reward: 5000,
      description: 'Explosive! Extreme difficulty',
      explosive: true,
    ),
  ];

  static CargoClass getByType(CargoType type) {
    return all.firstWhere((cargo) => cargo.type == type);
  }
}

enum ObstacleType {
  mountain,
  bird,
  missile,
  plane,
  alien,
}

enum MovementPattern {
  straight, // Di chuyển thẳng
  curved, // Đường cong (sine wave)
  diagonal, // Đường chéo lên/xuống
  zigzag, // Đường zigzag
}

class Obstacle {
  final ObstacleType type;
  double x;
  double y;
  final double width;
  final double height;
  final double speed;
  bool isActive;

  // Random movement properties
  double velocityX;
  double velocityY;
  double moveTimer;
  double targetY;

  // Movement pattern properties
  final MovementPattern movementPattern;
  double movementTime; // Time elapsed for pattern calculation
  double amplitude; // Amplitude for curved/zigzag movements
  double frequency; // Frequency for wave patterns
  double baseY; // Base Y position for pattern movements
  double diagonalDirection; // Direction for diagonal movement (1 or -1)

  Obstacle({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.speed = 0.0,
    this.isActive = true,
    this.velocityX = 0.0,
    this.velocityY = 0.0,
    this.moveTimer = 0.0,
    double? targetY,
    this.movementPattern = MovementPattern.straight,
    this.movementTime = 0.0,
    this.amplitude = 0.0,
    this.frequency = 0.0,
    double? baseY,
    this.diagonalDirection = 1.0,
  })  : targetY = targetY ?? y,
        baseY = baseY ?? y;

  void update(double deltaTime) {
    movementTime += deltaTime;

    // Apply movement pattern
    switch (movementPattern) {
      case MovementPattern.curved:
        // Sine wave movement
        y = baseY + amplitude * sin(movementTime * frequency);
        x += velocityX * deltaTime;
        break;

      case MovementPattern.diagonal:
        // Diagonal up/down movement
        x += velocityX * deltaTime;
        y += diagonalDirection * speed * deltaTime;
        // Bounce off screen edges
        if (y < 50 || y > 750) {
          diagonalDirection *= -1;
        }
        break;

      case MovementPattern.zigzag:
        // Zigzag pattern - sharp direction changes
        x += velocityX * deltaTime;
        if (moveTimer <= 0) {
          diagonalDirection *= -1;
          moveTimer = 0.5; // Change direction every 0.5 seconds
        }
        y += diagonalDirection * amplitude * deltaTime * 100;
        // Keep within screen bounds
        y = y.clamp(50.0, 750.0);
        break;

      case MovementPattern.straight:
        // Standard movement
        x += velocityX * deltaTime;
        y += velocityY * deltaTime;
        break;
    }

    // Update timer for movement changes
    moveTimer -= deltaTime;
  }

  bool collidesWith(
      double planeX, double planeY, double planeWidth, double planeHeight) {
    if (!isActive) return false;

    return planeX < x + width &&
        planeX + planeWidth > x &&
        planeY < y + height &&
        planeY + planeHeight > y;
  }
}

class PlaneStats {
  final String name;
  final double baseWeight;
  final double liftPower;
  final double fuelEfficiency;
  final double maxFuelCapacity;
  final int price;
  final String description;

  const PlaneStats({
    required this.name,
    required this.baseWeight,
    required this.liftPower,
    required this.fuelEfficiency,
    required this.maxFuelCapacity,
    required this.price,
    required this.description,
  });

  static const List<PlaneStats> all = [
    PlaneStats(
      name: 'Sparrow',
      baseWeight: 50.0,
      liftPower: 15.0,
      fuelEfficiency: 0.3,
      maxFuelCapacity: 50.0,
      price: 0,
      description: 'Starter plane - Light and nimble',
    ),
    PlaneStats(
      name: 'Eagle',
      baseWeight: 80.0,
      liftPower: 22.0,
      fuelEfficiency: 0.5,
      maxFuelCapacity: 80.0,
      price: 500,
      description: 'Balanced performance',
    ),
    PlaneStats(
      name: 'Falcon',
      baseWeight: 120.0,
      liftPower: 30.0,
      fuelEfficiency: 0.7,
      maxFuelCapacity: 120.0,
      price: 1500,
      description: 'Heavy hauler',
    ),
    PlaneStats(
      name: 'Phoenix',
      baseWeight: 150.0,
      liftPower: 40.0,
      fuelEfficiency: 0.9,
      maxFuelCapacity: 150.0,
      price: 5000,
      description: 'Ultimate cargo carrier',
    ),
  ];
}
