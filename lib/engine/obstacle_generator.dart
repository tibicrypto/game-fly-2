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

    // Update dynamic obstacles (birds, missiles, aliens move)
    for (var obstacle in _obstacles) {
      if (obstacle.type == ObstacleType.bird) {
        obstacle.y += sin(currentX * 0.01) * 2; // Birds fly in wave pattern
      } else if (obstacle.type == ObstacleType.missile ||
          obstacle.type == ObstacleType.alien) {
        // Missiles and aliens move horizontally
        obstacle.x -= obstacle.speed * 0.016; // Approx 60 FPS delta
      }
    }
  }

  void _generateNextObstacle() {
    double minDist = GameConfig.obstacleMinDistance;
    double maxDist = GameConfig.obstacleMaxDistance;

    // Random distance to next obstacle
    double distance = minDist + _random.nextDouble() * (maxDist - minDist);
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
        // Birds fly at various heights
        return Obstacle(
          type: type,
          x: x,
          y: 150.0 + _random.nextDouble() * 300,
          width: 30.0,
          height: 20.0,
          speed: 0, // Birds don't move horizontally, only wave up/down
        );

      case ObstacleType.missile:
        // Missiles come from ahead, moving backwards
        return Obstacle(
          type: type,
          x: x + 200, // Start further ahead
          y: 200.0 + _random.nextDouble() * 250,
          width: 40.0,
          height: 15.0,
          speed: 150.0, // Fast moving
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
        // UFOs/aliens float around
        return Obstacle(
          type: type,
          x: x + 150,
          y: 300.0 + _random.nextDouble() * 150,
          width: 45.0,
          height: 35.0,
          speed: 80.0,
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
