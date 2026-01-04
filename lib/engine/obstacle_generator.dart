import 'dart:math';
import '../config/game_config.dart';

class ObstacleGenerator {
  final Random _random = Random();
  final List<Obstacle> _obstacles = [];
  double _lastObstacleX = 0;

  List<Obstacle> get obstacles => _obstacles;

  ObstacleGenerator({double startX = 500.0}) {
    _lastObstacleX = startX;
  }

  void update(double currentX, double viewDistance) {
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
      // Pick new random target height
      bird.targetY = 150.0 + _random.nextDouble() * 350;
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
    bird.velocityX = -10.0 + _random.nextDouble() * 20.0;
  }

  void _updateMissileMovement(Obstacle missile) {
    // Missiles move fast with slight wobble
    if (missile.moveTimer <= 0) {
      missile.velocityX = -missile.speed - _random.nextDouble() * 50.0;
      missile.velocityY =
          -30.0 + _random.nextDouble() * 60.0; // Random vertical
      missile.moveTimer = 0.3 + _random.nextDouble() * 0.5; // Quick changes
    }
  }

  void _updateAlienMovement(Obstacle alien) {
    // UFOs move in random patterns
    if (alien.moveTimer <= 0) {
      // Random direction change
      alien.velocityX = -alien.speed + _random.nextDouble() * 40.0 - 20.0;
      alien.targetY = 250.0 + _random.nextDouble() * 250.0;
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
    double minDist = GameConfig.obstacleMinDistance;
    double maxDist = GameConfig.obstacleMaxDistance;

    // Random distance to next obstacle with more variation
    double distance = minDist + _random.nextDouble() * (maxDist - minDist);
    // Add extra randomness - sometimes cluster obstacles, sometimes spread them out
    if (_random.nextDouble() < 0.2) {
      distance *= 0.5; // 20% chance of closer obstacle
    } else if (_random.nextDouble() < 0.15) {
      distance *= 1.8; // 15% chance of farther obstacle
    }
    _lastObstacleX += distance;

    // Random obstacle type (weighted probabilities)
    ObstacleType type;
    double rand = _random.nextDouble();

    if (rand < 0.35) {
      type = ObstacleType.bird; // 35% chance
    } else if (rand < 0.60) {
      type = ObstacleType.mountain; // 25% chance
    } else if (rand < 0.75) {
      type = ObstacleType.plane; // 15% chance
    } else if (rand < 0.90) {
      type = ObstacleType.missile; // 15% chance
    } else {
      type = ObstacleType.alien; // 10% chance
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
        // Birds fly at various heights with random initial movement
        double initialY = 150.0 + _random.nextDouble() * 300;
        return Obstacle(
          type: type,
          x: x,
          y: initialY,
          width: 30.0,
          height: 20.0,
          speed: 25.0,
          velocityX: -10.0 + _random.nextDouble() * 20.0,
          velocityY: -20.0 + _random.nextDouble() * 40.0,
          moveTimer: _random.nextDouble() * 2.0,
          targetY: 150.0 + _random.nextDouble() * 350,
        );

      case ObstacleType.missile:
        // Missiles come from ahead with random trajectory
        double initialY = 200.0 + _random.nextDouble() * 250;
        return Obstacle(
          type: type,
          x: x + 200, // Start further ahead
          y: initialY,
          width: 40.0,
          height: 15.0,
          speed: 150.0 + _random.nextDouble() * 100.0,
          velocityX: -150.0 - _random.nextDouble() * 100.0,
          velocityY: -40.0 + _random.nextDouble() * 80.0,
          moveTimer: _random.nextDouble() * 0.5,
        );

      case ObstacleType.plane:
        // Other planes fly at mid height
        return Obstacle(
          type: type,
          x: x,
          y: 250.0 + _random.nextDouble() * 200,
          width: 50.0,
          height: 30.0,
        );

      case ObstacleType.alien:
        // UFOs/aliens float around randomly
        double initialY = 250.0 + _random.nextDouble() * 250;
        return Obstacle(
          type: type,
          x: x + 150,
          y: initialY,
          width: 45.0,
          height: 35.0,
          speed: 60.0 + _random.nextDouble() * 60.0,
          velocityX: -80.0 + _random.nextDouble() * 40.0,
          velocityY: -25.0 + _random.nextDouble() * 50.0,
          moveTimer: _random.nextDouble() * 2.5,
          targetY: 250.0 + _random.nextDouble() * 250,
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
