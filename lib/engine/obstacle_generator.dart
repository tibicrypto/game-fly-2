import 'dart:math';
import '../config/game_config.dart';

class ObstacleGenerator {
  final Random _random = Random();
  final List<Obstacle> _obstacles = [];
  double _lastObstacleX = 0;
  double _currentDistance = 0;

  List<Obstacle> get obstacles => _obstacles;

  ObstacleGenerator({double startX = 500.0}) {
    _lastObstacleX = startX;
  }

  // Calculate difficulty multiplier based on distance
  double _getDifficultyMultiplier() {
    double multiplier =
        1.0 + (_currentDistance * GameConfig.difficultyIncreaseRate);
    return multiplier.clamp(1.0, GameConfig.maxDifficultyMultiplier);
  }

  void update(double currentX, double viewDistance) {
    // Update current distance
    _currentDistance = currentX;

    // Remove obstacles that are far behind the camera
    _obstacles.removeWhere((obstacle) => obstacle.x < currentX - 500);

    // Generate new obstacles ahead
    while (_lastObstacleX < currentX + viewDistance) {
      _generateNextObstacle();
    }

    // Update dynamic obstacles with random movement patterns
    for (var obstacle in _obstacles) {
      obstacle.update(0.016); // Approx 60 FPS delta

      // Apply random movement based on type
      switch (obstacle.type) {
        case ObstacleType.bird:
          _updateBirdMovement(obstacle);
          break;
        case ObstacleType.missile:
          _updateMissileMovement(obstacle);
          break;
        case ObstacleType.alien:
          _updateAlienMovement(obstacle);
          break;
        default:
          break;
      }
    }
  }

  void _updateBirdMovement(Obstacle bird) {
    // Birds change direction randomly
    if (bird.moveTimer <= 0) {
      // Pick new random target height across full screen
      bird.targetY = 50.0 + _random.nextDouble() * 700;
      bird.moveTimer = 1.0 + _random.nextDouble() * 2.0; // 1-3 seconds
    }

    // Move towards target height
    double diff = bird.targetY - bird.y;
    if (diff.abs() > 5) {
      bird.velocityY = diff.sign * (30.0 + _random.nextDouble() * 20.0);
    } else {
      bird.velocityY = 0;
    }

    // Random horizontal drift
    bird.velocityX = -5.0 + _random.nextDouble() * 10.0;
  }

  void _updateMissileMovement(Obstacle missile) {
    // Missiles move fast with slight wobble
    if (missile.moveTimer <= 0) {
      missile.velocityX = -missile.speed - _random.nextDouble() * 30.0;
      missile.velocityY =
          -30.0 + _random.nextDouble() * 60.0; // Random vertical
      missile.moveTimer = 0.3 + _random.nextDouble() * 0.5; // Quick changes
    }
  }

  void _updateAlienMovement(Obstacle alien) {
    // UFOs move in random patterns
    if (alien.moveTimer <= 0) {
      // Random direction change
      alien.velocityX = -alien.speed + _random.nextDouble() * 30.0 - 15.0;
      alien.targetY = 50.0 + _random.nextDouble() * 700.0; // Full screen height
      alien.moveTimer = 1.5 + _random.nextDouble() * 2.5; // 1.5-4 seconds
    }

    // Move towards target with smooth acceleration
    double diff = alien.targetY - alien.y;
    if (diff.abs() > 5) {
      alien.velocityY = diff.sign * (20.0 + _random.nextDouble() * 30.0);
    } else {
      alien.velocityY *= 0.9; // Slow down when close
    }
  }

  void _generateNextObstacle() {
    double difficulty = _getDifficultyMultiplier();

    // Distance between obstacles decreases as difficulty increases
    double minDist = GameConfig.obstacleMinDistance / difficulty;
    double maxDist = GameConfig.obstacleMaxDistance / difficulty;

    // Random distance to next obstacle with more variation
    double distance = minDist + _random.nextDouble() * (maxDist - minDist);
    // Add extra randomness - sometimes cluster obstacles, sometimes spread them out
    if (_random.nextDouble() < 0.2) {
      distance *= 0.5; // 20% chance of closer obstacle
    } else if (_random.nextDouble() < 0.15) {
      distance *= 1.8; // 15% chance of farther obstacle
    }
    _lastObstacleX += distance;

    // Random obstacle type with difficulty-based probabilities
    ObstacleType type;
    double rand = _random.nextDouble();

    // As difficulty increases, more dangerous obstacles appear
    // Early game (difficulty 1.0): Easy obstacles
    // Late game (difficulty 3.0): More missiles and aliens
    double birdChance = 0.35 - (difficulty - 1.0) * 0.1; // 35% -> 15%
    double mountainChance =
        birdChance + (0.25 - (difficulty - 1.0) * 0.05); // 25% -> 15%
    double planeChance = mountainChance + 0.15; // 15% stays same
    double missileChance =
        planeChance + (0.15 + (difficulty - 1.0) * 0.15); // 15% -> 45%
    // Remaining goes to alien

    if (rand < birdChance) {
      type = ObstacleType.bird;
    } else if (rand < mountainChance) {
      type = ObstacleType.mountain;
    } else if (rand < planeChance) {
      type = ObstacleType.plane;
    } else if (rand < missileChance) {
      type = ObstacleType.missile;
    } else {
      type = ObstacleType.alien;
    }

    _obstacles.add(_createObstacle(type, _lastObstacleX));
  }

  Obstacle _createObstacle(ObstacleType type, double x) {
    switch (type) {
      case ObstacleType.mountain:
        // Mountains are tall obstacles from ground
        return Obstacle(
          type: type,
          x: x,
          y: 0, // From ground
          width: 100.0 + _random.nextDouble() * 50,
          height: 200.0 + _random.nextDouble() * 200,
        );

      case ObstacleType.bird:
        // Birds fly at completely random heights across the screen with various patterns
        double difficulty = _getDifficultyMultiplier();
        double initialY = 50.0 + _random.nextDouble() * 700;

        // Randomly choose movement pattern for birds
        MovementPattern pattern = MovementPattern
            .values[_random.nextInt(MovementPattern.values.length)];

        return Obstacle(
          type: type,
          x: x,
          y: initialY,
          width: 30.0,
          height: 20.0,
          speed: 15.0 * difficulty,
          velocityX: (-5.0 + _random.nextDouble() * 10.0) * difficulty,
          velocityY: (-10.0 + _random.nextDouble() * 20.0) * difficulty,
          moveTimer: _random.nextDouble() * 2.0,
          targetY: 50.0 + _random.nextDouble() * 700,
          movementPattern: pattern,
          amplitude: 50.0 + _random.nextDouble() * 100.0,
          frequency: 2.0 + _random.nextDouble() * 4.0,
          baseY: initialY,
          diagonalDirection: _random.nextBool() ? 1.0 : -1.0,
        );

      case ObstacleType.missile:
        // Missiles with zigzag or diagonal patterns
        double difficulty = _getDifficultyMultiplier();
        double initialY = 50.0 + _random.nextDouble() * 700;

        // Missiles prefer zigzag or diagonal patterns
        MovementPattern pattern = _random.nextDouble() < 0.5
            ? MovementPattern.zigzag
            : MovementPattern.diagonal;

        return Obstacle(
          type: type,
          x: x + 200,
          y: initialY,
          width: 40.0,
          height: 15.0,
          speed: (80.0 + _random.nextDouble() * 50.0) * difficulty,
          velocityX: (-80.0 - _random.nextDouble() * 50.0) * difficulty,
          velocityY: (-20.0 + _random.nextDouble() * 40.0) * difficulty,
          moveTimer: _random.nextDouble() * 0.5 / difficulty,
          movementPattern: pattern,
          amplitude: 80.0 + _random.nextDouble() * 120.0,
          frequency: 3.0 + _random.nextDouble() * 5.0,
          baseY: initialY,
          diagonalDirection: _random.nextBool() ? 1.0 : -1.0,
        );

      case ObstacleType.plane:
        // Planes with curved or straight flight paths
        double initialY = 50.0 + _random.nextDouble() * 700;

        // Planes prefer curved or straight patterns
        MovementPattern pattern = _random.nextDouble() < 0.6
            ? MovementPattern.curved
            : MovementPattern.straight;

        return Obstacle(
          type: type,
          x: x,
          y: initialY,
          width: 50.0,
          height: 30.0,
          movementPattern: pattern,
          amplitude: 40.0 + _random.nextDouble() * 80.0,
          frequency: 1.5 + _random.nextDouble() * 3.0,
          baseY: initialY,
          velocityX: -20.0 - _random.nextDouble() * 10.0,
        );

      case ObstacleType.alien:
        // UFOs with unpredictable movement patterns
        double difficulty = _getDifficultyMultiplier();
        double initialY = 50.0 + _random.nextDouble() * 700;

        // Aliens can use any movement pattern
        MovementPattern pattern = MovementPattern
            .values[_random.nextInt(MovementPattern.values.length)];

        return Obstacle(
          type: type,
          x: x + 150,
          y: initialY,
          width: 45.0,
          height: 35.0,
          speed: (40.0 + _random.nextDouble() * 40.0) * difficulty,
          velocityX: (-50.0 + _random.nextDouble() * 30.0) * difficulty,
          velocityY: (-15.0 + _random.nextDouble() * 30.0) * difficulty,
          moveTimer: _random.nextDouble() * 2.5 / difficulty,
          targetY: 50.0 + _random.nextDouble() * 700,
          movementPattern: pattern,
          amplitude: 60.0 + _random.nextDouble() * 140.0,
          frequency: 2.5 + _random.nextDouble() * 4.5,
          baseY: initialY,
          diagonalDirection: _random.nextBool() ? 1.0 : -1.0,
        );
    }
  }

  List<Obstacle> getObstaclesInRange(double minX, double maxX) {
    return _obstacles
        .where((obstacle) =>
            obstacle.isActive &&
            obstacle.x + obstacle.width >= minX &&
            obstacle.x <= maxX)
        .toList();
  }

  void reset() {
    _obstacles.clear();
    _lastObstacleX = 500.0;
  }
}
